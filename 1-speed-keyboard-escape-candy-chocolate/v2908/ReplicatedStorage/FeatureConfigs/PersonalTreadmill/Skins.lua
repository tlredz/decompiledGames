local SKINS = {
	DefaultTreadmill = {
		modelName = "Default",
		displayName = "Default Treadmill",
		description = "The classic personal treadmill.",
		icon = "rbxassetid://92354488821094",
		color = Color3.new(0.643137, 0.282353, 0.105882),
		category = "F2P",
		isLocked = false,
		isRobux = false
	},
	["BBNO$Treadmill"] = {
		displayName = "BBNO$ Treadmill",
		modelName = "BBNO$Treadmill",
		description = "Exclusive reward for completing the BBno$ event.",
		icon = "rbxassetid://134366443249667",
		color = Color3.fromRGB(51, 88, 130),
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = true,
		isRobux = false,
		unlockHint = "Unlocked by completing the BBno$ event"
	},
	["BBNO$BoxingTreadmill"] = {
		modelName = "BBNO$BoxingTreadmill",
		price = 3611159138,
		displayName = "BBNO$: Boxing Treadmill",
		description = "Step into the ring with bbno$'s boxing look.",
		color = Color3.fromRGB(165, 72, 73),
		icon = "rbxassetid://130503790281786",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$BrazilTreadmill"] = {
		modelName = "BBNO$BrazilTreadmill",
		price = 3611159921,
		displayName = "BBNO$: Brazil Treadmill",
		description = "Carnival energy on every stride.",
		color = Color3.fromRGB(244, 198, 118),
		icon = "rbxassetid://75022446462614",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$CosmicTreadmill"] = {
		modelName = "BBNO$CosmicTreadmill",
		price = 3611159960,
		displayName = "BBNO$: Cosmic Treadmill",
		description = "Out-of-this-world bbno$ drip.",
		color = Color3.fromRGB(172, 182, 239),
		icon = "rbxassetid://84010094568129",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$EdamameTreadmill"] = {
		modelName = "BBNO$EdamameTreadmill",
		price = 3611160004,
		displayName = "BBNO$: Edamame Treadmill",
		description = "Fresh green energy from the edamame era.",
		color = Color3.fromRGB(160, 255, 168),
		icon = "rbxassetid://82755146574495",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$FashionTreadmill"] = {
		modelName = "BBNO$FashionTreadmill",
		price = 3611160040,
		displayName = "BBNO$: Fashion Treadmill",
		description = "Runway-ready bbno$ style.",
		color = Color3.fromRGB(186, 77, 79),
		icon = "rbxassetid://134731958457505",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$LALALATreadmill"] = {
		modelName = "BBNO$LALALATreadmill",
		price = 3611160104,
		displayName = "BBNO$: LALALA Treadmill",
		description = "Sing along while you grind.",
		color = Color3.fromRGB(218, 172, 255),
		icon = "rbxassetid://111383791916474",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$PlaneTreadmill"] = {
		modelName = "BBNO$PlaneTreadmill",
		price = 3611160134,
		displayName = "BBNO$: Plane Treadmill",
		description = "Take off with bbno$'s plane fit.",
		color = Color3.fromRGB(232, 232, 232),
		icon = "rbxassetid://86888750074950",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	["BBNO$CowboyTreadmill"] = {
		modelName = "BBNO$CowboyTreadmill",
		price = 3611160175,
		displayName = "BBNO$: Cowboy's Treadmill",
		description = "Yeehaw meets bbno$.",
		color = Color3.fromRGB(158, 125, 102),
		icon = "rbxassetid://134230518317640",
		category = "BBNO",
		EventKey = "Bbno2026",
		canGift = false,
		isLocked = false,
		isRobux = false,
		isProduct = true
	},
	SteakTreadmill = {
		displayName = "Steak Treadmill",
		modelName = "SteakTreadmill",
		description = "Well-done grind.",
		icon = "rbxassetid://71796320433967",
		color = Color3.fromRGB(150, 60, 55),
		category = "Other",
		isLocked = false,
		isRobux = false,
		isProduct = false,
		unlockHint = "Unlocked by admin grant"
	},
	AdminTreadmill = {
		displayName = "Admin Treadmill",
		modelName = "Admin",
		description = "Personal treadmill skin from the Admin gamepass.",
		icon = "rbxassetid://94137693106401",
		price = 1799430547,
		color = Color3.new(0.764706, 0.129412, 0.129412),
		category = "Gamepass",
		isLocked = false,
		isRobux = true
	},
	DiamondTreadmill = {
		modelName = "Diamond",
		price = 1724758929,
		displayName = "Diamond Treadmill",
		description = "Personal treadmill skin from the Diamond gamepass.",
		icon = "rbxassetid://86071441418100",
		color = Color3.new(0, 0.611765, 0.968627),
		category = "Gamepass",
		isLocked = false,
		isRobux = true
	},
	CandyTreadmill = {
		modelName = "Candy",
		price = 1799448573,
		displayName = "Candy Treadmill",
		description = "Personal treadmill skin from the Candy gamepass.",
		icon = "rbxassetid://92767808101132",
		color = Color3.new(0.960784, 0.419608, 0.780392),
		category = "Gamepass",
		isLocked = false,
		isRobux = true
	},
	GoldTreadmill = {
		modelName = "Gold",
		price = 1674743386,
		displayName = "Gold Treadmill",
		description = "Personal treadmill skin from the Gold gamepass.",
		icon = "rbxassetid://137155275018163",
		color = Color3.new(1, 0.85098, 0),
		category = "Gamepass",
		isLocked = false,
		isRobux = true
	}
}
local v2 = {
	"F2P",
	"BBNO",
	"Gamepass",
	"Other"
}
local v3 = {}

for i, v5 in ipairs(v2) do
	v3[v5] = i
end

return {
	SKINS = SKINS,
	CATEGORY_ORDER = v2,
	CATEGORY_LABELS = {
		F2P = "Free",
		BBNO = "BBNO$ Collab",
		Gamepass = "Gamepass Skins",
		Other = "Exclusive"
	},
	CATEGORY_RANK = v3,
	LAYOUT_CATEGORY_BLOCK = 1000,
	LAYOUT_BUNDLE_OFFSET = 900
}