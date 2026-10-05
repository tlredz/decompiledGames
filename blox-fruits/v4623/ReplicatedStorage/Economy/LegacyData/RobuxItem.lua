require(game.ReplicatedStorage.Packages.Result)
local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.Economy.EconomyItem.LegacyInfo)
require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local literal = Type.literal({
	"Common",
	"Uncommon",
	"Rare",
	"Legendary",
	"Mythical",
	"Premium"
})
return {
	REVERSE_LOOK_UP_FIELD = "ItemId",
	Types = {
		RobuxItemData = Type.strictInterface({
			Name = Type.string,
			subtype = Type.literal(
				"Bundle Product",
				"Stored Product",
				"Fruit",
				"Fragment Product",
				"AuraSkin",
				"FruitSkin",
				"Cash Product",
				"Named Product",
				"Exp Product",
				"Skin Bundle",
				"FruitMutation"
			),
			seaLevelGiftCheck = Type.optional(Type.boolean),
			dressrosa = Type.optional(Type.boolean),
			productType = Type.literal("Product", "GamePass"),
			storageName = Type.string,
			doNotFeature = Type.optional(Type.boolean),
			reducer = Type.optional((Type.numberConstrained(0, 1))),
			IsForSale = Type.optional(Type.boolean),
			gift = Type.optional(Type.boolean),
			ItemId = Type.optional(Type.integer),
			assetId = Type.optional(Type.integer),
			subitem = Type.optional(Type.string),
			Cash = Type.optional(Type.array(Type.integer)),
			Fragments = Type.optional(Type.array(Type.integer)),
			MinRobuxSpend = Type.optional(Type.integer),
			maxGift = Type.optional(Type.integer),
			maxPurchase = Type.optional(Type.integer),
			StoreAll = Type.optional(Type.boolean),
			Fruits = Type.optional(Type.array(Type.string)),
			PurchaseLimits = Type.optional(Type.strictInterface({
				MaxGift = Type.integer,
				MaxPurchase = Type.integer
			})),
			StorageName = Type.optional(Type.string),
			Gift = Type.optional(Type.boolean),
			AssetId = Type.optional(Type.integer),
			modifiers = Type.optional(Type.map(Type.literal("Beli", "Fragments"), Type.integer)),
			Amount = Type.optional(Type.integer),
			isDungeonProduct = Type.optional(Type.boolean),
			redeemedFor = Type.optional(Type.literal("Random")),
			Rarity = Type.optional(Type.union(Type.strictInterface({
				Name = literal,
				Value = Type.integer,
				Outline = Type.boolean,
				Color = Type.Color3
			}), Type.integer)),
			item = Type.optional(Type.string),
			productId = Type.optional(Type.integer),
			nostore = Type.optional(Type.boolean),
			bundleItems = Type.optional(Type.array(Type.string)),
			bundletype = Type.optional(Type.literal("FruitSkin"))
		})
	}
}