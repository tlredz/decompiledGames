local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)("@game/ReplicatedStorage/Common/RewardInfo")

local function updateReward(displayName: string, icon: string?, p)
	p.DisplayName = displayName

	if icon then
		p.Icon = icon
	end

	return p
end

local battlepassTierSkipReward = v.createBattlepassTierSkipReward(20)
battlepassTierSkipReward.DisplayName = "20 Battlepass Tier Skips"
battlepassTierSkipReward.Icon = "rbxassetid://0"
local boostReward = v.createBoostReward("BattlepassLuck", 86400)
boostReward.DisplayName = "24h Battlepass Luck"
boostReward.Icon = "rbxassetid://0"
local abilityFreeTrialReward = v.createAbilityFreeTrialReward("Dash", 1800)
abilityFreeTrialReward.DisplayName = "30m Dash Free Trial"
abilityFreeTrialReward.Icon = "rbxassetid://0"
local boostReward2 = v.createBoostReward("Coins2x", 86400)
boostReward2.DisplayName = "24h 2x Coins"
boostReward2.Icon = "rbxassetid://0"
local abilityFreeTrialReward2 = v.createAbilityFreeTrialReward("Dash", 1800)
abilityFreeTrialReward2.DisplayName = "30m Dash Free Trial"
abilityFreeTrialReward2.Icon = "rbxassetid://0"
local titleReward = v.createTitleReward("Veteran")
titleReward.DisplayName = "Veteral Title"
titleReward.Icon = "rbxassetid://0"
local swordReward = v.createSwordReward("Base Sword")
swordReward.DisplayName = "Base Sword"
return {
	PlayTimeToUnlockReward = 1800,
	Rewards = {
		battlepassTierSkipReward,
		boostReward,
		abilityFreeTrialReward,
		boostReward2,
		abilityFreeTrialReward2,
		titleReward,
		swordReward
	}
}