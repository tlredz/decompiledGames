local Weathers = {
	Clear = {
		Group = "main",
		DisplayName = "Clear",
		Icon = "rbxassetid://16956671633",
		Chance = 0,
		TimeOfDay = "Both",
		CanBeEither = false,
		AllowTradePlaza = true,
		LightingConfig = {
			Clouds = {
				Density = 0,
				Cover = 0
			},
			Atmosphere = {
				Density = 0.35,
				Offset = 0
			}
		}
	},
	Rain = {
		Group = "main",
		DisplayName = "Rain",
		Icon = "rbxassetid://16956671324",
		Chance = 48,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = false,
		LightingConfig = {
			Clouds = {
				Density = 0.5,
				Cover = 0.82
			},
			ColorCorrectionEffect = {
				Brightness = -0.07,
				Contrast = -0.12,
				Saturation = -0.1
			},
			Atmosphere = {
				Density = 0.45,
				Offset = 0
			}
		}
	},
	Windy = {
		Group = "main",
		DisplayName = "Windy",
		Icon = "rbxassetid://17860107825",
		Chance = 55,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = false,
		LightingConfig = {
			Clouds = {
				Density = 0.25,
				Cover = 0.4
			},
			Atmosphere = {
				Density = 0.35,
				Offset = 0
			},
			Terrain = {
				WaterWaveSpeed = 15
			}
		}
	},
	Foggy = {
		Group = "main",
		DisplayName = "Foggy",
		Icon = "rbxassetid://18132224774",
		Chance = 55,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = false,
		LightingConfig = {
			Clouds = {
				Density = 0.5,
				Cover = 0.6
			},
			Atmosphere = {
				Density = 0.4,
				Offset = 0
			},
			Terrain = {
				WaterWaveSpeed = 15
			}
		}
	},
	Stormy = {
		Group = "main",
		DisplayName = "Stormy",
		Icon = "rbxassetid://109169960630186",
		Tooltip = "+20% Lure Speed, -15% Resilience",
		Chance = 10,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = false,
		Mutations = {
			Electric = 10
		},
		RoamingMutations = {
			Electric = 2
		},
		StatBoosts = {
			Lure = 20,
			Resilience = -15
		},
		ChatMessage = "A <b>Storm</b> is brewing... Lightning crackles across the sky.",
		ChatColor = Color3.fromRGB(112, 186, 255),
		LightingConfig = {
			Clouds = {
				Density = 0.7,
				Cover = 0.9,
				Color = Color3.fromRGB(140, 140, 140)
			},
			ColorCorrectionEffect = {
				Brightness = -0.1,
				Contrast = -0.15,
				Saturation = -0.15
			},
			Atmosphere = {
				Density = 0.5,
				Offset = 0,
				Color = Color3.fromRGB(180, 180, 195),
				Decay = Color3.fromRGB(160, 170, 190),
				Glare = 0,
				Haze = 0.8
			},
			Terrain = {
				WaterWaveSize = 0.6,
				WaterWaveSpeed = 30
			}
		}
	},
	Tornado = {
		Group = "main",
		DisplayName = "Tornado",
		Icon = "rbxassetid://74898422304497",
		Tooltip = "+20% Lure Speed",
		Chance = 0,
		TimeOfDay = "Both",
		CanBeEither = false,
		AllowTradePlaza = false,
		StatBoosts = {
			Lure = 20
		},
		LightingConfig = {
			Clouds = {
				Density = 0.75,
				Cover = 0.85,
				Color = Color3.fromRGB(189, 181, 143)
			},
			ColorCorrectionEffect = {
				Brightness = -0.05,
				Contrast = -0.1,
				Saturation = -0.1,
				TintColor = Color3.fromRGB(255, 255, 255)
			},
			Atmosphere = {
				Density = 0.5,
				Offset = 0,
				Color = Color3.fromRGB(148, 148, 148),
				Decay = Color3.fromRGB(79, 88, 93),
				Glare = 0.35,
				Haze = 2.25
			},
			Terrain = {
				WaterWaveSize = 1,
				WaterWaveSpeed = 40
			}
		}
	},
	["Aurora Borealis"] = {
		Group = "meteorological",
		DisplayName = "Aurora Borealis",
		Icon = "rbxassetid://18987581016",
		IconColor = Color3.fromRGB(121, 255, 192),
		Tooltip = "7× Luck",
		Chance = 1,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Aurora = 1
		},
		RoamingMutations = {
			Aurora = 1
		},
		StatBoosts = {
			LuckMultiply = 6
		},
		Protected = true,
		ProtectedMessage = "<font color='#fdff6a'>Tonight's weather is too sacred. The keepers will not let you ruin it.</font>",
		ChatMessage = "Tonight is the illusive <b>Aurora Borealis</b>! Luck is drastically multiplied.",
		ChatColor = Color3.fromRGB(126, 255, 173),
		AnnounceMessage = "<font color = '#f5f5f5'>Tonight is the illusive</font> <font color = '#7effad'><b>Aurora Borealis</b></font><font color = '#f5f5f5'>! Luck is drastically multiplied.</font>",
		AnnounceSound = "aurora",
		BadgeId = 553555175646641,
		LightingConfig = {}
	},
	Eclipse = {
		Group = "meteorological",
		DisplayName = "Eclipse",
		Icon = "rbxassetid://93815001725064",
		IconColor = Color3.fromRGB(255, 152, 62),
		Tooltip = "+4 Disturbance",
		Chance = 8,
		TimeOfDay = "Day",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Solarblaze = 10
		},
		RoamingMutations = {
			Solarblaze = 2
		},
		StatBoosts = {
			Disturbance = 4
		},
		LightingConfig = {
			Sky = {
				MoonTextureId = "rbxassetid://139598411861800",
				MoonAngularSize = 12
			}
		}
	},
	Rainbow = {
		Group = "meteorological",
		DisplayName = "Rainbow",
		Icon = "rbxassetid://103810521111306",
		IconColor = Color3.fromRGB(255, 128, 183),
		Tooltip = "8× Luck, +5% Shiny & Sparkling chance",
		Chance = 1,
		TimeOfDay = "Day",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Mythical = 15,
			RainbowCluster = 5
		},
		RoamingMutations = {
			Mythical = 5,
			RainbowCluster = 1
		},
		StatBoosts = {
			ShinyChance = 5,
			SparklingChance = 5,
			LuckMultiply = 7
		},
		Protected = true,
		ProtectedMessage = "<font color='#FF3E30'>T</font><font color='#FF823A'>o</font><font color='#FFD632'>d</font><font color='#B5D84B'>a</font><font color='#5FD6CC'>y</font><font color='#9D68D8'>'</font><font color='#FF3E30'>s </font><font color='#FF823A'>w</font><font color='#FFD632'>e</font><font color='#B5D84B'>a</font><font color='#5FD6CC'>t</font><font color='#9D68D8'>h</font><font color='#FF3E30'>e</font><font color='#FF823A'>r </font><font color='#FFD632'>i</font><font color='#B5D84B'>s </font><font color='#5FD6CC'>t</font><font color='#9D68D8'>o</font><font color='#FF3E30'>o </font><font color='#FF823A'>s</font><font color='#FFD632'>a</font><font color='#B5D84B'>c</font><font color='#5FD6CC'>r</font><font color='#9D68D8'>e</font><font color='#FF3E30'>d</font><font color='#FF823A'>. </font><font color='#FFD632'>T</font><font color='#B5D84B'>h</font><font color='#5FD6CC'>e </font><font color='#9D68D8'>k</font><font color='#FF3E30'>e</font><font color='#FF823A'>e</font><font color='#FFD632'>p</font><font color='#B5D84B'>e</font><font color='#5FD6CC'>r</font><font color='#9D68D8'>s </font><font color='#FF3E30'>w</font><font color='#FF823A'>i</font><font color='#FFD632'>l</font><font color='#B5D84B'>l </font><font color='#5FD6CC'>n</font><font color='#9D68D8'>o</font><font color='#FF3E30'>t </font><font color='#FF823A'>l</font><font color='#FFD632'>e</font><font color='#B5D84B'>t </font><font color='#5FD6CC'>y</font><font color='#9D68D8'>o</font><font color='#FF3E30'>u </font><font color='#FF823A'>r</font><font color='#FFD632'>u</font><font color='#B5D84B'>i</font><font color='#5FD6CC'>n </font><font color='#9D68D8'>i</font><font color='#FF3E30'>t</font><font color='#FF823A'>.</font>",
		ChatMessage = "A <b>Rainbow</b> has appeared on the horizon.",
		ChatColor = Color3.fromRGB(163, 191, 255),
		LightingConfig = {
			Atmosphere = {
				Density = 0.35,
				Offset = 0
			}
		}
	},
	Starfall = {
		Group = "meteorological",
		DisplayName = "Starfall",
		Icon = "rbxassetid://80284902771699",
		IconColor = Color3.fromRGB(163, 140, 255),
		Tooltip = "The stars are falling.\n+10% True Progress Speed",
		Chance = 1,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = false,
		Mutations = {
			Nova = 10
		},
		RoamingMutations = {
			Nova = 2
		},
		StatBoosts = {
			TrueProgressSpeed = 10
		},
		Protected = true,
		ProtectedMessage = "<font color='#ad99ff'>Stars are falling, the keepers will not let you ruin it.</font>",
		ChatMessage = "<b>Starfall</b> has begun.",
		ChatColor = Color3.fromRGB(136, 89, 255),
		LightingConfig = {
			Atmosphere = {
				Density = 0.35,
				Offset = 0
			}
		}
	},
	["Frost Moon"] = {
		Group = "meteorological",
		DisplayName = "Frost Moon",
		Icon = "rbxassetid://136062614384735",
		IconColor = Color3.fromRGB(134, 207, 255),
		Tooltip = "9× Luck",
		Chance = 0,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Merry = 3,
			Peppermint = 3,
			Gingerbread = 3,
			Frostnova = 1,
			Frostbitten = 2,
			Frozen = 20,
			Permafrost = 0.5
		},
		RoamingMutations = {
			Merry = 1,
			Peppermint = 1,
			Gingerbread = 1,
			Frostnova = 1,
			Frostbitten = 1,
			Frozen = 5,
			Permafrost = 0.5
		},
		StatBoosts = {
			LuckMultiply = 8
		},
		Protected = true,
		ProtectedMessage = "<font color='#54aaff'>Under the Frost Moon's gaze, time itself freezes. The keepers forbid your tampering.</font>",
		ChatMessage = "A chill settles over the world as the <b>Frost Moon</b> ascends...",
		ChatColor = Color3.fromRGB(66, 170, 255),
		AnnounceMessage = "<font color='#f5f5f5'>A chill settles over the world as the</font> <font color='#42aaff'><b>Frost Moon</b></font> <font color='#f5f5f5'> ascends...</font>",
		AnnounceSound = "frostmoon",
		BadgeId = 4173794829392220,
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = -0.025,
				Contrast = 0.1,
				Saturation = 0.1,
				TintColor = Color3.fromRGB(234, 250, 255)
			},
			Atmosphere = {
				Density = 0.54,
				Offset = 0,
				Color = Color3.fromRGB(255, 255, 255),
				Decay = Color3.fromRGB(216, 240, 255),
				Glare = 0,
				Haze = 1.4
			},
			Sky = {
				StarCount = 5000,
				MoonTextureId = "rbxassetid://116046179196630",
				MoonAngularSize = 18,
				SkyboxBk = "rbxassetid://93154192457852",
				SkyboxDn = "rbxassetid://123516087589496",
				SkyboxFt = "rbxassetid://93154192457852",
				SkyboxLf = "rbxassetid://93154192457852",
				SkyboxRt = "rbxassetid://93154192457852",
				SkyboxUp = "rbxassetid://123516087589496"
			},
			Terrain = {
				WaterWaveSpeed = 0
			}
		}
	},
	["Tropical Sun"] = {
		Group = "meteorological",
		DisplayName = "Tropical Sun",
		Icon = "rbxassetid://79523391252060",
		IconColor = Color3.fromRGB(255, 201, 115),
		Tooltip = "9× Luck",
		Chance = 0,
		TimeOfDay = "Day",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Sandy = 5,
			Beached = 5,
			Tropical = 5,
			Paradise = 5,
			Tanned = 15,
			["Super-Tanned"] = 1
		},
		RoamingMutations = {
			Sandy = 1,
			Beached = 1,
			Tropical = 1,
			Paradise = 1,
			Tanned = 4,
			["Super-Tanned"] = 1
		},
		StatBoosts = {
			LuckMultiply = 8
		},
		Protected = true,
		ProtectedMessage = "<font color='#ffd36a'>Under the Tropical Sun's embrace, time slows to a golden haze. The island spirits forbid your interference.</font>",
		ChatMessage = "A warm glow spreads across the world as the <b>Tropical Sun</b> rises...",
		ChatColor = Color3.fromRGB(255, 194, 71),
		AnnounceMessage = "<font color='#fff3d6'>A warm glow spreads across the world as the</font> <font color='#ffd36a'><b>Tropical Sun</b></font> <font color='#fff3d6'> rises...</font>",
		AnnounceSound = "tropicalsun",
		BadgeId = 257343123916833,
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = 0.01,
				Contrast = 0.01,
				Saturation = 0.25,
				TintColor = Color3.fromRGB(255, 233, 228)
			},
			Clouds = {
				Cover = 0,
				Density = 0
			},
			Atmosphere = {
				Density = 0.35,
				Offset = 0,
				Color = Color3.fromRGB(255, 193, 148),
				Decay = Color3.fromRGB(255, 209, 145),
				Glare = 0.79,
				Haze = 1
			},
			Sky = {
				StarCount = 5000,
				SunTextureId = "rbxassetid://98595228318267",
				SunAngularSize = 35,
				SkyboxBk = "rbxassetid://109352512537885",
				SkyboxDn = "rbxassetid://93969482849348",
				SkyboxFt = "rbxassetid://109352512537885",
				SkyboxLf = "rbxassetid://109352512537885",
				SkyboxRt = "rbxassetid://109352512537885",
				SkyboxUp = "rbxassetid://93969482849348"
			},
			SunRaysEffect = {
				Intensity = 0.6,
				Spread = 1
			}
		}
	},
	["Sovereign Surge"] = {
		Group = "sovereign",
		DisplayName = "Sovereign Surge",
		Icon = "rbxassetid://128702641323760",
		IconColor = Color3.fromRGB(100, 211, 255),
		Tooltip = [[
Find <font color='#59a1ff'>Sovereign Beams</font> across the ocean to fish up rare Relics!
2× Luck]],
		Chance = 65,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = true,
		FixedDuration = 900,
		StatBoosts = {
			LuckMultiply = 1
		},
		ChatMessage = "A <b>Sovereign Surge</b> ripples across the sea... beams of relic-light pierce the ocean.",
		ChatColor = Color3.fromRGB(77, 156, 255),
		AnnounceMessage = "A <font color='#59a1ff'><b>Sovereign Surge</b></font> has begun! Find <font color='#59a1ff'>Sovereign Beams</font> across the ocean to fish up more relics!",
		LightingConfig = {
			Atmosphere = {
				Density = 0.3,
				Offset = 0,
				Color = Color3.fromRGB(30, 63, 88),
				Haze = 10,
				Glare = 0
			},
			Lighting = {
				ClockTime = 2.2,
				Brightness = 2,
				Ambient = Color3.fromRGB(64, 82, 95),
				OutdoorAmbient = Color3.fromRGB(68, 148, 194)
			},
			Clouds = {
				Cover = 0.7,
				Density = 0.2,
				Color = Color3.fromRGB(11, 23, 35)
			},
			Sky = {
				MoonAngularSize = 0
			}
		}
	},
	["Sovereign Storm"] = {
		Group = "sovereign",
		DisplayName = "Sovereign Storm",
		Icon = "rbxassetid://87436037959004",
		IconColor = Color3.fromRGB(122, 115, 255),
		Tooltip = [[
Find <font color='#59a1ff'>Sovereign Beams</font> across the ocean to fish up rare Relics!
4× Luck]],
		Chance = 25,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = true,
		FixedDuration = 900,
		StatBoosts = {
			LuckMultiply = 3
		},
		ChatMessage = "A <b>Sovereign Storm</b> is upon us. The Keepers' light intensifies.",
		ChatColor = Color3.fromRGB(114, 111, 209),
		AnnounceMessage = "A <font color='#726FD1'><b>Sovereign Storm</b></font> has begun! Hunt the <font color='#59a1ff'>Sovereign Beams</font> across the ocean — relics are abundant!",
		LightingConfig = {
			Atmosphere = {
				Density = 0.3,
				Offset = 0,
				Color = Color3.fromRGB(70, 29, 88),
				Haze = 10,
				Glare = 0
			},
			Lighting = {
				ClockTime = 2.2,
				Brightness = 2,
				Ambient = Color3.fromRGB(69, 64, 95),
				OutdoorAmbient = Color3.fromRGB(125, 120, 194)
			},
			Clouds = {
				Cover = 0.7,
				Density = 0.2,
				Color = Color3.fromRGB(15, 11, 35)
			},
			Sky = {
				MoonAngularSize = 0
			}
		}
	},
	["Sovereign Reckoning"] = {
		Group = "sovereign",
		DisplayName = "Sovereign Reckoning",
		Icon = "rbxassetid://110018430206748",
		IconColor = Color3.fromRGB(216, 97, 255),
		Tooltip = [[
Find <font color='#59a1ff'>Sovereign Beams</font> across the ocean to fish up rare Relics!
8× Luck]],
		Chance = 10,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = true,
		FixedDuration = 900,
		StatBoosts = {
			LuckMultiply = 7
		},
		ChatMessage = "A <b>Sovereign Reckoning</b> has descended. The world bows to the Keepers.",
		ChatColor = Color3.fromRGB(208, 131, 237),
		AnnounceMessage = "A <font color='#D083ED'><b>Sovereign Reckoning</b></font> has descended! The ocean is flooded with <font color='#ff783c'>Sovereign Beams</font> — the relics are calling!",
		LightingConfig = {
			Atmosphere = {
				Density = 0.3,
				Offset = 0,
				Color = Color3.fromRGB(65, 0, 93),
				Decay = Color3.fromRGB(0, 0, 0),
				Haze = 10,
				Glare = 1
			},
			Lighting = {
				ClockTime = 14,
				Brightness = 2,
				Ambient = Color3.fromRGB(28, 22, 48),
				OutdoorAmbient = Color3.fromRGB(70, 60, 78),
				ColorShift_Top = Color3.fromRGB(140, 0, 255)
			},
			Clouds = {
				Cover = 0.7,
				Density = 0.2,
				Color = Color3.fromRGB(15, 11, 35)
			},
			Sky = {
				SunAngularSize = 0
			}
		}
	},
	["Celestial Congregation"] = {
		Group = "astral",
		DisplayName = "Celestial Congregation",
		Icon = "rbxassetid://108911125456650",
		IconColor = Color3.fromRGB(255, 214, 128),
		Tooltip = "The stars gather overhead.\n+25% Luck",
		Chance = 0,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Celestial = 5
		},
		RoamingMutations = {
			Celestial = 1
		},
		StatBoosts = {
			LuckMultiply = 1.25
		},
		Protected = true,
		ProtectedMessage = "<font color='#ffd680'>The congregation is not yours to disperse.</font>",
		ChatMessage = "The stars have gathered — a <b>Celestial Congregation</b> begins.",
		ChatColor = Color3.fromRGB(255, 214, 128),
		AnnounceMessage = "<font color='#f5f5f5'>The stars have gathered... a</font> <font color='#ffd680'><b>Celestial Congregation</b></font> <font color='#f5f5f5'>begins.</font>",
		AnnounceSound = "celestialcongregation",
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = 0.02,
				Contrast = 0.08,
				Saturation = 0.12,
				TintColor = Color3.fromRGB(255, 246, 224)
			},
			Atmosphere = {
				Density = 0.38,
				Offset = 0,
				Color = Color3.fromRGB(255, 232, 190),
				Decay = Color3.fromRGB(120, 110, 160),
				Glare = 0.2,
				Haze = 1.2
			},
			Clouds = {
				Density = 0.05,
				Cover = 0.1
			},
			Sky = {
				StarCount = 12000
			},
			Lighting = {
				Ambient = Color3.fromRGB(142, 130, 177),
				OutdoorAmbient = Color3.fromRGB(96, 88, 120),
				ColorShift_Top = Color3.fromRGB(255, 214, 128)
			}
		}
	},
	["Abyssal Alignment"] = {
		Group = "astral",
		DisplayName = "Abyssal Alignment",
		Icon = "rbxassetid://96440855620859",
		IconColor = Color3.fromRGB(12, 15, 212),
		Tooltip = "The depths align with the sky.\n+20% Weight",
		Chance = 0,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Abyssal = 5
		},
		RoamingMutations = {
			Abyssal = 1
		},
		StatBoosts = {
			WeightBoost = 20
		},
		Protected = true,
		ProtectedMessage = "<font color='#5effd8'>The alignment holds. You cannot break it.</font>",
		ChatMessage = "The depths answer the sky... An <b>Abyssal Alignment</b> has formed.",
		ChatColor = Color3.fromRGB(61, 71, 255),
		AnnounceMessage = "An <font color='#0c0fd4'><b>Abyssal Alignment</b></font> <font color='#f5f5f5'>has formed.</font>",
		AnnounceSound = "abyssalalignment",
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = 0.05,
				Contrast = 0.12,
				Saturation = -0.05,
				TintColor = Color3.fromRGB(214, 255, 246)
			},
			Atmosphere = {
				Density = 0.5,
				Offset = 0,
				Color = Color3.fromRGB(26, 26, 74),
				Decay = Color3.fromRGB(10, 14, 40),
				Glare = 0,
				Haze = 3
			},
			Clouds = {
				Density = 0.35,
				Cover = 0.75,
				Color = Color3.fromRGB(17, 22, 48)
			},
			Sky = {
				StarCount = 3000,
				MoonAngularSize = 8
			},
			Lighting = {
				Ambient = Color3.fromRGB(140, 154, 218),
				OutdoorAmbient = Color3.fromRGB(97, 115, 181),
				ColorShift_Top = Color3.fromRGB(12, 15, 212)
			},
			Terrain = {
				WaterWaveSize = 0.15,
				WaterWaveSpeed = 6
			}
		}
	},
	["Evershifting Eclipse"] = {
		Group = "astral",
		DisplayName = "Evershifting Eclipse",
		Icon = "rbxassetid://112259946385971",
		IconColor = Color3.fromRGB(255, 152, 62),
		Tooltip = "The seasons blur together.\n+25% XP",
		Chance = 0,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Solarblaze = 5
		},
		RoamingMutations = {
			Solarblaze = 1
		},
		StatBoosts = {
			XpMultiply = 0.25
		},
		Protected = true,
		ProtectedMessage = "<font color='#ff983e'>The eclipse shifts on its own terms.</font>",
		ChatMessage = "An <b>Evershifting Eclipse</b> takes hold.",
		ChatColor = Color3.fromRGB(255, 152, 62),
		AnnounceMessage = "An <font color='#ff983e'><b>Evershifting Eclipse</b></font> <font color='#f5f5f5'>takes hold.</font>",
		AnnounceSound = "evershiftingeclipse",
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = 0,
				Contrast = 0.1,
				Saturation = 0.2,
				TintColor = Color3.fromRGB(255, 236, 214)
			},
			Atmosphere = {
				Density = 0.42,
				Offset = 0,
				Color = Color3.fromRGB(255, 174, 96),
				Decay = Color3.fromRGB(96, 52, 88),
				Glare = 0.45,
				Haze = 1.8
			},
			Clouds = {
				Density = 0.3,
				Cover = 0.45,
				Color = Color3.fromRGB(120, 74, 58)
			},
			Sky = {
				StarCount = 4000,
				MoonTextureId = "rbxassetid://139598411861800",
				MoonAngularSize = 22
			},
			Lighting = {
				Ambient = Color3.fromRGB(163, 116, 99),
				OutdoorAmbient = Color3.fromRGB(120, 82, 62),
				ColorShift_Top = Color3.fromRGB(255, 152, 62),
				ColorShift_Bottom = Color3.fromRGB(90, 60, 110)
			}
		}
	},
	["Meteoric Outburst"] = {
		Group = "astral",
		DisplayName = "Meteoric Outburst",
		Icon = "rbxassetid://103064196616943",
		IconColor = Color3.fromRGB(255, 118, 84),
		Tooltip = "Supercharged Meteors fall out of the sky\nBetter Meteor Loot",
		Chance = 0,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = false,
		Mutations = {
			Chaotic = 5
		},
		RoamingMutations = {
			Chaotic = 1
		},
		Protected = true,
		ProtectedMessage = "<font color='#ff7654'>Supercharged Meteors are falling. Nothing you do will stop them.</font>",
		ChatMessage = "A <b>Meteoric Outburst</b> tears across the sky.",
		ChatColor = Color3.fromRGB(255, 118, 84),
		AnnounceMessage = "A <font color='#ff7654'><b>Meteoric Outburst</b></font> tears across the sky. Meteors are now supercharged.",
		AnnounceSound = "meteoricoutburst",
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = -0.03,
				Contrast = 0.18,
				Saturation = 0.15,
				TintColor = Color3.fromRGB(255, 226, 214)
			},
			Atmosphere = {
				Density = 0.55,
				Offset = 0,
				Color = Color3.fromRGB(88, 40, 28),
				Decay = Color3.fromRGB(40, 18, 14),
				Glare = 0.6,
				Haze = 2.6
			},
			Clouds = {
				Density = 0.5,
				Cover = 0.65,
				Color = Color3.fromRGB(70, 32, 24)
			},
			Sky = {
				StarCount = 6000
			},
			Lighting = {
				Ambient = Color3.fromRGB(162, 87, 69),
				OutdoorAmbient = Color3.fromRGB(122, 62, 42),
				ColorShift_Top = Color3.fromRGB(255, 85, 0)
			},
			Terrain = {
				WaterWaveSize = 0.5,
				WaterWaveSpeed = 22
			}
		}
	},
	["Lunar Eclipse"] = {
		Group = "astral",
		DisplayName = "Lunar Eclipse",
		Icon = "rbxassetid://71217259667090",
		IconColor = Color3.fromRGB(178, 148, 255),
		Tooltip = [[
The moon darkens, and the void bleeds through.
5% Aurora, Nova, Celestial, and Lunar Chance]],
		Chance = 0,
		TimeOfDay = "Night",
		CanBeEither = false,
		AllowTradePlaza = true,
		Mutations = {
			Aurora = 5,
			Nova = 5,
			Celestial = 5,
			Lunar = 5
		},
		RoamingMutations = {
			Aurora = 1,
			Nova = 1,
			Celestial = 1,
			Lunar = 1
		},
		Protected = true,
		ProtectedMessage = "<font color='#b294ff'>The moon is already swallowed. Leave it be.</font>",
		ChatMessage = "The moon darkens... A <b>Lunar Eclipse</b> has begun.",
		ChatColor = Color3.fromRGB(178, 148, 255),
		AnnounceMessage = "A <font color='#b294ff'><b>Lunar Eclipse</b></font> <font color='#f5f5f5'>has begun.</font>",
		AnnounceSound = "lunareclipse",
		LightingConfig = {
			ColorCorrectionEffect = {
				Brightness = -0.08,
				Contrast = 0.15,
				Saturation = 0.1,
				TintColor = Color3.fromRGB(226, 220, 255)
			},
			Atmosphere = {
				Density = 0.58,
				Offset = 0,
				Color = Color3.fromRGB(46, 34, 78),
				Decay = Color3.fromRGB(18, 12, 34),
				Glare = 0.15,
				Haze = 2.2
			},
			Clouds = {
				Density = 0.2,
				Cover = 0.3,
				Color = Color3.fromRGB(30, 22, 52)
			},
			Sky = {
				StarCount = 9000,
				MoonTextureId = "rbxassetid://88868958966855",
				MoonAngularSize = 26
			},
			Lighting = {
				Ambient = Color3.fromRGB(123, 99, 198),
				OutdoorAmbient = Color3.fromRGB(74, 62, 118),
				ColorShift_Top = Color3.fromRGB(178, 148, 255),
				ColorShift_Bottom = Color3.fromRGB(60, 40, 90),
				Brightness = 1.6
			},
			Terrain = {
				WaterWaveSize = 0.2,
				WaterWaveSpeed = 8
			}
		}
	},
	["Tropical Squall"] = {
		Group = "squall",
		DisplayName = "Tropical Squall",
		Icon = "rbxassetid://90365438621376",
		IconColor = Color3.fromRGB(123, 172, 199),
		Tooltip = "2× Luck; Unique things are happening at Skycrest...",
		Chance = 8,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = false,
		StatBoosts = {
			LuckMultiply = 1
		},
		Mutations = {
			Squalled = 15
		},
		RoamingMutations = {
			Squalled = 5
		},
		Protected = true,
		ChatMessage = "A Tropical Squall has descended!",
		ChatColor = Color3.fromRGB(123, 172, 199),
		AnnounceMessage = "A <font color='#7bacc7'><b>Tropical Squall</b></font> has descended!",
		AnnounceSound = "tropicalSquall",
		LightingConfig = {
			Atmosphere = {
				Density = 0.35,
				Offset = 0,
				Color = Color3.fromRGB(111, 121, 135),
				Decay = Color3.fromRGB(88, 114, 141),
				Glare = 3.65,
				Haze = 10
			},
			Lighting = {
				Brightness = 0.12
			},
			SunRaysEffect = {
				Intensity = 0
			}
		}
	},
	["Raging Squall"] = {
		Group = "squall",
		DisplayName = "Raging Squall",
		Icon = "rbxassetid://100716341012952",
		IconColor = Color3.fromRGB(75, 105, 121),
		Tooltip = "4× Luck; Unique things are happening at Skycrest...",
		Chance = 2,
		TimeOfDay = "Both",
		CanBeEither = true,
		AllowTradePlaza = false,
		StatBoosts = {
			LuckMultiply = 3
		},
		Mutations = {
			Squalled = 25
		},
		RoamingMutations = {
			Squalled = 10
		},
		Protected = true,
		ChatMessage = "A Raging Squall has descended!",
		ChatColor = Color3.fromRGB(75, 105, 121),
		AnnounceMessage = "A <font color='#4b6979'><b>Raging Squall</b></font> has descended!",
		AnnounceSound = "ragingSquall",
		LightingConfig = {
			Atmosphere = {
				Density = 0.383,
				Offset = 0,
				Color = Color3.fromRGB(107, 112, 118),
				Decay = Color3.fromRGB(70, 80, 86),
				Glare = 4.13,
				Haze = 10
			},
			Lighting = {
				Brightness = 0.12
			},
			SunRaysEffect = {
				Intensity = 0
			}
		}
	}
}

for k, v in Weathers do
	v.Name = k
end

return Weathers