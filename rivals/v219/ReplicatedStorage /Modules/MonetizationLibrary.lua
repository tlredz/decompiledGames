local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
require(ReplicatedStorage.Modules.Utility)
local v = {
	["\\"] = true,
	["|"] = true,
	[" "] = true,
	q = true,
	w = true,
	e = true,
	r = true,
	t = true,
	y = true,
	u = true,
	i = true,
	o = true,
	p = true,
	a = true,
	s = true,
	d = true,
	f = true,
	g = true,
	h = true,
	j = true,
	k = true,
	l = true,
	z = true,
	x = true,
	c = true,
	v = true,
	b = true,
	n = true,
	m = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true,
	["0"] = true,
	["`"] = true,
	["-"] = true,
	["="] = true,
	["["] = true,
	["]"] = true,
	[";"] = true,
	["'"] = true,
	[","] = true,
	["."] = true,
	["/"] = true,
	["~"] = true,
	["!"] = true,
	["@"] = true,
	["#"] = true,
	["$"] = true,
	["%"] = true,
	["^"] = true,
	["&"] = true,
	["*"] = true,
	["("] = true,
	[")"] = true,
	_ = true,
	["+"] = true,
	["{"] = true,
	["}"] = true,
	[":"] = true,
	["\""] = true,
	["<"] = true,
	[">"] = true,
	["?"] = true
}
local MonetizationLibrary = {
	NUM_KEY_BUNDLES = 5,
	NUM_EVENT_CURRENCY_BUNDLES = 5,
	GIFT_REWARD_DATA = "Bubbles",
	BATTLE_PASS_LEVELS = {
		"BattlePassLevels1",
		"BattlePassLevels5",
		"BattlePassLevels10",
		"BattlePassLevels20",
		"BattlePassLevels30",
		"BattlePassLevels40",
		"BattlePassLevels50",
		"BattlePassLevels60",
		"BattlePassLevels70"
	},
	MAX_GIFTING_NOTE_CHARACTER_COUNT = 128,
	VIDEO_AD_REWARDS_ENABLED = true,
	VIDEO_AD_REWARDS_MAX_SCALE_FACTOR = 2,
	VIDEO_ADS_SHOP_OFFER_PLACEMENT_ID = CONSTANTS.IS_TESTING_SERVER and 539056999862972 or 329421439571920,
	MAX_FREE_WEAPON_TRIALS_PER_DAY = 5,
	VIDEO_ADS_WEAPON_TRIAL_PLACEMENT_ID = CONSTANTS.IS_TESTING_SERVER and 711043139604582 or 755928445335559,
	MAX_BILLBOARD_VIDEO_ADS_PER_DAY = 2,
	BILLBOARD_KEYS_REWARD_DATA = {
		Name = "Key",
		Quantity = 1
	},
	BILLBOARD_WRAPS_REWARD_DATA = {
		Name = "Brimstone",
		Quantity = 1,
		Weapon = "IsRandom"
	},
	BILLBOARD_KEYS_VIDEO_AD_PLACEMENT_ID = CONSTANTS.IS_TESTING_SERVER and 329647288529142 or 118857322168446,
	BILLBOARD_WRAPS_VIDEO_AD_PLACEMENT_ID = CONSTANTS.IS_TESTING_SERVER and 842581759201595 or 345653440933702,
	SUPER_STARTER_BUNDLE_OFFER_DURATION = 604800,
	Gamepasses = {},
	Products = {},
	Bundles = {},
	CosmeticBundlesOrder = {},
	Gifts = {},
	GiftOrder = {},
	VideoAdRewards = {},
	UGCs = {},
	UGCAssetIDToName = {},
	UGCOrder = {},
	UGCMilestones = {},
	UGCMilestoneOrder = {},
	GetGiftRewardRobuxSpentRequirement = function(_, p)
		return (math.min(500, 25 + 25 * p))
	end,
	GetGamepassName = function(p, p2)
		for k, gamepass in pairs(p.Gamepasses) do
			if p2 == gamepass.GamepassID then
				return k
			end
		end
	end,
	GetProductName = function(p, p2)
		for k, product in pairs(p.Products) do
			if p2 == product.ProductID then
				return k
			end
		end
	end
}

function MonetizationLibrary.GetBundleByProductID(_, p)
	for k, bundle in pairs(MonetizationLibrary.Bundles) do
		if bundle.ProductID == p then
			return k
		end
	end
end

function MonetizationLibrary.GetBundleContainingReward(_, p)
	for k, bundle in pairs(MonetizationLibrary.Bundles) do
		for _, reward in pairs(bundle.Rewards) do
			if reward.Name == p then
				return k
			end
		end
	end
end

function MonetizationLibrary.GetStandardWeaponBundleWeapons(_)
	local result = {}

	for _, v2 in pairs(ShopLibrary:GetReleasedOwnableWeapons(
		CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET,
		ShopLibrary.OwnableWeaponsAlphabetized
	)) do
		if table.find(CONSTANTS.DEFAULT_WEAPONS, v2) or ItemLibrary.Items[v2].Status ~= "Standard" or not ShopLibrary.Weapons[v2].KeyPrice then
			continue
		end

		table.insert(result, v2)
	end

	return result
end

