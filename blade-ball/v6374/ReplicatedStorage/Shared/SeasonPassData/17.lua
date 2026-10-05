local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.Table)
local _17 = {
	StartTime = 0,
	EndTime = 0
}
local startTime

if require3(ReplicatedStorage2.ServerInfo).isTestGame() then
	startTime = DateTime.now()
else
	startTime = DateTime.fromUniversalTime(2025, 5, 31, 17)
end

_17.StartTime = startTime
_17.EndTime = DateTime.fromUniversalTime(2025, 7, 5, 17)

local function cloneRewards(p: number)
	return v2.Copy(_17.Rewards[p])
end

_17.Rewards = {
	{
		{
			XP = 50,
			Free = v.createCoinsReward(100, "Small"),
			Premium = v.createSwordReward("Twilight Edge")
		},
		{
			XP = 100,
			Free = v.createSeasonPassCurrencyReward(25),
			Premium = v.createSeasonPassCurrencyReward(50)
		},
		{
			XP = 160,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createBoostReward("Coins2x", 30)
		},
		{
			XP = 220,
			Free = v.createSeasonPassCurrencyReward(35),
			Premium = v.createSeasonPassCurrencyReward(75)
		},
		{
			XP = 290,
			Free = v.createEmoteReward("Super Style"),
			Premium = v.createSeasonPassCurrencyReward(85)
		},
		{
			XP = 360,
			Free = v.createGachaSpinsReward(1),
			Premium = v.createGachaSpinsReward(2)
		},
		{
			XP = 440,
			Free = v.createCoinsReward(200, "Small"),
			Premium = v.createCoinsReward(400, "Small")
		},
		{
			XP = 525,
			Free = v.createWheelSpinReward(1),
			Premium = v.createWheelSpinReward(3)
		},
		{
			XP = 615,
			Free = v.createSeasonPassCurrencyReward(40),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 710,
			Free = v.createSwordReward("Ashen Crescent"),
			Premium = v.createSwordReward("Temple Cleaver")
		},
		{
			XP = 810,
			Free = v.createSeasonPassCurrencyReward(45),
			Premium = v.createGachaSpinsReward(1)
		},
		{
			XP = 915,
			Free = v.createSeasonPassCurrencyReward(45),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 1025,
			Free = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Premium = v.createCrateKeyReward("PremiumSword", 2, "Premium Sword Crate", "rbxassetid://16039967646")
		},
		{
			XP = 1140,
			Free = v.createBattlepassExplosionCrateReward(1),
			Premium = v.createBattlepassExplosionCrateReward(2)
		},
		{
			XP = 1260,
			Free = v.createEmoteReward("Uptown Downtown"),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 1385,
			Free = v.createGachaSpinsReward(1),
			Premium = v.createGachaSpinsReward(2)
		},
		{
			XP = 1515,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createSeasonPassCurrencyReward(100)
		},
		{
			XP = 1655,
			Free = v.createSeasonPassCurrencyReward(55),
			Premium = v.createSeasonPassCurrencyReward(125)
		},
		{
			XP = 1805,
			Free = v.createSeasonPassCurrencyReward(55),
			Premium = v.createSeasonPassCurrencyReward(125)
		},
		{
			XP = 1955,
			Free = v.createSeasonPassCurrencyReward(60),
			Premium = v.createEmoteReward("Tip Toe Dance")
		},
		{
			XP = 2115,
			Free = v.createCoinsReward(250, "Small"),
			Premium = v.createCoinsReward(500, "Small")
		},
		{
			XP = 2275,
			Free = v.createWheelSpinReward(1),
			Premium = v.createSeasonPassCurrencyReward(100)
		},
		{
			XP = 2445,
			Free = v.createSeasonPassCurrencyReward(65),
			Premium = v.createSeasonPassCurrencyReward(120)
		},
		{
			XP = 2615,
			Free = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Premium = v.createSeasonPassCurrencyReward(140)
		},
		{
			XP = 2795,
			Free = v.createCoinsReward(300, "Small"),
			Premium = v.createSwordReward("Silent Peak")
		},
		{
			XP = 2975,
			Free = v.createSeasonPassCurrencyReward(65),
			Premium = v.createSeasonPassCurrencyReward(150)
		},
		{
			XP = 3165,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createSeasonPassCurrencyReward(150)
		},
		{
			XP = 3365,
			Free = v.createSeasonPassCurrencyReward(70),
			Premium = v.createSeasonPassCurrencyReward(150)
		},
		{
			XP = 3575,
			Free = v.createSeasonPassCurrencyReward(70),
			Premium = v.createSeasonPassCurrencyReward(155)
		},
		{
			XP = 3795,
			Free = v.createSwordReward("Whispers of the Fallen"),
			Premium = v.createSeasonPassCurrencyReward(155)
		},
		{
			XP = 4025,
			Free = v.createSeasonPassCurrencyReward(70),
			Premium = v.createSeasonPassCurrencyReward(160)
		},
		{
			XP = 4265,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createBoostReward("Coins2x", 30)
		},
		{
			XP = 4515,
			Free = v.createSeasonPassCurrencyReward(75),
			Premium = v.createSeasonPassCurrencyReward(165)
		},
		{
			XP = 4775,
			Free = v.createBattlepassExplosionCrateReward(1),
			Premium = v.createSeasonPassCurrencyReward(165)
		},
		{
			XP = 5045,
			Free = v.createSeasonPassCurrencyReward(75),
			Premium = v.createSeasonPassCurrencyReward(165)
		},
		{
			XP = 5325,
			Free = v.createBattlepassExplosionCrateReward(1),
			Premium = v.createBattlepassExplosionCrateReward(2)
		},
		{
			XP = 5615,
			Free = v.createSeasonPassCurrencyReward(75),
			Premium = v.createSeasonPassCurrencyReward(165)
		},
		{
			XP = 5915,
			Free = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Premium = v.createCrateKeyReward("PremiumSword", 3, "Premium Sword Crate", "rbxassetid://16039967646")
		},
		{
			XP = 6215,
			Free = v.createSeasonPassCurrencyReward(85),
			Premium = v.createSeasonPassCurrencyReward(170)
		},
		{
			XP = 6515,
			Free = v.createSeasonPassCurrencyReward(85),
			Premium = v.createSeasonPassCurrencyReward(175)
		},
		{
			XP = 6815,
			Free = v.createWheelSpinReward(1),
			Premium = v.createWheelSpinReward(3)
		},
		{
			XP = 7115,
			Free = v.createSeasonPassCurrencyReward(85),
			Premium = v.createSeasonPassCurrencyReward(180)
		},
		{
			XP = 7415,
			Free = v.createBattlepassExplosionCrateReward(1),
			Premium = v.createSeasonPassCurrencyReward(120)
		},
		{
			XP = 7715,
			Free = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Premium = v.createSeasonPassCurrencyReward(190)
		},
		{
			XP = 8015,
			Free = v.createSeasonPassCurrencyReward(85),
			Premium = v.createEmoteReward("Dap me up!")
		},
		{
			XP = 8315,
			Free = v.createWheelSpinReward(1),
			Premium = v.createSeasonPassCurrencyReward(200)
		},
		{
			XP = 8615,
			Free = v.createSeasonPassCurrencyReward(90),
			Premium = v.createSeasonPassCurrencyReward(205)
		},
		{
			XP = 8915,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createBoostReward("Coins2x", 30)
		},
		{
			XP = 9215,
			Free = v.createSeasonPassCurrencyReward(90),
			Premium = v.createSeasonPassCurrencyReward(205)
		},
		{
			XP = 9515,
			Free = v.createSeasonPassCurrencyReward(90),
			Premium = v.createSwordReward("Cursed Ink")
		},
		{
			XP = 9815,
			Free = v.createWheelSpinReward(1),
			Premium = v.createWheelSpinReward(3)
		},
		{
			XP = 10115,
			Free = v.createBattlepassExplosionCrateReward(1),
			Premium = v.createBattlepassExplosionCrateReward(2)
		},
		{
			XP = 10415,
			Free = v.createSeasonPassCurrencyReward(95),
			Premium = v.createSeasonPassCurrencyReward(210)
		},
		{
			XP = 10715,
			Free = v.createSeasonPassCurrencyReward(95),
			Premium = v.createSeasonPassCurrencyReward(210)
		},
		{
			XP = 11015,
			Free = v.createSwordReward("Ricefield Cutter"),
			Premium = v.createSwordReward("Duskgloom Piercer")
		},
		{
			XP = 11315,
			Free = v.createSeasonPassCurrencyReward(100),
			Premium = v.createSeasonPassCurrencyReward(225)
		},
		{
			XP = 11615,
			Free = v.createSeasonPassCurrencyReward(100),
			Premium = v.createSeasonPassCurrencyReward(225)
		},
		{
			XP = 11915,
			Free = v.createGachaSpinsReward(1),
			Premium = v.createSeasonPassCurrencyReward(250)
		},
		{
			XP = 12215,
			Free = v.createSeasonPassCurrencyReward(150),
			Premium = v.createSeasonPassCurrencyReward(300)
		},
		{
			XP = 12515,
			Free = v.createBattlepassSelectionCrateReward(1, "Normal"),
			Premium = v.createBattlepassSelectionCrateReward(1, "Premium")
		}
	},
	{
		{
			XP = 50,
			Free = v.createCoinsReward(100, "Small"),
			Premium = v.createCoinsReward(200, "Small")
		},
		{
			XP = 110,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createBoostReward("Coins2x", 30)
		},
		{
			XP = 180,
			Free = v.createSeasonPassCurrencyReward(40),
			Premium = v.createSeasonPassCurrencyReward(80)
		},
		{
			XP = 260,
			Free = v.createGachaSpinsReward(1),
			Premium = v.createGachaSpinsReward(3)
		},
		{
			XP = 350,
			Free = v.createSeasonPassCurrencyReward(40),
			Premium = v.createSeasonPassCurrencyReward(80)
		},
		{
			XP = 450,
			Free = v.createSeasonPassCurrencyReward(45),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 565,
			Free = v.createCoinsReward(250, "Small"),
			Premium = v.createCoinsReward(500, "Small")
		},
		{
			XP = 695,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 840,
			Free = v.createSeasonPassCurrencyReward(45),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 1000,
			Free = v.createSeasonPassCurrencyReward(45),
			Premium = v.createSeasonPassCurrencyReward(90)
		},
		{
			XP = 1175,
			Free = v.createGachaSpinsReward(1),
			Premium = v.createGachaSpinsReward(3)
		},
		{
			XP = 1375,
			Free = v.createSeasonPassCurrencyReward(50),
			Premium = v.createSeasonPassCurrencyReward(100)
		},
		{
			XP = 1575,
			Free = v.createCoinsReward(250, "Small"),
			Premium = v.createCoinsReward(500, "Small")
		},
		{
			XP = 1775,
			Free = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Premium = v.createCrateKeyReward("PremiumSword", 2, "Premium Sword Crate", "rbxassetid://16039967646")
		},
		{
			XP = 2000,
			Free = v.createSeasonPassCurrencyReward(60),
			Premium = v.createSeasonPassCurrencyReward(120)
		},
		{
			XP = 2250,
			Free = v.createSeasonPassCurrencyReward(60),
			Premium = v.createSeasonPassCurrencyReward(120)
		},
		{
			XP = 2525,
			Free = v.createSeasonPassCurrencyReward(65),
			Premium = v.createSeasonPassCurrencyReward(130)
		},
		{
			XP = 2825,
			Free = v.createWheelSpinReward(1),
			Premium = v.createWheelSpinReward(3)
		},
		{
			XP = 3150,
			Free = v.createSeasonPassCurrencyReward(65),
			Premium = v.createSeasonPassCurrencyReward(130)
		},
		{
			XP = 3500,
			Free = v.createSeasonPassCurrencyReward(70),
			Premium = v.createSeasonPassCurrencyReward(140)
		},
		{
			XP = 3875,
			Free = v.createBoostReward("Coins2x", 15),
			Premium = v.createSeasonPassCurrencyReward(140)
		},
		{
			XP = 4275,
			Free = v.createSeasonPassCurrencyReward(75),
			Premium = v.createSeasonPassCurrencyReward(150)
		},
		{
			XP = 4700,
			Free = v.createSeasonPassCurrencyReward(75),
			Premium = v.createSeasonPassCurrencyReward(150)
		},
		{
			XP = 5150,
			Free = v.createSeasonPassCurrencyReward(80),
			Premium = v.createSeasonPassCurrencyReward(160)
		},
		{
			XP = 5625,
			Free = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Premium = v.createSeasonPassCurrencyReward(160)
		},
		{
			XP = 6125,
			Free = v.createSeasonPassCurrencyReward(80),
			Premium = v.createSeasonPassCurrencyReward(160)
		},
		{
			XP = 6650,
			Free = v.createSeasonPassCurrencyReward(90),
			Premium = v.createSeasonPassCurrencyReward(175)
		},
		{
			XP = 7200,
			Free = v.createSeasonPassCurrencyReward(100),
			Premium = v.createSeasonPassCurrencyReward(200)
		},
		{
			XP = 7775,
			Free = v.createGachaSpinsReward(1),
			Premium = v.createGachaSpinsReward(3)
		},
		{
			XP = 8375,
			Free = v.createBattlepassSelectionCrateReward(1, "Normal"),
			Premium = v.createBattlepassSelectionCrateReward(1, "Premium")
		}
	}
}
_17.Rewards[3] = v2.Copy(_17.Rewards[2])
_17.Rewards[4] = v2.Copy(_17.Rewards[2])
return _17