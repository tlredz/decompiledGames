local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local IndexMenu = require(ReplicatedStorage._FRAMEWORK.Features.ItemIndex.IndexMenu)
require(ReplicatedStorage._FRAMEWORK.Features.ItemIndex.Types)
local v = {
	{
		id = "chocoBar",
		label = "Choco Bar",
		icon = "rbxassetid://83707728604228",
		rarity = "Common",
		multiplier = 0.03,
		category = "Main"
	},
	{
		id = "strawberryDonut",
		label = "Strawberry Donut",
		icon = "rbxassetid://128512272946347",
		rarity = "Common",
		multiplier = 0.03,
		category = "Main"
	},
	{
		id = "caramelBow",
		label = "Caramel Bow",
		icon = "rbxassetid://106469124996927",
		rarity = "Common",
		multiplier = 0.03,
		category = "Main"
	},
	{
		id = "chocolatePretzel",
		label = "Chocolate Pretzel",
		icon = "rbxassetid://119909846998032",
		rarity = "Common",
		multiplier = 0.03,
		category = "Main"
	},
	{
		id = "muffinHat",
		label = "Muffin Hat",
		icon = "rbxassetid://79719009938160",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Main"
	},
	{
		id = "candyGlasses",
		label = "Candy Glasses",
		icon = "rbxassetid://85359360299288",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Main"
	},
	{
		id = "cupcakeMic",
		label = "Cupcake Mic",
		icon = "rbxassetid://128503145976233",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Main"
	},
	{
		id = "pinkHeartLollipop",
		label = "Pink Heart Lollipop",
		icon = "rbxassetid://85295132522638",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Main"
	},
	{
		id = "marshmallowHelmet",
		label = "Marshmallow Helmet",
		icon = "rbxassetid://80245687171677",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Main"
	},
	{
		id = "cookieBag",
		label = "Cookie Bag",
		icon = "rbxassetid://139504376531887",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Main"
	},
	{
		id = "strawberryMilkshake",
		label = "Strawberry Milkshake",
		icon = "rbxassetid://98847820818459",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Main"
	},
	{
		id = "pinkGummyBear",
		label = "Pink Gummy Bear",
		icon = "rbxassetid://140237835092604",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Main"
	},
	{
		id = "caramelScooter",
		label = "Caramel Scooter",
		icon = "rbxassetid://101061924588501",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Main"
	},
	{
		id = "chocolateGuitar",
		label = "Chocolate Guitar",
		icon = "rbxassetid://128282102586831",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Main"
	},
	{
		id = "donutShield",
		label = "Donut Shield",
		icon = "rbxassetid://118519530332359",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Main"
	},
	{
		id = "whiteChocolateIceCream",
		label = "White Chocolate Ice Cream",
		icon = "rbxassetid://133121645063925",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Main"
	},
	{
		id = "chocolateCoin",
		label = "Chocolate Coin",
		icon = "rbxassetid://118895208757669",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Main"
	},
	{
		id = "candyCaneSword",
		label = "Candy Cane Sword",
		icon = "rbxassetid://70623031207656",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Main"
	},
	{
		id = "chocolateKart",
		label = "Chocolate Kart",
		icon = "rbxassetid://126379720590319",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Main"
	},
	{
		id = "candyWings",
		label = "Candy Wings",
		icon = "rbxassetid://78731100327570",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Main"
	},
	{
		id = "chocolateMedal",
		label = "Chocolate Medal",
		icon = "rbxassetid://140588458952017",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Main"
	},
	{
		id = "candyCrown",
		label = "Candy Crown",
		icon = "rbxassetid://121997245505981",
		rarity = "Mythic",
		multiplier = 0.5,
		category = "Main"
	},
	{
		id = "chocolateTrophy",
		label = "Chocolate Trophy",
		icon = "rbxassetid://85495284349799",
		rarity = "Mythic",
		multiplier = 0.5,
		category = "Main"
	},
	{
		id = "rIA26Item",
		label = "Voter's Coin",
		icon = "rbxassetid://137472826273602",
		rarity = "Mythic",
		multiplier = 0.5,
		category = "Main"
	},
	{
		id = "goldenMask",
		label = "Golden Mask",
		icon = "rbxassetid://129287120641819",
		rarity = "Secret",
		multiplier = 1,
		category = "Main"
	},
	{
		id = "candyNoob",
		label = "Candy Noob",
		icon = "rbxassetid://77428382442403",
		rarity = "Secret",
		multiplier = 1.5,
		category = "Main"
	},
	{
		id = "candyDominus",
		label = "Candy Dominus",
		icon = "rbxassetid://136721646785674",
		rarity = "Secret",
		multiplier = 1.5,
		category = "Main"
	},
	{
		id = "BrokenMask",
		label = "Broken Mask",
		icon = "rbxassetid://129287120641819",
		rarity = "Unreal",
		multiplier = 2.5,
		category = "Main"
	},
	{
		id = "dumbell",
		label = "Dumbell",
		icon = "rbxassetid://127815647434610",
		rarity = "Common",
		multiplier = 0.03,
		category = "Bbno2026"
	},
	{
		id = "gloves",
		label = "Gloves",
		icon = "rbxassetid://131396066620190",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Bbno2026"
	},
	{
		id = "dollars",
		label = "Dollars",
		icon = "rbxassetid://93366698506428",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Bbno2026"
	},
	{
		id = "watch",
		label = "Watch",
		icon = "rbxassetid://138133358872758",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Bbno2026"
	},
	{
		id = "weLoveBrazil",
		label = "We Love Brazil",
		icon = "rbxassetid://102178085144064",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Bbno2026"
	},
	{
		id = "edamame",
		label = "Edamame",
		icon = "rbxassetid://98237106757186",
		rarity = "Mythic",
		multiplier = 0.5,
		category = "Bbno2026"
	},
	{
		id = "sixtySeven",
		label = "67 67",
		icon = "rbxassetid://118306183094934",
		rarity = "Secret",
		multiplier = 1,
		category = "Bbno2026"
	},
	{
		id = "canadaEarth",
		label = "Canada Earth",
		icon = "rbxassetid://75652047877518",
		rarity = "Exotic",
		multiplier = 2,
		category = "Bbno2026"
	},
	{
		id = "watermelonPop",
		label = "Watermelon Pop",
		icon = "rbxassetid://118601770477847",
		rarity = "Common",
		multiplier = 0.03,
		category = "Summer"
	},
	{
		id = "mangoDonut",
		label = "Mango Donut",
		icon = "rbxassetid://91634496030314",
		rarity = "Common",
		multiplier = 0.03,
		category = "Summer"
	},
	{
		id = "coconutBar",
		label = "Coconut Bar",
		icon = "rbxassetid://97573486011042",
		rarity = "Common",
		multiplier = 0.03,
		category = "Summer"
	},
	{
		id = "pineappleHat",
		label = "Pineapple Hat",
		icon = "rbxassetid://90744282039232",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Summer"
	},
	{
		id = "seashellShades",
		label = "Seashell Shades",
		icon = "rbxassetid://85564651956647",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Summer"
	},
	{
		id = "cherryIceCream",
		label = "Cherry Ice Cream",
		icon = "rbxassetid://108138857154922",
		rarity = "Uncommon",
		multiplier = 0.05,
		category = "Summer"
	},
	{
		id = "coconutHelmet",
		label = "Coconut Helmet",
		icon = "rbxassetid://119891066437221",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Summer"
	},
	{
		id = "tropicalBag",
		label = "Tropical Bag",
		icon = "rbxassetid://71884882442960",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Summer"
	},
	{
		id = "mangoMilkshake",
		label = "Mango Milkshake",
		icon = "rbxassetid://103316341528806",
		rarity = "Rare",
		multiplier = 0.1,
		category = "Summer"
	},
	{
		id = "watermelonSurfboard",
		label = "Watermelon Surfboard",
		icon = "rbxassetid://81027654406223",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Summer"
	},
	{
		id = "coconutShield",
		label = "Coconut Shield",
		icon = "rbxassetid://101968608216656",
		rarity = "Epic",
		multiplier = 0.15,
		category = "Summer"
	},
	{
		id = "coralSword",
		label = "Coral Sword",
		icon = "rbxassetid://105898745609221",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Summer"
	},
	{
		id = "sunsetKart",
		label = "Sunset Kart",
		icon = "rbxassetid://126590274896042",
		rarity = "Legendary",
		multiplier = 0.25,
		category = "Summer"
	},
	{
		id = "seashellCrown",
		label = "Seashell Crown",
		icon = "rbxassetid://125193807655795",
		rarity = "Mythic",
		multiplier = 0.5,
		category = "Summer"
	},
	{
		id = "sunTrophy",
		label = "Sun Trophy",
		icon = "rbxassetid://109902722278263",
		rarity = "Mythic",
		multiplier = 0.5,
		category = "Summer"
	},
	{
		id = "goldenHook",
		label = "Golden Hook",
		icon = "rbxassetid://138843089609973",
		rarity = "Secret",
		multiplier = 1,
		category = "Summer"
	},
	{
		id = "commonSteak",
		label = "Steak",
		icon = "rbxassetid://84958047734262",
		rarity = "Secret",
		multiplier = 1.5,
		category = "SteakEvent"
	},
	{
		id = "limitedSteak",
		label = "Golden Steak",
		icon = "rbxassetid://91165399169158",
		rarity = "Exotic",
		multiplier = 3,
		category = "SteakEvent"
	}
}
table.sort(v, function(a, b)
	if a.multiplier == b.multiplier then
		return a.label < b.label
	end

	return a.multiplier < b.multiplier
end)
local v2 = {}
local categories = {
	{
		id = "all",
		label = "ALL"
	},
	{
		id = "main",
		label = "MAIN",
		categories = { "Main" }
	},
	{
		id = "events",
		label = "EVENTS",
		categories = { "Summer", "Bbno2026", "SteakEvent" }
	}
}
local itemCategories = {
	{
		id = "Main",
		label = "MAIN"
	},
	{
		id = "Bbno2026",
		label = "BBNO$"
	},
	{
		id = "Summer",
		label = "SUMMER"
	},
	{
		id = "SteakEvent",
		label = "STEAK"
	}
}

