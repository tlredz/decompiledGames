return {
	Potions = {
		["All Season Potion"] = {
			DisplayName = "All Season Potion",
			Description = "This potion makes fish that are specific to a season possible to be caught even outside of the season, alongside a moderate boost to Lure Speed. This potion has a 20% chance of becoming available in the recipes UI when changing seasons.",
			Icon = "rbxassetid://128790211567708",
			ItemIcons = { "rbxassetid://91163615704045" },
			Color = Color3.fromRGB(255, 61, 236),
			PossiblesIngredients = {
				"Scylla",
				"Crowned Anglerfish",
				"Magma Leviathan",
				"Frozen Leviathan",
				"Crystallized Seadragon",
				"Lobster King",
				"Orca"
			},
			TiersChance = { 100 },
			TiersCraftDelay = { 21600 },
			TiersProducts = {}
		},
		["Luck Potion"] = {
			DisplayName = "Luck Potion",
			Description = "This potion gives you boosted Luck.",
			Icon = "rbxassetid://18198637843",
			ItemIcons = { "rbxassetid://80831441911714", "rbxassetid://84713047559989", "rbxassetid://92382493002977" },
			IconColor = Color3.fromRGB(0, 255, 106),
			Color = Color3.fromRGB(181, 255, 20),
			PossiblesIngredients = {
				"Megalodon",
				"Tartaruga",
				"Great White Shark",
				"Great Hammerhead Shark",
				"Voltfish",
				"Alligator"
			},
			TiersChance = { 45, 30, 25 },
			TiersCraftDelay = { 60, 300, 600 },
			TiersProducts = {}
		},
		["Lure Speed Potion"] = {
			DisplayName = "Lure Speed Potion",
			Description = "This potion gives you boosted Lure Speed.",
			Icon = "rbxassetid://72310870382459",
			ItemIcons = {
				"rbxassetid://104943576088184",
				"rbxassetid://111978961667800",
				"rbxassetid://140182909252728"
			},
			Color = Color3.fromRGB(24, 182, 255),
			PossiblesIngredients = {
				"Tartaruga",
				"Captain's Goldfish",
				"Colossal Squid",
				"Whiptail Catfish",
				"Pufferfish"
			},
			TiersChance = { 45, 30, 25 },
			TiersCraftDelay = { 60, 300, 600 },
			TiersProducts = {}
		},
		["Glitched Potion"] = {
			DisplayName = "Glitched Potion",
			Description = "This potion causes fish duplication when fishing.",
			Icon = "rbxassetid://74286595580144",
			ItemIcons = {
				"rbxassetid://86282309913830",
				"rbxassetid://106957064691512",
				"rbxassetid://109287553368574"
			},
			Color = Color3.fromRGB(255, 0, 55),
			PossiblesIngredients = {
				"Scylla",
				"Lobster King",
				"Moby",
				"Sea Leviathan",
				"Orca"
			},
			TiersChance = { 100, 0, 0 },
			TiersCraftDelay = { 3600, 7200, 10800 },
			TiersProducts = {}
		}
	}
}