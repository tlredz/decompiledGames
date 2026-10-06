local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local AuditService = {
	MAX_ENTRIES = 1000,
	MAX_BYTES = 262144,
	MAX_ENTRY_BYTES = 8192
}
local v = nil
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function finite(value)
	return typeof(value) == "number" and value == value and math.abs(value) < 1e999
end

local function natural(value)
	local v2

	if typeof(value) == "number" and value == value then
		v2 = math.abs(value) < 1e999
	else
		v2 = false
	end

	if v2 then
		return (math.max(0, (math.floor(value))))
	end

	return 0
end

local copy

copy = function(value, options)
	local typeName = typeof(value)

	if typeName == "nil" or typeName == "string" or typeName == "boolean" then
		return value
	end

	if typeName == "number" then
		local v2

		if typeof(value) == "number" and value == value then
			v2 = math.abs(value) < 1e999
		else
			v2 = false
		end

		assert(v2, "non-finite audit number")
		return value
	else
		assert(typeName == "table", "unsupported audit value: " .. typeName)
		local v2 = options or {}
		assert(not v2[value], "cyclic audit table")
		v2[value] = true
		local result = {}

		for k, v3 in value do
			local v4

			if typeof(k) == "string" then
				v4 = true
			else
				if typeof(k) == "number" and k == k then
					v4 = math.abs(k) < 1e999
				else
					v4 = false
				end

				if v4 then
					if k >= 1 then
						v4 = k % 1 == 0
					else
						v4 = false
					end
				end
			end

			assert(v4, "invalid audit key")
			result[k] = copy(v3, v2)
		end

		v2[value] = nil
		return result
	end
end

function AuditService.empty()
	return {
		version = 1,
		legacyMigrationVersion = 0,
		nextSequence = 1,
		entries = {},
		droppedCount = 0,
		lastTruncatedAt = 0
	}
end

local function sizeOf(p)
	local v2 = object[p]

	if not v2 then
		v2 = #HttpService:JSONEncode(p)
		object[p] = v2
	end

	return v2
end

local function cleanEntry(p)
	assert(typeof(p) == "table", "audit entry must be a table")
	local v2 = copy(p)
	local v3 = object[v2]

	if not v3 then
		v3 = #HttpService:JSONEncode(v2)
		object[v2] = v3
	end

	if not (AuditService.MAX_ENTRY_BYTES < v3) then
		return v2
	end

	local originalBytes = object[v2]

	if not originalBytes then
		originalBytes = #HttpService:JSONEncode(v2)
		object[v2] = originalBytes
	end

	local v4 = {
		detailTruncated = true,
		originalBytes = originalBytes
	}

	for _, v6 in {
		"id",
		"operationId",
		"at",
		"sequence",
		"assetType",
		"assetId",
		"action",
		"source",
		"delta",
		"before",
		"after",
		"counterpartyUserId",
		"count"
	} do
		local v7 = v2[v6]

		if typeof(v7) == "string" then
			local v8 = utf8.offset(v7, 257)

			if v8 then
				v7 = string.sub(v7, 1, v8 - 1)
			end

			v4[v6] = v7
		else
			if typeof(v7) ~= "boolean" then
				local v8

				if typeof(v7) == "number" and v7 == v7 then
					v8 = math.abs(v7) < 1e999
				else
					v8 = false
				end

				if not v8 then
					continue
				end
			end

			v4[v6] = v7
		end
	end

	return v4
end

function AuditService.prune(data, lastTruncatedAt: number)
	local empty = AuditService.empty()

	if typeof(data) == "table" then
		local legacyMigrationVersion = data.legacyMigrationVersion
		empty.legacyMigrationVersion = not finite(legacyMigrationVersion) and 0 or math.max(
			0,
			(math.floor(legacyMigrationVersion))
		)
		local nextSequence = data.nextSequence
		local v4

		if typeof(nextSequence) == "number" and nextSequence == nextSequence then
			v4 = math.abs(nextSequence) < 1e999
		else
			v4 = false
		end

		empty.nextSequence = math.max(1, not v4 and 0 or math.max(0, (math.floor(nextSequence))))
		local droppedCount = data.droppedCount
		empty.droppedCount = not finite(droppedCount) and 0 or math.max(0, (math.floor(droppedCount)))
		local lastTruncatedAt2 = data.lastTruncatedAt
		empty.lastTruncatedAt = not finite(lastTruncatedAt2) and 0 or math.max(0, (math.floor(lastTruncatedAt2)))
	end

	local v2 = (typeof(data) ~= "table" or typeof(data.entries) ~= "table") and {} or data.entries
	local v3 = 512

	for _, v4 in ipairs(v2) do
		local v5

		if typeof(v4) == "table" then
			local at = v4.at

			if typeof(at) == "number" and at == at then
				v5 = math.abs(at) < 1e999
			else
				v5 = false
			end
		else
			v5 = false
		end

		assert(v5, "invalid audit timestamp")
		local v6 = object[v4]

		if not v6 then
			v6 = #HttpService:JSONEncode(v4)
			object[v4] = v6
		end

		v3 += v6 + 1
	end

	local v4 = 1

	while #v2 - v4 + 1 > AuditService.MAX_ENTRIES or AuditService.MAX_BYTES < v3 do
		local v5 = v2[v4]
		local v6 = object[v5]

		if not v6 then
			v6 = #HttpService:JSONEncode(v5)
			object[v5] = v6
		end

		v3 -= v6 + 1
		v4 += 1
	end

	if v4 > 1 then
		empty.droppedCount += v4 - 1
		empty.lastTruncatedAt = lastTruncatedAt
	end

	for i = v4, #v2 do
		table.insert(empty.entries, v2[i])
	end

	object2[empty] = v3
	return empty