function MonetizationLibrary.SanitizeGiftNote(p, value)
	if typeof(value) ~= "string" or #value == 0 then
		return nil
	end

	local v2 = string.sub(value, 1, (math.min(#value, p.MAX_GIFTING_NOTE_CHARACTER_COUNT)))
	local v3 = ""

	for i = 1, #v2 do
		local v4 = string.sub(v2, i, i)
		v3 ..= not v[string.lower(v4)] and "#" or v4
	end

	return v3
end

function MonetizationLibrary.GetNextUGCMilestone(p, p2)
	for k, v2 in pairs(p.UGCMilestoneOrder) do
		local uGCMilestone = p.UGCMilestones[v2]

		if uGCMilestone.PurchaseRequirement <= p2 then
			continue
		end

		local v3 = p.UGCMilestoneOrder[k - 1]
		local v4

		if v3 then
			v4 = p.UGCMilestones[v3]
		end

		return uGCMilestone, v4
	end
end

function MonetizationLibrary.GetNumVideoAdsForFreeWeaponTrial(_, p)
	local item = ItemLibrary.Items[p]
	local keyPrice = ShopLibrary.Weapons[p] and ShopLibrary.Weapons[p].KeyPrice

	if item and item.Status == "Standard" and keyPrice then
		return (math.max(2, (math.floor(keyPrice / 7.5))))
	end

	return nil
end

function MonetizationLibrary.GetNumVideoAdsForBillboardReward(_, p)
	return 3 + 1 * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function add_gamepass(p, gamepassID, displayName, staticRobuxPrice)
	MonetizationLibrary.Gamepasses[p] = {
		GamepassID = gamepassID,
		DisplayName = displayName,
		StaticRobuxPrice = staticRobuxPrice,
		BundleName = nil
	}
end

add_gamepass("StandardWeaponsBundle", 838203071, "Standard Weapons Bundle", 999) -- equivalent call inferred; original call site unknown
add_gamepass("ClassicBundle", 838160059, "Classic Bundle", 1149) -- equivalent call inferred; original call site unknown
add_gamepass("HeavyDutyBundle", 838198043, "Heavy Duty Bundle", 1899) -- equivalent call inferred; original call site unknown
add_gamepass("ExogunBundle", 838087219, "Exogun Bundle", 649) -- equivalent call inferred; original call site unknown
add_gamepass("MedkitBundle", 837904767, "Medkit Bundle", 249) -- equivalent call inferred; original call site unknown
add_gamepass("StarterBundle", 839491390, "Starter Bundle", 49) -- equivalent call inferred; original call site unknown
add_gamepass("EnergyBundle", 977061826, "Energy Bundle", 1299) -- equivalent call inferred; original call site unknown
add_gamepass("RPGBundle", 1162134376, "RPG Bundle", 124) -- equivalent call inferred; original call site unknown

local function add_product(name, productID, displayName, options)
	local v2 = {
		Name = name,
		ProductID = productID,
		DisplayName = displayName
	}

	for k, v3 in pairs(options or {}) do
		v2[k] = v3
	end

	MonetizationLibrary.Products[name] = v2
end

add_product("RefreshTasks", 1852077788, "Refresh Daily Tasks")
add_product("DailySkin1Common", 1852078966, "Common Skin #1")
add_product("DailySkin1Rare", 1852080069, "Rare Skin #1")
add_product("DailySkin1Legendary", 1852068440, "Legendary Skin #1")
add_product("DailySkin2Common", 1857673571, "Common Skin #2")
add_product("DailySkin2Rare", 1857673748, "Rare Skin #2")
add_product("DailySkin2Legendary", 1857673858, "Legendary Skin #2")
add_product("DailySkin3Common", 2151911761, "Common Skin #3")
add_product("DailySkin3Rare", 2151911909, "Rare Skin #3")
add_product("DailySkin3Legendary", 2151912016, "Legendary Skin #3")
add_product("DailySkin4Common", 2151912274, "Common Skin #4")
add_product("DailySkin4Rare", 2151912453, "Rare Skin #4")
add_product("DailySkin4Legendary", 2151912592, "Legendary Skin #4")
add_product("DailySkin5Common", 2151912371, "Common Skin #5")
add_product("DailySkin5Rare", 2151912504, "Rare Skin #5")
add_product("DailySkin5Legendary", 2151912645, "Legendary Skin #5")
add_product(
	"VideoAdRewardShopOffer",
	CONSTANTS.IS_TESTING_SERVER and 3328255161 or 3322045009,
	"Video Ad Reward - Shop Offer"
)
add_product(
	"VideoAdRewardPlayWithReward",
	CONSTANTS.IS_TESTING_SERVER and 3592874068 or 3592870962,
	"Video Ad Reward - Play With Reward"
)
add_product(
	"VideoAdRewardWeaponTrial",
	CONSTANTS.IS_TESTING_SERVER and 3592920078 or 3592919946,
	"Video Ad Reward - Free Weapon Trial"
)
add_product(
	"VideoAdRewardBillboardKeys",
	CONSTANTS.IS_TESTING_SERVER and 3592980242 or 3592980112,
	"Video Ad Reward - Billboard Keys"
)
add_product(
	"VideoAdRewardBillboardWraps",
	CONSTANTS.IS_TESTING_SERVER and 3592980378 or 3592980464,
	"Video Ad Reward - Billboard Wraps"
)
add_product("BattlePassLevels1", 3406958794, "+1 Season Pass Level", {
	BattlePassLevelIncrement = 1
})
add_product("BattlePassLevels5", 3406958927, "+5 Season Pass Levels", {
	BattlePassLevelIncrement = 5
})
add_product("BattlePassLevels10", 3406959039, "+10 Season Pass Levels", {
	BattlePassLevelIncrement = 10
})
add_product("BattlePassLevels20", 3406959143, "+20 Season Pass Levels", {
	BattlePassLevelIncrement = 20
})
add_product("BattlePassLevels30", 3406962774, "+30 Season Pass Levels", {
	BattlePassLevelIncrement = 30
})
add_product("BattlePassLevels40", 3406959259, "+40 Season Pass Levels", {
	BattlePassLevelIncrement = 40
})
add_product("BattlePassLevels50", 3406962880, "+50 Season Pass Levels", {
	BattlePassLevelIncrement = 50
})
add_product("BattlePassLevels60", 3406963062, "+60 Season Pass Levels", {
	BattlePassLevelIncrement = 60
})
add_product("BattlePassLevels70", 3406959434, "+70 Season Pass Levels", {
	BattlePassLevelIncrement = 70
})

local function add_bundle(p, bundleName, displayName, productID, gamepassName, rewards, bubbleText, options)
	for _, item in pairs(rewards) do
		assert(item.Name)
	end

	local v2 = {
		Type = p,
		DisplayName = displayName,
		ProductID = productID,
		GamepassName = gamepassName,
		Rewards = rewards,
		BubbleText = bubbleText
	}

	for k, v3 in pairs(options or {}) do
		v2[k] = v3
	end

	MonetizationLibrary.Bundles[bundleName] = v2

	if gamepassName then
		MonetizationLibrary.Gamepasses[gamepassName].BundleName = bundleName
	end
end

add_bundle("Currency", "keybundle_1", "Key Bundle", 1851594490, nil, {
	{
		Name = "Key",
		Quantity = 10
	}
})
add_bundle("Currency", "keybundle_2", "Mega Key Bundle", 1851594599, nil, {
	{
		Name = "Key",
		Quantity = 40
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 1
	}
})
add_bundle("Currency", "keybundle_3", "Super Key Bundle", 1851594741, nil, {
	{
		Name = "Key",
		Quantity = 90
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 3
	},
	{
		Name = "Wrap Box 3",
		Weapon = "IsRandom",
		Quantity = 1
	},
	{
		Name = "Mini Key",
		Weapon = "IsRandom",
		Quantity = 1
	}
})
add_bundle("Currency", "keybundle_4", "Ultra Key Bundle", 1851594902, nil, {
	{
		Name = "Key",
		Quantity = 450
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 15
	},
	{
		Name = "Wrap Box 3",
		Weapon = "IsRandom",
		Quantity = 5
	},
	{
		Name = "Mini Key",
		Weapon = "IsRandom",
		Quantity = 5
	},
	{
		Name = "Luxurious",
		Weapon = "IsRandom",
		Quantity = 2
	},
	{
		Name = "Opulent",
		Weapon = "IsRandom",
		Quantity = 1
	},
	{
		Name = "Enerkey Rifle",
		Weapon = "Energy Rifle"
	}
})
add_bundle("Currency", "keybundle_5", "Legendary Key Bundle", 1851595031, nil, {
	{
		Name = "Key",
		Quantity = 1100
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 40
	},
	{
		Name = "Wrap Box 3",
		Weapon = "IsRandom",
		Quantity = 15
	},
	{
		Name = "Mini Key",
		Weapon = "IsRandom",
		Quantity = 15
	},
	{
		Name = "Luxurious",
		Weapon = "IsRandom",
		Quantity = 5
	},
	{
		Name = "Opulent",
		Weapon = "IsRandom",
		Quantity = 3
	},
	{
		Name = "Enerkey Pistols",
		Weapon = "Energy Pistols"
	},
	{
		Name = "Skin Case 3",
		Weapon = "IsRandom",
		Quantity = 1
	}
})

if EventLibrary.IS_ACTIVE then
	local displayName = CurrencyLibrary.Info.EventCurrency.DisplayName
	add_bundle("Currency", "eventcurrencybundle_1", displayName .. " Bundle", 2155532324, nil, {
		{
			Name = "EventCurrency",
			Quantity = 100
		}
	})
	add_bundle("Currency", "eventcurrencybundle_2", "Mega " .. displayName .. " Bundle", 2155532405, nil, {
		{
			Name = "EventCurrency",
			Quantity = 400
		},
		{
			Name = EventLibrary.SPECIAL_LOOTBOX_VARIETY,
			Weapon = "IsRandom",
			Quantity = 1
		}
	})
	add_bundle("Currency", "eventcurrencybundle_3", "Super " .. displayName .. " Bundle", 2155532505, nil, {
		{
			Name = "EventCurrency",
			Quantity = 900
		},
		{
			Name = EventLibrary.SPECIAL_LOOTBOX_VARIETY,
			Weapon = "IsRandom",
			Quantity = 3
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_CHARM,
			Weapon = "IsRandom",
			Quantity = 1
		}
	})
	add_bundle("Currency", "eventcurrencybundle_4", "Ultra " .. displayName .. " Bundle", 2155532614, nil, {
		{
			Name = "EventCurrency",
			Quantity = 4500
		},
		{
			Name = EventLibrary.SPECIAL_LOOTBOX_VARIETY,
			Weapon = "IsRandom",
			Quantity = 15
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_CHARM,
			Weapon = "IsRandom",
			Quantity = 5
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_WRAP,
			Weapon = "IsRandom",
			Quantity = 2
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_FINISHER,
			Weapon = "IsRandom",
			Quantity = 1
		}
	})
	add_bundle("Currency", "eventcurrencybundle_5", "Legendary " .. displayName .. " Bundle", 2155532697, nil, {
		{
			Name = "EventCurrency",
			Quantity = 11000
		},
		{
			Name = EventLibrary.SPECIAL_LOOTBOX_VARIETY,
			Weapon = "IsRandom",
			Quantity = 30
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_CHARM,
			Weapon = "IsRandom",
			Quantity = 15
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_WRAP,
			Weapon = "IsRandom",
			Quantity = 6
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_FINISHER,
			Weapon = "IsRandom",
			Quantity = 3
		},
		{
			Name = EventLibrary.CURRENCY_BUNDLE_SKIN,
			Weapon = CosmeticLibrary.Cosmetics[EventLibrary.CURRENCY_BUNDLE_SKIN].ItemName
		},
		{
			Name = EventLibrary.SPECIAL_LOOTBOX_SKINS,
			Weapon = "IsRandom",
			Quantity = 1
		}
	})
end

add_bundle("Product", "superstarter_bundle", "Super Starter Bundle", 3710468157, nil, {
	{
		Name = "Plasma Wildcat",
		Weapon = "Wildcat"
	},
	{
		Name = "Wildcat"
	},
	{
		Name = "Spray"
	},
	{
		Name = "Chainsaw"
	},
	{
		Name = "Flashbang"
	},
	{
		Name = "Key",
		Quantity = 25
	}
}, "x15 VALUE")
add_bundle("Gamepass", "starter_bundle", "Starter Bundle", nil, "StarterBundle", {
	{
		Name = "Standard Weapon Crate",
		Quantity = 1
	},
	{
		Name = "Shorty"
	},
	{
		Name = "Too Shorty",
		Weapon = "Shorty"
	},
	{
		Name = "Paint",
		Weapon = "IsUniversal"
	},
	{
		Name = "Emoji: Nauseated",
		Weapon = "IsUniversal"
	},
	{
		Name = "Stiff",
		Weapon = "IsUniversal"
	},
	{
		Name = "Key",
		Quantity = 10
	}
}, "x12 VALUE")
add_bundle("Gamepass", "standardweapons_bundle", "Standard Weapons Bundle", nil, "StandardWeaponsBundle", {
	{
		Name = "Disco",
		Weapon = "IsUniversal"
	},
	{
		Name = "Mini Disco Ball",
		Weapon = "IsUniversal"
	},
	{
		Name = "Boogie",
		Weapon = "IsUniversal"
	},
	{
		Name = "Wrap Box",
		Weapon = "IsRandom",
		Quantity = 5
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 10
	},
	{
		Name = "Key",
		Quantity = 15
	}
}, "x3 VALUE")
add_bundle("Gamepass", "classic_bundle", "Classic Bundle", nil, "ClassicBundle", {
	{
		Name = "Paintball Gun"
	},
	{
		Name = "Slingshot"
	},
	{
		Name = "Trowel"
	},
	{
		Name = "Subspace Tripmine"
	},
	{
		Name = "Classic",
		Weapon = "IsUniversal"
	},
	{
		Name = "Mini Ban Hammer",
		Weapon = "IsUniversal"
	},
	{
		Name = "OOF",
		Weapon = "IsUniversal"
	},
	{
		Name = "Wrap Box",
		Weapon = "IsRandom",
		Quantity = 10
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 20
	},
	{
		Name = "Key",
		Quantity = 40
	}
}, "x7 VALUE")
add_bundle("Gamepass", "heavyduty_bundle", "Heavy Duty Bundle", nil, "HeavyDutyBundle", {
	{
		Name = "Grenade Launcher"
	},
	{
		Name = "Minigun"
	},
	{
		Name = "Flamethrower"
	},
	{
		Name = "Magma",
		Weapon = "IsUniversal"
	},
	{
		Name = "Explosion",
		Weapon = "IsUniversal"
	},
	{
		Name = "Ignite",
		Weapon = "IsUniversal"
	},
	{
		Name = "Wrap Box",
		Weapon = "IsRandom",
		Quantity = 10
	},
	{
		Name = "Charm Capsule",
		Weapon = "IsRandom",
		Quantity = 20
	},
	{
		Name = "Key",
		Quantity = 40
	}
}, "x4 VALUE")
add_bundle("Gamepass", "exogun_bundle", "Exogun Bundle", nil, "ExogunBundle", {
	{
		Name = "Exogun"
	},
	{
		Name = "Wondergun",
		Weapon = "Exogun"
	},
	{
		Name = "Nebula",
		Weapon = "IsUniversal"
	},
	{
		Name = "Alien Head",
		Weapon = "IsUniversal"
	},
	{
		Name = "Low Gravity",
		Weapon = "IsUniversal"
	},
	{
		Name = "Wrap Box",
		Weapon = "IsRandom",
		Quantity = 15
	},
	{
		Name = "Key",
		Quantity = 20
	}
}, "x4 VALUE")
add_bundle("Gamepass", "medkit_bundle", "Medkit Bundle", nil, "MedkitBundle", {
	{
		Name = "Medkit"
	},
	{
		Name = "Briefcase",
		Weapon = "Medkit"
	},
	{
		Name = "Aurum",
		Weapon = "IsUniversal"
	},
	{
		Name = "First Aid",
		Weapon = "IsUniversal"
	},
	{
		Name = "Heartbeat",
		Weapon = "IsUniversal"
	},
	{
		Name = "Wrap Box",
		Weapon = "IsRandom",
		Quantity = 15
	},
	{
		Name = "Key",
		Quantity = 20
	}
}, "x10 VALUE")
add_bundle("Gamepass", "energy_bundle", "Energy Bundle", nil, "EnergyBundle", {
	{
		Name = "Energy Rifle"
	},
	{
		Name = "Energy Pistols"
	},
	{
		Name = "Apex Rifle",
		Weapon = "Energy Rifle"
	},
	{
		Name = "Apex Pistols",
		Weapon = "Energy Pistols"
	},
	{
		Name = ".dll",
		Weapon = "IsUniversal"
	},
	{
		Name = "Energy Cell",
		Weapon = "IsUniversal"
	},
	{
		Name = "Beacon",
		Weapon = "IsUniversal"
	}
}, "x5 VALUE")
add_bundle("Gamepass", "rpg_bundle", "RPG Bundle", nil, "RPGBundle", {
	{
		Name = "RPG"
	},
	{
		Name = "Pencil Launcher",
		Weapon = "RPG"
	},
	{
		Name = "Emoji: Nerd",
		Weapon = "IsUniversal"
	},
	{
		Name = "Cardboard",
		Weapon = "IsUniversal"
	},
	{
		Name = "Erased",
		Weapon = "IsUniversal"
	},
	{
		Name = "Key",
		Quantity = 5
	}
}, "x3 VALUE")

if SeasonLibrary.CurrentSeason.BattlePassActive then
	add_bundle("Product", "primeseason_bundle", "Prime Bundle", 3406969974, nil, {
		{
			Name = "Prime Season Pass"
		},
		{
			Name = "Prime Nametag"
		}
	}, "<s>" .. utf8.char(57346) .. " 724</s>", {
		BattlePassMaxPassTrackNum = 2,
		UnlockNowDisplayName = "Prime Season Pass",
		UnlockNowWeaponStatusUIEffect = "Prime"
	})
	add_bundle("Product", "contrabandseason_bundle", "Contraband Bundle", 3406992213, nil, {
		{
			Name = "Prime Season Pass"
		},
		{
			Name = "Contraband Nametag"
		},
		{
			Name = "Season Pass Level",
			Quantity = SeasonLibrary.SEASON_PASS_LEVELS_IN_SEASON_BUNDLE
		},
		{
			Name = "Prime Goodie Bag",
			Quantity = 10,
			Weapon = "IsRandom"
		},
		{
			Name = SeasonLibrary.CurrentSeason.ContrabandBundleSkinName,
			Quantity = 1,
			Weapon = CosmeticLibrary.Cosmetics[SeasonLibrary.CurrentSeason.ContrabandBundleSkinName].ItemName
		},
		{
			Name = SeasonLibrary.CurrentSeason.ContrabandBundleWrapName,
			Quantity = 1,
			Weapon = "IsUniversal"
		},
		{
			Name = SeasonLibrary.CurrentSeason.ContrabandBundleCharmName,
			Quantity = 1,
			Weapon = "IsUniversal"
		},
		{
			Name = SeasonLibrary.CurrentSeason.ContrabandBundleFinisherName,
			Quantity = 1,
			Weapon = "IsUniversal"
		},
		{
			Name = SeasonLibrary.CurrentSeason.ContrabandBundleEmoteName,
			Quantity = 1
		}
	}, "<s>" .. utf8.char(57346) .. " 2,499</s>", {
		BattlePassMaxPassTrackNum = 2,
		BattlePassLevelIncrement = SeasonLibrary.SEASON_PASS_LEVELS_IN_SEASON_BUNDLE
	})
end

local function add_cosmetic_bundle(p, bundleName, displayName, productID, giftProductID, rewardsWithIndividualProductIDs)
	for _, item in pairs(rewardsWithIndividualProductIDs) do
		CosmeticLibrary:ExternallySetCosmeticDescription(
			item[3].Name,
			string.format(p and "Used to be included in the %s" or "Included in the %s", displayName)
		)
	end

	if p then
		return
	end

	local rewards = {}
	local setRobuxTextArgs = {}

	for _, item in pairs(rewardsWithIndividualProductIDs) do
		table.insert(rewards, item[3])

		if not item[1] then
			continue
		end

		table.insert(setRobuxTextArgs, item[1])
		table.insert(setRobuxTextArgs, Enum.InfoType.Product)
	end

	add_bundle("Product", bundleName, displayName, productID, nil, rewards, nil, {
		IsCosmeticBundle = true,
		RewardsWithIndividualProductIDs = rewardsWithIndividualProductIDs,
		SetRobuxTextArgs = setRobuxTextArgs,
		GiftProductID = giftProductID
	})
	table.insert(MonetizationLibrary.CosmeticBundlesOrder, bundleName)
end

add_cosmetic_bundle(nil, "pixel_bundle", "Pixel Bundle", 3535136080, 2146952782, {
	{
		3535139215,
		3535796474,
		{
			Name = "Pixel Burst",
			Weapon = "Burst Rifle"
		}
	},
	{
		3535139428,
		3535796544,
		{
			Name = "Pixel Handgun",
			Weapon = "Handgun"
		}
	},
	{
		3535139535,
		3535796623,
		{
			Name = "Pixel Katana",
			Weapon = "Katana"
		}
	},
	{
		3535139628,
		3535796722,
		{
			Name = "Pixel Flashbang",
			Weapon = "Flashbang"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Geometric",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "EZ",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Pixel Coins",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Coin Block"
		}
	}
})
add_cosmetic_bundle(nil, "balloon_bundle", "Balloon Bundle", 3535217450, 3535800297, {
	{
		3535217737,
		3535800345,
		{
			Name = "Balloon Launcher",
			Weapon = "Grenade Launcher"
		}
	},
	{
		3535217775,
		3535800399,
		{
			Name = "Paintballoon Gun",
			Weapon = "Paintball Gun"
		}
	},
	{
		3535217832,
		3535800453,
		{
			Name = "Balloon Bow",
			Weapon = "Bow"
		}
	},
	{
		3535217904,
		3535800531,
		{
			Name = "Balloon Axe",
			Weapon = "Battle Axe"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Balloon Dog",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Red Rubber",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Inflate",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Whimsical"
		}
	}
})
add_cosmetic_bundle(nil, "nostalgia_bundle", "Nostalgia Bundle", 3535218231, 3535800586, {
	{
		3535218275,
		3535800641,
		{
			Name = "Ban Hammer",
			Weapon = "Maul"
		}
	},
	{
		3535218311,
		3535800699,
		{
			Name = "Rocket Launcher",
			Weapon = "RPG"
		}
	},
	{
		3535218352,
		3535800924,
		{
			Name = "Hyperlaser Guns",
			Weapon = "Energy Pistols"
		}
	},
	{
		3535218430,
		3535800959,
		{
			Name = "Linked Sword",
			Weapon = "Katana"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Happy Home",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "The Heights",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Dematerialize",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Illumina Storm"
		}
	}
})

for _, v2 in pairs({
	{
		3535218018,
		3535801045,
		{
			Name = "Beloved Bow",
			Weapon = "Bow"
		}
	},
	{
		3535218067,
		3535801071,
		{
			Name = "Broken Hearts",
			Weapon = "Daggers"
		}
	},
	{
		3535218104,
		3535801113,
		{
			Name = "Cuddle Bomb",
			Weapon = "Grenade"
		}
	},
	{
		3535218148,
		3535801142,
		{
			Name = "Box of Chocolates",
			Weapon = "Medkit"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Pierced Heart",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Heartfelt",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Poof",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Tango"
		}
	}
}) do
	CosmeticLibrary:ExternallySetCosmeticDescription(
		v2[3].Name,
		string.format("Used to be included in the %s", "Lovely Bundle")
	)
end

for _, v2 in pairs({
	{
		3549289473,
		3549289668,
		{
			Name = "Rainbowthrower",
			Weapon = "Flamethrower"
		}
	},
	{
		3549289501,
		3549289722,
		{
			Name = "Lucky Horseshoe",
			Weapon = "Slingshot"
		}
	},
	{
		3549289534,
		3549289757,
		{
			Name = "Caladbolg",
			Weapon = "Knife"
		}
	},
	{
		3549289575,
		3549289804,
		{
			Name = "Pot o' Keys",
			Weapon = "Subspace Tripmine"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Four-Leaf Clover",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Clovers",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Leprechaunify",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Step Dancing"
		}
	}
}) do
	CosmeticLibrary:ExternallySetCosmeticDescription(
		v2[3].Name,
		string.format("Used to be included in the %s", "Lucky Bundle")
	)
end

add_cosmetic_bundle(nil, "prop_bundle", "Prop Bundle", 3580412457, 3580412891, {
	{
		3580412515,
		3580412913,
		{
			Name = "Extinguisher",
			Weapon = "Flamethrower"
		}
	},
	{
		3580412541,
		3580412953,
		{
			Name = "Toaster",
			Weapon = "Daggers"
		}
	},
	{
		3580412562,
		3580412985,
		{
			Name = "Street Sign",
			Weapon = "Battle Axe"
		}
	},
	{
		3580412593,
		3580413018,
		{
			Name = "Pizza Box",
			Weapon = "Satchel"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Pencil",
			Weapon = "Knife"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Box TV",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "TV Error",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Goofy Brawl",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Scoot"
		}
	}
})
add_cosmetic_bundle(nil, "pirate_bundle", "Pirate Bundle", 3605561386, 3605561751, {
	{
		3605561596,
		3605561781,
		{
			Name = "Kraken Sniper",
			Weapon = "Sniper"
		}
	},
	{
		3605561621,
		3605561802,
		{
			Name = "Cannon Shorty",
			Weapon = "Shorty"
		}
	},
	{
		3605561673,
		3605561828,
		{
			Name = "Pirate Hook",
			Weapon = "Fists"
		}
	},
	{
		3605561690,
		3605561892,
		{
			Name = "Ship In A Bottle",
			Weapon = "Molotov"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Cutlass",
			Weapon = "Katana"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Long Lost Treasure",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Dutchman",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "Spectralized",
			Weapon = "IsUniversal"
		}
	},
	{
		nil,
		nil,
		{
			Name = "X Marks The Spot"
		}
	}
})

local function add_gift(productID, giftType, giftName, isPaidRandomItem, quantity, p6, p7)
	local v2 = giftType == "Gamepass" and MonetizationLibrary.Gamepasses[giftName] or giftType == "Product" and MonetizationLibrary.Products[giftName] or giftType == "Bundle" and MonetizationLibrary.Bundles[giftName] or giftType == "ShopEntry" and ShopLibrary.Entries[giftName] or error("???")
	local v3 = {
		ProductID = productID,
		ProductType = giftType == "Gamepass" and "Gamepass" or "Product",
		GiftType = giftType,
		GiftName = giftName,
		TargetProductID = p7 or giftType == "Gamepass" and v2.GamepassID or giftType == "ShopEntry" and quantity and v2.ProductIDTriple or v2.ProductID,
		DisplayName = p6 or giftType == "ShopEntry" and v2.Rewards[1].Name .. (quantity and " [x3]" or "") or v2.DisplayName,
		IsPaidRandomItem = isPaidRandomItem,
		Quantity = quantity,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(productID)] = v3
	table.insert(MonetizationLibrary.GiftOrder, (tostring(productID)))
end

if SeasonLibrary.CurrentSeason.BattlePassActive then
	local battlePassLevels10 = MonetizationLibrary.Products.BattlePassLevels10 or error("???")
	local v2 = {
		ProductID = 3407624520,
		ProductType = "Product",
		GiftType = "Product",
		GiftName = "BattlePassLevels10",
		TargetProductID = battlePassLevels10.ProductID,
		DisplayName = battlePassLevels10.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(3407624520)] = v2
	table.insert(MonetizationLibrary.GiftOrder, (tostring(3407624520)))
	local primeseason_bundle = MonetizationLibrary.Bundles.primeseason_bundle or error("???")
	local v3 = {
		ProductID = 3407614262,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "primeseason_bundle",
		TargetProductID = primeseason_bundle.ProductID,
		DisplayName = primeseason_bundle.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(3407614262)] = v3
	table.insert(MonetizationLibrary.GiftOrder, (tostring(3407614262)))
	local contrabandseason_bundle = MonetizationLibrary.Bundles.contrabandseason_bundle or error("???")
	local v4 = {
		ProductID = 3407615047,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "contrabandseason_bundle",
		TargetProductID = contrabandseason_bundle.ProductID,
		DisplayName = contrabandseason_bundle.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(3407615047)] = v4
	table.insert(MonetizationLibrary.GiftOrder, (tostring(3407615047)))
end

local standardWeaponsBundle = MonetizationLibrary.Gamepasses.StandardWeaponsBundle or error("???")
local v2 = {
	ProductID = 1890371681,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "StandardWeaponsBundle",
	TargetProductID = standardWeaponsBundle.GamepassID or standardWeaponsBundle.ProductID,
	DisplayName = standardWeaponsBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890371681)] = v2
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890371681)))
local classicBundle = MonetizationLibrary.Gamepasses.ClassicBundle or error("???")
local v3 = {
	ProductID = 1890372364,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "ClassicBundle",
	TargetProductID = classicBundle.GamepassID or classicBundle.ProductID,
	DisplayName = classicBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890372364)] = v3
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890372364)))
local heavyDutyBundle = MonetizationLibrary.Gamepasses.HeavyDutyBundle or error("???")
local v4 = {
	ProductID = 1890372130,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "HeavyDutyBundle",
	TargetProductID = heavyDutyBundle.GamepassID or heavyDutyBundle.ProductID,
	DisplayName = heavyDutyBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890372130)] = v4
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890372130)))
local exogunBundle = MonetizationLibrary.Gamepasses.ExogunBundle or error("???")
local v5 = {
	ProductID = 1890372574,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "ExogunBundle",
	TargetProductID = exogunBundle.GamepassID or exogunBundle.ProductID,
	DisplayName = exogunBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890372574)] = v5
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890372574)))
local medkitBundle = MonetizationLibrary.Gamepasses.MedkitBundle or error("???")
local v6 = {
	ProductID = 1890372831,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "MedkitBundle",
	TargetProductID = medkitBundle.GamepassID or medkitBundle.ProductID,
	DisplayName = medkitBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890372831)] = v6
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890372831)))
local starterBundle = MonetizationLibrary.Gamepasses.StarterBundle or error("???")
local v7 = {
	ProductID = 1890371901,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "StarterBundle",
	TargetProductID = starterBundle.GamepassID or starterBundle.ProductID,
	DisplayName = starterBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890371901)] = v7
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890371901)))
local energyBundle = MonetizationLibrary.Gamepasses.EnergyBundle or error("???")
local v8 = {
	ProductID = 2661338143,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "EnergyBundle",
	TargetProductID = energyBundle.GamepassID or energyBundle.ProductID,
	DisplayName = energyBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(2661338143)] = v8
