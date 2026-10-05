local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.ServerInfo).isTestGame() and true
local MerchantShopData = {
	ArrivalInterval = v2 and 30 or 10800,
	ArrivalChance = v2 and 1 or 0.333,
	Duration = v2 and 300 or 21600,
	ItemRevealAnimationTime = 4,
	Items = {
		{
			Item1 = {
				Reward = v.createExplosionReward("Pumpkin Burst"),
				Chance = 25,
				Cost = 500,
				MaxPurchases = 1
			},
			Item2 = {
				Reward = v.createExplosionReward("Specter Pop"),
				Chance = 25,
				Cost = 1500,
				MaxPurchases = 1
			},
			Item3 = {
				Reward = v.createExplosionReward("Witch's Cackle"),
				Chance = 20,
				Cost = 2500,
				MaxPurchases = 1
			},
			Item4 = {
				Reward = v.createExplosionReward("Headless Eruption"),
				Chance = 20,
				Cost = 3500,
				MaxPurchases = 1
			},
			Item5 = {
				Reward = v.createExplosionReward("Hellfire Surge"),
				Chance = 10,
				Cost = 5000,
				MaxPurchases = 1
			}
		},
		{
			Item6 = {
				Reward = v.createEmoteReward("Zombie Walk"),
				Chance = 25,
				Cost = 1000,
				MaxPurchases = 1
			},
			Item7 = {
				Reward = v.createEmoteReward("Spooky Spin"),
				Chance = 25,
				Cost = 2500,
				MaxPurchases = 1
			},
			Item8 = {
				Reward = v.createEmoteReward("Pumpkin Squash"),
				Chance = 20,
				Cost = 5000,
				MaxPurchases = 1
			},
			Item9 = {
				Reward = v.createEmoteReward("Ghoul Rise"),
				Chance = 20,
				Cost = 7500,
				MaxPurchases = 1
			},
			Item10 = {
				Reward = v.createEmoteReward("Graveyard Shuffle"),
				Chance = 10,
				Cost = 10000,
				MaxPurchases = 1
			}
		},
		{
			Item11 = {
				Reward = v.createSwordReward("Haunted Edge"),
				Chance = 25,
				Cost = 1500,
				MaxPurchases = 1
			},
			Item12 = {
				Reward = v.createSwordReward("Shadowbite"),
				Chance = 25,
				Cost = 3000,
				MaxPurchases = 1
			},
			Item13 = {
				Reward = v.createSwordReward("Cursed Steel"),
				Chance = 20,
				Cost = 7500,
				MaxPurchases = 1
			},
			Item14 = {
				Reward = v.createSwordReward("Spectral Cleaver"),
				Chance = 20,
				Cost = 10000,
				MaxPurchases = 1
			},
			Item15 = {
				Reward = v.createSwordReward("Pumpkin Reaper"),
				Chance = 10,
				Cost = 25000,
				MaxPurchases = 1
			}
		},
		{
			Item16 = {
				Reward = v.createWheelSpinReward(1),
				Chance = 50,
				Cost = 750,
				MaxPurchases = 2
			},
			Item18 = {
				Reward = v.createGachaSpinsReward(2),
				Chance = 25,
				Cost = 2500,
				MaxPurchases = 2
			},
			Item19 = {
				Reward = v.createGachaSpinsReward(4),
				Chance = 25,
				Cost = 5000,
				MaxPurchases = 1
			}
		},
		{
			Item20 = {
				Reward = v.createSeasonPassCurrencyReward(200),
				Chance = 40,
				Cost = 100,
				MaxPurchases = 2
			},
			Item21 = {
				Reward = v.createSeasonPassCurrencyReward(200),
				Chance = 40,
				Cost = 1000,
				MaxPurchases = 2
			},
			Item22 = {
				Reward = v.createClanPointsReward(100, "rbxassetid://15636248286"),
				Chance = 20,
				Cost = 750,
				MaxPurchases = 1
			}
		},
		{
			Item23 = {
				Reward = v.createAbilityFreeTrialReward("Titan Blade", 1800),
				Chance = 20,
				Cost = 1500,
				MaxPurchases = 1
			},
			Item24 = {
				Reward = v.createAbilityFreeTrialReward("Dribble", 1800),
				Chance = 20,
				Cost = 2500,
				MaxPurchases = 1
			},
			Item25 = {
				Reward = v.createAbilityFreeTrialReward("Infinity", 1800),
				Chance = 20,
				Cost = 2500,
				MaxPurchases = 1
			},
			Item26 = {
				Reward = v.createAbilityFreeTrialReward("Singularity", 1800),
				Chance = 20,
				Cost = 5000,
				MaxPurchases = 1
			},
			Item27 = {
				Reward = v.createAbilityFreeTrialReward("Slash of Duality", 1800),
				Chance = 7,
				Cost = 10000,
				MaxPurchases = 1
			},
			Item28 = {
				Reward = v.createAbilityFreeTrialReward("Time Hole", 1800),
				Chance = 7,
				Cost = 10000,
				MaxPurchases = 1
			},
			Item32 = {
				Reward = v.createAbilityFreeTrialReward("Slashes of Fury", 1800),
				Chance = 6,
				Cost = 15000,
				MaxPurchases = 1
			}
		},
		{
			Item29 = {
				Reward = v.createMerchantCrate("Robux"),
				Description = "Contains exclusive limited items including swords, emotes, and explosion",
				Chance = 45,
				Cost = 399,
				Currency = "Robux",
				ProductId = 1795769492,
				GiftName = "RobuxMerchantCrate",
				MaxPurchases = 100000,
				InitialStock = 3000,
				GloballyLimitedStock = true,
				LimitedStockKey = "Merchant Crate",
				InitialStockFFlag = "MerchantCrateStock",
				HasPaidRandomItems = true,
				MaxPurchaseTime = 21600
			},
			Item30 = {
				Reward = v.createSwordReward("Mummy's Curse"),
				Description = "A legendary scythe wrapped in glowing blue bandages.",
				Chance = 15,
				Cost = 50000,
				MaxPurchases = 1,
				InitialStock = 10,
				GloballyLimitedStock = true,
				LimitedStockKey = "Merchant Sword",
				InitialStockFFlag = "MerchantSwordStock",
				GuaranteeStock = true,
				MaxPurchaseTime = 2700
			},
			Item31 = {
				Reward = v.createMerchantCrate("Coin"),
				Description = "Contains unique items including swords, emotes, explosions",
				Chance = 40,
				Cost = 5000,
				MaxPurchases = 1,
				HasPaidRandomItems = true
			}
		}
	},
	DefaultNPCSword = "Headless Horror"
}

for k, item in MerchantShopData.Items do
	local total = 0

	for k2, v3 in item do
		v3.ItemID = k2
		total += v3.Chance
	end

	if total ~= 100 and RunService:IsStudio() then
		warn((`Total odds for Merchant Shop Slot #{k} does not add up to 100% ({total}%)`))
	end
end

return MerchantShopData