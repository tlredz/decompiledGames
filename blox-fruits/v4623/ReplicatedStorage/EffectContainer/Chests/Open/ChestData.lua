local LOOSE = {
	"LooseChains",
	"TopDecoration",
	"Chain",
	"Lock",
	"TopMetal",
	"TopMetalLip",
	"TopWood"
}
return {
	{
		NAME = "Silver",
		OPEN_DELAY = 0.01,
		ANCHOR_DELAY = 0.2,
		OPEN_DUR = 1,
		EMIT_DUR = 1,
		LOOT_DUR = 1.5,
		BEAM_DUR = 2,
		LIGHT_COL = Color3.fromRGB(255, 255, 255),
		LIGHT_RADIUS = 10,
		LIGHT_BRIGHT = 1,
		LOOT = {
			PARTICLES = { "Coins" },
			AMOUNT = NumberRange.new(7, 10),
			DELAY = 0.1
		},
		LOOSE = LOOSE,
		SOUND = "SilverChestOpen"
	},
	{
		NAME = "Gold",
		OPEN_DELAY = 0.01,
		ANCHOR_DELAY = 0.2,
		OPEN_DUR = 1,
		EMIT_DUR = 1,
		LOOT_DUR = 1.2,
		BEAM_DUR = 2,
		LIGHT_COL = Color3.fromRGB(255, 223, 128),
		LIGHT_RADIUS = 12,
		LIGHT_BRIGHT = 2,
		LOOT = {
			PARTICLES = { "Coins", "Bills" },
			AMOUNT = NumberRange.new(9, 12),
			DELAY = 0.08
		},
		LOOSE = LOOSE,
		SOUND = "GoldChestOpen"
	},
	{
		NAME = "Diamond",
		OPEN_DELAY = 0.01,
		ANCHOR_DELAY = 0.4,
		OPEN_DUR = 1,
		EMIT_DUR = 1.2,
		LOOT_DUR = 1.6,
		BEAM_DUR = 1.5,
		LIGHT_COL = Color3.fromRGB(129, 228, 255),
		LIGHT_RADIUS = 12,
		LIGHT_BRIGHT = 2,
		LOOT = {
			PARTICLES = { "Coins", "Bills" },
			AMOUNT = NumberRange.new(10, 12),
			DELAY = 0.08
		},
		LOOSE = LOOSE,
		SOUND = "DiamondChestOpen"
	},
	{
		NAME = "Mirage",
		OPEN_DELAY = 0.01,
		ANCHOR_DELAY = 0.6,
		OPEN_DUR = 1,
		EMIT_DUR = 1.7,
		LOOT_DUR = 2,
		BEAM_DUR = 2.2,
		LIGHT_COL = Color3.fromRGB(96, 177, 124),
		LIGHT_RADIUS = 14,
		LIGHT_BRIGHT = 3,
		LOOT = {
			PARTICLES = { "Coins", "Bills" },
			AMOUNT = NumberRange.new(16, 20),
			DELAY = 0.06
		},
		LOOSE = LOOSE,
		SOUND = "MirageChestOpen"
	},
	{
		NAME = "Fragment",
		OPEN_DELAY = 0.01,
		ANCHOR_DELAY = 0.5,
		OPEN_DUR = 1,
		EMIT_DUR = 1.2,
		LOOT_DUR = 1.5,
		BEAM_DUR = 1.5,
		LIGHT_COL = Color3.fromRGB(108, 60, 176),
		LIGHT_RADIUS = 14,
		LIGHT_BRIGHT = 3,
		LOOT = {
			PARTICLES = { "Fragments", "FragmentsSpill" },
			AMOUNT = NumberRange.new(10, 12),
			DELAY = 0.08
		},
		LOOSE = LOOSE,
		SOUND = "FragmentChestOpen"
	}
}