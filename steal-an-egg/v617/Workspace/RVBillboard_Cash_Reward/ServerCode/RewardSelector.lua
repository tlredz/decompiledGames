local AdService = game:GetService("AdService")
local ConfigService = game:GetService("ConfigService")
local devProductId = 0
local reward = nil
local multiplier_Tier_1 = 1
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}

local function dbg(_: string) end

local v6 = { "A", "B", "C" }

local function getBucketForProduct(p: number)
	for k, v7 in v3 do
		if v7.devProductId == p then
			return v6[k] or "A"
		end
	end

	return "A"
end

local function parseMultiRewardList(value: string?)
	if not value or value == "" then
		return {}
	end

	local result = {}

	for k in string.gmatch(value, "[^,]+") do
		local v7 = tonumber(string.match(k, "%d+"))

		if v7 and v7 ~= 0 then
			table.insert(result, v7)
		end
	end

	return result
end

local function getConfigTier(p)
	local success, result = pcall(function()
		local configForPlayerAsync = ConfigService:GetConfigForPlayerAsync(p)

		if not configForPlayerAsync then
			return 1
		end

		local value = configForPlayerAsync:GetValue("RV_Multi_Experiment")
		v2[p] = value;
		("[RewardSelector] ConfigService RV_Multi_Experiment = %s (type: %s)"):format(tostring(value), (typeof(value)))

		if type(value) == "number" and (value == 2 or value == 4) then
			return 2
		end

		return 1
	end)
	local v7 = not success and 1 or result

	for _, v8 in v5 do
		if p.UserId ~= v8 then
			continue
		end

		print(("[RVB] Bypass: %s (UserId %d) original tier=%d, overridden to tier 2 (bucket B)"):format(
			p.Name,
			p.UserId,
			v7
		))
		return 2
	end

	return v7
end

local RewardSelector = {}

function RewardSelector.Init(_, p)
	devProductId = p.DevProductId;
	("[RewardSelector] INIT — mainDevProductId=%d"):format(devProductId)
	local success, result = pcall(AdService.CreateAdRewardFromDevProductId, AdService, devProductId)

	if not success then
		warn(("[RVBillboard/RewardSelector] Main reward creation failed for %d"):format(devProductId))
		return false
	end

	reward = result
	multiplier_Tier_1 = p.Multiplier_Tier_1 or 2
	return true
end

function RewardSelector.AssignPlayer(_, p)
	if not reward then
		return
	end

	local configTier = getConfigTier(p);
	("[RewardSelector] ASSIGN %s — config tier=%d"):format(p.Name, configTier)

	if configTier == 1 then
		v4[p] = {
			devProductId = devProductId,
			reward = reward,
			bucket = "A",
			synced = false
		}
		return
	end

	v4[p] = {
		devProductId = devProductId,
		reward = reward,
		bucket = "B",
		synced = false
	}
	("[RewardSelector] ASSIGN %s — bucket B, product=%d"):format(p.Name, devProductId)
end

function RewardSelector.HasMultiReward(_)
	return false
end

function RewardSelector.UnassignPlayer(_, p)
	v4[p] = nil
	v2[p] = nil
end

function RewardSelector.GetRawConfigValue(_, p)
	return (tostring(v2[p] or 0))
end

function RewardSelector.IsSynced(_, p)
	local v7 = v4[p]
	return v7 ~= nil and v7.synced
end

function RewardSelector.MarkSynced(_, p)
	local v7 = v4[p]

	if v7 then
		v7.synced = true
	end
end

function RewardSelector.IsAssigned(_, p)
	return v4[p] ~= nil
end

function RewardSelector.GetReward(_, p)
	local v7 = v4[p]

	if v7 then
		return v7.reward
	end

	return reward
end

function RewardSelector.GetAssignedProductId(_, p)
	local v7 = v4[p]

	if v7 then
		return v7.devProductId
	end

	return devProductId
end

function RewardSelector.GetBucket(_, p)
	local v7 = v4[p]

	if v7 then
		return v7.bucket
	end

	return "A"
end

function RewardSelector.GetMultiplier(_, _)
	return multiplier_Tier_1
end

function RewardSelector:GetMultiplierForProduct(_: number)
	return multiplier_Tier_1
end

function RewardSelector:CalculateReward(p: number, p2: number)
	return p * self:GetMultiplierForProduct(p2) * 30
end

function RewardSelector.GetRewardDuration(_)
	return 30
end

return RewardSelector