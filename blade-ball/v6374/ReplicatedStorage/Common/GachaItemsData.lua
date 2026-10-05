local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Shared.Inventory)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Shared.EmoteIds)
local v4 = require3(ReplicatedStorage2.ServerInfo)
local v5 = require3(ReplicatedStorage2.Shared.DeepCopy)
local abilitiesRewards = {
	Tsunami = {
		DisplayName = "Tsunami",
		AbilityTokenIcon = "rbxassetid://81282156992436",
		UpgradeTokenIcon = "rbxassetid://113580307415004",
		ChestIcon = "rbxassetid://115542071005167",
		Requirements = { "Eclipse Fang", "Waterburst Saber", "TsunamiToken" },
		RewardInfo = v.createAbilityReward("Tsunami")
	},
	TimeHole = {
		DisplayName = "Time Hole",
		AbilityTokenIcon = "rbxassetid://17516033085",
		UpgradeTokenIcon = "rbxassetid://17523602041",
		ChestIcon = "rbxassetid://16130315578",
		Requirements = { "Temporal Dagger", "Chrono Saber", "TimeHoleToken" },
		RewardInfo = v.createAbilityReward("Time Hole")
	},
	Infinity = {
		DisplayName = "Infinity",
		AbilityTokenIcon = "rbxassetid://18877906105",
		UpgradeTokenIcon = "rbxassetid://17523603847",
		ChestIcon = "rbxassetid://18887441505",
		Requirements = { "Eternal Slasher", "Boundless Reaver", "InfinityToken" },
		NoUpgrade = true,
		RewardInfo = v.createAbilityReward("Infinity")
	},
	SlashesofFury = {
		DisplayName = "Slashes of Fury",
		AbilityTokenIcon = "rbxassetid://18259401089",
		UpgradeTokenIcon = "rbxassetid://18256906198",
		ChestIcon = "rbxassetid://18259922454",
		Requirements = { "Fury Claw", "Raging Tempest", "SlashesofFuryToken" },
		RewardInfo = v.createAbilityReward("Slashes of Fury")
	}
}
local gachaTokens = {}

for k, v8 in abilitiesRewards do
	gachaTokens[k] = {
		Rarity = "Yellow",
		Probability = 5,
		ItemName = `{k}Token`,
		Amount = 1,
		Icon = assert(v8.AbilityTokenIcon),
		UpgradeIcon = assert(v8.UpgradeTokenIcon),
		DisplayName = `{v8.DisplayName} Token`
	}
end

local function getRewardFromRequirements(p: number, createSwordReward, ...)
	local v8 = table.pack(...)
	return function(object)
		return createSwordReward(
			abilitiesRewards[object:GetExpect("BattlepassGacha.SelectedAbility")].Requirements[p],
			table.unpack(v8)
		)
	end
end

local GachaItemsData = {}

function GachaItemsData.SpinTable(list, p: number, value: number?)
	local v8 = v5(list)
	local total = 0

	for _, v9 in ipairs(list) do
		total += v9.Probability
	end

	local v9 = (tonumber(workspace:GetAttribute("GachaLuck")) or 0) + (value or 0)

	if v9 > 0 then
		for _, v10 in ipairs(v8) do
			if v10.Probability / total <= 0.1 then
				v10.Probability += v10.Probability * v9
			end
		end
	end

	local total2 = 0

	for _, v10 in ipairs(v8) do
		total2 += v10.Probability
	end

	local v10 = Random.new(p):NextNumber() * total2
	local total3 = 0

	for i, v11 in ipairs(v8) do
		total3 += v11.Probability

		if v10 <= total3 then
			return i, v11
		end
	end

	return nil
end

