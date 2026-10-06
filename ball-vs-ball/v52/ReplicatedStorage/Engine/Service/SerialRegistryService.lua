local DataStoreService = game:GetService("DataStoreService")
game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)
local TimeService = require(script.Parent.TimeService)
local GameFlags = require(ReplicatedStorage.GameFlags)
local SerialRegistryService = {}
local flag = false
local v = {}
local v2 = RunService:IsStudio() and 2 or 30
local v3 = RunService:IsStudio() and 4 or 120
local v4 = typeof(GameFlags.serialRegistry) ~= "table" and {} or GameFlags.serialRegistry
local maxRequestsPerMinute = math.clamp(math.floor(tonumber(v4.maxRequestsPerMinute) or 30), 1, 60)
local v6 = 60 / maxRequestsPerMinute
local v7 = math.clamp(math.floor(tonumber(v4.retryAttempts) or 3), 1, 6)
local v8 = math.max(10, tonumber(v4.retryDelaySeconds) or 30)
local now = -1e999
local v9 = {
	requests = 0,
	failures = 0,
	budgetWaits = 0
}
local v10 = RunService:IsServer() and GameFlags.feature["编号登记"] ~= false
local dataStore

if v10 then
	dataStore = DataStoreService:GetDataStore("SerialRegistry")
else
	dataStore = nil
end

local random = Random.new()

local function isNonMythicBall(p: string)
	local Config = require(script.Parent.Config)
	local v11 = Config.ball.byCnId[p]
	return v11 ~= nil and (tonumber(v11.rating) or 0) < 5
end

function SerialRegistryService.counterKey(p: string)
	local Config = require(script.Parent.Config)
	local v11 = Config.ball.byCnId[p]
	local v12

	if v11 == nil then
		v12 = false
	else
		v12 = (tonumber(v11.rating) or 0) < 5
	end

	if v12 then
		return p .. "@v2"
	end

	return p
end

local function counterOf(data)
	if typeof(data.serialKey) == "string" then
		return data.serialKey
	end

	if data.itemType ~= "Ball" then
		return data.itemId
	end

	local itemId = data.itemId
	local Config = require(script.Parent.Config)
	local v11 = Config.ball.byCnId[itemId]
	local v12

	if v11 == nil then
		v12 = false
	else
		v12 = (tonumber(v11.rating) or 0) < 5
	end

	if v12 and (tonumber(data.obtainedAt) or 0) >= 1791075720 then
		return data.itemId .. "@v2"
	end

	return data.itemId
end

function SerialRegistryService.keyFor(data)
	if typeof(data) ~= "table" or data.serial == nil or typeof(data.itemId) ~= "string" then
		return nil
	end

	local serialKey

	if typeof(data.serialKey) == "string" then
		serialKey = data.serialKey
	elseif data.itemType == "Ball" then
		local itemId = data.itemId
		local Config = require(script.Parent.Config)
		local v11 = Config.ball.byCnId[itemId]
		local v12

		if v11 == nil then
			v12 = false
		else
			v12 = (tonumber(v11.rating) or 0) < 5
		end

		if v12 and (tonumber(data.obtainedAt) or 0) >= 1791075720 then
			serialKey = data.itemId .. "@v2"
		else
			serialKey = data.itemId
		end
	else
		serialKey = data.itemId
	end

	return serialKey .. "#" .. tostring(data.serial)
end

function SerialRegistryService.originOf(by: number, at: number, items)
	local result = {
		at = at,
		by = by,
		n = 0,
		bound = 0,
		src = {},
		crate = {}
	}

	for _, item in items do
		result.n += 1

		if item.tradable ~= true then
			result.bound += 1
		end

		local v11 = typeof(item.source) ~= "string" and "未知来源" or item.source
		result.src[v11] = (result.src[v11] or 0) + 1

		if typeof(item.sourceCrateCnId) == "string" then
			result.crate[item.sourceCrateCnId] = (result.crate[item.sourceCrateCnId] or 0) + 1
		end
	end

	if next(result.crate) == nil then
		result.crate = nil
	end

	return result
end

function SerialRegistryService.materialDetail(data)
	local v11 = typeof(data.metadata) ~= "table" and {} or data.metadata
	return {
		inst = data.instanceId,
		tradable = data.tradable == true,
		canFusion = data.canFusion == true,
		src = data.source,
		crate = data.sourceCrateCnId,
		at = data.obtainedAt,
		kills = v11.killCount,
		origin = v11.origin
	}
