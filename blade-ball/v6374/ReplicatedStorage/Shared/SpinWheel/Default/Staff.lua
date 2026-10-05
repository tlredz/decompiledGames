local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
return {
	{
		name = "twoTimes",
		bottomText = "15m",
		icon = "rbxassetid://14737693993",
		rewardText = "x2 Coins",
		wheelText = "x2 Coins",
		chance = 24,
		displayText = "2x coins for 15 minutes"
	},
	{
		name = "nebulaStaff",
		displayText = "Nebula Staff",
		icon = "rbxassetid://17858910891",
		rewardText = "Nebula Staff",
		bottomText = "CUSTOM VFX",
		chance = require3(ReplicatedStorage2.ServerInfo).isTestGame() and 30 or 0.25
	},
	{
		name = "fiveHundredCoins",
		bottomText = "500",
		icon = "rbxassetid://14737377983",
		rewardText = "500 Coins",
		wheelText = "Coins",
		displayText = "five hundred coins",
		chance = 17.75
	},
	{
		name = "hundredCoins",
		bottomText = "250",
		icon = "rbxassetid://14737356590",
		rewardText = "250 Coins",
		wheelText = "Coins",
		displayText = "two hundred and fifty coins",
		chance = 29
	},
	{
		name = "rapture",
		displayText = "Rapture",
		icon = "rbxassetid://14737436876",
		rewardText = "Rapture",
		bottomText = "ABILITY",
		chance = 2
	},
	{
		name = "instantSpin",
		icon = "rbxassetid://14737617340",
		rewardText = "Instant Spin",
		wheelText = "Instant Spin",
		displayText = "instant spin for 30 minutes",
		bottomText = "30m",
		chance = 27
	}
}