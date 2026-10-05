local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Shared.Inventory.Shared)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)

-- equivalent calls inferred from this helper; original call sites unknown
local function getCallerFromReplion(dataReplion, replion)
	return {
		Type = "FakeCaller",
		CustomType = "InventoryCaller",
		Replion = replion,
		InventoryVersion = "New",
		DataReplion = dataReplion
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLimitedStockReplion()
	return (v[RunService:IsClient() and "Client" or "Server"]:WaitReplion("LimitedStockItems"))
end

return {
	{
		Reward = v2.createExplosionReward("Confetti Pop"),
		Chance = 30
	},
	{
		Reward = v2.createEmoteReward("New Year Cheer"),
		Chance = 25
	},
	{
		Reward = v2.createSwordReward("Glacial Shard"),
		Chance = 20
	},
	{
		Reward = v2.createExplosionReward("Firework Flare"),
		Chance = 10
	},
	{
		Reward = v2.createSwordReward("Radiant Edge"),
		Chance = 7
	},
	{
		Reward = v2.createExplosionReward("Ecliptic Eruption"),
		Chance = 7
	},
	{
		Reward = function(dataReplion, replion)
			local abilityReward = v2.createAbilityReward("Bounty")

			if not (#v3:FindItems(getCallerFromReplion(dataReplion, replion), "Ability", "Bounty") > 0) then
				return abilityReward
			end

			local limitedStockReplion = getLimitedStockReplion() -- equivalent call inferred; original call site unknown

			if limitedStockReplion and limitedStockReplion:Get("Loaded") and (limitedStockReplion:Get({
				"Stock",
				"Aligned Constellation"
			}) or 0) > 0 then
				return (v2.createSwordReward("Aligned Constellation"))
			end

			abilityReward = v2.createSwordReward("Radiant Edge")
			return abilityReward
		end,
		Watch = function(dataReplion, replion, p3)
			local v4 = v3:OnInventoryChange(getCallerFromReplion(dataReplion, replion), "Ability", p3)
			local limitedStockReplion = getLimitedStockReplion() -- equivalent call inferred; original call site unknown

			if limitedStockReplion then
				limitedStockReplion:OnChange("Loaded", p3)
				limitedStockReplion:OnChange("Stock", p3)
				limitedStockReplion:OnChange({ "Stock", "Aligned Constellation" }, p3)
			end

			return function()
				if v4 then
					v4:Destroy()
				end
			end
		end,
		Chance = 1
	}
}