GachaItemsData.BottomRewards = {
	[1] = {
		Rarity = "Green",
		Probability = 33,
		ItemName = " 300 Coins",
		Amount = 1,
		AwardFunctionName = "AddCredits",
		AwardFunctionArguments = { 300, true },
		Icon = "rbxassetid://15013634268"
	},
	[2] = {
		Rarity = "Green",
		Probability = 28,
		ItemName = "Premium Weapon Skin Crate",
		Amount = 1,
		AwardFunctionName = "AddCrateKeys",
		AwardFunctionArguments = { "PremiumSword", 1 },
		Icon = "rbxassetid://16039967646"
	},
	[5] = {
		Rarity = "Green",
		Probability = 10,
		ItemName = "Venomspike Aegis",
		Amount = 1,
		AwardFunctionName = "AddSwordSkin",
		AwardFunctionArguments = {
			"Venomspike Aegis",
			nil,
			{
				AutoDeleteContainer = "BattlepassGacha"
			}
		},
		Icon = v3.Icons:GetSwordIcon("Venomspike Aegis"),
		RewardInfo = v.createSwordReward("Venomspike Aegis")
	},
	[4] = {
		Rarity = "Green",
		Probability = 26,
		ItemName = "Premium Explosion Skin Crate",
		Amount = 1,
		AwardFunctionName = "AddCrateKeys",
		AwardFunctionArguments = { "PremiumExplosion", 1 },
		Icon = "rbxassetid://15049303003"
	},
	[3] = {
		Rarity = "Blue",
		Probability = 3,
		ItemName = "Magic Token",
		Amount = 1,
		AwardFunctionName = "nil",
		AwardFunctionArguments = {},
		Icon = "rbxassetid://98225339545695"
	}
}
GachaItemsData.TopRewards = {
	{
		Rarity = "Yellow",
		Probability = 19,
		ItemName = "???",
		Amount = 1,
		AwardFunctionName = "nil",
		AwardFunctionArguments = {},
		Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		GetCustomReward = getRewardFromRequirements(1, v.createSwordReward)
	},
	{
		Rarity = "Yellow",
		Probability = 42,
		ItemName = "???",
		Amount = 1,
		AwardFunctionName = "nil",
		AwardFunctionArguments = {},
		Icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		GetCustomReward = getRewardFromRequirements(2, v.createSwordReward)
	},
	{
		Rarity = "Yellow",
		Probability = 34,
		ItemName = "Aurelfrost Fang",
		Amount = 1,
		AwardFunctionName = "AddSwordSkin",
		AwardFunctionArguments = {
			"Aurelfrost Fang",
			nil,
			{
				AutoDeleteContainer = "BattlepassGacha"
			}
		},
		Icon = v3.Icons:GetSwordIcon("Aurelfrost Fang"),
		RewardInfo = v.createSwordReward("Aurelfrost Fang")
	},
	{
		Rarity = "Yellow",
		Probability = v4.isTestGame() and 10 or 5,
		ItemName = "Ability Token",
		Amount = 1,
		AwardFunctionName = "nil",
		AwardFunctionArguments = {},
		Icon = "rbxassetid://14852723022"
	}
}
GachaItemsData.Probabilities = {}

function GachaItemsData.RewardCombinedItem(p, object)
	local v8 = require3(game.ServerScriptService.Game.Server.AwardService)
	local v9 = require3(ServerScriptService.Game.Services.GachaMessagingService)
	local v10 = abilitiesRewards[object:GetExpect("BattlepassGacha.SelectedAbility")]
	local v11 = not v10.RewardInfo or #v2.Server:FindItems(p, "Ability", v10.RewardInfo.Value) <= 0
	v8:AddAbility(p, v10.DisplayName, false)

	if v11 then
		v9:NotifyBigReward(p, v10.DisplayName)
	end
end

GachaItemsData.MagicTokenImage = "rbxassetid://17127295866"

function GachaItemsData.CheckIfPlayerOwnsOriginalInfinity(object)
	if object:Get("OwnedInfinityBeforeSeason6") then
		return true
	end

	return false
end

GachaItemsData.AbilitiesRewards = abilitiesRewards
GachaItemsData.GachaTokens = gachaTokens

function GachaItemsData.GetAbilityRewardData(object)
	local v8 = object:Get("BattlepassGacha.SelectedAbility")

	if v8 == nil then
		return
	else
		return abilitiesRewards[v8]
	end
end

function GachaItemsData.GetAbilityToken(object)
	local v8 = object:Get("BattlepassGacha.SelectedAbility")

	if v8 == nil then
		return
	else
		return gachaTokens[v8]
	end
end

function GachaItemsData.CheckIfPlayersOwnsBestPrizeAbility(object)
	local v8 = object:Get("BattlepassGacha.SelectedAbility")

	if v8 == nil or not abilitiesRewards[v8] then
		return false
	end

	local v9 = abilitiesRewards[v8]
	local v10

	if RunService:IsServer() then
		v10 = #v2.Server:FindItems(object.ReplicateTo, "Ability", v9.DisplayName) > 0
	else
		v10 = #v2.Client:FindItems("Ability", v9.DisplayName) > 0
	end

	local v11 = object:Get({ "Trials", "Abilities", v9.DisplayName })
	return v10 and (v11 == nil or v11 == 0)
end

return GachaItemsData