return {
	Types = {
		Fish = {
			"Char",
			"Cooked Char",
			"Clownfish",
			"Cooked Clownfish",
			"Eel",
			"Cooked Eel",
			"Mackerel",
			"Cooked Mackerel",
			"Salmon",
			"Cooked Salmon",
			"Swordfish",
			"Cooked Swordfish",
			"Shark",
			"Cooked Shark",
			"Lava Eel",
			"Lionfish",
			"Cooked Lava Eel",
			"Cooked Lionfish"
		},
		Steak = { "Steak", "Cooked Steak" },
		Ribs = { "Ribs", "Cooked Ribs" }
	},
	["Seafood Chowder"] = {
		ChefLevel = 1,
		Ingredients = { "Fish", "Any", "Any" },
		Description = "+140 Hunger",
		Priority = 2
	},
	["Steak Dinner"] = {
		ChefLevel = 1,
		Ingredients = { "Steak", "Any", "Any" },
		Description = "+150 Hunger",
		Priority = 3
	},
	["Pumpkin Soup"] = {
		ChefLevel = 1,
		Ingredients = { "Pumpkin", "Any", "Any" },
		Description = "Keeps you warm for 2 minutes",
		Priority = 4
	},
	["BBQ Ribs"] = {
		ChefLevel = 1,
		Ingredients = { "Ribs", "Any", "Any" },
		Description = "Restores lots of hunger and some health",
		Priority = 5
	},
	["Carrot Cake"] = {
		ChefLevel = 2,
		Ingredients = { "Cake", "Carrot", "Carrot" },
		Description = "Great night vision for 5 minutes and +40 health",
		Priority = 6
	},
	["Jar o' Jelly"] = {
		ChefLevel = 3,
		Ingredients = { "Jellyfish", "Any", "Any" },
		Description = "Heal to full health and gain a 5 minute speed boost",
		Priority = 7
	}
}