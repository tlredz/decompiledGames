local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RewardInfo = require(ReplicatedStorage.shared.RewardInfo)
local v = game.GameId == 6756890519
return {
	DoubleLuckProducts = {
		["2xLuck"] = {
			SetLuckAt = 2,
			Price = 99,
			ProductId = v and 2651667297 or 2651156738
		},
		["4xLuck"] = {
			SetLuckAt = 4,
			RequiredBoost = 2,
			Price = 199,
			Discount = 399,
			Previous = "2xLuck",
			Extensions = {
				["15Min"] = 2658213093,
				["30Min"] = 2658213211
			},
			ProductId = v and 2651667361 or 2651157043
		},
		["8xLuck"] = {
			SetLuckAt = 8,
			RequiredBoost = 4,
			Price = 399,
			Previous = "4xLuck",
			Discount = 799,
			Extensions = {
				["15Min"] = 2658213306,
				["30Min"] = 2658213423
			},
			ProductId = v and 2658212885 or 2651157275
		}
	},
	Gamepasses = {
		[901839344] = {
			Description = "Sell your fish from anywhere in Fisch!",
			Color = Color3.fromRGB(255, 106, 106),
			Priority = 1
		},
		[927437431] = {
			Description = "10 Cosmetic Bobbers & Bobber Enthusiast Title!",
			Color = Color3.fromRGB(140, 101, 255),
			Priority = 2
		},
		[837360470] = {
			Description = "Increases XP gain by 2x",
			Color = Color3.fromRGB(131, 185, 255),
			Priority = 3
		},
		[837341519] = {
			Description = "Increased Appraiser Luck & costs 25% less to appraise!",
			Color = Color3.fromRGB(144, 255, 148),
			Priority = 4
		},
		[837478377] = {
			Description = "Supporter Title, Halo, /e rain Emote & +1000 Credits!",
			Color = Color3.fromRGB(255, 233, 120),
			Priority = 5
		},
		[847012516] = {
			Description = "11+ Emotes & Dances",
			Color = Color3.fromRGB(229, 135, 255),
			Priority = 6
		},
		[948629114] = {
			Description = "Get a radio that can play music while you fisch",
			Color = Color3.fromRGB(255, 159, 111),
			Priority = 7
		},
		[986687236] = {
			Description = "Be able to spawn boats anywhere in the ocean!",
			Color = Color3.fromRGB(88, 233, 255),
			Priority = 8
		},
		[986882975] = {
			Description = "Appraise an item anywhere",
			Color = Color3.fromRGB(111, 255, 195),
			Priority = 8
		}
	},
	AquariumSlot = {
		ProductId = 3301643355
	},
	VideoAds = {
		ProductId = 3303181747
	},
	PersonalAquariumSlot = {
		{
			ProductId = 3525046322
		},
		{
			ProductId = 3525046324
		},
		{
			ProductId = 3525046330
		},
		{
			ProductId = 3525046323
		},
		{
			ProductId = 3525046331
		},
		{
			ProductId = 3525046327
		},
		{
			ProductId = 3525046325
		},
		{
			ProductId = 3525046329
		},
		{
			ProductId = 3525072900
		},
		{
			ProductId = 3525046326
		}
	},
	GamepassesGiftsProducts = {
		[901839344] = {
			name = "Sell Anywhere",
			devProduct = v and 2654237964 or 2653139351
		},
		[927437431] = {
			name = "Bobber Pack",
			devProduct = v and 2654238019 or 2653139607
		},
		[837360470] = {
			name = "Double XP",
			devProduct = v and 2654238060 or 2653139013
		},
		[837341519] = {
			name = "Appraisers Luck",
			devProduct = v and 2654238097 or 2653029225
		},
		[837478377] = {
			name = "Supporter",
			devProduct = v and 2654238173 or 2653079522
		},
		[847012516] = {
			name = "Emote Pack",
			devProduct = v and 2654238225 or 2653139236
		},
		[948629114] = {
			name = "Radio",
			devProduct = v and 2654238264 or 2653139748
		},
		[986882975] = {
			name = "Appraise Anywhere",
			devProduct = 2669993179
		},
		[1359918468] = {
			name = "Enchant Anywhere",
			devProduct = 3351840567
		},
		[986687236] = {
			name = "Spawn Boats Anywhere",
			devProduct = 2669991547
		}
	},
	LimitedBobbers = {
		Enabled = true,
		TimeRange = NumberRange.new(0, 1775923200),
		Bobbers = { "Pink Starbun", "Green Starbun", "Blue Starbun" },
		ProductIds = { v and 2654235282 or 3569935165, v and 2654235238 or 3569935166, v and 3231825610 or 3569935168 },
		BundleProductId = v and 2654235564 or 3569935167,
		BundlePurchaseCoins = 250000
	},
	Eggs = {
		OneEgg = {
			ProductId = v and 3231935730 or 3231935650
		},
		TenEggs = {
			ProductId = v and 3231936603 or 3231936535
		}
	},
	AFKLuck = {
		["1Hour"] = {
			ProductId = v and 3243444582 or 3243442865
		},
		["3Hours"] = {
			ProductId = v and 3243444636 or 3243443085
		},
		["10Hours"] = {
			ProductId = v and 3243444690 or 3243443442
		}
	},
	StarterPack = {
		Enabled = true,
		MaxLevel = 10,
		DisplayIn = 600,
		Timer = 600,
		ProductId = 2657335337,
		Rewards = {
			RewardInfo.Rod("Fischer's Rod"),
			RewardInfo.Boat("Coral Cruiser Boat"),
			RewardInfo.Item("Fish Radar")
		}
	},
	DateReward = {
		PreviousDay = 2668497927,
		DaySkip = 2669804295,
		["5DaySkip"] = 2669804736,
		SkipAll = 2669805001
	},
	Bait = {
		Buy5 = 3232726029,
		Buy25 = 3232726189
	}
}