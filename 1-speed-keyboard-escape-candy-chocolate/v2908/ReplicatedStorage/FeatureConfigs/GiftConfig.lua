local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(script.Parent:WaitForChild("Items"))
local RobuxShopConfig = require(script.Parent:WaitForChild("RobuxShopConfig"))
local SkinBundles = require(script.Parent:WaitForChild("PersonalTreadmill"):WaitForChild("SkinBundles"))
local Skins = require(script.Parent:WaitForChild("PersonalTreadmill"):WaitForChild("Skins"))
local SKINS = Skins.SKINS
local GameplayDefaults = require(ReplicatedStorage.Config.Shared.GameplayDefaults)
local GAMEPASS_IDS = GameplayDefaults.GAMEPASS_IDS
local GiftConfig = {
	TREADMILL_GIFTS = {
		Gold = {
			DevProductId = 3600201213,
			GamepassId = GAMEPASS_IDS.GOLD_ACCESS,
			Name = "Gold Treadmill",
			Image = "rbxassetid://125292754706588",
			ActivateKey = "GoldTreadmillActive",
			ManualKey = "ManualGoldAccess",
			Category = "Treadmill"
		},
		Diamond = {
			DevProductId = 3600201427,
			GamepassId = GAMEPASS_IDS.DIAMOND_ACCESS,
			Name = "Diamond Treadmill",
			Image = "rbxassetid://113120316768005",
			ActivateKey = "DiamondTreadmillActive",
			ManualKey = "ManualDiamondAccess",
			Category = "Treadmill"
		},
		Candy = {
			DevProductId = 3600200549,
			GamepassId = GAMEPASS_IDS.CANDY_ACCESS,
			Name = "Candy Treadmill",
			Image = "rbxassetid://92767808101132",
			ActivateKey = "CandyTreadmillActive",
			ManualKey = "ManualCandyAccess",
			Category = "Treadmill"
		},
		Admin = {
			DevProductId = 3600200986,
			GamepassId = GAMEPASS_IDS.ADMIN_ACCESS,
			Name = "Admin Treadmill",
			Image = "rbxassetid://94137693106401",
			ActivateKey = "AdminTreadmillActive",
			ManualKey = "ManualAdminAccess",
			Category = "Treadmill"
		}
	},
	TRAIL_GIFTS = {
		GreenTrail = {
			DevProductId = 3603980009,
			Name = "Green Trail",
			Image = "rbxassetid://116315544877519",
			Category = "Trail"
		},
		BlueTrail = {
			DevProductId = 3603979549,
			Name = "Blue Trail",
			Image = "rbxassetid://72675186287041",
			Category = "Trail"
		},
		PurpleTrail = {
			DevProductId = 3603980209,
			Name = "Purple Trail",
			Image = "rbxassetid://126782245837521",
			Category = "Trail"
		},
		RedTrail = {
			DevProductId = 3603980399,
			Name = "Red Trail",
			Image = "rbxassetid://131298799241304",
			Category = "Trail"
		},
		RainbowTrail = {
			DevProductId = 3603980305,
			Name = "Rainbow Trail",
			Image = "rbxassetid://132750347496620",
			Category = "Trail"
		},
		GalaxyTrail = {
			DevProductId = 3603979789,
			Name = "Galaxy Trail",
			Image = "rbxassetid://74943114716072",
			Category = "Trail"
		},
		CosmicTrail = {
			DevProductId = 3603979681,
			Name = "Cosmic Trail",
			Image = "rbxassetid://129213243546149",
			Category = "Trail"
		},
		VoidTrail = {
			DevProductId = 3603980604,
			Name = "Void Trail",
			Image = "rbxassetid://139930714433891",
			Category = "Trail"
		},
		SupernovaTrail = {
			DevProductId = 3603980539,
			Name = "Supernova Trail",
			Image = "rbxassetid://82185160246144",
			Category = "Trail"
		},
		GodlikeTrail = {
			DevProductId = 3603979901,
			Name = "Godlike Trail",
			Image = "rbxassetid://92114716678863",
			Category = "Trail"
		},
		InfinityTrail = {
			DevProductId = 3603980117,
			Name = "Infinity Trail",
			Image = "rbxassetid://73598304145234",
			Category = "Trail"
		},
		DivineTrail = {
			DevProductId = 3608748096,
			Name = "Divine Trail",
			Image = "rbxassetid://94173433829519",
			Category = "Trail"
		},
		CelestialTrail = {
			DevProductId = 3608748054,
			Name = "Celestial Trail",
			Image = "rbxassetid://102715274333816",
			Category = "Trail"
		},
		EternalTrail = {
			DevProductId = 3608747802,
			Name = "Eternal Trail",
			Image = "rbxassetid://88373259466873",
			Category = "Trail"
		},
		AscendantTrail = {
			DevProductId = 3608747919,
			Name = "Ascendant Trail",
			Image = "rbxassetid://127792880565531",
			Category = "Trail"
		},
		TranscendentTrail = {
			DevProductId = 3608747967,
			Name = "Transcendent Trail",
			Image = "rbxassetid://136230578407229",
			Category = "Trail"
		},
		OrangeTrail = {
			DevProductId = 3710124640,
			Name = "Orange Trail",
			Image = "rbxassetid://125951962131169",
			Category = "Trail"
		},
		PinkTrail = {
			DevProductId = 3710124688,
			Name = "Pink Trail",
			Image = "rbxassetid://140207456671251",
			Category = "Trail"
		},
		CyanTrail = {
			DevProductId = 3710124608,
			Name = "Cyan Trail",
			Image = "rbxassetid://88720701729597",
			Category = "Trail"
		},
		YellowTrail = {
			DevProductId = 3710124592,
			Name = "Yellow Trail",
			Image = "rbxassetid://123469450190967",
			Category = "Trail"
		},
		CaramelTrail = {
			DevProductId = 3710124536,
			Name = "Caramel Trail",
			Image = "rbxassetid://134204881006815",
			Category = "Trail"
		},
		WhiteChocolateTrail = {
			DevProductId = 3710124569,
			Name = "White Chocolate Trail",
			Image = "rbxassetid://122791185151363",
			Category = "Trail"
		},
		FadeTrail = {
			DevProductId = 3711312408,
			Name = "Fade Trail",
			Image = "rbxassetid://107738625645281",
			Category = "Trail"
		},
		CookieDoughTrail = {
			DevProductId = 3712083166,
			Name = "Cookie Dough Trail",
			Image = "rbxassetid://77672686055692",
			Category = "Trail"
		},
		SpookyTrail = {
			DevProductId = 3714849972,
			Name = "Spooky Trail",
			Image = "rbxassetid://109502817101737",
			Category = "Trail"
		},
		BbnoTrail = {
			DevProductId = 3611369423,
			Name = "bbno$ Trail",
			Image = "rbxassetid://82552316132333",
			Category = "Trail"
		},
		DollarsTrail = {
			DevProductId = 3611369452,
			Name = "Dollars Trail",
			Image = "rbxassetid://87065456379711",
			Category = "Trail"
		},
		BrazilTrail = {
			DevProductId = 3611369473,
			Name = "Brazil Trail",
			Image = "rbxassetid://130207591020983",
			Category = "Trail"
		},
		LarperTrail = {
			DevProductId = 3611369594,
			Name = "Larper Trail",
			Image = "rbxassetid://111459278322703",
			Category = "Trail"
		},
		CanadaTrail = {
			DevProductId = 3611369623,
			Name = "Canada Trail",
			Image = "rbxassetid://119977971187426",
			Category = "Trail"
		},
		BurgerTrail = {
			DevProductId = 3611369642,
			Name = "Burger Trail",
			Image = "rbxassetid://122606289396707",
			Category = "Trail"
		},
		BbnoFaceTrail = {
			DevProductId = 3611369711,
			Name = "bbno$ Face Trail",
			Image = "rbxassetid://134642135365486",
			Category = "Trail"
		}
	},
	AURA_GIFTS = {
		FireAura = {
			DevProductId = 3603978890,
			Name = "Fire Aura",
			Image = "rbxassetid://79901429526247",
			Category = "Aura"
		},
		WaterAura = {
			DevProductId = 3603979004,
			Name = "Water Aura",
			Image = "rbxassetid://93367062665094",
			Category = "Aura"
		},
		WindAura = {
			DevProductId = 3603979162,
			Name = "Wind Aura",
			Image = "rbxassetid://100794940939749",
			Category = "Aura"
		},
		GlowAura = {
			DevProductId = 3603979319,
			Name = "Glow Aura",
			Image = "rbxassetid://96628369089363",
			Category = "Aura"
		},
		ElectricAura = {
			DevProductId = 3605481509,
			Name = "Electric Aura",
			Image = "rbxassetid://88995860425004",
			Category = "Aura"
		},
		CandyAura = {
			DevProductId = 3609122779,
			Name = "Candy Aura",
			Image = "rbxassetid://132935336874400",
			Category = "Aura"
		},
		ChocolateAura = {
			DevProductId = 3609122826,
			Name = "Chocolate Aura",
			Image = "rbxassetid://108501379128287",
			Category = "Aura"
		},
		StormAura = {
			DevProductId = 3609122866,
			Name = "Storm Aura",
			Image = "rbxassetid://103592451250334",
			Category = "Aura"
		},
		DollarsAura = {
			DevProductId = 3611546664,
			Name = "Dollars Aura",
			Image = "rbxassetid://125251720917096",
			Category = "Aura"
		},
		BurgerAura = {
			DevProductId = 3611546684,
			Name = "Burger Aura",
			Image = "rbxassetid://78421654997594",
			Category = "Aura"
		},
		AlphabetAura = {
			DevProductId = 3708030775,
			Name = "Alphabet Aura",
			Image = "",
			Category = "Aura"
		},
		DarknessAura = {
			DevProductId = 3708030819,
			Name = "Darkness Aura",
			Image = "",
			Category = "Aura"
		},
		GhostAura = {
			DevProductId = 3714849294,
			Name = "Ghost Aura",
			Image = "rbxassetid://113253935027580",
			Category = "Aura"
		}
	},
	BOOMBOX_GIFTS = {
		Boombox = {
			DevProductId = 3631348221,
			Name = RobuxShopConfig.Boombox.Name,
			Image = ("rbxthumb://type=Asset&id=%d&w=420&h=420"):format(RobuxShopConfig.Boombox.AssetId),
			Category = "Boombox"
		}
	},
	SKIN_GIFTS = {}
}

