local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsShopConfig = require(ReplicatedStorage.FeatureConfigs.ItemsShopConfig)
require(script.Parent.Parent.Types)
return {
	id = "Summer2026",
	enabled = true,
	eventKey = "SummerEvent",
	activity = {
		kind = "AdminAbuse",
		modules = { "SummerAdminAbuse", "YoutuberSpecialSteakAdminAbuse", "CruzVsSplinkAdminAbuse" }
	},
	currency = {
		kind = "EventCurrency",
		key = "SummerCoins"
	},
	prices = {
		Common = 10,
		Uncommon = 30,
		Rare = 80,
		Epic = 200,
		Legendary = 500,
		Mythic = 1200,
		Secret = 3000
	},
	robuxProducts = ItemsShopConfig.DEV_PRODUCTS,
	giftable = true,
	catalog = {
		kind = "Rotating",
		restockInterval = 300,
		slots = {
			{
				id = "Common",
				rarities = {
					{
						rarity = "Common",
						weight = 1
					}
				}
			},
			{
				id = "Uncommon",
				rarities = {
					{
						rarity = "Uncommon",
						weight = 1
					}
				}
			},
			{
				id = "Rare",
				rarities = {
					{
						rarity = "Rare",
						weight = 1
					}
				}
			},
			{
				id = "Mysterious",
				rarities = {
					{
						rarity = "Epic",
						weight = 85
					},
					{
						rarity = "Legendary",
						weight = 15
					}
				},
				guaranteed = {
					{
						every = 480,
						rarity = "Secret"
					},
					{
						every = 60,
						rarity = "Mythic"
					}
				},
				stock = 3
			}
		}
	},
	ui = {
		modalTag = "SummerEventItemsShopModal",
		zoneTag = "SummerEventItemsShopZone",
		cardTemplate = "SummerEventItemCard",
		currencyButton = "BuyCoins",
		modalVisibleY = 0.6,
		restockLabel = "FIND COINS BY PLAYING / RESTOCK IN: %dm %02ds",
		restockNotice = "Summer shop restocked!",
		itemAddedNotice = "New Summer shop item: %s",
		errors = {
			NotEnoughCurrency = "Not enough Summer Coins",
			ShopInactive = "The Summer shop is not active on this server"
		}
	}
}