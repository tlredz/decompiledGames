local v = {
	{
		name = "4 NUGGETS",
		image = "rbxassetid://101773505175952",
		toolName = "JungleNuggets4"
	},
	{
		name = "8 NUGGETS",
		image = "rbxassetid://88027854023838",
		toolName = "JungleNuggets8"
	},
	{
		name = "12 NUGGETS",
		image = "rbxassetid://134726279876804",
		toolName = "JungleNuggets12"
	}
}
local v2 = {
	{
		name = "Banana Ice Cream Small",
		image = "rbxassetid://127411080866710",
		toolName = "BananaIceCreamSmall"
	},
	{
		name = "Banana Ice Cream Medium",
		image = "rbxassetid://119853649291674",
		toolName = "BananaIceCreamMedium"
	},
	{
		name = "Banana Ice Cream Large",
		image = "rbxassetid://70734035566838",
		toolName = "BananaIceCreamLarge"
	}
}
local v3 = {
	{
		name = "Fruit Punch",
		image = "rbxassetid://133931729248432",
		toolName = "JettsFruitPunch"
	},
	{
		name = "Mango Fuego Sauce Bottle",
		image = "rbxassetid://85812166671946",
		toolName = "MangoFuegoSauceBottle"
	}
}
return {
	JETTS_MENU_ITEMS = v,
	JETTS_MENU_ITEMS_CONES = v2,
	JETTS_MENU_ITEMS_OTHERS = v3,
	JETTS_MENU_ITEMS_ALL = {
		MangoFuegoSauceBottle = v3[2],
		JettsFruitPunch = v3[1],
		BananaIceCreamSmall = v2[1],
		BananaIceCreamMedium = v2[2],
		BananaIceCreamLarge = v2[3],
		JungleNuggets4 = v[1],
		JungleNuggets8 = v[2],
		JungleNuggets12 = v[3]
	}
}