end

function AuditService.append(data, p, p2: number)
	local v2, v3

	if typeof(data) == "table" and typeof(data.entries) == "table" and object2[data] ~= nil then
		v2 = AuditService.empty()
		local legacyMigrationVersion = data.legacyMigrationVersion
		v2.legacyMigrationVersion = not finite(legacyMigrationVersion) and 0 or math.max(
			0,
			(math.floor(legacyMigrationVersion))
		)
		local nextSequence = data.nextSequence
		local v6

		if typeof(nextSequence) == "number" and nextSequence == nextSequence then
			v6 = math.abs(nextSequence) < 1e999
		else
			v6 = false
		end

		v2.nextSequence = math.max(1, not v6 and 0 or math.max(0, (math.floor(nextSequence))))
		local droppedCount = data.droppedCount
		v2.droppedCount = not finite(droppedCount) and 0 or math.max(0, (math.floor(droppedCount)))
		local lastTruncatedAt = data.lastTruncatedAt
		v2.lastTruncatedAt = not finite(lastTruncatedAt) and 0 or math.max(0, (math.floor(lastTruncatedAt)))
		v2.entries = table.clone(data.entries)
		v3 = object2[data]
	else
		v2 = AuditService.prune(data, p2)
		v3 = object2[v2]
	end

	local v4 = cleanEntry(p)
	v4.at = p2
	v4.id = HttpService:GenerateGUID(false)
	v4.sequence = v2.nextSequence
	v4.assetType = v4.assetType or "item"
	v4.action = v4.action or "unknown"
	v4.source = v4.source or "unknown"
	object[v4] = nil
	table.insert(v2.entries, v4)
	local v5 = object[v4]

	if not v5 then
		v5 = #HttpService:JSONEncode(v4)
		object[v4] = v5
	end

	local v6 = v3 + (v5 + 1)
	v2.nextSequence += 1

	if v4.detailTruncated then
		v2.droppedCount += 1
		v2.lastTruncatedAt = p2
	end

	local v7 = 1

	while #v2.entries - v7 + 1 > AuditService.MAX_ENTRIES or AuditService.MAX_BYTES < v6 do
		local entry = v2.entries[v7]
		local v8 = object[entry]

		if not v8 then
			v8 = #HttpService:JSONEncode(entry)
			object[entry] = v8
		end

		v6 -= v8 + 1
		v7 += 1
	end

	if v7 > 1 then
		local entries = {}

		for i = v7, #v2.entries do
			table.insert(entries, v2.entries[i])
		end

		v2.entries = entries
		v2.droppedCount += v7 - 1
		v2.lastTruncatedAt = p2
	end

	object2[v2] = v6
	return v2
end