for i, v5 in ipairs(v) do
	v2[v5.id] = i
end

local controls2 = {
	Variant = UILabs.Choose({ "Panel", "Soft" }),
	OwnedCount = UILabs.Slider(18, 0, #v),
	Tier = UILabs.Slider(2, 0, 5)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function bonusLabel(multiplier: number, p: number)
	local v6 = multiplier + p * math.log(multiplier + 2.0137527074704766 - 1) * 1.5
	return string.format("+%d%%", (math.floor(v6 * 100 + 0.5)))
end

return UILabs.CreateVideStory({
	name = "Item Index — Full",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls
	local source = Vide.source({})

	local function isOwned(p2: number)
		return p2 <= controls.OwnedCount()
	end

	local function tierOf(p2: string, p3: number)
		local v6 = source()[p2]

		if v6 ~= nil then
			return v6
		end

		if p3 <= controls.OwnedCount() then
			return (controls.Tier())
		end

		return 0
	end

	local function cycleTier(p2: string)
		local v6 = v2[p2]

		if v6 == nil then
			return
		end

		local clone = table.clone(source())
		local v7 = source()[p2]

		if v7 == nil then
			v7 = not (v6 <= controls.OwnedCount()) and 0 or controls.Tier()
		end

		clone[p2] = (v7 + 1) % 6
		source(clone)
	end

	local function items()
		local result = {}

		for i, v6 in ipairs(v) do
			local id = v6.id
			local tier = source()[id]

			if tier == nil then
				tier = not (i <= controls.OwnedCount()) and 0 or controls.Tier()
			end

			local v8 = {
				id = v6.id,
				label = v6.label,
				icon = v6.icon,
				rarity = v6.rarity,
				bonus = bonusLabel(v6.multiplier, tier),
				nextBonus = 0,
				stat = "XP",
				tier = 0,
				category = 0,
				owned = 0
			}
			local nextBonus

			if tier < 5 then
				nextBonus = bonusLabel(v6.multiplier, tier + 1)
			end

			v8.nextBonus = nextBonus
			v8.tier = tier
			v8.category = v6.category
			v8.owned = i <= controls.OwnedCount()
			result[i] = v8
		end

		return result
	end

	return IndexMenu({
		Variant = controls.Variant,
		Items = items,
		Categories = categories,
		ItemCategories = itemCategories,
		MainCategory = "Main",
		OnSelect = cycleTier,
		OnClose = function()
			print("[full.story] close")
		end
	})
end)