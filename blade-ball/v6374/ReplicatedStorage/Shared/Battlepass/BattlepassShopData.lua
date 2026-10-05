local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local BattlepassShopData = {
	LimitedStockSlot = {
		{
			Reward = v.createSwordReward("Clans Warrior"),
			ItemID = "Item1D",
			Chance = 35,
			Cost = 100000,
			TotalStock = 500,
			StockPerDay = 50
		},
		{
			Reward = v.createExplosionReward("Radiant Detonation"),
			ItemID = "Item2D",
			Chance = 35,
			Cost = 50000,
			TotalStock = 500,
			StockPerDay = 50
		},
		{
			Reward = v.createSwordReward("Harvest Reaper"),
			ItemID = "Item3D",
			Chance = 35,
			Cost = 10000,
			TotalStock = 500,
			StockPerDay = 50
		}
	},
	Slots = {
		{
			Item1 = {
				Reward = v.createSwordReward("Cyclops Carver"),
				Chance = 27,
				Cost = 300
			},
			Item2 = {
				Reward = v.createGachaSpinsReward(1),
				Chance = 27,
				Cost = 300
			},
			Item3 = {
				Reward = v.createGachaSpinsReward(1),
				Chance = 10,
				Cost = 750
			},
			Item4 = {
				Reward = v.createExplosionReward("Temple Cataclysm"),
				Chance = 35,
				Cost = 750
			},
			Item5 = {
				Reward = v.createExplosionReward("Emperor's Collapse"),
				Chance = 1,
				Cost = 5000
			}
		},
		{
			Item6 = {
				Reward = v.createSwordReward("Heavenpiercer"),
				Chance = 37,
				Cost = 100
			},
			Item7 = {
				Reward = v.createSwordReward("Gilded Typhon"),
				Chance = 35,
				Cost = 125
			},
			Item8 = {
				Reward = v.createGachaSpinsReward(1),
				Chance = 25,
				Cost = 750
			},
			Item9 = {
				Reward = v.createGachaSpinsReward(1),
				Chance = 3,
				Cost = 750
			}
		},
		{
			Item10 = {
				Reward = v.createEmoteReward("Laughing"),
				Chance = 35,
				Cost = 150
			},
			Item11 = {
				Reward = v.createEmoteReward("Shadow Flip"),
				Chance = 35,
				Cost = 150
			},
			Item12 = {
				Reward = v.createEmoteReward("Groovy"),
				Chance = 20,
				Cost = 750
			},
			Item13 = {
				Reward = v.createEmoteReward("Selfie"),
				Chance = 10,
				Cost = 750
			}
		},
		{
			Item14 = {
				Reward = v.createWheelSpinReward(1),
				Chance = 75,
				Cost = 100
			},
			Item15 = {
				Reward = v.createGachaSpinsReward(1),
				Chance = 25,
				Cost = 750
			}
		},
		{
			Item16 = {
				Reward = v.createCoinsReward(500, "Med"),
				Chance = 70,
				Cost = 75
			},
			Item17 = {
				Reward = v.createCoinsReward(1000, "Big"),
				Chance = 23,
				Cost = 200
			},
			Item20 = {
				Reward = v.createCoinsReward(1000, "Big"),
				Chance = 7,
				Cost = 200
			}
		},
		{
			Item21 = {
				Reward = v.createBattlepassTierSkipReward(1),
				Chance = 100,
				Cost = 250
			}
		}
	}
}

for k, slot in BattlepassShopData.Slots do
	local total = 0

	for k2, v2 in slot do
		v2.ItemID = k2
		total += v2.Chance
	end

	if total ~= 100 and RunService:IsStudio() then
		warn((`Total odds for Battlepass Shop Slot #{k} does not add up to 100% ({total}%)`))
	end
end

return BattlepassShopData