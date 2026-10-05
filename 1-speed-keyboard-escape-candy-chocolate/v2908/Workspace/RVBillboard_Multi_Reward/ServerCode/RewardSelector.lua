local AdService = game:GetService("AdService")
local devProductId = 0
local reward = nil
local v2 = {}
local v3 = {}
local v4 = false

local function dbg(p: string)
	print(p)
end

local function parseMultiRewardList(multiRewardList: string?)
	if not multiRewardList or multiRewardList == "" then
		return {}
	end

	local result = {}

	for k in string.gmatch(multiRewardList, "[^,]+") do
		local v5 = tonumber(string.match(k, "%d+"))

		if v5 and v5 ~= 0 then
			table.insert(result, v5)
		end
	end

	return result
end

local function checkBucket(p)
	local success, result = pcall(function()
		local ConfigService = game:GetService("ConfigService")
		local configForPlayerAsync = ConfigService:GetConfigForPlayerAsync(p)

		if not configForPlayerAsync then
			print("[RewardSelector] ConfigService returned nil config — defaulting to bucket A")
			return false
		end

		local value = configForPlayerAsync:GetValue("RVB_Multi_Reward")
		local formatted = ("[RewardSelector] ConfigService RVB_Multi_Reward = %s (type: %s)"):format(
			tostring(value),
			(typeof(value))
		)
		print(formatted)
		return type(value) == "boolean" and value
	end)

	if success then
		return result
	end

	print("[RewardSelector] ConfigService fetch failed — defaulting to bucket A")
	return false
end

local RewardSelector = {}

function RewardSelector.Init(_, p)
	devProductId = p.DevProductId
	local formatted = ("[RewardSelector] INIT — mainDevProductId=%d"):format(devProductId)
	print(formatted)
	local success, result = pcall(AdService.CreateAdRewardFromDevProductId, AdService, devProductId)

	if not success then
		warn(("[RVBillboard/RewardSelector] Main reward creation failed for %d"):format(devProductId))
		return false
	end

	reward = result
	local v5 = parseMultiRewardList(p.MultiRewardList)
	local formatted2 = ("[RewardSelector] Parsed %d B-table IDs"):format(#v5)
	print(formatted2)

	for _, devProductId2 in v5 do
		local success2, result2 = pcall(AdService.CreateAdRewardFromDevProductId, AdService, devProductId2)

		if success2 then
			table.insert(v2, {
				devProductId = devProductId2,
				reward = result2
			})
			local formatted3 = ("[RewardSelector] B-table reward created for ID %d"):format(devProductId2)
			print(formatted3)
		else
			warn(("[RVBillboard/RewardSelector] B-table reward creation failed for %d — skipping"):format(devProductId2))
		end
	end

	v4 = #v2 > 0
	local formatted3 = ("[RewardSelector] INIT COMPLETE — B-table available: %s (%d entries)"):format(tostring(v4), #v2)
	print(formatted3)
	return true
end

function RewardSelector.AssignPlayer(_, p)
	if not reward or v3[p] and v3[p].synced then
		return
	end

	if not v4 then
		v3[p] = {
			devProductId = devProductId,
			reward = reward,
			bucket = "A",
			synced = false
		}
		return
	end

	local success, result = pcall(function()
		local ConfigService = game:GetService("ConfigService")
		local configForPlayerAsync = ConfigService:GetConfigForPlayerAsync(p)

		if not configForPlayerAsync then
			print("[RewardSelector] ConfigService returned nil config — defaulting to bucket A")
			return false
		end

		local value = configForPlayerAsync:GetValue("RVB_Multi_Reward")
		local formatted = ("[RewardSelector] ConfigService RVB_Multi_Reward = %s (type: %s)"):format(
			tostring(value),
			(typeof(value))
		)
		print(formatted)
		return type(value) == "boolean" and value
	end)

	if not success then
		print("[RewardSelector] ConfigService fetch failed — defaulting to bucket A")
		result = false
	end

	if not result then
		v3[p] = {
			devProductId = devProductId,
			reward = reward,
			bucket = "A",
			synced = false
		}
		return
	end

	local v6 = v2[math.random(1, #v2)]
	v3[p] = {
		devProductId = v6.devProductId,
		reward = v6.reward,
		bucket = "B",
		synced = false
	}
	local formatted = ("[RewardSelector] ASSIGN %s — bucket B, product=%d"):format(p.Name, v6.devProductId)
	print(formatted)
end

function RewardSelector.AcceptSync(_, p, p2: number)
	if v3[p] and v3[p].synced then
		return false
	end

	for _, v5 in v2 do
		if v5.devProductId ~= p2 then
			continue
		end

		v3[p] = {
			devProductId = v5.devProductId,
			reward = v5.reward,
			bucket = "B",
			synced = true
		}
		return true
	end

	if p2 ~= devProductId then
		return false
	end

	v3[p] = {
		devProductId = devProductId,
		reward = reward,
		bucket = "A",
		synced = true
	}
	return true
end

function RewardSelector.HasMultiReward(_)
	return v4
end

function RewardSelector.UnassignPlayer(_, p)
	v3[p] = nil
end

function RewardSelector.IsSynced(_, p)
	local v5 = v3[p]
	return v5 ~= nil and v5.synced
end

function RewardSelector.MarkSynced(_, p)
	local v5 = v3[p]

	if v5 then
		v5.synced = true
	end
end

function RewardSelector.IsAssigned(_, p)
	return v3[p] ~= nil
end

function RewardSelector.GetReward(_, p)
	local v5 = v3[p]

	if v5 then
		return v5.reward
	end

	return reward
end

function RewardSelector.GetAssignedProductId(_, p)
	local v5 = v3[p]

	if v5 then
		return v5.devProductId
	end

	return devProductId
end

function RewardSelector.GetBucket(_, p)
	local v5 = v3[p]

	if v5 then
		return v5.bucket
	end

	return "A"
end

return RewardSelector