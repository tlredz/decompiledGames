local DataStoreService = game:GetService("DataStoreService")
local SaveData = {}
local v = {}
local v2 = {}
local success, dataStore = pcall(DataStoreService.GetDataStore, DataStoreService, "RewardedAdData")
local v3

if success then
	v3 = true
else
	v3 = false
	dataStore = nil
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function utcWindowStart(value: number)
	local v4 = math.clamp(value, 1e-8, 365) * 86400
	return math.floor(os.time() / v4) * v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function warnLocalOnly()
	if flag then
		return
	end

	flag = true
	warn("[RVBillboard/SaveData] DataStore is unavailable — claim data will only persist for this server session.")
end

local function retry(callback, ...)
	local v4 = { ... }

	for i = 1, 3 do
		local success2, result = pcall(callback, table.unpack(v4))

		if success2 then
			return true, result
		end

		if i < 3 then
			task.wait(i * 2)
		end
	end

	return false, nil
end

function SaveData.Load(_, p: number)
	if v[p] then
		return
	end

	if not v3 then
		v[p] = {}
		return
	end

	local v4, v5 = retry(dataStore.GetAsync, dataStore, (tostring(p)))

	if v4 then
		v[p] = v5 or {}
		return
	end

	v3 = false
	warnLocalOnly() -- equivalent call inferred; original call site unknown
	v[p] = {}
end

function SaveData:GetActiveClaimCount(p: number, p2: string, p3: number?, value: number)
	local v4 = v[p]

	if not v4 then
		return 0
	end

	local v5 = v4[p2]

	if not v5 then
		return 0
	end

	local v6 = utcWindowStart(value) -- equivalent call inferred; original call site unknown
	local count = 0

	for _, v7 in v5 do
		if v7.timestamp < v6 then
			continue
		end

		local placementId = v7.placementId

		if placementId == nil or placementId == 0 or p3 == nil or placementId == p3 then
			count += 1
		end
	end

	return count
end

function SaveData.GetLastClaimTime(_, p: number, p2: string, p3: number?)
	local v4 = v[p]

	if not v4 then
		return 0
	end

	local v5 = v4[p2]

	if not v5 then
		return 0
	end

	local timestamp = 0

	for _, v6 in v5 do
		local placementId = v6.placementId

		if (placementId == nil or placementId == 0 or p3 == nil or placementId == p3) and timestamp < v6.timestamp then
			timestamp = v6.timestamp
		end
	end

	return timestamp
end

function SaveData:CanClaim(p: number, p2: string, p3: number?, p4: number, p5: number)
	return p4 == 0 or self:GetActiveClaimCount(p, p2, p3, p5) < p4
end

function SaveData.AddEntry(_, p: number, p2: string, placementId: number?, productName: string, _: number)
	local v4 = v[p]

	if not v4 then
		v[p] = {}
		v4 = v[p]
	end

	if not v4[p2] then
		v4[p2] = {}
	end

	local v5 = {
		timestamp = os.time(),
		placementId = placementId,
		productName = productName,
		devProductId = tonumber(p2)
	}
	table.insert(v4[p2], v5)
	v2[p] = true
	local v6 = os.time() - 2592000
	local v7 = {}

	for _, v8 in v4[p2] do
		if v6 <= v8.timestamp then
			table.insert(v7, v8)
		end
	end

	v4[p2] = v7

	if v3 and not retry(function()
		dataStore:UpdateAsync(tostring(p), function(options)
			local v8 = options or {}

			if not v8[p2] then
				v8[p2] = {}
			end

			table.insert(v8[p2], v5)
			local v9 = {}

			for _, v10 in v8[p2] do
				if v6 <= v10.timestamp then
					table.insert(v9, v10)
				end
			end

			v8[p2] = v9
			return v8
		end)
	end) then
		warn(("[RVBillboard/SaveData] Failed to persist entry for UserId %d, DevProductId %s"):format(p, p2))
		return false
	else
		return true
	end
end

function SaveData:SetClaimCount(p: number, p2: string, placementId: number?, p4: number, p5: number)
	local v4 = v[p]

	if not v4 then
		v[p] = {}
		v4 = v[p]
	end

	if not v4[p2] then
		v4[p2] = {}
	end

	local activeClaimCount = self:GetActiveClaimCount(p, p2, placementId, p5)

	if activeClaimCount < p4 then
		for _ = 1, p4 - activeClaimCount do
			table.insert(v4[p2], {
				timestamp = os.time(),
				placementId = placementId,
				productName = "",
				devProductId = tonumber(p2)
			})
		end
	end
end

function SaveData.GetCache(_)
	return v
end

function SaveData.Unload(_, p: number)
	local v4 = v[p]

	if not v4 then
		return
	end

	v[p] = nil

	if not v2[p] then
		return
	end

	v2[p] = nil

	if not v3 then
		return
	end

	retry(function()
		dataStore:UpdateAsync(tostring(p), function(options)
			local result = options or {}

			for k, v5 in v4 do
				if not result[k] then
					result[k] = {}
				end

				for _, v6 in v5 do
					local v7 = false

					for _, v9 in result[k] do
						if not (v9.timestamp == v6.timestamp and v9.devProductId == v6.devProductId) then
							continue
						end

						v7 = true
						break
					end

					if not v7 then
						table.insert(result[k], v6)
					end
				end
			end

			return result
		end)
	end)
end

return SaveData