function AuditService:migrate(lastTruncatedAt: number)
	local success, result = pcall(function()
		local prune = AuditService.prune(self.auditLog, lastTruncatedAt)
		local v2 = prune.legacyMigrationVersion < 1

		if v2 then
			for _, legacySource in { "currencyLedger", "itemLedger" } do
				local v4 = self[legacySource]

				if v4 == nil then
					continue
				end

				local v5

				if typeof(v4) == "table" then
					v5 = typeof(v4.entries) == "table"
				else
					v5 = false
				end

				assert(v5, "invalid " .. legacySource)

				for i, entry in ipairs(v4.entries) do
					local v6

					if typeof(entry) == "table" then
						local at = entry.at

						if typeof(at) == "number" and at == at then
							v6 = math.abs(at) < 1e999
						else
							v6 = false
						end
					else
						v6 = false
					end

					assert(v6, "invalid legacy entry: " .. legacySource)
					local v7 = copy(entry)
					v7.legacySource = legacySource
					v7.legacySequence = entry.sequence
					v7.operationId = entry.id
					v7.id = "legacy:" .. legacySource .. ":" .. tostring(entry.sequence or i)
					v7.source = entry.reason or "legacy"
					v7.assetType = legacySource == "currencyLedger" and "currency" or "item"
					v7.action = entry.type or (entry.delta or 0) >= 0 and "grant" or "spend"

					if legacySource == "currencyLedger" then
						v7.assetId = entry.currency
						v7.after = entry.balance
						local balance = entry.balance
						local v8

						if typeof(balance) == "number" and balance == balance then
							v8 = math.abs(balance) < 1e999
						else
							v8 = false
						end

						if v8 then
							local delta = entry.delta
							local v9

							if typeof(delta) == "number" and delta == delta then
								v9 = math.abs(delta) < 1e999
							else
								v9 = false
							end

							if v9 then
								v7.before = entry.balance - entry.delta
							end
						end
					end

					local v8 = cleanEntry(v7)

					if v8.detailTruncated then
						prune.droppedCount += 1
						prune.lastTruncatedAt = lastTruncatedAt
					end

					object[v8] = nil
					v8.sequence = prune.nextSequence
					prune.nextSequence += 1
					table.insert(prune.entries, v8)
				end
			end

			prune.legacyMigrationVersion = 1
		end

		table.sort(prune.entries, function(a, b)
			if a.at == b.at then
				return (a.sequence or 0) < (b.sequence or 0)
			end

			return a.at < b.at
		end)

		if not v2 then
			return AuditService.prune(prune, lastTruncatedAt)
		end

		for i, entry in ipairs(prune.entries) do
			local clone = table.clone(entry)
			clone.sequence = i
			prune.entries[i] = clone
		end

		prune.nextSequence = #prune.entries + 1
		return AuditService.prune(prune, lastTruncatedAt)
	end)

	if not success then
		return false, result
	end

	self.auditLog = result
	self.currencyLedger = nil
	self.itemLedger = nil
	return true, nil
end

function AuditService.bind(p)
	assert(RunService:IsServer(), "AuditService is server-only")

	if v then
		assert(v == p, "AuditService already bound")
		return
	end

	v = p
	local networker = p.Service.networker
	local fire = networker.fire
	local v2 = {
		auditLog = true,
		currencyLedger = true,
		itemLedger = true
	}

	function networker.fire(p2, p3, p4: string, list, ...)
		if p4 == "load" then
			local clone = table.clone(list)

			for k in v2 do
				clone[k] = nil
			end

			return fire(p2, p3, "load", clone, ...)
		elseif typeof(list) == "table" and v2[list[1]] then
			return
		else
			return fire(p2, p3, p4, list, ...)
		end
	end

	p.Service:addPlayerRemovingCallback(function(_, p2)
		p2.auditLog = AuditService.prune(p2.auditLog, os.time())
	end)
end

function AuditService.record(p, p2)
	assert(RunService:IsServer(), "AuditService is server-only")
	local success, result = pcall(function()
		assert(v ~= nil, "AuditService not bound")
		v[p].auditLog(function(p3)
			return AuditService.append(p3, p2, os.time())
		end, false)
	end)

	if not success then
		warn("[AuditService] 记录失败 userId=" .. tostring(p.UserId) .. ": " .. tostring(result))
	end

	return success
end

function AuditService.query(p, data)
	assert(RunService:IsServer() and v ~= nil, "AuditService is server-only")
	local prune = AuditService.prune(v[p].auditLog(), os.time())
	local entries = {}
	local v2 = not data and 100 or data.limit or 100
	local v3

	if typeof(v2) == "number" and v2 == v2 then
		v3 = math.abs(v2) < 1e999
	else
		v3 = false
	end

	local v4 = math.clamp(not v3 and 0 or math.max(0, (math.floor(v2))), 1, AuditService.MAX_ENTRIES)

	for i = #prune.entries, 1, -1 do
		local entry = prune.entries[i]

		if not ((not data or not data.assetType or entry.assetType == data.assetType) and (not data or not data.beforeSequence or entry.sequence < data.beforeSequence)) then
			continue
		end

		table.insert(entries, entry)

		if v4 <= #entries then
			break
		end
	end

	return (copy({
		entries = entries,
		droppedCount = prune.droppedCount,
		lastTruncatedAt = prune.lastTruncatedAt
	}))
end

return AuditService