end

local function combineOrigins(materials)
	local result = {
		materials = #materials,
		base = 0,
		unknown = 0,
		bound = 0,
		src = {},
		crate = {}
	}

	for _, v11 in materials do
		local origin = v11.origin

		if typeof(origin) == "table" and typeof(origin.n) == "number" then
			result.base += origin.n
			result.bound += tonumber(origin.bound) or 0

			for k, v12 in origin.src or {} do
				result.src[k] = (result.src[k] or 0) + v12
			end

			for k, v12 in origin.crate or {} do
				result.crate[k] = (result.crate[k] or 0) + v12
			end
		elseif v11.kills == nil then
			result.base += 1

			if v11.tradable ~= true then
				result.bound += 1
			end

			local v12 = typeof(v11.src) ~= "string" and "未知来源" or v11.src
			result.src[v12] = (result.src[v12] or 0) + 1

			if typeof(v11.crate) == "string" then
				result.crate[v11.crate] = (result.crate[v11.crate] or 0) + 1
			end
		else
			result.unknown += 1
		end
	end

	return result
end

local function minterFlags(p)
	local v11 = PlayerData.server[p]

	if not v11 then
		return nil
	end

	local v12 = {}
	local voucherExploitPenalty = v11.voucherExploitPenalty()

	if typeof(voucherExploitPenalty) == "table" and (voucherExploitPenalty.penalized == true or voucherExploitPenalty.coinExceeded == true) then
		v12.voucherPenalty = true
	end

	local exploitCleanup = v11.exploitCleanup()

	if typeof(exploitCleanup) == "table" and exploitCleanup.hit == true then
		v12.cleanupHit = true
	end

	if next(v12) then
		return v12
	end

	return nil
end

local function pushLimited(anomalies, p, p2: number)
	table.insert(anomalies, p)
	local count = 0

	while p2 < #anomalies do
		table.remove(anomalies, 1)
		count += 1
	end

	return count
end

local function hasOp(data, id: string)
	if typeof(data.state) == "table" and data.state.op == id or typeof(data.mint) == "table" and data.mint.op == id then
		return true
	end

	for _, v11 in data.history or {} do
		if v11.op == id then
			return true
		end
	end

	return false
end