table.insert(MonetizationLibrary.GiftOrder, (tostring(2661338143)))
local rPGBundle = MonetizationLibrary.Gamepasses.RPGBundle or error("???")
local v9 = {
	ProductID = 3277561206,
	ProductType = "Gamepass",
	GiftType = "Gamepass",
	GiftName = "RPGBundle",
	TargetProductID = rPGBundle.GamepassID or rPGBundle.ProductID,
	DisplayName = rPGBundle.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(3277561206)] = v9
table.insert(MonetizationLibrary.GiftOrder, (tostring(3277561206)))
local lootbox_SkinCase = ShopLibrary.Entries["lootbox_Skin Case"] or error("???")
local v10 = {
	ProductID = 1892544195,
	ProductType = "Product",
	GiftType = "ShopEntry",
	GiftName = "lootbox_Skin Case",
	TargetProductID = lootbox_SkinCase.ProductID,
	DisplayName = lootbox_SkinCase.Rewards[1].Name .. "" or lootbox_SkinCase.DisplayName,
	IsPaidRandomItem = true,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1892544195)] = v10
table.insert(MonetizationLibrary.GiftOrder, (tostring(1892544195)))
local lootbox_SkinCase2 = ShopLibrary.Entries["lootbox_Skin Case"] or error("???")
local v11 = {
	ProductID = 2319692001,
	ProductType = "Product",
	GiftType = "ShopEntry",
	GiftName = "lootbox_Skin Case",
	TargetProductID = lootbox_SkinCase2.ProductIDTriple or lootbox_SkinCase2.ProductID,
	DisplayName = lootbox_SkinCase2.Rewards[1].Name .. " [x3]" or lootbox_SkinCase2.DisplayName,
	IsPaidRandomItem = true,
	Quantity = 3,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(2319692001)] = v11
