require("../SharedTypes")
return table.freeze({
	Messages = {
		OnlineReceived = "You just received some rewards.",
		OfflineReceived = "You received some rewards while you were away.",
		Redemption = "You redeemed your rewards!"
	},
	RewardInterval = 3600,
	MaxOfflineRewardIntervals = 6,
	RedeemDelayLength = 15,
	OfflineRewardsMessageOffset = 30,
	WeightedRewardOptions = {
		{
			ItemName = "Smokescreen Totem",
			Type = "Item",
			Weight = 3
		},
		{
			ItemName = "Sundial Totem",
			Type = "Item",
			Weight = 5
		},
		{
			ItemName = "Clearcast Totem",
			Type = "Item",
			Weight = 5
		},
		{
			ItemName = "Tempest Totem",
			Type = "Item",
			Weight = 5
		},
		{
			ItemName = "Meteor Totem",
			Type = "Item",
			Weight = 3
		},
		{
			ItemName = "Eclipse Totem",
			Type = "Item",
			Weight = 1
		},
		{
			ItemName = "Magic Thread",
			Type = "Item",
			Weight = 1
		},
		{
			ItemName = "Ancient Thread",
			Type = "Item",
			Weight = 0.5
		},
		{
			ItemName = "Mutation Totem",
			Type = "Item",
			Weight = 0.2099
		},
		{
			ItemName = "Shiny Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Sparkling Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Lunar Thread",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Cursed Nuke",
			Type = "Item",
			Weight = 0.001
		},
		{
			ItemName = "Thalass Essence",
			Type = "Item",
			Weight = 0.05
		},
		{
			ItemName = "Tide Essence",
			Type = "Item",
			Weight = 0.05
		},
		{
			ItemName = "Requis Essence",
			Type = "Item",
			Weight = 0.05
		},
		{
			ItemName = "Dripstone Collapse Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Kraken Hunt Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Megalodon Hunt Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Scylla Hunt Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Colossal Dragon Hunt Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Blue Moon Totem",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Starfall Totem",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Bloop Whistle",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Shark Whistle",
			Type = "Item",
			Weight = 0.2
		},
		{
			ItemName = "Luck Potion",
			Type = "Potion",
			Weight = 1.2
		},
		{
			ItemName = "Lure Speed Potion",
			Type = "Potion",
			Weight = 1.1
		},
		{
			ItemName = "All Season Potion",
			Type = "Potion",
			Weight = 1
		},
		{
			ItemName = "Glitched Potion",
			Type = "Potion",
			Weight = 0.25
		},
		{
			ItemName = "Kraken Egg",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Megalodon Egg",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Orca Egg",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Whale Egg",
			Type = "Item",
			Weight = 0.1
		},
		{
			ItemName = "Garbage",
			Type = "Bait",
			Weight = 8.88
		},
		{
			ItemName = "Bagel",
			Type = "Bait",
			Weight = 8.4
		},
		{
			ItemName = "Worm",
			Type = "Bait",
			Weight = 8
		},
		{
			ItemName = "Mist Worms",
			Type = "Bait",
			Weight = 5
		},
		{
			ItemName = "Coral",
			Type = "Bait",
			Weight = 5
		},
		{
			ItemName = "Phantom Leech",
			Type = "Bait",
			Weight = 5
		},
		{
			ItemName = "Glass Beetle",
			Type = "Bait",
			Weight = 5
		},
		{
			ItemName = "Neuro Slug",
			Type = "Bait",
			Weight = 4
		},
		{
			ItemName = "Toxic Jelly Core",
			Type = "Bait",
			Weight = 4
		},
		{
			ItemName = "Deep Coral",
			Type = "Bait",
			Weight = 4
		},
		{
			ItemName = "Shark Head",
			Type = "Bait",
			Weight = 3
		},
		{
			ItemName = "Nightmare Larva",
			Type = "Bait",
			Weight = 3
		},
		{
			ItemName = "Golden Worm",
			Type = "Bait",
			Weight = 2
		},
		{
			ItemName = "Glowworm",
			Type = "Bait",
			Weight = 0.5
		},
		{
			ItemName = "Enchant Relic",
			Type = "Fish",
			Weight = 2.12
		},
		{
			ItemName = "Exalted Relic",
			Type = "Fish",
			Weight = 0.25
		},
		{
			ItemName = "Cosmic Relic",
			Type = "Fish",
			Weight = 0.02
		},
		{
			ItemName = "Twisted Relic",
			Type = "Fish",
			Weight = 0.05
		},
		{
			ItemName = "Song of the Deep",
			Type = "Fish",
			Weight = 0.01
		},
		{
			ItemName = "Amethyst",
			Type = "Fish",
			Weight = 0.7
		},
		{
			ItemName = "Ruby",
			Type = "Fish",
			Weight = 0.5
		},
		{
			ItemName = "Opal",
			Type = "Fish",
			Weight = 0.3
		},
		{
			ItemName = "Lapis Lazuli",
			Type = "Fish",
			Weight = 0.2
		},
		{
			ItemName = "Moonstone",
			Type = "Fish",
			Weight = 0.01
		},
		{
			ItemName = "Bloop Cosmetic Crate",
			Type = "Fish",
			Weight = 0.01
		}
	}
})