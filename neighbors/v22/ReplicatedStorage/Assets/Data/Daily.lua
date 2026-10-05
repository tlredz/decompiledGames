local v = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v2 = {
	{
		Amount = 15,
		ReducedAmount = 3,
		Icon = "http://www.roblox.com/asset/?id=12859368888"
	},
	{
		Amount = 20,
		ReducedAmount = 5,
		Icon = "http://www.roblox.com/asset/?id=12859369557"
	},
	{
		Amount = 25,
		ReducedAmount = 8,
		Icon = "http://www.roblox.com/asset/?id=12859370335"
	},
	{
		Amount = 30,
		ReducedAmount = 10,
		Icon = "http://www.roblox.com/asset/?id=12859371115"
	},
	{
		Amount = 40,
		ReducedAmount = 15,
		Icon = "http://www.roblox.com/asset/?id=12859372004"
	},
	{
		Amount = 50,
		ReducedAmount = 20,
		Icon = "http://www.roblox.com/asset/?id=12859372654"
	},
	{
		Amount = 60,
		ReducedAmount = 40,
		Icon = "http://www.roblox.com/asset/?id=12859372654"
	}
}

local function getDayIndexFromStreak(p: number)
	return p % 7 + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBaseReward(p: number)
	return table.clone(v2[p % 7 + 1])
end

local function getAdjustedReward(p: number, p2: string)
	local baseReward = getBaseReward(p) -- equivalent call inferred; original call site unknown

	if p2 == "ReducedReward" then
		baseReward.Amount = baseReward.ReducedAmount
	end

	return baseReward
end

if RunService:IsServer() then
	local Server = require(ReplicatedStorage.Modules.GameConfig.Server)

	function v.GetRewardData(_, p, p2: number)
		local playerValue = Server:GetPlayerValue(p, "DailyRewardType")
		local baseReward = getBaseReward(p2) -- equivalent call inferred; original call site unknown

		if playerValue == "ReducedReward" then
			baseReward.Amount = baseReward.ReducedAmount
		end

		return baseReward
	end

	return v
else
	if RunService:IsClient() then
		local Client = require(ReplicatedStorage.Modules.GameConfig.Client)

		function v.GetLocalRewardData(_, p: number)
			local value = Client:GetValue("DailyRewardType")
			local baseReward = getBaseReward(p) -- equivalent call inferred; original call site unknown

			if value == "ReducedReward" then
				baseReward.Amount = baseReward.ReducedAmount
			end

			return baseReward
		end
	end

	return v
end