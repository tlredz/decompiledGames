local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsShopConfig = require(ReplicatedStorage.FeatureConfigs.ItemsShopConfig)
require(script.Parent.Parent.Types)
return {
	id = "RIA2026",
	enabled = true,
	eventKey = "RIAAdminAbuse2026",
	activity = {
		kind = "AdminAbuse",
		modules = { "RIAAdminAbuse2026" }
	},
	currency = {
		kind = "Wins"
	},
	prices = ItemsShopConfig.WINS_PRICES,
	robuxProducts = ItemsShopConfig.DEV_PRODUCTS,
	giftable = true,
	catalog = {
		kind = "Fixed",
		listings = {
			{
				itemKey = "RIATrophy"
			},
			{
				itemKey = "RIATools"
			},
			{
				itemKey = "RIAPass"
			}
		}
	},
	ui = {
		modalTag = "RIAAdminAbuse2026ShopModal",
		zoneTag = "RIAAdminAbuse2026ShopZone",
		cardTemplate = "RIAEventItemCard",
		currencyButton = "BuyWins",
		modalVisibleY = 0.6,
		errors = {
			NotEnoughCurrency = "Not enough Wins",
			ShopInactive = "The RIA shop is not active on this server"
		}
	}
}