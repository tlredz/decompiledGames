return {
	Currencies = {
		Coins = {
			DataPath = "Stats.coins",
			DataName = "coins",
			Display = "C$",
			Formatting = "%s C$",
			Icon = "rbxassetid://118279268040315",
			LabelProperties = {
				TextColor3 = Color3.fromRGB(255, 253, 228)
			}
		},
		Embercoins = {
			DataPath = "Stats.embercoins",
			DataName = "embercoins",
			Display = "E$",
			Formatting = "%s E$",
			Icon = "rbxassetid://125202790684860",
			LabelProperties = {
				TextColor3 = Color3.fromRGB(110, 255, 243)
			}
		}
	},
	WorldStats = {
		["Sea 1"] = {
			Display = "Sea 1",
			Currency = "Coins",
			LevelCap = 2000,
			XpPerLevel = 190,
			DefaultBestiary = "Moosewood",
			InvalidWorldModifiers = {
				Rod = 0.5
			},
			["Sea Level"] = 127
		},
		["Sea 2"] = {
			Display = "Sea 2",
			Currency = "Embercoins",
			LevelCap = 2000,
			XpPerLevel = 190,
			DefaultBestiary = "All",
			InvalidWorldModifiers = {
				Rod = 0.5
			},
			["Sea Level"] = 74.023
		}
	},
	DefaultPlace = "Sea 1",
	Places = {
		[131579468225600] = "Sea 1",
		[115164489660674] = "Sea 2",
		[140688791331730] = "Sea 1",
		[124935812290893] = "Sea 1",
		[135499799161875] = "Sea 2",
		[16732694052] = "Sea 1",
		[131716211654599] = "Sea 1",
		[106011698424775] = "Sea 1",
		[72907489978215] = "Sea 2",
		[70451556031302] = "Sea 2",
		[95655505523303] = "Sea 1",
		[78575977164594] = "Sea 1",
		[99519129453387] = "Sea 1"
	},
	DefaultPlaceType = "Main",
	PlaceTypes = {
		[131579468225600] = "Main",
		[115164489660674] = "Main",
		[140688791331730] = "Main",
		[124935812290893] = "Main",
		[135499799161875] = "Main",
		[16732694052] = "Main",
		[131716211654599] = "NewPlayer",
		[106011698424775] = "DeepSea",
		[72907489978215] = "Main",
		[70451556031302] = "DeepSea",
		[95655505523303] = "TradePlaza",
		[78575977164594] = "TradePlaza",
		[99519129453387] = "TradePlaza"
	},
	Games = {
		[7431162737] = {
			["Sea 1"] = { 124935812290893, 109078222235130 },
			["Sea 2"] = { 115164489660674, 95655505523303 }
		},
		[6756890519] = {
			["Sea 1"] = 131579468225600,
			["Sea 2"] = { 115164489660674, 78575977164594 }
		},
		[5750914919] = {
			["Sea 1"] = { 16732694052, 131716211654599, 106011698424775 },
			["Sea 2"] = { 72907489978215, 70451556031302, 99519129453387 }
		}
	}
}