for k, devProductId in pairs({
	["BBNO$BoxingTreadmill"] = 3611170500,
	["BBNO$BrazilTreadmill"] = 3611170539,
	["BBNO$CosmicTreadmill"] = 3611170559,
	["BBNO$EdamameTreadmill"] = 3611170582,
	["BBNO$FashionTreadmill"] = 3611170606,
	["BBNO$LALALATreadmill"] = 3611170658,
	["BBNO$PlaneTreadmill"] = 3611170678,
	["BBNO$CowboyTreadmill"] = 3611170700
}) do
	local v2 = SKINS[k]
	local SKIN_GIFTS = GiftConfig.SKIN_GIFTS
	local name

	if v2 then
		name = v2.displayName or k
	else
		name = k
	end

	SKIN_GIFTS[k] = {
		DevProductId = devProductId,
		Name = name,
		Image = v2 and v2.icon or "",
		Category = "Skin"
	}
end

GiftConfig.SKIN_BUNDLE_GIFTS = {}

for k, v in pairs(SkinBundles.BUNDLES) do
	GiftConfig.SKIN_BUNDLE_GIFTS[k] = {
		DevProductId = 3611170730,
		Name = v.displayName,
		Image = v.icon,
		Category = "SkinBundle",
		SkinKeys = v.skinKeys
	}