table.insert(MonetizationLibrary.GiftOrder, (tostring(2319692001)))
local lootbox_SkinCase22 = ShopLibrary.Entries["lootbox_Skin Case 2"] or error("???")
local v12 = {
	ProductID = 1892544449,
	ProductType = "Product",
	GiftType = "ShopEntry",
	GiftName = "lootbox_Skin Case 2",
	TargetProductID = lootbox_SkinCase22.ProductID,
	DisplayName = lootbox_SkinCase22.Rewards[1].Name .. "" or lootbox_SkinCase22.DisplayName,
	IsPaidRandomItem = true,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1892544449)] = v12
table.insert(MonetizationLibrary.GiftOrder, (tostring(1892544449)))
local lootbox_SkinCase23 = ShopLibrary.Entries["lootbox_Skin Case 2"] or error("???")
local v13 = {
	ProductID = 2319692175,
	ProductType = "Product",
	GiftType = "ShopEntry",
	GiftName = "lootbox_Skin Case 2",
	TargetProductID = lootbox_SkinCase23.ProductIDTriple or lootbox_SkinCase23.ProductID,
	DisplayName = lootbox_SkinCase23.Rewards[1].Name .. " [x3]" or lootbox_SkinCase23.DisplayName,
	IsPaidRandomItem = true,
	Quantity = 3,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(2319692175)] = v13
