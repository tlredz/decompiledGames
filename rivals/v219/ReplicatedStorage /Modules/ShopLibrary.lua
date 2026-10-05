local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local ShopEntry = require(ReplicatedStorage.Modules.ShopEntry)
local Utility = require(ReplicatedStorage.Modules.Utility)
local testAttribute

if CONSTANTS.IS_STUDIO then
	testAttribute = TestLibrary:GetTestAttribute("StudioTestUnreleasedWeapons")
else
	testAttribute = CONSTANTS.IS_TESTING_SERVER
end

local testAttribute2 = TestLibrary:GetTestAttribute("StudioEnableFlashSales")
local ShopLibrary = {
	NUM_GLORIOUS_COSMETICS = {},
	Entries = {},
	Weapons = {},
	OwnableWeapons = {},
	OwnableWeaponsAlphabetized = {},
	OwnableWeaponsCanEliminate = {},
	OwnableWeaponReleaseSchedule = {},
	DailyShopCosmeticTypes = {},
	FlashSales = {},
	Lootboxes = {},
	GetWeaponKeyPriceInfo = function(p, p2, p3, p4)
		local v = p4[p2]
		local v2

		if v then
			v2 = v
		elseif p3 > 0 then
			v2 = ItemLibrary.Items[p2] and ItemLibrary.Items[p2].Status == "Standard"
		else
			v2 = false
		end

		return v2 and 0 or p.Weapons[p2] and p.Weapons[p2].KeyPrice or 1e999, v2, v, p3
	end,
	GetReleasedOwnableWeapons = function(self, p, p2)
		local result = {}

		for _, v in pairs(p2 or self.OwnableWeapons) do
			if self:IsWeaponReleased(v, p) then
				table.insert(result, v)
			end
		end

		return result
	end,
	GetTimeUntilWeaponRelease = function(self, p2)
		local weapon = self.Weapons[p2]
		return (weapon and weapon.ReleaseTime or 0) - ServerOsTime:GetRounded()
	end,
	IsWeaponReleased = function(self, p, value)
		return self.Weapons[p] and self:GetTimeUntilWeaponRelease(p) <= (value or 0)
	end,
	GetUpcomingWeapon = function(self)
		for k, v in pairs(self.OwnableWeaponReleaseSchedule) do
			if self:GetTimeUntilWeaponRelease(v) > 0 then
				return v, k
			end
		end
	end
}

local function add_weapon(weapon, keyPrice, value)
	local item = ItemLibrary.Items[weapon]
	local releaseTime = testAttribute and #ShopLibrary.OwnableWeapons or value or 0
	ShopLibrary.Weapons[weapon] = {
		Weapon = weapon,
		KeyPrice = keyPrice,
		ReleaseTime = releaseTime
	}
	table.insert(ShopLibrary.OwnableWeapons, weapon)
	table.insert(ShopLibrary.OwnableWeaponsAlphabetized, weapon)

	if item.CanEliminate then
		table.insert(ShopLibrary.OwnableWeaponsCanEliminate, weapon)
	end

	table.sort(ShopLibrary.OwnableWeaponsAlphabetized, function(a, b)
		return Utility:StringLessThan(string.lower(a), string.lower(b))
	end)
end