end

GiftConfig.ITEM_GIFT_PRODUCTS = {
	Common = 3603994101,
	Uncommon = 3603994050,
	Rare = 3603993993,
	Epic = 3603993915,
	Legendary = 3603993857,
	Mythic = 3603993797,
	Secret = 3603994195,
	Exotic = 3611453408
}
GiftConfig.ALL_GIFTS = {}

for k, v in pairs(GiftConfig.TREADMILL_GIFTS) do
	GiftConfig.ALL_GIFTS[k] = v
end

for k, v in pairs(GiftConfig.TRAIL_GIFTS) do
	GiftConfig.ALL_GIFTS[k] = v
end

for k, v in pairs(GiftConfig.AURA_GIFTS) do
	GiftConfig.ALL_GIFTS[k] = v
end

for k, v in pairs(GiftConfig.BOOMBOX_GIFTS) do
	GiftConfig.ALL_GIFTS[k] = v
end

for k, v in pairs(GiftConfig.SKIN_GIFTS) do
	GiftConfig.ALL_GIFTS[k] = v
end

for k, v in pairs(GiftConfig.SKIN_BUNDLE_GIFTS) do
	GiftConfig.ALL_GIFTS[k] = v
end

for k, v in pairs(Items.ITEMS) do
	local rarity = v.rarity
	local devProductId = GiftConfig.ITEM_GIFT_PRODUCTS[rarity]

	if devProductId then
		GiftConfig.ALL_GIFTS[k] = {
			DevProductId = devProductId,
			Name = v.name,
			Image = v.icon,
			Category = "Item",
			Rarity = rarity
		}
	end