table.insert(MonetizationLibrary.GiftOrder, (tostring(2319692175)))
local lootbox_SkinCase3 = ShopLibrary.Entries["lootbox_Skin Case 3"] or error("???")
local v14 = {
	ProductID = 3251887720,
	ProductType = "Product",
	GiftType = "ShopEntry",
	GiftName = "lootbox_Skin Case 3",
	TargetProductID = lootbox_SkinCase3.ProductID,
	DisplayName = lootbox_SkinCase3.Rewards[1].Name .. "" or lootbox_SkinCase3.DisplayName,
	IsPaidRandomItem = true,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(3251887720)] = v14
table.insert(MonetizationLibrary.GiftOrder, (tostring(3251887720)))
local lootbox_SkinCase32 = ShopLibrary.Entries["lootbox_Skin Case 3"] or error("???")
local v15 = {
	ProductID = 3251887824,
	ProductType = "Product",
	GiftType = "ShopEntry",
	GiftName = "lootbox_Skin Case 3",
	TargetProductID = lootbox_SkinCase32.ProductIDTriple or lootbox_SkinCase32.ProductID,
	DisplayName = lootbox_SkinCase32.Rewards[1].Name .. " [x3]" or lootbox_SkinCase32.DisplayName,
	IsPaidRandomItem = true,
	Quantity = 3,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(3251887824)] = v15