add_weapon("Assault Rifle", 0)
add_weapon("Bow", 15)
add_weapon("Burst Rifle", 25)
add_weapon("Flamethrower", 400)
add_weapon("Grenade Launcher", 425)
add_weapon("Minigun", 450)
add_weapon("Paintball Gun", 475)
add_weapon("RPG", 25)
add_weapon("Shotgun", 20)
add_weapon("Sniper", 75)
add_weapon("Handgun", 0)
add_weapon("Flare Gun", 10)
add_weapon("Exogun", 350)
add_weapon("Revolver", 25)
add_weapon("Shorty", 20)
add_weapon("Slingshot", 300)
add_weapon("Uzi", 20)
add_weapon("Fists", 0)
add_weapon("Chainsaw", 15)
add_weapon("Katana", 45)
add_weapon("Knife", 20)
add_weapon("Scythe", 40)
add_weapon("Trowel", 200)
add_weapon("Grenade", 0)
add_weapon("Flashbang", 15)
add_weapon("Medkit", 300)
add_weapon("Molotov", 25)
add_weapon("Smoke Grenade", 10)
add_weapon("Subspace Tripmine", 250)
add_weapon("Freeze Ray", 45, 1720886400)
add_weapon("War Horn", 30, 1735275600)
add_weapon("Satchel", 35, 1734670800)
add_weapon("Battle Axe", 50, 1734066000)
add_weapon("Riot Shield", 45, 1735880400)
add_weapon("Daggers", 30, 1733461200)
add_weapon("Energy Pistols", 400)
add_weapon("Energy Rifle", 425)
add_weapon("Spray", 5, 1736485200)
add_weapon("Crossbow", 35, 1732770000)
add_weapon("Gunblade", 45, 1737090000)
add_weapon("Jump Pad", nil)
add_weapon("Distortion", 700)
add_weapon("Warper", 650)
add_weapon("Warpstone", 400)
add_weapon("Maul", 550)
add_weapon("Permafrost", 600)
add_weapon("Spear", nil)
add_weapon("Grappler", nil)
add_weapon("Wildcat", 35)

local function add_shop_entry(...)
	local v = ShopEntry.new(...)
	ShopLibrary.Entries[v.EntryName] = v
	return v
end

add_shop_entry("Loose", "loose_arena", {
	{
		Name = "Arena",
		Weapon = "IsRandom"
	}
}, {
	WeaponKeys = 25
})
add_shop_entry("Loose", "loose_randomwrap", {
	{
		Name = "Overseer",
		Weapon = "IsRandom"
	}
}, {
	WeaponKeys = 25
}, nil, nil, true)
add_shop_entry("Loose", "loose_universalwrap", {
	{
		Name = "Splattered",
		Weapon = "IsUniversal"
	}
}, {
	WeaponKeys = 250
}, nil, nil, true)
add_shop_entry("Loose", "loose_glorycharm", {
	{
		Name = "Emoji: Imp",
		Weapon = "IsUniversal"
	}
}, {
	Glory = 250
})
add_shop_entry("Loose", "loose_gloryfinisher", {
	{
		Name = "Impaled",
		Weapon = "IsUniversal"
	}
}, {
	Glory = 500
})
add_shop_entry("Loose", "loose_gloryemote", {
	{
		Name = "Flex"
	}
}, {
	Glory = 1000
})
add_shop_entry("Loose", "loose_glorywrap", {
	{
		Name = "Black Glass",
		Weapon = "IsUniversal"
	}
}, {
	Glory = 2000
})

if EventLibrary.IS_ACTIVE then
	add_shop_entry("Loose", "loose_" .. EventLibrary.UNIVERSAL_SHOP_CHARM, {
		{
			Name = EventLibrary.UNIVERSAL_SHOP_CHARM,
			Weapon = "IsUniversal"
		}
	}, {
		EventCurrency = 1000
	}, nil, nil, true)
	add_shop_entry("Loose", "loose_" .. EventLibrary.UNIVERSAL_SHOP_WRAP, {
		{
			Name = EventLibrary.UNIVERSAL_SHOP_WRAP,
			Weapon = "IsUniversal"
		}
	}, {
		EventCurrency = 2000
	}, nil, nil, true)
	add_shop_entry("Loose", "loose_" .. EventLibrary.UNIVERSAL_SHOP_FINISHER, {
		{
			Name = EventLibrary.UNIVERSAL_SHOP_FINISHER,
			Weapon = "IsUniversal"
		}
	}, {
		EventCurrency = 3000
	}, nil, nil, true)
	add_shop_entry("Loose", "loose_" .. EventLibrary.UNIVERSAL_SHOP_EMOTE, {
		{
			Name = EventLibrary.UNIVERSAL_SHOP_EMOTE
		}
	}, {
		EventCurrency = 5000
	}, nil, nil, true)
