return {
	RESTOCK_INTERVAL = 300,
	EPOCH = 1750000000,
	MYTHIC_CYCLE = 60,
	SECRET_CYCLE = 480,
	STOCK_RANGES = {
		Common = {
			min = 1,
			max = 3
		},
		Uncommon = {
			min = 1,
			max = 3
		},
		Rare = {
			min = 1,
			max = 2
		},
		Mysterious = {
			min = 1,
			max = 1
		}
	},
	MYSTERIOUS_WEIGHTS = {
		{
			rarity = "Epic",
			weight = 85
		},
		{
			rarity = "Legendary",
			weight = 15
		}
	},
	PERSONAL_MYSTERIOUS_WEIGHTS = {
		{
			rarity = "Epic",
			weight = 83.9
		},
		{
			rarity = "Legendary",
			weight = 15
		},
		{
			rarity = "Mythic",
			weight = 1
		},
		{
			rarity = "Secret",
			weight = 0.1
		}
	},
	WINS_PRICES = {
		Common = 3000,
		Uncommon = 25000,
		Rare = 250000,
		Epic = 3500000,
		Legendary = 40000000,
		Mythic = 350000000,
		Secret = 1000000000
	},
	DEV_PRODUCTS = {
		Common = 3596948477,
		Uncommon = 3596948525,
		Rare = 3596948567,
		Epic = 3596948642,
		Legendary = 3596948750,
		Mythic = 3596948860,
		Secret = 3603021862,
		Exotic = 3611453359
	},
	RESTOCK_PRODUCT_ID = 3596948097,
	RESTOCK_ENABLED = false,
	MYSTERIOUS_ROBUX_PRICES = {
		Epic = "489",
		Legendary = "689",
		Mythic = "989",
		Secret = "1285"
	},
	MYSTERIOUS_WINS_DISPLAY = {
		Epic = "3.5M",
		Legendary = "40M",
		Mythic = "350M",
		Secret = "1B"
	},
	MYSTERIOUS_RARITY_COLORS = {
		Epic = Color3.fromRGB(220, 69, 247),
		Legendary = Color3.fromRGB(247, 206, 60),
		Mythic = Color3.fromRGB(255, 0, 0),
		Secret = Color3.fromRGB(255, 255, 255)
	},
	MYSTERIOUS_FRAME_COLORS = {
		Epic = Color3.fromRGB(115, 17, 186),
		Legendary = Color3.fromRGB(211, 175, 43),
		Mythic = Color3.fromRGB(255, 255, 255),
		Secret = Color3.fromRGB(40, 40, 40)
	},
	COOLDOWN = 0.3
}