table.insert(MonetizationLibrary.GiftOrder, (tostring(3251887824)))
local keybundle_1 = MonetizationLibrary.Bundles.keybundle_1 or error("???")
local v16 = {
	ProductID = 1890374722,
	ProductType = "Product",
	GiftType = "Bundle",
	GiftName = "keybundle_1",
	TargetProductID = keybundle_1.ProductID,
	DisplayName = keybundle_1.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890374722)] = v16
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890374722)))
local keybundle_2 = MonetizationLibrary.Bundles.keybundle_2 or error("???")
local v17 = {
	ProductID = 1890374959,
	ProductType = "Product",
	GiftType = "Bundle",
	GiftName = "keybundle_2",
	TargetProductID = keybundle_2.ProductID,
	DisplayName = keybundle_2.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890374959)] = v17
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890374959)))
local keybundle_3 = MonetizationLibrary.Bundles.keybundle_3 or error("???")
local v18 = {
	ProductID = 1890375172,
	ProductType = "Product",
	GiftType = "Bundle",
	GiftName = "keybundle_3",
	TargetProductID = keybundle_3.ProductID,
	DisplayName = keybundle_3.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890375172)] = v18
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890375172)))
local keybundle_4 = MonetizationLibrary.Bundles.keybundle_4 or error("???")
local v19 = {
	ProductID = 1890375405,
	ProductType = "Product",
	GiftType = "Bundle",
	GiftName = "keybundle_4",
	TargetProductID = keybundle_4.ProductID,
	DisplayName = keybundle_4.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890375405)] = v19
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890375405)))
local keybundle_5 = MonetizationLibrary.Bundles.keybundle_5 or error("???")
local v20 = {
	ProductID = 1890375611,
	ProductType = "Product",
	GiftType = "Bundle",
	GiftName = "keybundle_5",
	TargetProductID = keybundle_5.ProductID,
	DisplayName = keybundle_5.DisplayName,
	IsPaidRandomItem = nil,
	Quantity = nil,
	ImageID = nil
}
MonetizationLibrary.Gifts[tostring(1890375611)] = v20
table.insert(MonetizationLibrary.GiftOrder, (tostring(1890375611)))

