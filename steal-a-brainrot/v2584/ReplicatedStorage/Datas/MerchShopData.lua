local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlags = require(ReplicatedStorage.Packages.FFlags)
require(ReplicatedStorage.Shared.Updates)
local MerchShopData = {
	CodeLength = 12,
	CurrentShopItem = "Boppin Bunny",
	IsEnabled = function()
		return FFlags:GetInstant("MerchShopEnabled", true)
	end,
	Items = {
		["Boppin Bunny"] = {
			DlcType = "Exclusive-S1-B",
			CommerceProductId = "COM-1009232266037166506",
			DevProductId = 3568906008,
			RewardType = "Brainrot",
			RewardId = "Boppin Bunny",
			StockKey = "Boppin Bunny",
			InitialStock = 35000,
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("MechShopSoldOut", false)
			end
		},
		["Festive 67"] = {
			DlcType = "Exclusive-S1-A",
			CommerceProductId = "COM-7003089990728810945",
			DevProductId = 3477983793,
			RewardType = "Brainrot",
			RewardId = "Festive 67",
			StockKey = "Festive 67",
			InitialStock = 50000,
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("MechShopSoldOut2", false)
			end
		},
		Pineaplino = {
			DlcType = "Rare-001",
			RewardType = "Brainrot",
			RewardId = "Pineaplino",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/PineaplinoDisabled", false) and FFlags:Get(
					"Merch/MerchV3Enabled",
					false
				)
			end
		},
		["Lazy Ducky"] = {
			DlcType = "Rare-002",
			RewardType = "Brainrot",
			RewardId = "Lazy Ducky",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/LazyDuckyDisabled", false) and FFlags:Get(
					"Merch/MerchV3Enabled",
					false
				)
			end
		},
		["Globa Steppa"] = {
			DlcType = "Ultra-001",
			RewardType = "Brainrot",
			RewardId = "Globa Steppa",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get(
					"Merch/GlobaSteppaDisabled",
					false
				) and FFlags:Get("Merch/MerchV3Enabled", false)
			end
		},
		["Rico Dinero"] = {
			DlcType = "Ultra-002",
			RewardType = "Brainrot",
			RewardId = "Rico Dinero",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/RicoDineroDisabled", false) and FFlags:Get(
					"Merch/MerchV3Enabled",
					false
				)
			end
		},
		["Pancake and Syrup"] = {
			DlcType = "Op-001",
			RewardType = "Brainrot",
			RewardId = "Pancake and Syrup",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get(
					"Merch/PancakeandSyrupDisabled",
					false
				) and FFlags:Get("Merch/MerchV3Enabled", false)
			end
		},
		Arcadragon = {
			DlcType = "Op-002",
			RewardType = "Brainrot",
			RewardId = "Arcadragon",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/ArcadragonDisabled", false) and FFlags:Get(
					"Merch/MerchV3Enabled",
					false
				)
			end
		},
		["Common-001"] = {
			DlcType = "Common-001",
			RewardType = "Luck",
			RewardId = "2x-10m",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/Common001Disabled", false) and FFlags:Get(
					"Merch/MerchV3Enabled",
					false
				)
			end
		},
		["Common-002"] = {
			DlcType = "Common-002",
			RewardType = "Luck",
			RewardId = "4x-10m",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/Common002Disabled", false) and FFlags:Get(
					"Merch/MerchV3Enabled",
					false
				)
			end
		},
		Tralalero = {
			DlcType = "Rare-004",
			RewardType = "Base",
			RewardId = "Tralalero",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/Rare004Disabled", false) and FFlags:Get(
					"Merch/MerchV4Enabled",
					false
				)
			end
		},
		["Tenini Ballini"] = {
			DlcType = "Rare-003",
			RewardType = "Brainrot",
			RewardId = "Tenini Ballini",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/Rare003Disabled", false) and FFlags:Get(
					"Merch/MerchV4Enabled",
					false
				)
			end
		},
		Grabatron = {
			DlcType = "Ultra-003",
			RewardType = "Brainrot",
			RewardId = "Grabatron",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/Ultra003Disabled", false) and FFlags:Get(
					"Merch/MerchV4Enabled",
					false
				)
			end
		},
		Polaroidini = {
			DlcType = "Ultra-004",
			RewardType = "Brainrot",
			RewardId = "Polaroidini",
			IsEnabled = function()
				return FFlags:GetInstant("MerchShopEnabled", true) and not FFlags:Get("Merch/Ultra004Disabled", false) and FFlags:Get(
					"Merch/MerchV5Enabled",
					false
				)
			end
		}
	},
	TestProductInfo = {
		Description = "Test description",
		DisplayPrice = "$39.99",
		IconImageAssetId = 0,
		IsPurchasable = true
	},
	DlcTypeToItem = {}
}

for k, item in MerchShopData.Items do
	item.Name = k

	if MerchShopData.DlcTypeToItem[item.DlcType] then
		warn((`Duplicate dlcType found! {k} & {MerchShopData.DlcTypeToItem[item.DlcType].Name} share the same dlcType`))
	else
		MerchShopData.DlcTypeToItem[item.DlcType] = item
	end
end

MerchShopData.CurrentItem = MerchShopData.Items[MerchShopData.CurrentShopItem]
return MerchShopData