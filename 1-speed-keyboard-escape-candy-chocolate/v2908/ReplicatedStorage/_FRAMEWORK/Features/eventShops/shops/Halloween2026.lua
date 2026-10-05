local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsShopConfig = require(ReplicatedStorage.FeatureConfigs.ItemsShopConfig)
require(script.Parent.Parent.Types)
return {
	id = "Halloween2026",
	enabled = true,
	eventKey = "Halloween2026",
	activity = {
		kind = "AdminAbuse",
		modules = { "HalloweenAdminAbuse" }
	},
	currency = {
		kind = "EventCurrency",
		key = "CandyCorn"
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
		modalTag = "HalloweenEventItemsShopModal",
		zoneTag = "HalloweenEventItemsShopZone",
		cardTemplate = "HalloweenEventItemCard",
		currencyButton = "BuyCoins",
		modalVisibleY = 0.6,
		restockLabel = "COLLECT CANDY CORN / RESTOCK IN: %dm %02ds",
		restockNotice = "Halloween shop restocked!",
		itemAddedNotice = "New Halloween shop item: %s",
		errors = {
			NotEnoughCurrency = "Not enough Candy Corn",
			ShopInactive = "The Halloween shop is not active on this server"
		}
	}
}