if EventLibrary.IS_ACTIVE then
	local giftName = "lootbox_" .. EventLibrary.SPECIAL_LOOTBOX_SKINS
	local v22 = ShopLibrary.Entries[giftName] or error("???")
	local v23 = {
		ProductID = 2154618268,
		ProductType = "Product",
		GiftType = "ShopEntry",
		GiftName = giftName,
		TargetProductID = v22.ProductID,
		DisplayName = v22.Rewards[1].Name .. "" or v22.DisplayName,
		IsPaidRandomItem = true,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2154618268)] = v23
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2154618268)))
	local giftName2 = "lootbox_" .. EventLibrary.SPECIAL_LOOTBOX_SKINS
	local v25 = ShopLibrary.Entries[giftName2] or error("???")
	local v26 = {
		ProductID = 2319690506,
		ProductType = "Product",
		GiftType = "ShopEntry",
		GiftName = giftName2,
		TargetProductID = v25.ProductIDTriple or v25.ProductID,
		DisplayName = v25.Rewards[1].Name .. " [x3]" or v25.DisplayName,
		IsPaidRandomItem = true,
		Quantity = 3,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2319690506)] = v26
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2319690506)))
	local eventcurrencybundle_1 = MonetizationLibrary.Bundles.eventcurrencybundle_1 or error("???")
	local v27 = {
		ProductID = 2319763472,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "eventcurrencybundle_1",
		TargetProductID = eventcurrencybundle_1.ProductID,
		DisplayName = eventcurrencybundle_1.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2319763472)] = v27
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2319763472)))
	local eventcurrencybundle_2 = MonetizationLibrary.Bundles.eventcurrencybundle_2 or error("???")
	local v28 = {
		ProductID = 2319763545,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "eventcurrencybundle_2",
		TargetProductID = eventcurrencybundle_2.ProductID,
		DisplayName = eventcurrencybundle_2.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2319763545)] = v28
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2319763545)))
	local eventcurrencybundle_3 = MonetizationLibrary.Bundles.eventcurrencybundle_3 or error("???")
	local v29 = {
		ProductID = 2319763627,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "eventcurrencybundle_3",
		TargetProductID = eventcurrencybundle_3.ProductID,
		DisplayName = eventcurrencybundle_3.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2319763627)] = v29
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2319763627)))
	local eventcurrencybundle_4 = MonetizationLibrary.Bundles.eventcurrencybundle_4 or error("???")
	local v30 = {
		ProductID = 2319763722,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "eventcurrencybundle_4",
		TargetProductID = eventcurrencybundle_4.ProductID,
		DisplayName = eventcurrencybundle_4.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2319763722)] = v30
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2319763722)))
	local eventcurrencybundle_5 = MonetizationLibrary.Bundles.eventcurrencybundle_5 or error("???")
	local v31 = {
		ProductID = 2319763802,
		ProductType = "Product",
		GiftType = "Bundle",
		GiftName = "eventcurrencybundle_5",
		TargetProductID = eventcurrencybundle_5.ProductID,
		DisplayName = eventcurrencybundle_5.DisplayName,
		IsPaidRandomItem = nil,
		Quantity = nil,
		ImageID = nil
	}
	MonetizationLibrary.Gifts[tostring(2319763802)] = v31
	table.insert(MonetizationLibrary.GiftOrder, (tostring(2319763802)))
end

