local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = v2.isTestGame() or RunService:IsStudio()
require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v4 = require3(ReplicatedStorage2.Common.RewardInfo)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v6 = require3(ReplicatedStorage2.Shared.EmoteIds)
local v7 = nil
local LootboxData = {
	ActiveGacha = {
		Name = "SoccerGacha",
		Gui = "SoccerGacha"
	}
}
local gachaEvents = {
	SoccerGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2026, 7, 11, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 3606732989,
		OneSpinProductID = 3606732991,
		TenSpinsProductID = 3606732996,
		FiftySpinsProductID = 3606733002,
		TwoHundredFiftySpinsProductID = 3606733009,
		GiftTenSpinsProductID = 3606732999,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Big_Reward_1 = 1,
			Big_Reward_2 = 1,
			Big_Reward_3 = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "SoccerGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Prismshard_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Prismshard_Blade",
				PittyAmount = 500
			},
			{
				RewardKey = "Void_Eyes",
				PittyAmount = 1000
			},
			{
				RewardKey = "Void_Eyes_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		SpecialBigRewardsData = {
			USA = {
				{
					Reward = v4.createEmoteReward("Emote1237"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createExplosionReward("USA Explosion"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("USA Football"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			Germany = {
				{
					Reward = v4.createEmoteReward("Emote1238"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createExplosionReward("Germany Explosion"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("Germany Football"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			France = {
				{
					Reward = v4.createEmoteReward("Emote1240"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createExplosionReward("France Explosion"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("France Football"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			England = {
				{
					Reward = v4.createEmoteReward("Emote1236"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createExplosionReward("England Explosion"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("England Football"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			Brazil = {
				{
					Reward = v4.createEmoteReward("Emote1239"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createExplosionReward("Brazil Explosion"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("Brazil Football"),
					Chance = 0.3,
					Pitty = 400
				}
			}
		},
		ChancesFFlag = "VoidGachaChances",
		BaseItems = {
			Big_Reward_1 = {
				Rarity = "Rare",
				RewardKey = "Big_Reward_1",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Big_Reward_2 = {
				Rarity = "Rare",
				RewardKey = "Big_Reward_2",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Big_Reward_3 = {
				Rarity = "Rare",
				RewardKey = "Big_Reward_3",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Sunbeam Saber",
				ImageId = v5:GetSwordIcon("Sunbeam Saber") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 18,
				SimpleReward = {
					Sword = "Sunbeam Saber"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "World Cup Spark",
				ImageId = v5:GetSwordIcon("World Cup Spark") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 18,
				SimpleReward = {
					Sword = "World Cup Spark"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Singularity Shockwave",
				ImageId = v5:GetExplosionIcon("Singularity Shockwave") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Explosion = "Singularity Shockwave"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Knee Slide",
				ImageId = v5:GetEmoteIcon("Knee Slide") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Emote = "Emote1241"
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Celebratory Dance",
				ImageId = v5:GetEmoteIcon("Celebratory Dance") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Emote = "Emote738"
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 11.95,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	OwlGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 10, 11, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 3412351764,
		OneSpinProductID = 3412351767,
		TenSpinsProductID = 3412351768,
		FiftySpinsProductID = 3412351761,
		TwoHundredFiftySpinsProductID = 3412351760,
		GiftTenSpinsProductID = 3412351762,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Kitsune_Blade = 1,
			Dual_Kitsune_Blade = 1,
			Kitsune_Pet = 1,
			Kitsune_Pet_Finisher = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "OwlGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Kitsune_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Kitsune_Blade",
				PittyAmount = 500
			},
			{
				RewardKey = "Kitsune_Pet",
				PittyAmount = 1000
			},
			{
				RewardKey = "Kitsune_Pet_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = {
			"Kitsune_Blade",
			"Dual_Kitsune_Blade",
			"Kitsune_Pet",
			"Kitsune_Pet_Finisher"
		},
		PhysicalBigRewardData = {
			v4.createSwordReward("Lumen Petal"),
			v4.createSwordReward("Dual Lumen Petal"),
			v4.createSwordReward("Eclipse Warden"),
			(v4.createFinisherReward("Eclipse Warden"))
		},
		ChancesFFlag = "OwlGachaChances",
		Items = {
			Kitsune_Blade = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Blade",
				DisplayName = "Lumen Petal",
				ImageId = v5:GetSwordIcon("Lumen Petal") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Lumen Petal"
				}
			},
			Dual_Kitsune_Blade = {
				Rarity = "Rare",
				RewardKey = "Dual_Kitsune_Blade",
				DisplayName = "Dual Lumen Petal",
				ImageId = v5:GetSwordIcon("Dual Lumen Petal") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.25,
				SimpleReward = {
					Sword = "Dual Lumen Petal"
				}
			},
			Kitsune_Pet = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Pet",
				DisplayName = "Eclipse Warden",
				ImageId = v5:GetSwordIcon("Eclipse Warden") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.15,
				SimpleReward = {
					Sword = "Eclipse Warden"
				}
			},
			Kitsune_Pet_Finisher = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Pet_Finisher",
				DisplayName = "Eclipse Warden Finisher",
				ImageId = v5:GetFinisherIcon("Eclipse Warden") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.07,
				SimpleReward = {
					Finisher = "Eclipse Warden"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Solbane Edge",
				ImageId = v5:GetSwordIcon("Solbane Edge") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 20.5,
				SimpleReward = {
					Sword = "Solbane Edge"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Voidflare Blade",
				ImageId = v5:GetSwordIcon("Voidflare Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 20,
				SimpleReward = {
					Sword = "Voidflare Blade"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Dreadfang Pike",
				ImageId = v5:GetSwordIcon("Dreadfang Pike") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Dreadfang Pike"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Abysspiercer",
				ImageId = v5:GetSwordIcon("Abysspiercer") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Abysspiercer"
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Frostreaver",
				ImageId = v5:GetSwordIcon("Frostreaver") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Sword = "Frostreaver"
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 8,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	BlossomGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 8, 16, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 3344463132,
		OneSpinProductID = 3344463137,
		TenSpinsProductID = 3344463140,
		FiftySpinsProductID = 3344463146,
		TwoHundredFiftySpinsProductID = 3344463139,
		GiftTenSpinsProductID = 3344463143,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Kitsune_Blade = 1,
			Dual_Kitsune_Blade = 1,
			Kitsune_Pet = 1,
			Kitsune_Pet_Finisher = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "BlossomGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Kitsune_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Kitsune_Blade",
				PittyAmount = 500
			},
			{
				RewardKey = "Kitsune_Pet",
				PittyAmount = 1000
			},
			{
				RewardKey = "Kitsune_Pet_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = {
			"Kitsune_Blade",
			"Dual_Kitsune_Blade",
			"Kitsune_Pet",
			"Kitsune_Pet_Finisher"
		},
		PhysicalBigRewardData = {
			v4.createSwordReward("Flower Katana"),
			v4.createSwordReward("Dual Flower Katana"),
			v4.createSwordReward("Blossom Dragon"),
			(v4.createFinisherReward("Blossom Dragon"))
		},
		ChancesFFlag = "BlossomGachaChances",
		Items = {
			Kitsune_Blade = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Blade",
				DisplayName = "Flower Katana",
				ImageId = v5:GetSwordIcon("Flower Katana") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Flower Katana"
				}
			},
			Dual_Kitsune_Blade = {
				Rarity = "Rare",
				RewardKey = "Dual_Kitsune_Blade",
				DisplayName = "Dual Flower Katana",
				ImageId = v5:GetSwordIcon("Dual Flower Katana") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.25,
				SimpleReward = {
					Sword = "Dual Flower Katana"
				}
			},
			Kitsune_Pet = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Pet",
				DisplayName = "Blossom Dragon",
				ImageId = v5:GetSwordIcon("Blossom Dragon") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.15,
				SimpleReward = {
					Sword = "Blossom Dragon"
				}
			},
			Kitsune_Pet_Finisher = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Pet_Finisher",
				DisplayName = "Blossom Dragon Finisher",
				ImageId = v5:GetFinisherIcon("Blossom Dragon") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.07,
				SimpleReward = {
					Finisher = "Blossom Dragon"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Carrion Carver",
				ImageId = v5:GetSwordIcon("Carrion Carver") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 20.5,
				SimpleReward = {
					Sword = "Carrion Carver"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Necroshard Blade",
				ImageId = v5:GetSwordIcon("Necroshard Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 20,
				SimpleReward = {
					Sword = "Necroshard Blade"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Viral Edge",
				ImageId = v5:GetSwordIcon("Viral Edge") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Viral Edge"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Aura Farming",
				ImageId = v5:GetEmoteIcon("Aura Farming") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Emote = "Emote993"
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "King and Queen",
				ImageId = v5:GetEmoteIcon("King and Queen") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Emote = "Emote994"
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 8,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	ChromeGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 6, 28, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 3305412326,
		OneSpinProductID = 3305412334,
		TenSpinsProductID = 3305412331,
		FiftySpinsProductID = 3305412327,
		TwoHundredFiftySpinsProductID = 3305412332,
		GiftTenSpinsProductID = 3305412328,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Card_Big_Reward_1 = 1,
			Card_Big_Reward_2 = 1,
			Card_Big_Reward_3 = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "VoidGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Prismshard_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Prismshard_Blade",
				PittyAmount = 500
			},
			{
				RewardKey = "Void_Eyes",
				PittyAmount = 1000
			},
			{
				RewardKey = "Void_Eyes_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		CardsBigRewardsData = {
			Frost = {
				{
					Reward = v4.createSwordReward("Frost Kunai"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createSwordReward("Dual Frost Kunai"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("Frosted Cards"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			Lightning = {
				{
					Reward = v4.createSwordReward("Lightning Kunai"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createSwordReward("Dual Lightning Kunai"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("Lightning Cards"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			Nature = {
				{
					Reward = v4.createSwordReward("Nature Kunai"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createSwordReward("Dual Nature Kunai"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("Nature Cards"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			Shadow = {
				{
					Reward = v4.createSwordReward("Shadow Kunai"),
					Chance = 1.25,
					Pitty = 100
				},
				{
					Reward = v4.createSwordReward("Dual Shadow Kunai"),
					Chance = 0.5,
					Pitty = 250
				},
				{
					Reward = v4.createSwordReward("Shadow Cards"),
					Chance = 0.3,
					Pitty = 400
				}
			},
			Chroma = {
				{
					Reward = v4.createSwordReward("Chroma Cards"),
					Chance = 0.25,
					Pitty = 500
				},
				{
					Reward = v4.createFinisherReward("Chroma Cards"),
					Chance = 0.15,
					Pitty = 750
				}
			}
		},
		ChancesFFlag = "VoidGachaChances",
		BaseCardsItems = {
			Card_Big_Reward_1 = {
				Rarity = "Rare",
				RewardKey = "Card_Big_Reward_1",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Card_Big_Reward_2 = {
				Rarity = "Rare",
				RewardKey = "Card_Big_Reward_2",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Card_Big_Reward_3 = {
				Rarity = "Rare",
				RewardKey = "Card_Big_Reward_3",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Dusk Slicer",
				ImageId = v5:GetSwordIcon("Dusk Slicer") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 18,
				SimpleReward = {
					Sword = "Dusk Slicer"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Stormlash",
				ImageId = v5:GetSwordIcon("Stormlash") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 18,
				SimpleReward = {
					Sword = "Stormlash"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Blazebite",
				ImageId = v5:GetSwordIcon("Blazebite") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Blazebite"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Surge Step",
				ImageId = v5:GetEmoteIcon("Surge Step") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Surge Step"
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Lunar Vow",
				ImageId = v5:GetSwordIcon("Lunar Vow") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Sword = "Lunar Vow"
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 11.95,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		},
		ChromaItems = {
			Card_Big_Reward_1 = {
				Rarity = "Rare",
				RewardKey = "Card_Big_Reward_1",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Card_Big_Reward_2 = {
				Rarity = "Rare",
				RewardKey = "Card_Big_Reward_2",
				ImageId = v5:GetIcon("DEFAULT_MISSING"),
				Chance = -1,
				SimpleReward = {
					Sword = "IGNORE_THIS_WILL_BE_REPLACED_BY_CODE"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Dusk Slicer",
				ImageId = v5:GetSwordIcon("Dusk Slicer") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 18,
				SimpleReward = {
					Sword = "Dusk Slicer"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Stormlash",
				ImageId = v5:GetSwordIcon("Stormlash") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 18,
				SimpleReward = {
					Sword = "Stormlash"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Blazebite",
				ImageId = v5:GetSwordIcon("Blazebite") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Blazebite"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Surge Step",
				ImageId = v5:GetEmoteIcon("Surge Step") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Surge Step"
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Lunar Vow",
				ImageId = v5:GetSwordIcon("Lunar Vow") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Sword = "Lunar Vow"
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 15,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 15.36,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	VoidGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 5, 10, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 3272742470,
		OneSpinProductID = 3272742471,
		TenSpinsProductID = 3272742469,
		FiftySpinsProductID = 3272742466,
		TwoHundredFiftySpinsProductID = 3272742472,
		GiftTenSpinsProductID = 3272742468,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Prismshard_Blade = 1,
			Dual_Prismshard_Blade = 1,
			Void_Eyes = 1,
			Void_Eyes_Finisher = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "VoidGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Prismshard_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Prismshard_Blade",
				PittyAmount = 500
			},
			{
				RewardKey = "Void_Eyes",
				PittyAmount = 1000
			},
			{
				RewardKey = "Void_Eyes_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = {
			"Prismshard_Blade",
			"Dual_Prismshard_Blade",
			"Void_Eyes",
			"Void_Eyes_Finisher"
		},
		PhysicalBigRewardData = {
			v4.createSwordReward("Prismshard Blade"),
			v4.createSwordReward("Dual Prismshard Blade"),
			v4.createSwordReward("Void Eyes"),
			(v4.createFinisherReward("Void Eyes"))
		},
		ChancesFFlag = "VoidGachaChances",
		Items = {
			Prismshard_Blade = {
				Rarity = "Rare",
				RewardKey = "Prismshard_Blade",
				DisplayName = "Prismshard Blade",
				ImageId = v5:GetSwordIcon("Prismshard Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Prismshard Blade"
				}
			},
			Dual_Prismshard_Blade = {
				Rarity = "Rare",
				RewardKey = "Dual_Prismshard_Blade",
				DisplayName = "Dual Prismshard Blade",
				ImageId = v5:GetSwordIcon("Dual Prismshard Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.25,
				SimpleReward = {
					Sword = "Dual Prismshard Blade"
				}
			},
			Void_Eyes = {
				Rarity = "Rare",
				RewardKey = "Void_Eyes",
				DisplayName = "Void Eyes",
				ImageId = v5:GetSwordIcon("Void Eyes") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.15,
				SimpleReward = {
					Sword = "Void Eyes"
				}
			},
			Void_Eyes_Finisher = {
				Rarity = "Rare",
				RewardKey = "Void_Eyes_Finisher",
				DisplayName = "Void Eyes Finisher",
				ImageId = v5:GetFinisherIcon("Void Eyes") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.1,
				SimpleReward = {
					Finisher = "Void Eyes"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Null Fang",
				ImageId = v5:GetSwordIcon("Null Fang") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 20.5,
				SimpleReward = {
					Sword = "Null Fang"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Fracture Blade",
				ImageId = v5:GetSwordIcon("Fracture Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 20,
				SimpleReward = {
					Sword = "Fracture Blade"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Voidborn",
				ImageId = v5:GetSwordIcon("Voidborn") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Voidborn"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Null Dagger",
				ImageId = v5:GetSwordIcon("Null Dagger") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Null Dagger"
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Distorted Longsword",
				ImageId = v5:GetSwordIcon("Distorted Longsword") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Sword = "Distorted Longsword"
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 8,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	BloomGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 4, 5, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 3245222353,
		OneSpinProductID = 3245222358,
		TenSpinsProductID = 3245222359,
		FiftySpinsProductID = 3245222357,
		TwoHundredFiftySpinsProductID = 3245222362,
		GiftTenSpinsProductID = 3245222354,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Bloom_Katana = 1,
			Dual_Bloom_Katana = 1,
			Shuriken = 1,
			Shuriken_Finisher = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "BloomGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Bloom_Katana",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Bloom_Katana",
				PittyAmount = 500
			},
			{
				RewardKey = "Shuriken",
				PittyAmount = 1000
			},
			{
				RewardKey = "Shuriken_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = {
			"Bloom_Katana",
			"Dual_Bloom_Katana",
			"Shuriken",
			"Shuriken_Finisher"
		},
		PhysicalBigRewardData = {
			v4.createSwordReward("Bloom Katana"),
			v4.createSwordReward("Dual Bloom Katana"),
			v4.createSwordReward("Bloom Shuriken"),
			(v4.createFinisherReward("Bloom Shuriken"))
		},
		ChancesFFlag = "BloomGachaChances",
		Items = {
			Bloom_Katana = {
				Rarity = "Rare",
				RewardKey = "Bloom_Katana",
				DisplayName = "Bloom Katana",
				ImageId = v5:GetSwordIcon("Bloom Katana") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Bloom Katana"
				}
			},
			Dual_Bloom_Katana = {
				Rarity = "Rare",
				RewardKey = "Dual_Bloom_Katana",
				DisplayName = "Dual Bloom Katana",
				ImageId = v5:GetSwordIcon("Dual Bloom Katana") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.25,
				SimpleReward = {
					Sword = "Dual Bloom Katana"
				}
			},
			Shuriken = {
				Rarity = "Rare",
				RewardKey = "Shuriken",
				DisplayName = "Shuriken",
				ImageId = v5:GetSwordIcon("Bloom Shuriken") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.1,
				SimpleReward = {
					Sword = "Bloom Shuriken"
				}
			},
			Shuriken_Finisher = {
				Rarity = "Rare",
				RewardKey = "Shuriken_Finisher",
				DisplayName = "Shuriken Finisher",
				ImageId = v5:GetFinisherIcon("Bloom Shuriken") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.07,
				SimpleReward = {
					Finisher = "Bloom Shuriken"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Spiritbloom Dagger",
				ImageId = v5:GetSwordIcon("Spiritbloom Dagger") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 21,
				SimpleReward = {
					Sword = "Spiritbloom Dagger"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Verdant Bloom Saber",
				ImageId = v5:GetSwordIcon("Verdant Bloom Saber") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 21,
				SimpleReward = {
					Sword = "Verdant Bloom Saber"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Moonlit Blossom Blade",
				ImageId = v5:GetSwordIcon("Moonlit Blossom Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Moonlit Blossom Blade"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Keep it Clean",
				ImageId = v5:GetEmoteIcon("Keep it Clean") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Emote = v6.EmotesToIds["Keep it Clean"]
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "T-Tornado (Duo Emote)",
				ImageId = v5:GetEmoteIcon("T-Tornado") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Emote = v6.EmotesToIds["T-Tornado"]
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 8,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	KitsuneGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 3, 1, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 2916582857,
		OneSpinProductID = 2916582855,
		TenSpinsProductID = 2916582862,
		FiftySpinsProductID = 2916582863,
		TwoHundredFiftySpinsProductID = 2916582860,
		GiftTenSpinsProductID = 2916582859,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Kitsune_Blade = 1,
			Dual_Kitsune_Blade = 1,
			Kitsune_Pet = 1,
			Kitsune_Pet_Finisher = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "KitsuneGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Kitsune_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Dual_Kitsune_Blade",
				PittyAmount = 500
			},
			{
				RewardKey = "Kitsune_Pet",
				PittyAmount = 1000
			},
			{
				RewardKey = "Kitsune_Pet_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = {
			"Kitsune_Blade",
			"Dual_Kitsune_Blade",
			"Kitsune_Pet",
			"Kitsune_Pet_Finisher"
		},
		PhysicalBigRewardData = {
			v4.createSwordReward("Kitsune Blade"),
			v4.createSwordReward("Dual Kitsune Blade"),
			v4.createSwordReward("Kitsune"),
			(v4.createFinisherReward("Kitsune"))
		},
		ChancesFFlag = "KitsuneGachaChances",
		Items = {
			Kitsune_Blade = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Blade",
				DisplayName = "Kitsune Blade",
				ImageId = v5:GetSwordIcon("Kitsune Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Kitsune Blade"
				}
			},
			Dual_Kitsune_Blade = {
				Rarity = "Rare",
				RewardKey = "Dual_Kitsune_Blade",
				DisplayName = "Dual Kitsune Blade",
				ImageId = v5:GetSwordIcon("Dual Kitsune Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.25,
				SimpleReward = {
					Sword = "Dual Kitsune Blade"
				}
			},
			Kitsune_Pet = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Pet",
				DisplayName = "Kitsune Pet",
				ImageId = v5:GetSwordIcon("Kitsune") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.1,
				SimpleReward = {
					Sword = "Kitsune"
				}
			},
			Kitsune_Pet_Finisher = {
				Rarity = "Rare",
				RewardKey = "Kitsune_Pet_Finisher",
				DisplayName = "Kitsune Pet Finisher",
				ImageId = v5:GetFinisherIcon("Kitsune") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.07,
				SimpleReward = {
					Finisher = "Kitsune"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Foxfang Dagger",
				ImageId = v5:GetSwordIcon("Foxfang Dagger") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 21,
				SimpleReward = {
					Sword = "Foxfang Dagger"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Spiritbound Katana",
				ImageId = v5:GetSwordIcon("Spiritbound Katana") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 21,
				SimpleReward = {
					Sword = "Spiritbound Katana"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Ethereal Kitsune Blade",
				ImageId = v5:GetSwordIcon("Ethereal Kitsune Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Ethereal Kitsune Blade"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Playful Pounce",
				ImageId = v5:GetEmoteIcon("Playful Pounce") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Emote = v6.EmotesToIds["Playful Pounce"]
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Foxfire Ritual (Duo Emote)",
				ImageId = v5:GetEmoteIcon("Foxfire Ritual") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Emote = v6.EmotesToIds["Foxfire Ritual"]
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 8,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	ArachnidGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 2, 1, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 2699508065,
		OneSpinProductID = 2699508064,
		TenSpinsProductID = 2699508067,
		FiftySpinsProductID = 2700885176,
		TwoHundredFiftySpinsProductID = 2700885177,
		GiftTenSpinsProductID = 2699508066,
		EventCurrencyPath = "Fireworks",
		MaxEventCurrencySpins = 2,
		EventCurrencySpinPrice = 100,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Arachnoblade = 1,
			Void_Weaver = 1,
			Void_Weaver_Finisher = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "ArachnidGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Arachnoblade",
				PittyAmount = 100
			},
			{
				RewardKey = "Void_Weaver",
				PittyAmount = 750
			},
			{
				RewardKey = "Void_Weaver_Finisher",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = { "Arachnoblade", "Void_Weaver", "Void_Weaver_Finisher" },
		PhysicalBigRewardData = {
			v4.createSwordReward("Arachnoblade"),
			v4.createSwordReward("Void Weaver"),
			(v4.createFinisherReward("Void Weaver"))
		},
		ChancesFFlag = "ArachnidGachaChances",
		Items = {
			Arachnoblade = {
				Rarity = "Rare",
				RewardKey = "Arachnoblade",
				DisplayName = "Arachnoblade",
				ImageId = v5:GetSwordIcon("Arachnoblade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Arachnoblade"
				}
			},
			Void_Weaver = {
				Rarity = "Rare",
				RewardKey = "Void_Weaver",
				DisplayName = "Void Weaver",
				ImageId = v5:GetSwordIcon("Void Weaver") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.25,
				SimpleReward = {
					Sword = "Void Weaver"
				}
			},
			Void_Weaver_Finisher = {
				Rarity = "Rare",
				RewardKey = "Void_Weaver_Finisher",
				DisplayName = "Void Weaver Finisher",
				ImageId = v5:GetFinisherIcon("Void Weaver") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.1,
				SimpleReward = {
					Finisher = "Void Weaver"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Silken Fang",
				ImageId = v5:GetSwordIcon("Silken Fang") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 21,
				SimpleReward = {
					Sword = "Silken Fang"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Venom Edge",
				ImageId = v5:GetSwordIcon("Venom Edge") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 21,
				SimpleReward = {
					Sword = "Venom Edge"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Voidweaver's Fang",
				ImageId = v5:GetSwordIcon("Voidweaver's Fang") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Sword = "Voidweaver's Fang"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Spider Skitter",
				ImageId = v5:GetEmoteIcon("Spider Skitter") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Emote = v6.EmotesToIds["Spider Skitter"]
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Webbed (Duo Emote)",
				ImageId = v5:GetEmoteIcon("Webbed") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Emote = v6.EmotesToIds.Webbed
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			},
			WheelSpin = {
				Rarity = "Rare",
				RewardKey = "WheelSpin",
				DisplayName = "Wheel Spin",
				Chance = 8,
				ImageId = "rbxassetid://15051770001",
				SimpleReward = {
					Rolls = 1
				}
			}
		}
	},
	ReindeerGacha = {
		CrateSpinRequirement = 100,
		EventEndTimeStamp = DateTime.fromUniversalTime(2025, 1, 2, 17),
		FirstOfTheDayPrice = "49",
		OneSpinPrice = "99",
		TenSpinPrice = "799",
		FirstOfTheDayOneSpin = 2672143991,
		OneSpinProductID = 2672143993,
		TenSpinsProductID = 2672143992,
		GiftTenSpinsProductID = 2672143994,
		EventCurrencyPath = "ChristmasEvent.CandyCanes",
		MaxEventCurrencySpins = 2,
		EventCurrencySpinPrice = 100,
		EliminationsToGetSpin = 7,
		MaxEliminationSpinPerDay = 2,
		FrameAlliases = {
			Reindeer_Blade = 1,
			Reindeer = 1,
			Reindeer_Mount = 1,
			Low_Tier_Sword = 2,
			Mid_Tier_Sword = 3,
			High_Tier_Sword = 4,
			Low_Tier_Emote = 5,
			Duo_Emote = 6,
			ThreeHundredCoins = 7,
			FiveHundredCoins = 8
		},
		PityRewardBucketFFlag = "ReindeerGachaPity",
		PityRewardBucket = {
			{
				RewardKey = "Reindeer_Blade",
				PittyAmount = 100
			},
			{
				RewardKey = "Reindeer",
				PittyAmount = 750
			},
			{
				RewardKey = "Reindeer_Mount",
				PittyAmount = 1500
			}
		},
		RollTimeOut = 10,
		BigRewardData = { "Reindeer_Blade", "Reindeer", "Reindeer_Mount" },
		PhysicalBigRewardData = {
			v4.createSwordReward("Reindeer Blade"),
			v4.createSwordReward("Reindeer"),
			(v4.createSwordAccessoryReward("Reindeer"))
		},
		ChancesFFlag = "ReindeerGachaChances",
		Items = {
			Reindeer_Blade = {
				Rarity = "Rare",
				RewardKey = "Reindeer_Blade",
				DisplayName = "Reindeer Blade",
				ImageId = v5:GetSwordIcon("Reindeer Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 1,
				SimpleReward = {
					Sword = "Reindeer Blade"
				}
			},
			Reindeer = {
				Rarity = "Rare",
				RewardKey = "Reindeer",
				DisplayName = "Reindeer",
				ImageId = v5:GetSwordIcon("Reindeer") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.15,
				SimpleReward = {
					Sword = "Reindeer"
				}
			},
			Reindeer_Mount = {
				Rarity = "Rare",
				RewardKey = "Reindeer_Mount",
				DisplayName = "Reindeer Mount",
				ImageId = v5:GetSwordAccessoryIcon("Reindeer") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 0.07,
				SimpleReward = {
					SwordAccessory = "Reindeer"
				}
			},
			Low_Tier_Sword = {
				Rarity = "Common",
				RewardKey = "Low_Tier_Sword",
				DisplayName = "Frosted Antler",
				ImageId = v5:GetSwordIcon("Frosted Antler") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 25,
				SimpleReward = {
					Sword = "Frosted Antler"
				}
			},
			Mid_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "Mid_Tier_Sword",
				DisplayName = "Antler Blade",
				ImageId = v5:GetSwordIcon("Antler Blade") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 25,
				SimpleReward = {
					Sword = "Antler Blade"
				}
			},
			High_Tier_Sword = {
				Rarity = "Limited",
				RewardKey = "High_Tier_Sword",
				DisplayName = "Aurora Antlers",
				ImageId = v5:GetSwordIcon("Aurora Antlers") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 8.65,
				SimpleReward = {
					Sword = "Aurora Antlers"
				}
			},
			Low_Tier_Emote = {
				Rarity = "Limited",
				RewardKey = "Low_Tier_Emote",
				DisplayName = "Rudolph Stomp",
				ImageId = v5:GetEmoteIcon("Rudolph Stomp") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 10,
				SimpleReward = {
					Emote = v6.EmotesToIds["Rudolph Stomp"]
				}
			},
			Duo_Emote = {
				Rarity = "Limited",
				RewardKey = "Duo_Emote",
				DisplayName = "Polar Opposites (Duo Emote)",
				ImageId = v5:GetEmoteIcon("Polar Opposites") or v5:GetIcon("DEFAULT_MISSING"),
				Chance = 3,
				SimpleReward = {
					Emote = v6.EmotesToIds["Polar Opposites"]
				}
			},
			ThreeHundredCoins = {
				Rarity = "Common",
				RewardKey = "ThreeHundredCoins",
				DisplayName = "300 Coins",
				Chance = 17,
				ImageId = "rbxassetid://15038384377",
				SimpleReward = {
					Credits = 300
				}
			},
			FiveHundredCoins = {
				Rarity = "Common",
				RewardKey = "FiveHundredCoins",
				DisplayName = "500 Coins",
				Chance = 10,
				ImageId = "rbxassetid://14713794582",
				SimpleReward = {
					Credits = 500
				}
			}
		}
	},
	EternalNightGacha = 0,
	JackolanternGacha = 0,
	BorealisGacha = 0,
	CyberGacha = 0,
	ChromaGacha = 0,
	IceDragonGacha = 0,
	FireDragonGacha = 0,
	MatrixGacha = 0,
	DevilKatanaGacha = 0,
	FrogGacha = 0,
	SciFiGacha = 0,
	NebulaGacha = 0,
	SciFiMysteryCrateVFX = 0,
	ClanSwordCrate = 0,
	ClanMagicalCrate = 0
}
local eventEndTimeStamp

if v2.isTestGame() then
	eventEndTimeStamp = DateTime.now()
else
	eventEndTimeStamp = DateTime.fromUniversalTime(2024, 11, 30, 16)
end

gachaEvents.EternalNightGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = eventEndTimeStamp,
	FirstOfTheDayPrice = "49",
	OneSpinPrice = "99",
	TenSpinPrice = "799",
	FirstOfTheDayOneSpin = 2657342508,
	OneSpinProductID = 2657342509,
	TenSpinsProductID = 2657342510,
	GiftTenSpinsProductID = 2657342511,
	EliminationsToGetSpin = 7,
	MaxEliminationSpinPerDay = 5,
	FrameAlliases = {
		Eternal_Staff = 1,
		OP_Eternal_Scythe = 1,
		OP_Eternal_Finisher = 1,
		Low_Tier_Sword = 2,
		Mid_Tier_Sword = 3,
		High_Tier_Sword = 4,
		High_Tier_Emote = 5,
		Duo_Emote = 6,
		ThreeHundredCoins = 7,
		FiveHundredCoins = 8
	},
	PityRewardBucketFFlag = "EternalNightGachaPity",
	PityRewardBucket = {
		{
			RewardKey = "Eternal_Staff",
			PittyAmount = 100
		},
		{
			RewardKey = "OP_Eternal_Scythe",
			PittyAmount = 400
		},
		{
			RewardKey = "OP_Eternal_Finisher",
			PittyAmount = 1000
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Eternal_Staff", "OP_Eternal_Scythe", "OP_Eternal_Finisher" },
	PhysicalBigRewardData = {
		v4.createSwordReward("Base Sword"),
		v4.createSwordReward("Jackolantern"),
		(v4.createSwordAccessoryReward("Jackolantern"))
	},
	ChancesFFlag = "EternalNightGachaChances",
	Items = {
		Eternal_Staff = {
			Rarity = "Rare",
			RewardKey = "Eternal_Staff",
			DisplayName = "Eternal (Staff)",
			ImageId = "rbxassetid://128656229773524",
			Chance = 1,
			SimpleReward = {
				Sword = "Eternal Staff"
			}
		},
		OP_Eternal_Scythe = {
			Rarity = "Rare",
			RewardKey = "OP_Eternal_Scythe",
			DisplayName = "Eternal (Scythe)",
			ImageId = "rbxassetid://99933294440055",
			Chance = 0.25,
			SimpleReward = {
				Sword = "Eternal Scythe"
			}
		},
		OP_Eternal_Finisher = {
			Rarity = "Rare",
			RewardKey = "OP_Eternal_Finisher",
			DisplayName = "Eternal (Finisher)",
			ImageId = "rbxassetid://122718573812212",
			Chance = 0.1,
			SimpleReward = {
				Finisher = "Eternal Scythe"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Frosted Dagger",
			ImageId = "rbxassetid://136714638541746",
			Chance = 25,
			SimpleReward = {
				Sword = "Frosted Dagger"
			}
		},
		Mid_Tier_Sword = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Sword",
			DisplayName = "Icebound Saber",
			ImageId = "rbxassetid://128871865730557",
			Chance = 25,
			SimpleReward = {
				Sword = "Icebound Saber"
			}
		},
		High_Tier_Sword = {
			Rarity = "Limited",
			RewardKey = "High_Tier_Sword",
			DisplayName = "Shivering Strike",
			ImageId = "rbxassetid://82435021210508",
			Chance = 10,
			SimpleReward = {
				Sword = "Shivering Strike"
			}
		},
		High_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "High_Tier_Emote",
			DisplayName = "Frozen Pose",
			ImageId = "rbxassetid://119210232776868",
			Chance = 10,
			SimpleReward = {
				Emote = "Emote637"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Friendship Dance (Duo Emote)",
			ImageId = "rbxassetid://127813637873834",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote633"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		}
	}
}
gachaEvents.JackolanternGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 11, 2, 16),
	FirstOfTheDayPrice = "49",
	OneSpinPrice = "99",
	TenSpinPrice = "799",
	FirstOfTheDayOneSpin = 2257212773,
	OneSpinProductID = 2257212761,
	TenSpinsProductID = 2257212779,
	GiftTenSpinsProductID = 2257212764,
	MaxEventCurrencySpins = 2,
	EventCurrencySpinPrice = 100,
	FrameAlliases = {
		Hallow_Blaster = 1,
		OP_Pumpkin_Sword = 1,
		OP_Pumpkin_Finisher = 1,
		Low_Tier_Sword = 2,
		Mid_Tier_Sword = 3,
		High_Tier_Sword = 4,
		High_Tier_Emote = 5,
		Duo_Emote = 6,
		ThreeHundredCoins = 7,
		FiveHundredCoins = 8,
		WheelSpin = 9
	},
	PityRewardBucketFFlag = "JackolanternGachaPity",
	PityRewardBucket = {
		{
			RewardKey = "Hallow_Blaster",
			PittyAmount = 100
		},
		{
			RewardKey = "OP_Pumpkin_Sword",
			PittyAmount = 400
		},
		{
			RewardKey = "OP_Pumpkin_Finisher",
			PittyAmount = 1000
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Hallow_Blaster", "OP_Pumpkin_Sword", "OP_Pumpkin_Finisher" },
	PhysicalBigRewardData = {
		v4.createSwordReward("Base Sword"),
		v4.createSwordReward("Jackolantern"),
		(v4.createFinisherReward("Jackolantern"))
	},
	ChancesFFlag = "JackolanternGachaChances",
	Items = {
		Hallow_Blaster = {
			Rarity = "Rare",
			RewardKey = "Hallow_Blaster",
			DisplayName = "Hallow's Blaster",
			ImageId = "rbxassetid://107742581811611",
			Chance = 1,
			SimpleReward = {
				Sword = "Hallow's Blaster"
			}
		},
		OP_Pumpkin_Sword = {
			Rarity = "Rare",
			RewardKey = "OP_Pumpkin_Sword",
			DisplayName = "Jackolantern (Sword)",
			ImageId = "rbxassetid://119405092463529",
			Chance = 0.25,
			SimpleReward = {
				Sword = "Jackolantern"
			}
		},
		OP_Pumpkin_Finisher = {
			Rarity = "Rare",
			RewardKey = "OP_Pumpkin_Finisher",
			DisplayName = "Jackolantern (Finisher)",
			ImageId = "rbxassetid://127180495919312",
			Chance = 0.1,
			SimpleReward = {
				Finisher = "Jackolantern"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Tombcarver",
			ImageId = "rbxassetid://133832325295274",
			Chance = 21,
			SimpleReward = {
				Sword = "Tombcarver"
			}
		},
		Mid_Tier_Sword = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Sword",
			DisplayName = "Grim Saber",
			ImageId = "rbxassetid://85078909595550",
			Chance = 21,
			SimpleReward = {
				Sword = "Grim Saber"
			}
		},
		High_Tier_Sword = {
			Rarity = "Limited",
			RewardKey = "High_Tier_Sword",
			DisplayName = "Reaper's Wrath",
			ImageId = "rbxassetid://80788992516921",
			Chance = 10,
			SimpleReward = {
				Sword = "Reaper's Wrath"
			}
		},
		High_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "High_Tier_Emote",
			DisplayName = "Ghostly Step",
			ImageId = "rbxassetid://130993338514161",
			Chance = 10,
			SimpleReward = {
				Emote = "Emote583"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Cursed Pact (Duo Emote)",
			ImageId = "rbxassetid://79997428188655",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote588"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		WheelSpin = {
			Rarity = "Rare",
			RewardKey = "WheelSpin",
			DisplayName = "Wheel Spin",
			Chance = 8,
			ImageId = "rbxassetid://15051770001",
			SimpleReward = {
				Rolls = 1
			}
		}
	}
}
gachaEvents.BorealisGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 8, 31, 16),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1908075946,
	OneSpinProductID = 1908075947,
	TenSpinsProductID = 1908075950,
	GiftTenSpinsProductID = 1908075948,
	FrameAlliases = {
		Borealis_Dagger = 1,
		Borealis = 1,
		Borealis_Finisher = 1,
		Low_Tier_Sword = 2,
		Duo_Emote = 3,
		Mid_Tier_Emote = 4,
		ThreeHundredCoins = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucketFFlag = "BorealisSpinsPity",
	PityRewardBucket = {
		{
			RewardKey = "Borealis_Dagger",
			PittyAmount = 100
		},
		{
			RewardKey = "Borealis",
			PittyAmount = 500
		},
		{
			RewardKey = "Borealis_Finisher",
			PittyAmount = 750
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Borealis_Dagger", "Borealis", "Borealis_Finisher" },
	PhysicalBigRewardData = {
		v4.createSwordReward("Base Sword"),
		v4.createSwordReward("Borealis"),
		(v4.createFinisherReward("Borealis"))
	},
	ChancesFFlag = "BorealisSpinsChances",
	Items = {
		Borealis_Dagger = {
			Rarity = "Rare",
			RewardKey = "Borealis_Dagger",
			DisplayName = "Aurora Shard",
			ImageId = "rbxassetid://18977352496",
			Chance = 0.75,
			SimpleReward = {
				Sword = "Aurora Shard"
			}
		},
		Borealis = {
			Rarity = "Rare",
			RewardKey = "Borealis",
			DisplayName = "Borealis",
			ImageId = "rbxassetid://16280297683",
			Chance = 0.2,
			SimpleReward = {
				Sword = "Borealis"
			}
		},
		Borealis_Finisher = {
			Rarity = "Rare",
			RewardKey = "Borealis_Finisher",
			DisplayName = "Borealis Finisher",
			ImageId = "rbxassetid://18983046607",
			Chance = 0.13,
			SimpleReward = {
				Finisher = "Borealis"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Aurora Protector",
			ImageId = "rbxassetid://18977361446",
			Chance = 25,
			SimpleReward = {
				Sword = "Aurora Protector"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Piggyback Ride (Duo Emote)",
			ImageId = "rbxassetid://18977508466",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote491"
			}
		},
		Mid_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Emote",
			DisplayName = "Kickflip",
			ImageId = "rbxassetid://18977518286",
			Chance = 25,
			SimpleReward = {
				Emote = "Emote494"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Common",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		}
	}
}
gachaEvents.CyberGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 8, 31, 16),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1880293929,
	OneSpinProductID = 1880293928,
	TenSpinsProductID = 1880293930,
	GiftTenSpinsProductID = 1880293927,
	GiftOneCyberGacha = 1880541600,
	FrameAlliases = {
		Cyber_Sickle = 1,
		Dual_Cyber_Sickle = 1,
		Dual_Cyber_Sickle_Finisher = 1,
		Low_Tier_Sword = 2,
		Duo_Emote = 3,
		Mid_Tier_Emote = 4,
		ThreeHundredCoins = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Cyber_Sickle",
			PittyAmount = 75
		},
		{
			RewardKey = "Dual_Cyber_Sickle",
			PittyAmount = 350
		},
		{
			RewardKey = "Dual_Cyber_Sickle_Finisher",
			PittyAmount = 500
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Cyber_Sickle", "Dual_Cyber_Sickle", "Dual_Cyber_Sickle_Finisher" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Cyber Sickle"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Cyber Sickle"
		},
		{
			Path = "Finishers.Unlocked",
			Value = "Dual Cyber Sickle"
		}
	},
	Items = {
		Cyber_Sickle = {
			Rarity = "Rare",
			RewardKey = "Cyber_Sickle",
			DisplayName = "Cyber Sickle",
			ImageId = "rbxassetid://18578675819",
			Chance = 0.75,
			SimpleReward = {
				Sword = "Cyber Sickle"
			}
		},
		Dual_Cyber_Sickle = {
			Rarity = "Rare",
			RewardKey = "Dual_Cyber_Sickle",
			DisplayName = "Dual Cyber Sickle",
			ImageId = "rbxassetid://18578675506",
			Chance = 0.35,
			SimpleReward = {
				Sword = "Dual Cyber Sickle"
			}
		},
		Dual_Cyber_Sickle_Finisher = {
			Rarity = "Rare",
			RewardKey = "Dual_Cyber_Sickle_Finisher",
			DisplayName = "Dual Cyber Sickle Finisher",
			ImageId = "rbxassetid://18582475806",
			Chance = 0.15,
			SimpleReward = {
				Finisher = "Dual Cyber Sickle"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Shark Sword",
			ImageId = "rbxassetid://18576815100",
			Chance = 25.25,
			SimpleReward = {
				Sword = "Shark Sword"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Shark Attack (Duo Emote)",
			ImageId = "rbxassetid://18577274452",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote441"
			}
		},
		Mid_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Emote",
			DisplayName = "Shark Dance",
			ImageId = "rbxassetid://18577273859",
			Chance = 25,
			SimpleReward = {
				Emote = "Emote439"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Common",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		}
	}
}
gachaEvents.ChromaGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 7, 6, 16),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1852344373,
	OneSpinProductID = 1852344371,
	TenSpinsProductID = 1852344372,
	GiftTenSpinsProductID = 1852344374,
	FrameAlliases = {
		Chroma_Blaster = 1,
		Dual_Chroma_Blasters = 1,
		Dual_Chroma_Finisher = 1,
		Low_Tier_Sword = 2,
		Mid_Tier_Sword = 3,
		Duo_Emote = 4,
		Mid_Tier_Emote = 5,
		ThreeHundredCoins = 6,
		FiveHundredCoins = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Chroma_Blaster",
			PittyAmount = 75
		},
		{
			RewardKey = "Dual_Chroma_Blasters",
			PittyAmount = 350
		},
		{
			RewardKey = "Dual_Chroma_Finisher",
			PittyAmount = 500
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Chroma_Blaster", "Dual_Chroma_Blasters", "Dual_Chroma_Finisher" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Chroma Blaster"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Chroma Blasters"
		},
		{
			Path = "Finishers.Unlocked",
			Value = "Dual Chroma Blasters"
		}
	},
	Items = {
		Chroma_Blaster = {
			Rarity = "Rare",
			RewardKey = "Chroma_Blaster",
			DisplayName = "Chroma Blaster",
			ImageId = "rbxassetid://18153155803",
			Chance = 0.5,
			SimpleReward = {
				Sword = "Chroma Blaster"
			}
		},
		Dual_Chroma_Blasters = {
			Rarity = "Rare",
			RewardKey = "Dual_Chroma_Blasters",
			DisplayName = "Dual Chroma Blasters",
			ImageId = "rbxassetid://18153155352",
			Chance = 0.25,
			SimpleReward = {
				Sword = "Dual Chroma Blasters"
			}
		},
		Dual_Chroma_Finisher = {
			Rarity = "Rare",
			RewardKey = "Dual_Chroma_Finisher",
			DisplayName = "Dual Chroma Finisher",
			Chance = 0.1,
			ImageId = "rbxassetid://18158463101",
			SimpleReward = {
				Finisher = "Dual Chroma Blasters"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Chroma Fragment",
			ImageId = "rbxassetid://18139157083",
			Chance = 20,
			SimpleReward = {
				Sword = "Chroma Fragment"
			}
		},
		Mid_Tier_Sword = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Sword",
			DisplayName = "Chroma Sword",
			ImageId = "rbxassetid://18139157382",
			Chance = 15,
			SimpleReward = {
				Sword = "Chroma Sword"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Secret Handshake (Duo Emote)",
			ImageId = "rbxassetid://18138917162",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote386"
			}
		},
		Mid_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Emote",
			DisplayName = "Instigator",
			ImageId = "rbxassetid://18144594305",
			Chance = 25,
			SimpleReward = {
				Emote = "Emote387"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Common",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		}
	}
}
gachaEvents.IceDragonGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 6, 22, 16),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1844458071,
	OneSpinProductID = 1844458074,
	TenSpinsProductID = 1844458073,
	GiftTenSpinsProductID = 1844458075,
	FrameAlliases = {
		Ice_Blaster = 1,
		Dual_Frost_Blasters = 1,
		Frost_Dragon = 1,
		Low_Tier_Sword = 2,
		Duo_Emote = 3,
		Mid_Tier_Emote = 4,
		ThreeHundredCoins = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Ice_Blaster",
			PittyAmount = 50
		},
		{
			RewardKey = "Dual_Frost_Blasters",
			PittyAmount = 250
		},
		{
			RewardKey = "Frost_Dragon",
			PittyAmount = 1000
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Ice_Blaster", "Dual_Frost_Blasters", "Frost_Dragon" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Frost Blaster"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Frost Blasters"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Frost Dragon"
		}
	},
	Items = {
		Ice_Blaster = {
			Rarity = "Rare",
			RewardKey = "Ice_Blaster",
			DisplayName = "Frost Blaster",
			ImageId = "rbxassetid://17773288764",
			Chance = 1,
			SimpleReward = {
				Sword = "Frost Blaster"
			}
		},
		Dual_Frost_Blasters = {
			Rarity = "Rare",
			RewardKey = "Dual_Frost_Blasters",
			DisplayName = "Dual Frost Blasters",
			ImageId = "rbxassetid://17773288435",
			Chance = 0.5,
			SimpleReward = {
				Sword = "Dual Frost Blasters"
			}
		},
		Frost_Dragon = {
			Rarity = "Rare",
			RewardKey = "Frost_Dragon",
			DisplayName = "Frost Dragon",
			ImageId = "rbxassetid://17774903653",
			Chance = 0.1,
			SimpleReward = {
				Sword = "Frost Dragon"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Glacier Blade",
			ImageId = "rbxassetid://17757367769",
			Chance = 25,
			SimpleReward = {
				Sword = "Glacier Blade"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Chilling Embrace (Duo Emote)",
			ImageId = "rbxassetid://17769207479",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote374"
			}
		},
		Mid_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Emote",
			DisplayName = "Frost Breath",
			ImageId = "rbxassetid://17767298879",
			Chance = 25,
			SimpleReward = {
				Emote = "Emote371"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Common",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		}
	}
}
gachaEvents.FireDragonGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 6, 22, 16),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1843780735,
	OneSpinProductID = 1843780737,
	TenSpinsProductID = 1843780736,
	GiftTenSpinsProductID = 1843780738,
	FrameAlliases = {
		Fire_Blaster = 1,
		Dual_Fire_Blasters = 1,
		Fire_Dragon = 1,
		Low_Tier_Sword = 2,
		Duo_Emote = 3,
		Mid_Tier_Emote = 4,
		ThreeHundredCoins = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Fire_Blaster",
			PittyAmount = 50
		},
		{
			RewardKey = "Dual_Fire_Blasters",
			PittyAmount = 250
		},
		{
			RewardKey = "Fire_Dragon",
			PittyAmount = 1000
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Fire_Blaster", "Dual_Fire_Blasters", "Fire_Dragon" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Fire Blaster"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Fire Blasters"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Fire Dragon"
		}
	},
	Items = {
		Fire_Blaster = {
			Rarity = "Rare",
			RewardKey = "Fire_Blaster",
			DisplayName = "Fire Blaster",
			ImageId = "rbxassetid://17773289125",
			Chance = v3 and 20 or 1,
			SimpleReward = {
				Sword = "Fire Blaster"
			}
		},
		Dual_Fire_Blasters = {
			Rarity = "Rare",
			RewardKey = "Dual_Fire_Blasters",
			DisplayName = "Dual Fire Blasters",
			ImageId = "rbxassetid://17773288207",
			Chance = v3 and 15 or 0.5,
			SimpleReward = {
				Sword = "Dual Fire Blasters"
			}
		},
		Fire_Dragon = {
			Rarity = "Rare",
			RewardKey = "Fire_Dragon",
			DisplayName = "Fire Dragon",
			ImageId = "rbxassetid://17774903936",
			Chance = v3 and 10 or 0.1,
			SimpleReward = {
				Sword = "Fire Dragon"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Blazing Edge",
			ImageId = "rbxassetid://17757369370",
			Chance = 25,
			SimpleReward = {
				Sword = "Blazing Edge"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Ancient Channeling (Duo Emote)",
			ImageId = "rbxassetid://17769207281",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote373"
			}
		},
		Mid_Tier_Emote = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Emote",
			DisplayName = "Inferno Stomp",
			ImageId = "rbxassetid://17767313384",
			Chance = 25,
			SimpleReward = {
				Emote = "Emote370"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Common",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		}
	}
}
gachaEvents.MatrixGacha = {
	CrateSpinRequirement = 100,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 6, 8, 16),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1829221744,
	OneSpinProductID = 1829221741,
	TenSpinsProductID = 1829221742,
	GiftTenSpinsProductID = 1829221743,
	FrameAlliases = {
		Encrypted_Clone = 1,
		Ability_Token = 1,
		Low_Tier_Sword = 2,
		High_Tier_Sword = 3,
		Duo_Emote = 4,
		Mid_Tier_Explosion = 5,
		OneHundredBloxyCola = 6,
		ThreeHundredBloxyCola = 7,
		PremiumSwordCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Encrypted_Clone"
		},
		{
			RewardKey = "Ability_Token"
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Encrypted_Clone", "Ability_Token" },
	PhysicalBigRewardData = {
		{
			Path = "Abilities.Unlocked",
			Value = "Encrypted Clone"
		},
		{
			Path = "Abilities.Unlocked",
			Value = "Ability Token"
		}
	},
	Items = {
		Encrypted_Clone = {
			Rarity = "Rare",
			RewardKey = "Encrypted_Clone",
			DisplayName = "Encrypted Clone",
			ImageId = "rbxassetid://17524787969",
			Chance = 0.5,
			SimpleReward = {
				Abilities = { "Encrypted Clone" }
			}
		},
		Ability_Token = {
			Rarity = "Rare",
			RewardKey = "Ability_Token",
			DisplayName = "Ability Token",
			ImageId = "rbxassetid://17524787770",
			Chance = 0.25,
			CustomReward = function(p)
				local replionFor = v.Server:GetReplionFor(p, "Data")

				if not replionFor then
					return false
				end

				if replionFor:Get("EncryptedCloneToken") then
					replionFor:Increase("EncryptedCloneToken", 1)
				else
					replionFor:Set("EncryptedCloneToken", 1)
				end

				return true
			end,
			RewardQuantity = 1
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "The Ice Dagger",
			ImageId = "rbxassetid://17483231678",
			Chance = 30,
			SimpleReward = {
				Sword = "The Ice Dagger"
			}
		},
		High_Tier_Sword = {
			Rarity = "Rare",
			RewardKey = "High_Tier_Sword",
			DisplayName = "Darkheart's Fury",
			ImageId = "rbxassetid://17493762337",
			Chance = 1,
			SimpleReward = {
				Sword = "Darkheart's Fury"
			}
		},
		Duo_Emote = {
			Rarity = "Limited",
			RewardKey = "Duo_Emote",
			DisplayName = "Boost Me Up! (Duo Emote)",
			ImageId = "rbxassetid://17483243576",
			Chance = 20,
			SimpleReward = {
				Emote = "Emote315"
			}
		},
		Mid_Tier_Explosion = {
			Rarity = "Limited",
			RewardKey = "Mid_Tier_Explosion",
			DisplayName = "Bloxxer",
			ImageId = "rbxassetid://17483284960",
			Chance = 25,
			SimpleReward = {
				Explosion = "Bloxxer"
			}
		},
		OneHundredBloxyCola = {
			Rarity = "Common",
			RewardKey = "OneHundredBloxyCola",
			DisplayName = "100 Bloxy Colas",
			Chance = 7,
			ImageId = "rbxassetid://17488812377",
			CustomReward = function(p)
				if not v7 then
					v7 = require3(game.ServerScriptService.Game.Server.AwardService)
				end

				return v7:AddClassicCurrency(p, "BloxyCola", 100)
			end,
			RewardQuantity = 100
		},
		ThreeHundredBloxyCola = {
			Rarity = "Rare",
			RewardKey = "ThreeHundredBloxyCola",
			DisplayName = "300 Bloxy Colas",
			Chance = 4.5,
			ImageId = "rbxassetid://17488812377",
			CustomReward = function(p)
				if not v7 then
					v7 = require3(game.ServerScriptService.Game.Server.AwardService)
				end

				return v7:AddClassicCurrency(p, "BloxyCola", 300)
			end,
			RewardQuantity = 300
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 12,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		}
	}
}
gachaEvents.DevilKatanaGacha = {
	CrateSpinRequirement = 200,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 5, 18, 13),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1821529244,
	OneSpinProductID = 1821529241,
	TenSpinsProductID = 1821529246,
	GiftTenSpinsProductID = 1821529242,
	FrameAlliases = {
		Single_Katana = 1,
		Dual_Katana = 1,
		Triple_Katana = 1,
		Low_Tier_Sword = 2,
		Mid_Tier_Emote = 3,
		Duo_Emote = 4,
		SevenHundredFiftyCoins = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Single_Katana",
			PittyAmount = 50
		},
		{
			RewardKey = "Dual_Katana",
			PittyAmount = 250
		},
		{
			RewardKey = "Triple_Katana",
			PittyAmount = 500
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Single_Katana", "Dual_Katana", "Triple_Katana" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Devil Katana"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Devil Katana"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Triple Devil Katana"
		}
	},
	Items = {
		Single_Katana = {
			Rarity = "Rare",
			RewardKey = "Single_Katana",
			DisplayName = "Devil Katana",
			ImageId = "rbxassetid://17371633349",
			Chance = 1,
			SimpleReward = {
				Sword = "Devil Katana"
			}
		},
		Dual_Katana = {
			Rarity = "Rare",
			RewardKey = "Dual_Katana",
			DisplayName = "Dual Devil Katana",
			ImageId = "rbxassetid://17371632188",
			Chance = 0.5,
			SimpleReward = {
				Sword = "Dual Devil Katana"
			}
		},
		Triple_Katana = {
			Rarity = "Rare",
			RewardKey = "Triple_Katana",
			DisplayName = "Triple Devil Katana",
			ImageId = "rbxassetid://17371631481",
			Chance = 0.25,
			SimpleReward = {
				Sword = "Triple Devil Katana"
			}
		},
		Low_Tier_Sword = {
			Rarity = "Common",
			RewardKey = "Low_Tier_Sword",
			DisplayName = "Evil Slicer",
			ImageId = "rbxassetid://17374828403",
			Chance = 25,
			SimpleReward = {
				Sword = "Evil Slicer"
			}
		},
		Mid_Tier_Emote = {
			Rarity = "Common",
			RewardKey = "Mid_Tier_Emote",
			DisplayName = "Smoke Bomb",
			ImageId = "rbxassetid://17371653325",
			Chance = 25,
			SimpleReward = {
				Emote = "Emote306"
			}
		},
		Duo_Emote = {
			Rarity = "Rare",
			RewardKey = "Duo_Emote",
			DisplayName = "Traitor! (Duo Emote)",
			ImageId = "rbxassetid://17370472807",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote302"
			}
		},
		SevenHundredFiftyCoins = {
			Rarity = "Common",
			RewardKey = "SevenHundredFiftyCoins",
			DisplayName = "750 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 750
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Common",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		}
	}
}
gachaEvents.FrogGacha = {
	CrateSpinRequirement = 200,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 5, 4, 13),
	FirstOfTheDayPrice = "49",
	OneSpinPrice = "99",
	TenSpinPrice = "799",
	FirstOfTheDayOneSpin = 1809636376,
	OneSpinProductID = 1809636463,
	TenSpinsProductID = 1809636721,
	GiftTenSpinsProductID = 1809636820,
	FrameAlliases = {
		Blaster = 1,
		Dual_Blaster = 1,
		Frog = 1,
		Frog_Sword = 2,
		Froggy_Hop = 3,
		Duo_Emote = 4,
		SevenHundredFiftyCoins = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		WheelSpin = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Blaster",
			PittyAmount = 50
		},
		{
			RewardKey = "Dual_Blaster",
			PittyAmount = 250
		},
		{
			RewardKey = "Frog",
			PittyAmount = 1000
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Blaster", "Dual_Blaster", "Frog" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Frog Blaster"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Frog Blasters"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Frog"
		}
	},
	Items = {
		Blaster = {
			Rarity = "Rare",
			RewardKey = "Blaster",
			DisplayName = "Frog Blaster",
			ImageId = "rbxassetid://17218832736",
			Chance = 1,
			SimpleReward = {
				Sword = "Frog Blaster"
			}
		},
		Dual_Blaster = {
			Rarity = "Rare",
			RewardKey = "Dual_Blaster",
			DisplayName = "Dual Frog Blasters",
			ImageId = "rbxassetid://17218833703",
			Chance = 0.5,
			SimpleReward = {
				Sword = "Dual Frog Blasters"
			}
		},
		Frog = {
			Rarity = "Rare",
			RewardKey = "Frog",
			DisplayName = "Frog",
			ImageId = "rbxassetid://17208833278",
			Chance = 0.1,
			SimpleReward = {
				Sword = "Frog"
			}
		},
		Frog_Sword = {
			Rarity = "Common",
			RewardKey = "Frog_Sword",
			DisplayName = "Frog Sword",
			ImageId = "rbxassetid://17196840184",
			Chance = 21,
			SimpleReward = {
				Sword = "Frog Sword"
			}
		},
		Froggy_Hop = {
			Rarity = "Common",
			RewardKey = "Froggy_Hop",
			DisplayName = "Froggy Hop",
			ImageId = "rbxassetid://17173770604",
			Chance = 21,
			SimpleReward = {
				Emote = "Emote274"
			}
		},
		Duo_Emote = {
			Rarity = "Rare",
			RewardKey = "Duo_Emote",
			DisplayName = "Leap Frog (DUO)",
			ImageId = "rbxassetid://17213816856",
			Chance = 3,
			SimpleReward = {
				Emote = "Emote278"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumSwordCrate = {
			Rarity = "Common",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		WheelSpin = {
			Rarity = "Rare",
			RewardKey = "WheelSpin",
			DisplayName = "Wheel Spin",
			Chance = 8,
			ImageId = "rbxassetid://15051770001",
			SimpleReward = {
				Rolls = 1
			}
		}
	}
}
gachaEvents.SciFiGacha = {
	CrateSpinRequirement = 200,
	EventEndTimeStamp = DateTime.fromUnixTimestamp(1702080000),
	FirstOfTheDayPrice = "49",
	OneSpinPrice = "99",
	TenSpinPrice = "799",
	FirstOfTheDayOneSpin = 1691960624,
	OneSpinProductID = 1691959073,
	TenSpinsProductID = 1691959171,
	FiftySpinsProductID = 1695725769,
	TwoHundredFiftySpinsProductID = 1695725846,
	FrameAlliases = {
		Blaster = 1,
		Dual_Blaster = 1,
		Twinblade = 1,
		OneHundredCoins = 2,
		Explosion = 3,
		ThreeHundredCoins = 4,
		InstantSpin = 5,
		FiveHundredCoins = 6,
		WheelSpin = 7,
		PremiumCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Blaster",
			PittyAmount = 50
		},
		{
			RewardKey = "Twinblade",
			PittyAmount = 240
		},
		{
			RewardKey = "Dual_Blaster",
			PittyAmount = 450
		}
	},
	RollTimeOut = 10,
	BigRewardData = { "Blaster", "Twinblade", "Dual_Blaster" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Plasma Blaster"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Laser Twinblade"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Plasma Blasters"
		}
	},
	Items = {
		Blaster = {
			Rarity = "Rare",
			RewardKey = "Blaster",
			DisplayName = "Blaster",
			ImageId = "rbxassetid://15431876934",
			Chance = 2,
			SimpleReward = {
				Sword = "Plasma Blaster",
				Emote = "Emote33"
			}
		},
		Twinblade = {
			Rarity = "Rare",
			RewardKey = "Twinblade",
			DisplayName = "Twin Blade",
			Chance = 0.7,
			ImageId = "rbxassetid://15460234203",
			SimpleReward = {
				Sword = "Laser Twinblade",
				Emote = "Emote34"
			}
		},
		Dual_Blaster = {
			Rarity = "Rare",
			RewardKey = "Dual_Blaster",
			DisplayName = "Dual Blasters",
			ImageId = "rbxassetid://15450904604",
			Chance = 0.3,
			SimpleReward = {
				Sword = "Plasma Blasters",
				Emote = "Emote32"
			}
		},
		OneHundredCoins = {
			Rarity = "Common",
			RewardKey = "OneHundredCoins",
			DisplayName = "100 Coins",
			Chance = 30,
			ImageId = "rbxassetid://15013634268",
			SimpleReward = {
				Credits = 100
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 25,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 14,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumCrate = {
			Rarity = "Limited",
			RewardKey = "PremiumCrate",
			DisplayName = "Premium Crate",
			Chance = 9,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		InstantSpin = {
			Rarity = "Limited",
			RewardKey = "InstantSpin",
			DisplayName = "Instant Spin",
			Chance = 9,
			ImageId = "rbxassetid://15289128167",
			CustomReward = function(p)
				local ServerScriptService = game:GetService("ServerScriptService")
				require3(ServerScriptService.Game.Services.BoostsService):AddBoost(p, "InstantSpin", 108000)
			end,
			SimpleReward = {}
		},
		Explosion = {
			Rarity = "Rare",
			RewardKey = "Explosion",
			DisplayName = "Premium Explosion",
			Chance = 5,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		},
		WheelSpin = {
			Rarity = "Rare",
			RewardKey = "WheelSpin",
			DisplayName = "Wheel Spin",
			Chance = 5,
			ImageId = "rbxassetid://15051770001",
			SimpleReward = {
				Rolls = 1
			}
		}
	}
}
gachaEvents.NebulaGacha = {
	CrateSpinRequirement = 200,
	EventEndTimeStamp = DateTime.fromUniversalTime(2024, 3, 19, 24),
	FirstOfTheDayPrice = "25",
	OneSpinPrice = "49",
	TenSpinPrice = "399",
	FirstOfTheDayOneSpin = 1766143984,
	OneSpinProductID = 1766144149,
	TenSpinsProductID = 1766144315,
	FiftySpinsProductID = 1766144447,
	TwoHundredFiftySpinsProductID = 1766144580,
	FrameAlliases = {
		Blaster = 1,
		Dual_Blaster = 1,
		Dual_Finisher = 1,
		NebulaSword = 2,
		SideStepper = 3,
		ThreeHundredCoins = 4,
		HypnosisEmote = 5,
		FiveHundredCoins = 6,
		PremiumSwordCrate = 7,
		PremiumExplosionCrate = 8
	},
	PityRewardBucket = {
		{
			RewardKey = "Blaster",
			PittyAmount = 50
		},
		{
			RewardKey = "Dual_Blaster",
			PittyAmount = 250
		},
		{
			RewardKey = "Dual_Finisher",
			PittyAmount = 500
		}
	},
	RollTimeOut = 7,
	BigRewardData = { "Blaster", "Dual_Blaster", "Dual_Finisher" },
	PhysicalBigRewardData = {
		{
			Path = "SwordSkins.Unlocked",
			Value = "Nebula Blaster"
		},
		{
			Path = "SwordSkins.Unlocked",
			Value = "Dual Nebula Blasters"
		},
		{
			Path = "Finishers.Unlocked",
			Value = "Dual Nebula Blasters"
		}
	},
	Items = {
		Blaster = {
			Rarity = "Rare",
			RewardKey = "Blaster",
			DisplayName = "Blaster",
			ImageId = "rbxassetid://16584556493",
			Chance = 1,
			SimpleReward = {
				Sword = "Nebula Blaster"
			}
		},
		Dual_Blaster = {
			Rarity = "Rare",
			RewardKey = "Dual_Blaster",
			DisplayName = "Dual Blasters",
			ImageId = "rbxassetid://16584556825",
			Chance = 0.4,
			SimpleReward = {
				Sword = "Dual Nebula Blasters"
			}
		},
		Dual_Finisher = {
			Rarity = "Rare",
			RewardKey = "Dual_Finisher",
			DisplayName = "Dual Finisher",
			Chance = 0.25,
			ImageId = "rbxassetid://16587643792",
			SimpleReward = {
				Finisher = "Dual Nebula Blasters"
			}
		},
		NebulaSword = {
			Rarity = "Rare",
			RewardKey = "NebulaSword",
			DisplayName = "Nebula Sword",
			Chance = 25,
			ImageId = "rbxassetid://16578882853",
			SimpleReward = {
				Sword = "Nebula Sword"
			}
		},
		SideStepper = {
			Rarity = "Common",
			RewardKey = "SideStepper",
			DisplayName = "Side Stepper",
			Chance = 23.35,
			ImageId = "rbxassetid://16587551858",
			SimpleReward = {
				Emote = "Emote165"
			}
		},
		HypnosisEmote = {
			Rarity = "Common",
			RewardKey = "HypnosisEmote",
			DisplayName = "Hypnosis (DUO EMOTE!)",
			Chance = 3,
			ImageId = "rbxassetid://16572657600",
			SimpleReward = {
				Emote = "Emote160"
			}
		},
		ThreeHundredCoins = {
			Rarity = "Common",
			RewardKey = "ThreeHundredCoins",
			DisplayName = "300 Coins",
			Chance = 17,
			ImageId = "rbxassetid://15038384377",
			SimpleReward = {
				Credits = 300
			}
		},
		FiveHundredCoins = {
			Rarity = "Common",
			RewardKey = "FiveHundredCoins",
			DisplayName = "500 Coins",
			Chance = 10,
			ImageId = "rbxassetid://14713794582",
			SimpleReward = {
				Credits = 500
			}
		},
		PremiumSwordCrate = {
			Rarity = "Limited",
			RewardKey = "PremiumSwordCrate",
			DisplayName = "Premium Sword Crate",
			Chance = 10,
			ImageId = "rbxassetid://16039967646",
			SimpleReward = {
				CrateKeys = { "PremiumSword" }
			}
		},
		PremiumExplosionCrate = {
			Rarity = "Limited",
			RewardKey = "PremiumExplosionCrate",
			DisplayName = "Premium Explosion Crate",
			Chance = 10,
			ImageId = "rbxassetid://15049303003",
			SimpleReward = {
				CrateKeys = { "PremiumExplosion" }
			}
		}
	}
}
gachaEvents.SciFiMysteryCrateVFX = {
	IgnoreDisableWheelSpin = true,
	RollTimeOut = 3,
	Items = {
		Blaster_Finisher = {
			RewardKey = "Blaster_Finisher",
			DisplayName = "Blaster Finisher",
			Chance = 34,
			ImageId = "rbxassetid://15464941227",
			SimpleReward = {
				Finisher = "Plasma Blaster"
			}
		},
		Twinblade_Finisher = {
			RewardKey = "Twinblade_Finisher",
			DisplayName = "Twinblade Finisher",
			Chance = 33,
			ImageId = "rbxassetid://15465863900",
			SimpleReward = {
				Finisher = "Laser Twinblade"
			}
		},
		Dual_Blaster_Finisher = {
			RewardKey = "Dual_Blaster_Finisher",
			DisplayName = "Dual Blaster Finisher",
			Chance = 33,
			ImageId = "rbxassetid://15464940814",
			SimpleReward = {
				Finisher = "Plasma Blasters"
			}
		}
	}
}
gachaEvents.ClanSwordCrate = {
	IgnoreDisableWheelSpin = true,
	RollTimeOut = 3,
	Items = {
		Cyber_Explosion = {
			RewardKey = "Cyber_Explosion",
			DisplayName = "Cyber Explosion",
			Chance = 50,
			ImageId = "rbxassetid://16844619020",
			SimpleReward = {
				Explosion = "Cyber Explosion"
			}
		},
		Glitch_Dance = {
			RewardKey = "Glitch_Dance",
			DisplayName = "Glitch Dance",
			Chance = 30,
			ImageId = "rbxassetid://16837917596",
			SimpleReward = {
				Emote = "Emote220"
			}
		},
		Digital_Edge = {
			RewardKey = "Digital_Edge",
			DisplayName = "Digital Edge",
			Chance = 19,
			ImageId = "rbxassetid://16837887738",
			SimpleReward = {
				Sword = "Digital Edge"
			}
		},
		Cyber_Sweeper = {
			RewardKey = "Cyber_Sweeper",
			DisplayName = "Cyber Sweeper",
			Chance = 1,
			ImageId = "rbxassetid://16837888040",
			SimpleReward = {
				Sword = "Cyber Sweeper"
			}
		}
	}
}
local items = {
	Starflare = {
		RewardKey = "Starflare",
		DisplayName = "Starflare",
		Chance = 35,
		ImageId = v5:GetExplosionIcon("Starflare") or v5:GetIcon("DEFAULT_MISSING"),
		SimpleReward = {
			Explosion = "Starflare"
		}
	},
	Titan_Fang = {
		RewardKey = "Titan_Fang",
		DisplayName = "Titan Fang",
		Chance = 35,
		ImageId = v5:GetSwordIcon("Titan Fang") or v5:GetIcon("DEFAULT_MISSING"),
		SimpleReward = {
			Sword = "Titan Fang"
		}
	},
	Bring_It = 0,
	Runesteel = 0,
	Plasma_Katana = 0
}
local imageId

if v6.EmotesToIds["Bring It!"] then
	imageId = v5:GetEmoteIcon(v6.EmotesToIds["Bring It!"])
else
	imageId = v5:GetIcon("DEFAULT_MISSING")
end

items.Bring_It = {
	RewardKey = "Bring_It",
	DisplayName = "Bring It!",
	Chance = 19,
	ImageId = imageId,
	SimpleReward = {
		Emote = v6.EmotesToIds["Bring It!"]
	}
}
items.Runesteel = {
	RewardKey = "Runesteel",
	DisplayName = "Runesteel",
	Chance = 10,
	ImageId = v5:GetSwordIcon("Runesteel") or v5:GetIcon("DEFAULT_MISSING"),
	SimpleReward = {
		Sword = "Runesteel"
	}
}
items.Plasma_Katana = {
	RewardKey = "Plasma_Katana",
	DisplayName = "Plasma Katana",
	Chance = 1,
	ImageId = v5:GetSwordIcon("Plasma Katana") or v5:GetIcon("DEFAULT_MISSING"),
	SimpleReward = {
		Sword = "Plasma Katana"
	}
}
gachaEvents.ClanMagicalCrate = {
	IgnoreDisableWheelSpin = true,
	RollTimeOut = 3,
	Items = items
}
LootboxData.GachaEvents = gachaEvents
return LootboxData