end

for _, weapon in pairs(ShopLibrary:GetReleasedOwnableWeapons(
	CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET,
	ShopLibrary.OwnableWeaponsAlphabetized
)) do
	local count = 0

	for i = 1, 4 do
		if not (i ~= 3 or ItemLibrary.Items[weapon].CanEliminate) then
			continue
		end

		count += 1
		local v2 = "loose_gloriouscosmetic_" .. count .. "_" .. weapon
		local name

		if i == 1 then
			name = "Glory Coin"
		elseif i == 2 then
			name = "Glorious"
		elseif i == 3 then
			name = "For Glory"
		elseif i == 4 then
			name = "Glorious " .. weapon
		else
			name = assert(false, "???")
		end

		add_shop_entry("Loose", v2, {
			{
				Name = name,
				Weapon = weapon
			}
		}, {
			Glory = i == 1 and 100 or i == 2 and 200 or i == 3 and 300 or i == 4 and 400 or assert(false, "???")
		})
		ShopLibrary.NUM_GLORIOUS_COSMETICS[weapon] = (ShopLibrary.NUM_GLORIOUS_COSMETICS[weapon] or 0) + 1
	end
end

local function add_daily_shop_cosmetic_type(p, pricesByRarity)
	ShopLibrary.DailyShopCosmeticTypes[p] = {
		PricesByRarity = pricesByRarity,
		CosmeticNames = {}
	}
end

ShopLibrary.DailyShopCosmeticTypes.Emote = {
	PricesByRarity = {
		Common = {
			WeaponKeys = 50
		},
		Rare = {
			WeaponKeys = 75
		},
		Legendary = {
			WeaponKeys = 100
		}
	},
	CosmeticNames = {}
}

local function add_daily_shop_cosmetic(p, p2)
	table.insert(ShopLibrary.DailyShopCosmeticTypes[p].CosmeticNames, p2)
	task.defer(function()
		local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
		CosmeticLibrary:ExternallySetCosmeticDescription(p2, "Can be purchased from the Daily Shop")
	end)
end

table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Shoulder Brush")
local v = "Shoulder Brush"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Vegetable")
local v2 = "Vegetable"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v2, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Coo Coo")
local v3 = "Coo Coo"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v3, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Denial")
local v4 = "Denial"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v4, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Facepalm")
local v5 = "Facepalm"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v5, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Kneel")
local v6 = "Kneel"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v6, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Agree")
local v7 = "Agree"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v7, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Think")
local v8 = "Think"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v8, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Salty")
local v9 = "Salty"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v9, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Superhero")
local v10 = "Superhero"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v10, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Cream Cheese Honey")
local v11 = "Cream Cheese Honey"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v11, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Criss Cross")
local v12 = "Criss Cross"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v12, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Side To Side")
local v13 = "Side To Side"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v13, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Off of You")
local v14 = "Off of You"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v14, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Round & Round")
local v15 = "Round & Round"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v15, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Smile")
local v16 = "Smile"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v16, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Take The L")
local v17 = "Take The L"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v17, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Selfie")
local v18 = "Selfie"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v18, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Giant Camera")
local v19 = "Giant Camera"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v19, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Horsey")
local v20 = "Horsey"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v20, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Bad Feeling")
local v21 = "Bad Feeling"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v21, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Hollywoodin'")
local v22 = "Hollywoodin'"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v22, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Bad Boy")
local v23 = "Bad Boy"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v23, "Can be purchased from the Daily Shop")
end)
table.insert(ShopLibrary.DailyShopCosmeticTypes.Emote.CosmeticNames, "Old Timer")
local v24 = "Old Timer"
task.defer(function()
	local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
	CosmeticLibrary:ExternallySetCosmeticDescription(v24, "Can be purchased from the Daily Shop")
end)