for _, giftName in pairs(MonetizationLibrary.CosmeticBundlesOrder) do
	local bundle = MonetizationLibrary.Bundles[giftName]

	if bundle.GiftProductID then
		local giftProductID = bundle.GiftProductID
		local v22 = MonetizationLibrary.Bundles[giftName] or error("???")
		local v23 = {
			ProductID = giftProductID,
			ProductType = "Product",
			GiftType = "Bundle",
			GiftName = giftName,
			TargetProductID = v22.ProductID,
			DisplayName = v22.DisplayName,
			IsPaidRandomItem = nil,
			Quantity = nil,
			ImageID = nil
		}
		MonetizationLibrary.Gifts[tostring(giftProductID)] = v23
		table.insert(MonetizationLibrary.GiftOrder, (tostring(giftProductID)))
	end

	for _, rewardsWithIndividualProductID in pairs(bundle.RewardsWithIndividualProductIDs) do
		if not (rewardsWithIndividualProductID[1] and rewardsWithIndividualProductID[2]) then
			continue
		end

		local productID = rewardsWithIndividualProductID[2]
		local name = rewardsWithIndividualProductID[3].Name
		local v23 = rewardsWithIndividualProductID[1]
		local v24 = MonetizationLibrary.Bundles[giftName] or error("???")
		local v25 = {
			ProductID = productID,
			ProductType = "Product",
			GiftType = "Bundle",
			GiftName = giftName,
			TargetProductID = v23 or v24.ProductID,
			DisplayName = name or v24.DisplayName,
			IsPaidRandomItem = nil,
			Quantity = nil,
			ImageID = nil
		}
		MonetizationLibrary.Gifts[tostring(productID)] = v25
		table.insert(MonetizationLibrary.GiftOrder, (tostring(productID)))
	end
end

local function add_video_ad_reward(numAdsRequired, options, options2)
	table.insert(MonetizationLibrary.VideoAdRewards, {
		NumAdsRequired = numAdsRequired,
		RewardDatas = options or {},
		PreRepetitionRewardDatas = options2 or {}
	})
end

add_video_ad_reward(1, {
	{
		Name = "3D Glasses",
		Quantity = 1,
		Weapon = "IsRandom"
	}
}, nil)
add_video_ad_reward(2, {
	{
		Name = "Glamour",
		Quantity = 1,
		Weapon = "IsRandom"
	}
}, nil)
add_video_ad_reward(3, {
	{
		Name = "Director's Cut",
		Quantity = 1,
		Weapon = "IsRandom"
	}
}, {
	{
		Name = "Key",
		Quantity = 3
	}
})

local function add_ugc(name, assetID, canBeMisleading)
	assert(not MonetizationLibrary.UGCs[name])

	for _, UGC in pairs(MonetizationLibrary.UGCs) do
		assert(UGC.AssetID ~= assetID)
	end

	MonetizationLibrary.UGCs[name] = {
		Name = name,
		AssetID = assetID,
		CanBeMisleading = canBeMisleading
	}
	MonetizationLibrary.UGCAssetIDToName[tostring(assetID)] = name
	table.insert(MonetizationLibrary.UGCOrder, name)
end

add_ugc("clothing_iloverivals1", 137732463728326)
add_ugc("clothing_iloverivals2", 90796679262086)
add_ugc("clothing_arenashirt", 137296265324812)
add_ugc("clothing_arenapants", 129512336852435)
add_ugc("ugc_arenamanhead", 92733410260261)
add_ugc("ugc_removeautoshootsign", 96099566912338)
add_ugc("ugc_rivalskatana", 125867270722283, true)
add_ugc("ugc_rivalsrpkey", 111522988085700, true)
add_ugc("ugc_rivalskeyvolver", 113554056154134, true)
add_ugc("ugc_rivalskeytana", 109723477692566, true)
add_ugc("ugc_rivalskeythe", 124750945461549, true)
add_ugc("ugc_rivalsakey", 107643383612249, true)
add_ugc("ugc_rivalskeyper", 115241839813934, true)
add_ugc("ugc_rivalskeybow", 84129786923826, true)
add_ugc("ugc_rivalsshotkey", 85619994948307, true)
add_ugc("ugc_rivalskeyttleaxe", 112664145011287, true)
add_ugc("ugc_rivalskeyzi", 103972049379360, true)
add_ugc("ugc_rivalskeylisong", 138648784848614, true)
add_ugc("ugc_rivalskeyrambit", 84629336575689, true)
add_ugc("ugc_rivalskeynais", 105245077140577, true)
add_ugc("ugc_rivalskeyst", 117095370466098, true)
add_ugc("ugc_shouldermedkitty", 103869769768832, true)
add_ugc("ugc_rivalsnotebook", 133770605510980, true)
add_ugc("ugc_targetmask", 127292540343907)
add_ugc("ugc_eliminatedtrollface", 121118883943056)
add_ugc("ugc_disconnectedtrollface", 73916910731449)
add_ugc("ugc_unranked", 115861376533108)
add_ugc("ugc_bronzerank", 101681212276850)
add_ugc("ugc_silverrank", 140214523497602)
add_ugc("ugc_goldrank", 102276356750407)
add_ugc("ugc_platinumrank", 110101090201266)
add_ugc("ugc_diamondrank", 133745283061883)
add_ugc("ugc_onyxrank", 85555348152612)
add_ugc("ugc_nemesisrank", 110806369909684)
add_ugc("ugc_archnemesisrank", 102797305676607)

local function add_ugc_milestone(name, purchaseRequirement, reward)
	assert(not MonetizationLibrary.UGCMilestones[name])
	local v21 = {
		Name = name,
		PurchaseRequirement = purchaseRequirement,
		Reward = reward
	}
	MonetizationLibrary.UGCMilestones[name] = v21
	table.insert(MonetizationLibrary.UGCMilestoneOrder, name)

	if CosmeticLibrary.Cosmetics[v21.Reward.Name] then
		CosmeticLibrary:ExternallySetCosmeticDescription(
			v21.Reward.Name,
			"Earned from purchasing " .. v21.PurchaseRequirement .. " UGC item" .. (v21.PurchaseRequirement == 1 and "" or "s")
		)
	end
end

add_ugc_milestone("ugc_milestone0", 1, {
	Name = "Skin Ticket",
	Quantity = 1
})
add_ugc_milestone("ugc_milestone1", 5, {
	Name = "Sneaker",
	Weapon = "IsUniversal"
})
add_ugc_milestone("ugc_milestone2", 10, {
	Name = "Heirloom",
	Weapon = "IsUniversal"
})
add_ugc_milestone("ugc_milestone3", 15, {
	Name = "Plushify",
	Weapon = "IsUniversal"
})
add_ugc_milestone("ugc_milestone4", 20, {
	Name = "Busting A Move"
})
add_ugc_milestone("ugc_milestone5", 25, {
	Name = "Fist",
	Weapon = "Fists"
})
return MonetizationLibrary