local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local WithoutInstantSpin = {
	{
		name = "twoTimes",
		bottomText = "15m",
		icon = "rbxassetid://14737693993",
		rewardText = "x2 Coins",
		wheelText = "x2 Coins",
		chance = 28,
		displayText = "2x coins for 15 minutes"
	},
	{
		name = "nebulaShard",
		displayText = "Nebula Shard",
		icon = "rbxassetid://17861539338",
		rewardText = "Nebula Shard",
		bottomText = "CUSTOM VFX",
		chance = v.isTestGame() and 30 or 1
	},
	{
		name = "fiveHundredCoins",
		bottomText = "500",
		icon = "rbxassetid://14737377983",
		rewardText = "500 Coins",
		wheelText = "Coins",
		displayText = "five hundred coins",
		chance = 20
	},
	{
		name = "hundredCoins",
		bottomText = "250",
		icon = "rbxassetid://14737356590",
		rewardText = "250 Coins",
		wheelText = "Coins",
		displayText = "two hundred and fifty coins",
		chance = 33
	},
	{
		name = "rapture",
		displayText = "Rapture",
		icon = "rbxassetid://14737436876",
		rewardText = "Rapture",
		bottomText = "ABILITY",
		chance = 2
	}
}

if v2.SeasonData.Currency then
	table.insert(WithoutInstantSpin, {
		name = "seasonPassPoints",
		bottomText = "100",
		icon = v2.SeasonData.Currency.Icon,
		rewardText = "100 " .. v2.SeasonData.Currency.Name,
		wheelText = v2.SeasonData.Currency.Name,
		displayText = "hundred " .. string.lower(v2.SeasonData.Currency.Name),
		chance = 16
	})
	return WithoutInstantSpin
end

table.insert(WithoutInstantSpin, {
	name = "threeHundredCoins",
	bottomText = "300",
	icon = "rbxassetid://14737377983",
	rewardText = "300 Coins",
	wheelText = "Coins",
	displayText = "three hundred coins",
	chance = 16
})
return WithoutInstantSpin