local function newEntry(data, mint)
	return {
		v = 2,
		key = data.key,
		itemType = data.itemType,
		itemId = data.itemId,
		serial = data.serial,
		status = "active",
		tradable = data.tradable,
		mint = mint,
		owner = nil,
		instanceId = data.inst,
		history = {},
		dropped = 0,
		anomalies = {},
		updatedAt = data.at
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function backfillMint(data)
	return {
		via = "回填",
		at = data.at,
		src = data.src,
		crate = data.crate,
		obtainedAt = data.obtainedAt,
		place = data.place,
		job = data.job
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addAnomaly(p, p2)
	p.anomalies = p.anomalies or {}
	pushLimited(p.anomalies, p2, 20)
end

local function addHistory(state, p)
	state.history = state.history or {}
	table.insert(state.history, p)
	table.sort(state.history, function(a, b)
		if a.at ~= b.at then
			return (tonumber(a.at) or 0) < (tonumber(b.at) or 0)
		end

		if typeof(a.revision) == "number" and typeof(b.revision) == "number" and a.revision ~= b.revision then
			return a.revision < b.revision
		end

		return tostring(a.op) < tostring(b.op)
	end)

	while #state.history > 200 do
		table.remove(state.history, 1)
		state.dropped = (state.dropped or 0) + 1
	end
end

local copyRecord

copyRecord = function(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = copyRecord(item)
	end

	return result
end

local function stateOf(data)
	if typeof(data.state) == "table" then
		return data.state
	end

	local at = tonumber(data.mint and data.mint.at) or 0

	for _, v11 in data.history or {} do
		if v11.t ~= "回填" then
			at = math.max(at, tonumber(v11.at) or 0)
		end
	end

	return {
		at = at
	}
end

local function recordState(p, data)
	p.state = {
		revision = data.revision,
		at = data.at,
		op = data.id
	}
	p.instanceId = data.inst
	p.v = 2
	p.updatedAt = math.max(tonumber(p.updatedAt) or 0, data.at)
end

local function lateHistory(p, data)
	local history = p.history or {}

	if #history >= 200 then
		local v11 = history[1]

		if typeof(data.revision) == "number" and typeof(v11.revision) == "number" then
			if data.revision <= v11.revision then
				return nil, "stale"
			end
		elseif data.at <= (tonumber(v11.at) or 0) then
			return nil, "stale"
		end
	end

	local v11 = copyRecord(data.row)
	v11.revision = data.revision
	addHistory(p, v11)
	return p, "historical"
end

local function transform(p, data)
	local v11 = copyRecord(p)

	if data.kind == "mint" then
		if v11 == nil then
			local v12 = newEntry(data, copyRecord(data.mint))
			v12.owner = {
				id = data.to,
				inst = data.inst,
				since = data.at
			}
			recordState(v12, data)
			return v12, "created"
		else
			if v11.mint and v11.mint.op == data.id then
				return nil, "duplicate"
			end

			local instanceId = v11.instanceId or v11.owner and v11.owner.inst or v11.mint and v11.mint.inst

			if v11.mint and v11.mint.via == "回填" and instanceId == data.inst then
				v11.mint = copyRecord(data.mint)
				v11.instanceId = data.inst
				v11.v = 2
				return v11, "replaced_backfill"
			else
				addAnomaly(v11, {
					t = "重复编号",
					at = data.at,
					inst = data.inst,
					by = data.to
				}) -- equivalent call inferred; original call site unknown
				return v11, "conflict"
			end
		end
	elseif data.kind == "transfer" or data.kind == "destroy" then
		if v11 == nil then
			v11 = newEntry(data, backfillMint(data))
			v11.owner = {
				id = data.from,
				inst = data.inst,
				since = data.at
			}
		else
			if hasOp(v11, data.id) then
				return nil, "duplicate"
			end

			local instanceId = v11.instanceId or v11.owner and v11.owner.inst or v11.mint and v11.mint.inst

			if instanceId == nil or instanceId == data.inst then
				if v11.status == "destroyed" then
					if data.kind == "transfer" and typeof(data.revision) == "number" and v11.state and typeof(v11.state.revision) == "number" and data.revision <= v11.state.revision then
						return lateHistory(v11, data)
					end

					return nil, "stale"
				else
					local v12 = stateOf(v11)

					if typeof(data.revision) == "number" and typeof(v12.revision) == "number" then
						if data.revision < v12.revision then
							return lateHistory(v11, data)
						end

						if data.kind == "transfer" and data.revision == v12.revision then
							return nil, "stale"
						end
					else
						if typeof(v12.revision) == "number" or data.at < v12.at then
							return lateHistory(v11, data)
						end

						if data.kind == "transfer" and v11.owner and v11.owner.id ~= data.from and data.at == v12.at then
							addAnomaly(v11, {
								t = "旧操作顺序不明",
								at = data.at,
								inst = data.inst,
								from = data.from,
								to = data.to
							}) -- equivalent call inferred; original call site unknown
							return v11, "conflict"
						end
					end
				end
			else
				addAnomaly(v11, {
					t = "实例不一致",
					at = data.at,
					inst = data.inst,
					registeredInst = instanceId
				}) -- equivalent call inferred; original call site unknown
				return v11, "conflict"
			end
		end

		if data.kind == "transfer" then
			if v11.owner and v11.owner.id ~= data.from then
				addAnomaly(v11, {
					t = "转出人与登记持有人不一致",
					at = data.at,
					inst = data.inst,
					registered = v11.owner.id,
					from = data.from
				}) -- equivalent call inferred; original call site unknown
			end

			local v12 = copyRecord(data.row)
			v12.revision = data.revision
			addHistory(v11, v12)
			v11.tradable = data.tradable
			v11.owner = {
				id = data.to,
				inst = data.inst,
				since = data.at
			}
			v11.status = "active"
			recordState(v11, data)
			return v11, "moved"
		else
			local v12 = copyRecord(data.row)
			v12.revision = data.revision
			addHistory(v11, v12)
			v11.status = "destroyed"
			v11.owner = nil
			recordState(v11, data)
			return v11, "destroyed"
		end
	else
		if data.kind ~= "verify" then
			return nil, "unknown_op"
		end

		if v11 == nil then
			local v12 = newEntry(data, backfillMint(data))
			v12.owner = {
				id = data.holder,
				inst = data.inst,
				since = data.at
			}
			addHistory(v12, {
				op = data.id,
				at = data.at,
				t = "回填",
				to = data.holder,
				kills = data.kills
			})
			recordState(v12, data)
			return v12, "backfilled"
		else
			local owner = v11.owner
			local v12 = stateOf(v11)

			if v11.status == "active" and owner and owner.id == data.holder and owner.inst == data.inst and (v12.revision == nil or v12.revision == data.revision) then
				if v12.revision ~= nil then
					return nil, "ok"
				end

				v11.state = {
					revision = data.revision,
					at = v12.at
				}
				v11.instanceId = data.inst
				v11.v = 2
				return v11, "ok"
			else
				addAnomaly(v11, {
					t = "持有人不一致",
					at = data.at,
					seen = data.holder,
					inst = data.inst,
					registered = owner and owner.id,
					registeredInst = owner and owner.inst,
					status = v11.status,
					revision = data.revision,
					registeredRevision = v12.revision
				}) -- equivalent call inferred; original call site unknown
				return v11, "mismatch"
			end
		end
	end
end

local function relatedUserIds(data)
	local v11 = {}
	local v12 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(value)
		if typeof(value) == "number" and value > 0 and not v12[value] and #v11 < 4 then
			v12[value] = true
			table.insert(v11, value)
		end
	end

	if typeof(data.mint) == "table" then
		add(data.mint.by) -- equivalent call inferred; original call site unknown
	end

	if typeof(data.owner) == "table" then
		add(data.owner.id) -- equivalent call inferred; original call site unknown
	end

	local history = data.history or {}

	for i = #history, 1, -1 do
		add(history[i].from) -- equivalent call inferred; original call site unknown
		add(history[i].to) -- equivalent call inferred; original call site unknown
	end

	return v11
end

local v11 = {}
local v12 = {}
local flag2 = false
local v13 = {}
local v14 = {}

local function persistedHolders(p)
	return p.holders or {}
end

local function persist(data)
	for _, v15 in data.holders or {} do
		local playerByUserId = Players:GetPlayerByUserId(v15)
		local v16 = playerByUserId and PlayerData.server[playerByUserId]

		if not v16 then
			continue
		end

		local v17 = v16
		local v18 = v15
		local success, result = pcall(function()
			v17.serialRegistryPending(function(p)
				local v19 = typeof(p) ~= "table" and {} or table.clone(p)

				if v19[data.id] ~= nil then
					return p
				end

				local count = 0

				for k in v19 do
					count += 1
				end

				if count >= 100 and not v[v18] then
					v[v18] = true
					warn(string.format("[SerialRegistry] 玩家 %d 待写登记超过 %d 条，保留恢复记录并等待预算", v18, 100))
				end

				v19[data.id] = copyRecord(data)
				return v19
			end, false)
		end)

		if not success then
			warn("[SerialRegistry] 待写登记存档失败: " .. tostring(result))
		end
	end
end

local function unpersist(p)
	for _, v15 in p.holders or {} do
		local playerByUserId = Players:GetPlayerByUserId(v15)
		local v16 = playerByUserId and PlayerData.server[playerByUserId]

		if not v16 then
			continue
		end

		local v17 = v16
		pcall(function()
			v17.serialRegistryPending(function(p2)
				if typeof(p2) ~= "table" or p2[p.id] == nil then
					return p2
				end

				local clone = table.clone(p2)
				clone[p.id] = nil
				return clone
			end, false)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sameSnapshot(p, data)
	return typeof(p) == "table" and p.instanceId == data.inst and SerialRegistryService.keyFor(p) == data.key and (tonumber(p.metadata and p.metadata.tradeCount) or 0) == data.revision
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markVerified(data, p: string)
	local playerByUserId = Players:GetPlayerByUserId(data.holder)
	local v15 = playerByUserId and PlayerData.server[playerByUserId]

	if not v15 then
		return
	end

	pcall(function()
		v15.items(function(p2)
			local v16 = p2[data.inst]
			local v17 = data
			local v18

			if typeof(v16) == "table" and v16.instanceId == v17.inst and SerialRegistryService.keyFor(v16) == v17.key then
				v18 = (tonumber(v16.metadata and v16.metadata.tradeCount) or 0) == v17.revision
			else
				v18 = false
			end

			if not v18 or v16.ownerUserId ~= data.holder then
				return p2
			end

			local clone = table.clone(p2)
			local clone2 = table.clone(v16)
			clone2.metadata = table.clone(v16.metadata or {})
			local v19 = {
				v = 2,
				holder = data.holder,
				inst = data.inst,
				key = data.key,
				trade = data.revision,
				at = TimeService.now()
			}

			if p == "mismatch" then
				clone2.metadata.registryFailed = v19
				clone2.metadata.registryVerified = nil
			else
				clone2.metadata.registryVerified = v19
				clone2.metadata.registryFailed = nil

				if typeof(clone2.serialKey) ~= "string" then
					clone2.serialKey = data.counter
				end
			end

			clone2.metadata.registryTrade = nil
			clone[data.inst] = clone2
			return clone
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function budgetAvailable()
	local success, result = pcall(function()
		return DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)
	end)
	return success and result > 10
end

local function stillHeld(data)
	local playerByUserId = Players:GetPlayerByUserId(data.holder)
	local v15 = playerByUserId and PlayerData.server[playerByUserId]

	if not v15 or playerByUserId.Parent ~= Players then
		return false
	end

	local v16 = v15.items()[data.inst]
	return sameSnapshot(v16, data) and v16.ownerUserId == data.holder
end

local function apply(p)
	if p.kind == "verify" and ((v13[p.key] or 0) > 0 or not stillHeld(p)) then
		return true, "skipped"
	end

	local v15 = "none"
	now = os.clock()
	v9.requests += 1
	local success, result = pcall(function()
		dataStore:UpdateAsync(p.key, function(p2)
			local v17, v18 = transform(p2, p)
			v15 = v18

			if v17 == nil then
				return nil
			end

			return v17, (relatedUserIds(v17))
		end)
	end)

	if success then
		return true, v15
	end

	v9.failures += 1
	return false, (tostring(result))
end

local runWorker

runWorker = function()
	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		while #v11 > 0 do
			local v15 = 1

			for k, v17 in v11 do
				if v17.kind == "verify" then
					continue
				end

				v15 = k
				break
			end

			local v17 = table.remove(v11, v15)

			if budgetAvailable() then
				local v18 = v6 - (os.clock() - now)

				if v18 > 0 then
					table.insert(v11, 1, v17)

					if flag then
						break
					else
						task.wait(v18)
					end
				else
					local v19, v20 = apply(v17)

					if v19 then
						v12[v17.id] = nil

						if v17.kind == "verify" then
							if v20 == "ok" or v20 == "backfilled" or v20 == "mismatch" then
								markVerified(v17, v20) -- equivalent call inferred; original call site unknown
							end

							if v20 == "backfilled" then
								print(string.format("[SerialRegistry] 回填登记 %s 持有人 %d", v17.key, v17.holder))
							elseif v20 == "mismatch" then
								warn(string.format("[SerialRegistry] 持有人不一致 %s：存档里在 %d 手上，登记表不是", v17.key, v17.holder))
							end
						else
							v14[v17.id] = nil
							v13[v17.key] = math.max(0, (v13[v17.key] or 1) - 1)
							unpersist(v17)

							if v20 == "conflict" then
								warn(string.format(
									"[SerialRegistry] 编号重复 %s：已有不同实例的铸造记录（新实例 %s）",
									v17.key,
									(tostring(v17.inst))
								))
							end
						end
					else
						v17.attempts = (v17.attempts or 0) + 1

						if v17.attempts < v7 then
							local v21 = v17
							task.delay(math.min(v8 * 2 ^ (v17.attempts - 1), 300), function()
								table.insert(v11, v21)
								runWorker()
							end)
						else
							v12[v17.id] = nil
							warn(string.format(
								"[SerialRegistry] 登记写入失败（已重试 %d 次）%s %s: %s",
								v17.attempts,
								v17.kind,
								v17.key,
								(tostring(v20))
							))
						end
					end

					task.wait(0.1)
				end
			else
				v9.budgetWaits += 1
				table.insert(v11, 1, v17)

				if flag then
					break
				else
					task.wait(2)
				end
			end
		end

		flag2 = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enqueue(data, flag3: boolean)
	if not v10 or v12[data.id] then
		return
	end

	v12[data.id] = true

	if data.kind ~= "verify" and not v14[data.id] then
		v14[data.id] = true
		v13[data.key] = (v13[data.key] or 0) + 1
	end

	if flag3 then
		persist(data)
	end

	table.insert(v11, data)

	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		while #v11 > 0 do
			local v15 = 1

			for k, v17 in v11 do
				if v17.kind == "verify" then
					continue
				end

				v15 = k
				break
			end

			local v17 = table.remove(v11, v15)

			if budgetAvailable() then
				local v18 = v6 - (os.clock() - now)

				if v18 > 0 then
					table.insert(v11, 1, v17)

					if flag then
						break
					else
						task.wait(v18)
					end
				else
					local v19, v20 = apply(v17)

					if v19 then
						v12[v17.id] = nil

						if v17.kind == "verify" then
							if v20 == "ok" or v20 == "backfilled" or v20 == "mismatch" then
								markVerified(v17, v20) -- equivalent call inferred; original call site unknown
							end

							if v20 == "backfilled" then
								print(string.format("[SerialRegistry] 回填登记 %s 持有人 %d", v17.key, v17.holder))
							elseif v20 == "mismatch" then
								warn(string.format("[SerialRegistry] 持有人不一致 %s：存档里在 %d 手上，登记表不是", v17.key, v17.holder))
							end
						else
							v14[v17.id] = nil
							v13[v17.key] = math.max(0, (v13[v17.key] or 1) - 1)
							unpersist(v17)

							if v20 == "conflict" then
								warn(string.format(
									"[SerialRegistry] 编号重复 %s：已有不同实例的铸造记录（新实例 %s）",
									v17.key,
									(tostring(v17.inst))
								))
							end
						end
					else
						v17.attempts = (v17.attempts or 0) + 1

						if v17.attempts < v7 then
							local v21 = v17
							task.delay(math.min(v8 * 2 ^ (v17.attempts - 1), 300), function()
								table.insert(v11, v21)
								runWorker()
							end)
						else
							v12[v17.id] = nil
							warn(string.format(
								"[SerialRegistry] 登记写入失败（已重试 %d 次）%s %s: %s",
								v17.attempts,
								v17.kind,
								v17.key,
								(tostring(v20))
							))
						end
					end

					task.wait(0.1)
				end
			else
				v9.budgetWaits += 1
				table.insert(v11, 1, v17)

				if flag then
					break
				else
					task.wait(2)
				end
			end
		end

		flag2 = false
	end)
end

local function baseOp(kind: string, data, now2: number)
	return {
		kind = kind,
		key = SerialRegistryService.keyFor(data),
		at = now2,
		inst = data.instanceId,
		itemType = data.itemType,
		itemId = data.itemId,
		serial = data.serial,
		tradable = data.tradable == true,
		revision = tonumber(data.metadata and data.metadata.tradeCount) or 0,
		src = data.source,
		crate = data.sourceCrateCnId,
		obtainedAt = data.obtainedAt,
		place = game.PlaceVersion,
		job = game.JobId
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function killsOf(p)
	if typeof(p.metadata) == "table" then
		return p.metadata.killCount
	end

	return nil
end

function SerialRegistryService.mint(p, data, p2)
	if not v10 or typeof(data) ~= "table" or data.serial == nil then
		return
	end

	local now2 = TimeService.now()
	local v15 = baseOp("mint", data, now2)
	v15.id = "mint:" .. v15.key .. ":" .. tostring(data.instanceId)
	v15.to = p.UserId
	v15.holders = { p.UserId }
	local mint = {
		op = v15.id,
		at = now2,
		by = p.UserId,
		via = 0,
		src = 0,
		crate = 0,
		inst = 0,
		place = 0,
		job = 0,
		flags = 0
	}
	local via

	if p2 and typeof(p2.via) == "string" then
		via = p2.via
	else
		via = data.source or "未知"
	end

	mint.via = via
	mint.src = data.source
	mint.crate = data.sourceCrateCnId
	mint.inst = data.instanceId
	mint.place = game.PlaceVersion
	mint.job = game.JobId
	mint.flags = minterFlags(p)

	if p2 and typeof(p2.materials) == "table" then
		mint.materials = p2.materials
		mint.summary = combineOrigins(p2.materials)
		mint.crate = nil
	end

	v15.mint = mint
	enqueue(v15, true)
end

function SerialRegistryService.transfer(p, p2, items, data)
	if not v10 then
		return
	end

	local v15 = PlayerData.server[p2]

	if not v15 then
		return
	end

	local items2 = v15.items()
	local now2 = TimeService.now()

	for _, item in items do
		local item2 = items2[item]

		if not (typeof(item2) == "table" and item2.serial ~= nil) then
			continue
		end

		local v16 = baseOp("transfer", item2, now2)
		v16.id = "xfer:" .. tostring(data.txn) .. ":" .. tostring(item)
		v16.from = p.UserId
		v16.to = p2.UserId
		v16.holders = { p.UserId, p2.UserId }
		local row = {
			op = v16.id,
			at = now2,
			t = data.t,
			from = p.UserId,
			to = p2.UserId,
			txn = data.txn,
			price = data.price,
			give = data.give,
			kills = 0
		}
		local kills = killsOf(item2) -- equivalent call inferred; original call site unknown
		row.kills = kills
		v16.row = row
		enqueue(v16, true)
	end
end

function SerialRegistryService.destroy(p, p2, reason: string, txn: string?)
	if not v10 or typeof(p2) ~= "table" or p2.serial == nil then
		return
	end

	local now2 = TimeService.now()
	local v15 = baseOp("destroy", p2, now2)
	v15.id = "del:" .. tostring(p2.instanceId) .. ":" .. (txn or reason)
	v15.from = p.UserId
	v15.holders = { p.UserId }
	local row = {
		op = v15.id,
		at = now2,
		t = "销毁",
		from = p.UserId,
		reason = reason,
		txn = txn,
		kills = 0
	}
	local kills = killsOf(p2) -- equivalent call inferred; original call site unknown
	row.kills = kills
	v15.row = row
	enqueue(v15, true)
end

local function onPlayerReady(p, flag3: boolean?, flag4: boolean?, flag5: boolean?)
	if not flag3 then
		task.wait(random:NextNumber(v2, v3))
	end

	local v15 = PlayerData.server[p]

	if p.Parent ~= Players or not v15 then
		return
	end

	local serialRegistryPending = v15.serialRegistryPending()

	if typeof(serialRegistryPending) == "table" then
		local v16 = {}

		for _, v17 in serialRegistryPending do
			if not (typeof(v17) == "table" and typeof(v17.id) == "string" and typeof(v17.key) == "string") then
				continue
			end

			table.insert(v16, (copyRecord(v17)))
		end

		table.sort(v16, function(a, b)
			if a.key ~= b.key then
				return a.key < b.key
			end

			if a.at ~= b.at then
				return (tonumber(a.at) or 0) < (tonumber(b.at) or 0)
			end

			if typeof(a.revision) == "number" and typeof(b.revision) == "number" and a.revision ~= b.revision then
				return a.revision < b.revision
			end

			local v17 = {
				mint = 1,
				transfer = 2,
				destroy = 3
			}

			if v17[a.kind] == v17[b.kind] then
				return a.id < b.id
			end

			return (v17[a.kind] or 4) < (v17[b.kind] or 4)
		end)

		for _, v17 in v16 do
			if not (typeof(v17) == "table" and typeof(v17.id) == "string" and typeof(v17.key) == "string") then
				continue
			end

			v17.attempts = 0

			if not v10 or v12[v17.id] then
				continue
			end

			v12[v17.id] = true

			if v17.kind ~= "verify" and not v14[v17.id] then
				v14[v17.id] = true
				v13[v17.key] = (v13[v17.key] or 0) + 1
			end

			table.insert(v11, v17)

			if flag2 then
				continue
			end

			flag2 = true
			task.spawn(function()
				while #v11 > 0 do
					local v18 = 1

					for k, v20 in v11 do
						if v20.kind == "verify" then
							continue
						end

						v18 = k
						break
					end

					local v20 = table.remove(v11, v18)

					if budgetAvailable() then
						local v21 = v6 - (os.clock() - now)

						if v21 > 0 then
							table.insert(v11, 1, v20)

							if flag then
								break
							else
								task.wait(v21)
							end
						else
							local v22, v23 = apply(v20)

							if v22 then
								v12[v20.id] = nil

								if v20.kind == "verify" then
									if v23 == "ok" or v23 == "backfilled" or v23 == "mismatch" then
										markVerified(v20, v23) -- equivalent call inferred; original call site unknown
									end

									if v23 == "backfilled" then
										print(string.format("[SerialRegistry] 回填登记 %s 持有人 %d", v20.key, v20.holder))
									elseif v23 == "mismatch" then
										warn(string.format(
											"[SerialRegistry] 持有人不一致 %s：存档里在 %d 手上，登记表不是",
											v20.key,
											v20.holder
										))
									end
								else
									v14[v20.id] = nil
									v13[v20.key] = math.max(0, (v13[v20.key] or 1) - 1)
									unpersist(v20)

									if v23 == "conflict" then
										warn(string.format(
											"[SerialRegistry] 编号重复 %s：已有不同实例的铸造记录（新实例 %s）",
											v20.key,
											(tostring(v20.inst))
										))
									end
								end
							else
								v20.attempts = (v20.attempts or 0) + 1

								if v20.attempts < v7 then
									local v24 = v20
									task.delay(math.min(v8 * 2 ^ (v20.attempts - 1), 300), function()
										table.insert(v11, v24)
										runWorker()
									end)
								else
									v12[v20.id] = nil
									warn(string.format(
										"[SerialRegistry] 登记写入失败（已重试 %d 次）%s %s: %s",
										v20.attempts,
										v20.kind,
										v20.key,
										(tostring(v23))
									))
								end
							end

							task.wait(0.1)
						end
					else
						v9.budgetWaits += 1
						table.insert(v11, 1, v20)

						if flag then
							break
						else
							task.wait(2)
						end
					end
				end

				flag2 = false
			end)
		end
	end

	if flag4 ~= true then
		return
	end

	local now2 = TimeService.now()
	local count = 0

	for k, v16 in v15.items() do
		if not (typeof(v16) == "table" and v16.serial ~= nil and (typeof(v16.locks) ~= "table" and {} or v16.locks).serialPending == nil) then
			continue
		end

		local v17 = typeof(v16.metadata) ~= "table" and {} or v16.metadata
		local registryFailed = v17.registryFailed

		if not (flag5 == true or typeof(registryFailed) ~= "table" or registryFailed.v ~= 2 or registryFailed.holder ~= p.UserId or registryFailed.inst ~= k or registryFailed.key ~= SerialRegistryService.keyFor(v16) or registryFailed.trade ~= (tonumber(v17.tradeCount) or 0) or typeof(registryFailed.at) ~= "number" or not (registryFailed.at <= now2 and now2 - registryFailed.at < 600)) then
			continue
		end

		local registryVerified = v17.registryVerified

		if not (flag5 == true or typeof(registryVerified) ~= "table" or registryVerified.v ~= 2 or registryVerified.holder ~= p.UserId or registryVerified.inst ~= k or registryVerified.key ~= SerialRegistryService.keyFor(v16) or registryVerified.trade ~= (tonumber(v17.tradeCount) or 0)) then
			continue
		end

		if not (v16.tradable == true or typeof(v16.serialKey) == "string") then
			continue
		end

		local v18 = baseOp("verify", v16, now2)
		v18.id = "verify:" .. v18.key .. ":" .. tostring(k) .. ":" .. tostring(p.UserId) .. ":" .. tostring(v17.tradeCount or 0)
		v18.holder = p.UserId
		local serialKey

		if typeof(v16.serialKey) == "string" then
			serialKey = v16.serialKey
		elseif v16.itemType == "Ball" then
			local itemId = v16.itemId
			local Config = require(script.Parent.Config)
			local v19 = Config.ball.byCnId[itemId]
			local v20

			if v19 == nil then
				v20 = false
			else
				v20 = (tonumber(v19.rating) or 0) < 5
			end

			if v20 and (tonumber(v16.obtainedAt) or 0) >= 1791075720 then
				serialKey = v16.itemId .. "@v2"
			else
				serialKey = v16.itemId
			end
		else
			serialKey = v16.itemId
		end

		v18.counter = serialKey
		local kills = killsOf(v16) -- equivalent call inferred; original call site unknown
		v18.kills = kills
		enqueue(v18, false) -- equivalent call inferred; original call site unknown
		count += 1

		if not (count >= 5) then
			continue
		end

		task.wait(1)

		if p.Parent ~= Players or PlayerData.server[p] ~= v15 then
			break
		end

		count = 0
	end
end

local v15 = false

function SerialRegistryService.init()
	if v15 or not v10 then
		return
	end

	v15 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onPlayerAdded(p)
		task.spawn(function()
			PlayerData.server.Service:waitForData(p)

			if p.Parent == Players then
				onPlayerReady(p)
			end
		end)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v16 in Players:GetPlayers() do
		onPlayerAdded(v16) -- equivalent call inferred; original call site unknown
	end

	game:BindToClose(function()
		flag = true
		local v16 = os.clock() + 15

		while (#v11 > 0 or flag2) and os.clock() < v16 do
			task.wait(0.5)
		end
	end)
end

function SerialRegistryService.queueSize()
	return #v11 + (flag2 and 1 or 0)
end

function SerialRegistryService.verifyNow(p, flag3: boolean?)
	if v10 then
		onPlayerReady(p, true, true, flag3)
	end
end

function SerialRegistryService.getStats()
	return {
		requests = v9.requests,
		failures = v9.failures,
		budgetWaits = v9.budgetWaits,
		queueSize = SerialRegistryService.queueSize(),
		maxRequestsPerMinute = maxRequestsPerMinute
	}
end

return SerialRegistryService