local function add_flash_sale(displayName, ...)
	local shopEntry = add_shop_entry("Flash Sale", ...)

	if testAttribute2 then
		shopEntry.PurchaseAppearTime = os.time() + 5
		shopEntry.PurchaseStartTime = os.time() + 10
		shopEntry.PurchaseDuration = 60
	end

	table.insert(ShopLibrary.FlashSales, {
		ShopEntry = shopEntry,
		DisplayName = displayName
	})
end

local function add_lootbox(name, p2, p3, p4, p5, pricesByRarity)
	local v25 = {
		ShopEntry = add_shop_entry("Lootbox", "lootbox_" .. name, {
			{
				Name = name,
				Weapon = "IsRandom",
				Quantity = 1
			}
		}, p2, p3, p4, p5),
		PricesByRarity = pricesByRarity
	}
	ShopLibrary.Lootboxes[name] = v25
end

add_lootbox("Skin Case", {
	SkinTickets = 10
}, 1852079505, 1861165031)
add_lootbox("Skin Case 2", {
	SkinTickets = 10
}, 1892542763, 1892543013)
add_lootbox("Skin Case 3", {
	SkinTickets = 10
}, 3251887315, 3251887576)
add_lootbox("Wrap Box", {
	WeaponKeys = 5
}, nil, nil, nil, {
	Common = {
		WeaponKeys = 5
	},
	Rare = {
		WeaponKeys = 10
	},
	Legendary = {
		WeaponKeys = 15
	}
})
add_lootbox("Wrap Box 2", {
	WeaponKeys = 5
}, nil, nil, nil, {
	Common = {
		WeaponKeys = 5
	},
	Rare = {
		WeaponKeys = 10
	},
	Legendary = {
		WeaponKeys = 15
	}
})
add_lootbox("Wrap Box 3", {
	WeaponKeys = 5
}, nil, nil, nil, {
	Common = {
		WeaponKeys = 5
	},
	Rare = {
		WeaponKeys = 10
	},
	Legendary = {
		WeaponKeys = 15
	}
})
add_lootbox("Charm Capsule", {
	WeaponKeys = 3
}, nil, nil, nil, {
	Common = {
		WeaponKeys = 3
	},
	Rare = {
		WeaponKeys = 4
	},
	Legendary = {
		WeaponKeys = 5
	}
})
add_lootbox("Finisher Pack", {
	WeaponKeys = 10
}, nil, nil, nil, {
	Common = {
		WeaponKeys = 10
	},
	Rare = {
		WeaponKeys = 15
	},
	Legendary = {
		WeaponKeys = 20
	}
})
add_lootbox("Finisher Pack 2", {
	WeaponKeys = 10
}, nil, nil, nil, {
	Common = {
		WeaponKeys = 10
	},
	Rare = {
		WeaponKeys = 15
	},
	Legendary = {
		WeaponKeys = 20
	}
})

if EventLibrary.IS_ACTIVE then
	add_lootbox(EventLibrary.SPECIAL_LOOTBOX_SKINS, {
		SkinTickets = 10
	}, 2154617424, 2154618109, true)
	add_lootbox(EventLibrary.SPECIAL_LOOTBOX_VARIETY, {
		EventCurrency = 30
	}, nil, nil, true, {
		Common = {
			EventCurrency = 30
		},
		Rare = {
			EventCurrency = 60
		},
		Legendary = {
			EventCurrency = 90
		}
	})
end

local function setup_schedule()
	for _, ownableWeapon in pairs(ShopLibrary.OwnableWeapons) do
		table.insert(ShopLibrary.OwnableWeaponReleaseSchedule, ownableWeapon)
	end

	table.sort(ShopLibrary.OwnableWeaponReleaseSchedule, function(a, b)
		local releaseTime = ShopLibrary.Weapons[a].ReleaseTime or -1
		local releaseTime2 = ShopLibrary.Weapons[b].ReleaseTime or -1

		if releaseTime == releaseTime2 then
			return Utility:StringLessThan(a, b)
		end

		return releaseTime < releaseTime2
	end)
end

setup_schedule()
return ShopLibrary