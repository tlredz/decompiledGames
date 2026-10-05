local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.ServerInfo)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Shared.Inventory)
local welcomeBackDailyRewards = {
	{
		Reward = v.createSwordReward("Persistence Blade")
	},
	{
		Reward = v.createReturnCoinsReward(250)
	},
	{
		Reward = v.createEmoteReward("Emote288")
	},
	{
		Reward = v.createExplosionReward("Quantum Fracture")
	},
	{
		Reward = v.createReturnCoinsReward(500)
	},
	{
		Reward = v.createSwordReward("Wind Slicer")
	},
	{
		Reward = "SWORD_SELECTION_CRATE"
	}
}
local welcomeBackReturnCoinShop = {
	{
		Cost = 200,
		Reward = v.createSwordReward("Lament's Blade"),
		ItemType = "Sword"
	},
	{
		Cost = 500,
		Reward = v.createSwordReward("Whispering Katana"),
		ItemType = "Sword"
	},
	{
		Cost = 125,
		Reward = v.createEmoteReward("Emote289"),
		ItemType = "Emote"
	},
	{
		Cost = 350,
		Reward = v.createEmoteReward("Emote286"),
		ItemType = "Emote"
	},
	{
		Cost = 100,
		Reward = v.createExplosionReward("Corrupted Duality"),
		ItemType = "Explosion"
	},
	{
		Cost = 300,
		Reward = v.createExplosionReward("Aurora's Blast"),
		ItemType = "Explosion"
	}
}
local welcomeBackMilestones = {
	{
		XP = 50,
		Reward = v.createReturnCoinsReward(150)
	},
	{
		XP = 100,
		Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646")
	},
	{
		XP = 150,
		Reward = v.createReturnCoinsReward(350)
	},
	{
		XP = 200,
		Reward = v.createSwordReward("Shadow Saber")
	},
	{
		XP = 250,
		Reward = v.createSwordReward("Frigidus' Starforge")
	}
}
local milestoneFinalRewards = {
	v.createSwordReward("Frigidus' Starforge"),
	v.createSwordReward("Hyper Starforge"),
	v.createSwordReward("Inferno's Starforge")
}
local v7 = {
	["Continuity Zero"] = {
		Reward = v.createAbilityReward("Continuity Zero"),
		ItemType = "Ability"
	},
	["Skyfall's Edge"] = {
		Reward = v.createSwordReward("Skyfall's Edge"),
		ItemType = "Sword"
	},
	Emote290 = {
		Reward = v.createEmoteReward("Emote290"),
		ItemType = "Emote"
	}
}
local v8 = {
	Force = {
		Reward = v.createAbilityReward("Force"),
		ItemType = "Ability"
	},
	["Skyfall's Edge"] = {
		Reward = v.createSwordReward("Skyfall's Edge"),
		ItemType = "Sword"
	},
	Emote290 = {
		Reward = v.createEmoteReward("Emote290"),
		ItemType = "Emote"
	}
}
return {
	MaxMilestoneXP = 250,
	WelcomeBackMilestones = welcomeBackMilestones,
	MilestoneFinalRewards = milestoneFinalRewards,
	GetSelectionCrateRewards = function(p)
		local v9

		if RunService:IsServer() then
			v9 = #v2.Server:FindItems(p, "Ability", "Force") > 0
		else
			v9 = #v2.Client:FindItems("Ability", "Force") > 0
		end

		if v9 then
			return v7
		end

		return v8
	end,
	WelcomeBackDailyRewards = welcomeBackDailyRewards,
	WelcomeBackReturnCoinShop = welcomeBackReturnCoinShop
}