end

GiftConfig.PRODUCT_TO_GIFT = {}

for k, v in pairs(GiftConfig.TREADMILL_GIFTS) do
	GiftConfig.PRODUCT_TO_GIFT[v.DevProductId] = {
		Type = k,
		GamepassId = v.GamepassId,
		Name = v.Name,
		ActivateKey = v.ActivateKey,
		ManualKey = v.ManualKey,
		Category = "Treadmill"
	}
end

for k, v in pairs(GiftConfig.TRAIL_GIFTS) do
	if v.DevProductId and v.DevProductId > 0 then
		GiftConfig.PRODUCT_TO_GIFT[v.DevProductId] = {
			Type = k,
			Name = v.Name,
			Category = "Trail"
		}
	end
end

for k, v in pairs(GiftConfig.AURA_GIFTS) do
	if v.DevProductId and v.DevProductId > 0 then
		GiftConfig.PRODUCT_TO_GIFT[v.DevProductId] = {
			Type = k,
			Name = v.Name,
			Category = "Aura"
		}
	end
end

for k, v in pairs(GiftConfig.BOOMBOX_GIFTS) do
	GiftConfig.PRODUCT_TO_GIFT[v.DevProductId] = {
		Type = k,
		Name = v.Name,
		Category = "Boombox"
	}
end

for k, v in pairs(GiftConfig.SKIN_GIFTS) do
	GiftConfig.PRODUCT_TO_GIFT[v.DevProductId] = {
		Type = k,
		Name = v.Name,
		Category = "Skin"
	}
end

for k, v in pairs(GiftConfig.SKIN_BUNDLE_GIFTS) do
	if v.DevProductId and v.DevProductId > 0 then
		GiftConfig.PRODUCT_TO_GIFT[v.DevProductId] = {
			Type = k,
			Name = v.Name,
			Category = "SkinBundle"
		}
	end
end

for k, v in pairs(GiftConfig.ITEM_GIFT_PRODUCTS) do
	GiftConfig.PRODUCT_TO_GIFT[v] = {
		Category = "Item",
		Rarity = k
	}
end

return GiftConfig