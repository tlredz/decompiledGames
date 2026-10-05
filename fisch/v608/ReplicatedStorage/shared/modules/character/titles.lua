local Titles = {
	Spectre = {
		Text = "Spectre",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 237, 255)),
			ColorSequenceKeypoint.new(0.3333333333333333, Color3.fromRGB(222, 93, 253)),
			ColorSequenceKeypoint.new(0.6666666666666666, Color3.fromRGB(114, 98, 254)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 141, 251))
		}),
		StrokeColor = Color3.fromRGB(84, 84, 84),
		Bold = true
	},
	["Cozy Cruiser"] = {
		Text = "Cozy Cruiser",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 121, 121)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(189, 52, 52)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 121, 121))
		}),
		StrokeColor = Color3.fromRGB(75, 30, 30),
		Bold = true
	},
	["Scurvy Speedster"] = {
		Text = "Scurvy Speedster",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 111)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 147, 63)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 111))
		}),
		StrokeColor = Color3.fromRGB(75, 54, 30),
		Bold = true
	},
	["Magma Drifter"] = {
		Text = "Magma Drifter",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 206, 107)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 149, 73)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 112, 112))
		}),
		StrokeColor = Color3.fromRGB(75, 54, 30),
		Bold = true
	},
	["Frostbite Flyer"] = {
		Text = "Frostbite Flyer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 233, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(112, 143, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 233, 255))
		}),
		StrokeColor = Color3.fromRGB(30, 54, 75),
		Bold = true
	},
	["Fossil Fueled"] = {
		Text = "Fossil Fueled",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 186, 55)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 168, 62)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 186, 55))
		}),
		StrokeColor = Color3.fromRGB(53, 75, 29),
		Bold = true
	},
	["CHAMPION OF THE VEIL"] = {
		Text = "◈━〔CONQUEROR OF THE RIFT | S3 #1〕━◈",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 184, 97)),
			ColorSequenceKeypoint.new(0.407, Color3.fromRGB(240, 213, 117)),
			ColorSequenceKeypoint.new(0.441, Color3.fromRGB(239, 220, 188)),
			ColorSequenceKeypoint.new(0.561, Color3.fromRGB(236, 185, 98)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 55, 32))
		}),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json", Enum.FontWeight.Regular),
		GradientRotation = 90,
		HideBrackets = true,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.fromRGB(99, 82, 68),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0.28
		}
	},
	["CONQUEROR OF THE VEIL"] = {
		Text = "◈━〔HARBINGER OF THE DIVINE | S3 #2〕━◈",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 187, 255)),
			ColorSequenceKeypoint.new(0.407, Color3.fromRGB(217, 219, 240)),
			ColorSequenceKeypoint.new(0.441, Color3.fromRGB(228, 232, 239)),
			ColorSequenceKeypoint.new(0.561, Color3.fromRGB(155, 179, 236)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 48, 65))
		}),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json", Enum.FontWeight.Regular),
		GradientRotation = 90,
		HideBrackets = true,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.fromRGB(101, 133, 208),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0.28
		}
	},
	["DEVOURER OF THE VEIL"] = {
		Text = "◈━〔WITNESS OF OLYMPUS | S3 #3〕━◈",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 157, 159)),
			ColorSequenceKeypoint.new(0.407, Color3.fromRGB(172, 108, 102)),
			ColorSequenceKeypoint.new(0.441, Color3.fromRGB(239, 198, 185)),
			ColorSequenceKeypoint.new(0.561, Color3.fromRGB(138, 86, 77)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 28, 28))
		}),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json", Enum.FontWeight.Regular),
		GradientRotation = 90,
		HideBrackets = true,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.fromRGB(208, 132, 132),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0.28
		}
	},
	["WARDEN OF THE VEIL"] = {
		Text = "◈━〔DESCENDANT OF THE GODS | S3 TOP 50〕━◈",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.407, Color3.fromRGB(172, 172, 172)),
			ColorSequenceKeypoint.new(0.441, Color3.fromRGB(239, 239, 239)),
			ColorSequenceKeypoint.new(0.561, Color3.fromRGB(138, 138, 138)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 65, 65))
		}),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json", Enum.FontWeight.Regular),
		GradientRotation = 90,
		HideBrackets = true,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.fromRGB(129, 129, 129),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0.28
		}
	},
	["Sky Keeper"] = {
		Text = "Sky Keeper",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 229, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 243, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		StrokeColor = Color3.fromRGB(75, 75, 75)
	},
	["The Requiem"] = {
		Text = "The Requiem",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 255, 73)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 162, 56)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 53, 0))
		}),
		StrokeColor = Color3.fromRGB(21, 75, 13)
	},
	["🎹"] = {
		Text = "🎹",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 246)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 243, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(227, 215, 243))
		}),
		StrokeColor = Color3.fromRGB(30, 54, 75)
	},
	Caprine = {
		Text = "·•《caprine》•·",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 255, 139)),
			ColorSequenceKeypoint.new(0.394, Color3.fromRGB(124, 255, 139)),
			ColorSequenceKeypoint.new(0.457, Color3.fromRGB(29, 131, 61)),
			ColorSequenceKeypoint.new(0.683, Color3.fromRGB(108, 255, 145)),
			ColorSequenceKeypoint.new(0.888, Color3.fromRGB(33, 65, 43)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(122, 122, 122),
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Heavy),
		GradientRotation = 90
	},
	["The Ascended"] = {
		Text = "The Ascended",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 239, 176)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(134, 227, 255))
		}),
		StrokeColor = Color3.fromRGB(102, 102, 102),
		Bold = true,
		Animated = true
	},
	Fugu = {
		Text = "Fugu",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 255, 255)),
			ColorSequenceKeypoint.new(0.16666666666666666, Color3.fromRGB(130, 243, 255)),
			ColorSequenceKeypoint.new(0.3333333333333333, Color3.fromRGB(65, 177, 243)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(48, 146, 227)),
			ColorSequenceKeypoint.new(0.6666666666666666, Color3.fromRGB(49, 135, 216)),
			ColorSequenceKeypoint.new(0.8333333333333334, Color3.fromRGB(40, 95, 203)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 57, 108))
		}),
		StrokeColor = Color3.fromRGB(30, 54, 75),
		CustomFont = Font.fromId(12187367362),
		Animated = true,
		Bold = true
	},
	["Plague Doctor"] = {
		Text = "Plague Doctor",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 35, 62)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(73, 47, 118)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(108, 84, 148))
		}),
		StrokeColor = Color3.fromRGB(26, 19, 34),
		CustomFont = Font.new(
			"rbxasset://fonts/families/Merriweather.json",
			Enum.FontWeight.Heavy,
			Enum.FontStyle.Italic
		),
		GradientRotation = 90
	},
	["ABYSSAL GODSEEKER"] = {
		Text = "CHAMPION OF THE ABYSS (S2 #1)",
		TextColor = ColorSequence.new(Color3.fromRGB(4, 0, 130), Color3.fromRGB(82, 85, 255)),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new(
			"rbxasset://fonts/families/Merriweather.json",
			Enum.FontWeight.Heavy,
			Enum.FontStyle.Italic
		),
		GradientRotation = 90,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.new(0, 0, 0),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0
		}
	},
	["TIDAL OMENBRINGER"] = {
		Text = "CONQUEROR OF THE ABYSS (S2 #2)",
		TextColor = ColorSequence.new(Color3.fromRGB(111, 30, 30), Color3.fromRGB(255, 87, 95)),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new(
			"rbxasset://fonts/families/Merriweather.json",
			Enum.FontWeight.Heavy,
			Enum.FontStyle.Italic
		),
		GradientRotation = 90,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.new(0, 0, 0),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0
		}
	},
	["DREAD ASCENDANT"] = {
		Text = "DEVOURER OF THE ABYSS (S2 #3)",
		TextColor = ColorSequence.new(Color3.fromRGB(47, 39, 104), Color3.fromRGB(135, 83, 214)),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new(
			"rbxasset://fonts/families/Merriweather.json",
			Enum.FontWeight.Heavy,
			Enum.FontStyle.Italic
		),
		GradientRotation = 90,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.new(0, 0, 0),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0
		}
	},
	["DEEPWATER WARDEN"] = {
		Text = "WARDEN OF THE ABYSS (S2 TOP 50)",
		TextColor = ColorSequence.new(Color3.fromRGB(56, 56, 56), Color3.fromRGB(138, 138, 138)),
		StrokeColor = Color3.fromRGB(59, 59, 59),
		CustomFont = Font.new(
			"rbxasset://fonts/families/Merriweather.json",
			Enum.FontWeight.Heavy,
			Enum.FontStyle.Italic
		),
		GradientRotation = 90,
		Shadow = {
			BlurRadius = UDim.new(0.5, 0),
			Color = Color3.new(0, 0, 0),
			Spread = UDim2.fromScale(0, -0.5),
			Transparency = 0
		}
	},
	["Trench Marksman"] = {
		Text = "Trench Marksman",
		TextColor = ColorSequence.new(Color3.fromRGB(255, 120, 90), Color3.fromRGB(150, 40, 40)),
		StrokeColor = Color3.fromRGB(20, 10, 10),
		Bold = true,
		GradientRotation = 90
	},
	["Deep Hunter"] = {
		Text = "Deep Hunter",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 60)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 30, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 60))
		}),
		StrokeColor = Color3.fromRGB(10, 5, 20),
		Bold = true,
		GradientRotation = 90
	},
	["Trench Cartographer"] = {
		Text = "Trench Cartographer",
		TextColor = ColorSequence.new(Color3.fromRGB(140, 210, 255), Color3.fromRGB(50, 90, 170)),
		StrokeColor = Color3.fromRGB(10, 20, 40),
		Bold = true,
		GradientRotation = 90
	},
	["Master Biochemist"] = {
		Text = "Master Biochemist",
		TextColor = ColorSequence.new(Color3.fromRGB(170, 255, 170), Color3.fromRGB(50, 170, 120)),
		StrokeColor = Color3.fromRGB(10, 40, 25),
		Bold = true,
		GradientRotation = 90
	},
	["Benthic Scrapper"] = {
		Text = "Benthic Scrapper",
		TextColor = ColorSequence.new(Color3.fromRGB(230, 180, 110), Color3.fromRGB(140, 100, 60)),
		StrokeColor = Color3.fromRGB(40, 25, 10),
		Bold = true,
		GradientRotation = 90
	},
	["Sightless Scholar"] = {
		Text = "Sightless Scholar",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 220)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 255))
		}),
		StrokeColor = Color3.fromRGB(30, 30, 60),
		Bold = true,
		GradientRotation = 90
	},
	["Archive Keeper"] = {
		Text = "Archive Keeper",
		TextColor = ColorSequence.new(Color3.fromRGB(170, 240, 250), Color3.fromRGB(90, 160, 180)),
		StrokeColor = Color3.fromRGB(15, 40, 45),
		Bold = true,
		GradientRotation = 90
	},
	["City Benefactor"] = {
		Text = "City Benefactor",
		TextColor = ColorSequence.new(Color3.fromRGB(190, 230, 190), Color3.fromRGB(110, 160, 110)),
		StrokeColor = Color3.fromRGB(25, 45, 25),
		Bold = true,
		GradientRotation = 90
	},
	["Deep Engineer"] = {
		Text = "Deep Engineer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 130)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 140, 70)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 200, 220))
		}),
		StrokeColor = Color3.fromRGB(40, 30, 10),
		Animated = true,
		Bold = true
	},
	["The Deep Hero"] = {
		Text = "The Deep Hero",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 235, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45, 110, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 250, 255))
		}),
		StrokeColor = Color3.fromRGB(10, 25, 45),
		Animated = true,
		Bold = true
	},
	Avatar = {
		Text = "Avatar",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(247, 255, 164)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(163, 129, 74)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 115, 39)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 148, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Animated = true,
		Bold = true
	},
	["On Fire!"] = {
		Text = "🔥 ON FIRE! 🔥",
		TextColor = ColorSequence.new(Color3.fromRGB(240, 142, 12), Color3.fromRGB(255, 204, 77)),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		GradientRotation = 90
	},
	["The Mourned"] = {
		Text = "The Mourned",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(71, 71, 71)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(71, 71, 71)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		GradientRotation = 85
	},
	Exalted = {
		Text = "Exalted",
		TextColor = ColorSequence.new(Color3.fromRGB(143, 203, 240), Color3.fromRGB(219, 176, 255)),
		StrokeColor = Color3.fromRGB(141, 48, 255),
		Bold = true,
		GradientRotation = 90
	},
	Patriot = {
		Text = "Patriot",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Animated = true,
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Bangers.json")
	},
	["🎆"] = {
		Text = "🎆",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 60, 134)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 227, 180)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(47, 60, 134))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	["🏜️"] = {
		Text = "🏜️",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(113, 185, 6)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 175, 112))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	["🦦"] = {
		Text = "🦦",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 83, 63)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(184, 139, 118)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(134, 83, 63))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	MERICAAA = {
		Text = "MERICAAA RAAHHH",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		Animated = true,
		Bold = true
	},
	["Waterpark Engineer"] = {
		Text = "Waterpark Engineer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 164, 74)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
		}),
		StrokeColor = Color3.fromRGB(30, 30, 30),
		GradientRotation = 90,
		Bold = true
	},
	["Fifty Cacti"] = {
		Text = "Hello, my name is {name} and for some reason, I died to Cacti 50 times. I am 4 IQ.",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 85, 53)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(92, 143, 104))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Animated = true,
		Bold = true
	},
	["🏝️"] = {
		Text = "🏝️",
		TextColor = Color3.fromRGB(244, 190, 59),
		StrokeColor = Color3.fromRGB(34, 34, 34),
		Bold = true
	},
	["⛱️"] = {
		Text = "⛱️",
		TextColor = Color3.fromRGB(244, 190, 59),
		StrokeColor = Color3.fromRGB(34, 34, 34),
		Bold = true
	},
	["Umbrella Carried"] = {
		Text = "❌ UMBRELLA CARRIED ❌",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	["Bonfire Helper"] = {
		Text = "🔥 Bonfire Helper 🔥",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(116, 67, 50)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 181, 66)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 97, 35))
		}),
		StrokeColor = Color3.fromRGB(90, 21, 4),
		GradientRotation = 90,
		Animated = true,
		Bold = true
	},
	["Sand Castle Architect"] = {
		Text = "🏖️ Sand Castle Architect",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 160)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 184, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(199, 150, 84))
		}),
		StrokeColor = Color3.fromRGB(90, 64, 36),
		GradientRotation = 90,
		Animated = true,
		Bold = true
	},
	["Beach Volleyball Professional"] = {
		Text = "💥🏐 Beach Volleyball Professional",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 122)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 190, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		Animated = true,
		Bold = true
	},
	["Beach Volleyballer"] = {
		Text = "Beach Volleyballer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 192, 193)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 252, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true
	},
	["Jetski Racer"] = {
		Text = "Jetski Racer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 175, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 77, 130))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true
	},
	["Jetski Champion"] = {
		Text = "Jetski Champion",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 193, 117)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 223, 128))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true
	},
	PuadLauncher = {
		Text = "🐡💥",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 156, 128)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 133, 99)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 78, 43))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true
	},
	overflow = {
		Text = "_-over:flow-_",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 255, 133)),
			ColorSequenceKeypoint.new(0.0657, Color3.fromRGB(38, 255, 127)),
			ColorSequenceKeypoint.new(0.114, Color3.fromRGB(69, 255, 81)),
			ColorSequenceKeypoint.new(0.259, Color3.fromRGB(164, 255, 163)),
			ColorSequenceKeypoint.new(0.458, Color3.fromRGB(225, 255, 255)),
			ColorSequenceKeypoint.new(0.576, Color3.fromRGB(166, 255, 168)),
			ColorSequenceKeypoint.new(0.592, Color3.fromRGB(237, 255, 239)),
			ColorSequenceKeypoint.new(0.702, Color3.fromRGB(59, 255, 140)),
			ColorSequenceKeypoint.new(0.803, Color3.fromRGB(2, 10, 5)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Italic = true,
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Shady = {
		Text = "Shady",
		TextColor = ColorSequence.new(Color3.fromRGB(120, 90, 160), Color3.fromRGB(60, 45, 90)),
		StrokeColor = Color3.fromRGB(30, 20, 45),
		Bold = true
	},
	["🕵️"] = {
		Text = "🕵️",
		TextColor = Color3.fromRGB(200, 200, 210),
		StrokeColor = Color3.fromRGB(70, 70, 80)
	},
	EvilCat = {
		Text = ">:3",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
	},
	Toasty = {
		Text = "Toasty",
		TextColor = ColorSequence.new(Color3.fromRGB(255, 73, 49), Color3.fromRGB(255, 128, 55)),
		StrokeColor = Color3.fromRGB(90, 55, 32),
		Bold = true
	},
	Cooked = {
		Text = "Cooked",
		TextColor = ColorSequence.new(Color3.fromRGB(255, 196, 46), Color3.fromRGB(255, 128, 55)),
		StrokeColor = Color3.fromRGB(90, 55, 32),
		Bold = true
	},
	["Aspiring Fish"] = {
		Text = "Aspiring Fish",
		TextColor = ColorSequence.new(Color3.fromRGB(47, 200, 255), Color3.fromRGB(156, 187, 255)),
		StrokeColor = Color3.fromRGB(30, 66, 90),
		Bold = true
	},
	["Fish Food"] = {
		Text = "Fish Food",
		TextColor = ColorSequence.new(Color3.fromRGB(158, 79, 255), Color3.fromRGB(83, 49, 124)),
		StrokeColor = Color3.fromRGB(67, 30, 90),
		Bold = true
	},
	Electric = {
		Text = "⚡",
		TextColor = ColorSequence.new(Color3.fromRGB(255, 201, 75), Color3.fromRGB(255, 173, 80)),
		StrokeColor = Color3.fromRGB(90, 69, 31),
		Bold = true
	},
	Bound = {
		Text = "Bound",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(249, 255, 78)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(109, 255, 204)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(49, 76, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 0,
		Animated = true,
		Bold = true
	},
	Mesmerizer = {
		Text = "Mesmerizer",
		TextColor = Color3.fromRGB(255, 255, 0),
		StrokeColor = Color3.fromRGB(117, 117, 0),
		CustomFont = Font.new("rbxasset://fonts/families/FredokaOne.json")
	},
	Mesmerized = {
		Text = "Mesmerized",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.1111111111111111, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.2222222222222222, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.3333333333333333, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.4444444444444444, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5555555555555556, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.6666666666666666, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.7777777777777778, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.8888888888888888, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 2,
		GradientRotation = 0,
		CustomFont = Font.new("rbxasset://fonts/families/FredokaOne.json")
	},
	ooeeoo = {
		Text = "ooeeoo",
		TextColor = ColorSequence.new(Color3.fromRGB(62, 255, 216), Color3.fromRGB(64, 220, 255)),
		StrokeColor = Color3.fromRGB(24, 70, 65),
		GradientRotation = 0,
		Animated = true,
		Bold = true
	},
	Wave = {
		Text = "🌊",
		TextColor = Color3.fromRGB(135, 197, 255),
		StrokeColor = Color3.fromRGB(101, 150, 255)
	},
	Tempest = {
		Text = "Tempest",
		TextColor = Color3.fromRGB(189, 246, 255),
		StrokeColor = Color3.fromRGB(69, 97, 106),
		Bold = true,
		Italic = true
	},
	["Seeker of Depths"] = {
		Text = "Seeker of Depths",
		TextColor = Color3.fromRGB(57, 76, 106),
		StrokeColor = Color3.fromRGB(112, 151, 209),
		Bold = true
	},
	["🥚"] = {
		Text = "🥚",
		TextColor = Color3.fromRGB(255, 233, 188),
		StrokeColor = Color3.fromRGB(255, 242, 221)
	},
	Fool = {
		Text = "ばかだな",
		TextColor = Color3.fromRGB(188, 66, 66),
		StrokeColor = Color3.fromRGB(255, 252, 252),
		Bold = true
	},
	["Lucky Sailor"] = {
		Text = "Lucky Sailor",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 243, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 175, 47))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(188, 255, 80),
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Bold)
	},
	Rich = {
		Text = "Rich",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 150))
		}),
		StrokeColor = Color3.fromRGB(100, 80, 0),
		GradientRotation = 90,
		Bold = true
	},
	["Really Rich"] = {
		Text = "Really Rich",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 245, 130))
		}),
		StrokeColor = Color3.fromRGB(120, 90, 0),
		GradientRotation = 90,
		Bold = true
	},
	["🍀"] = {
		Text = "🍀",
		TextColor = Color3.fromRGB(62, 207, 92),
		StrokeColor = Color3.fromRGB(20, 80, 35)
	},
	["Luckiest Fischer"] = {
		Text = "Luckiest Fischer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 220, 120)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 100))
		}),
		StrokeColor = Color3.fromRGB(25, 70, 30),
		GradientRotation = 90,
		Bold = true
	},
	["Unluckiest Fischer"] = {
		Text = "Unluckiest Fischer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 100, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 70, 60))
		}),
		StrokeColor = Color3.fromRGB(40, 35, 30),
		GradientRotation = 90,
		Italic = true
	},
	Dove = {
		Text = "🕊️",
		TextColor = Color3.new(1, 1, 1),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	["Boulder Basher"] = {
		Text = "Boulder Basher",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 57, 57))
		}),
		StrokeColor = Color3.fromRGB(181, 181, 181),
		Bold = true
	},
	["I Found Two Anchovies In A Meteor And All I Got Was This Lousy Title"] = {
		Text = "I Found Anchovies In A Meteor And Got This Lousy Title",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 238, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(211, 231, 255))
		}),
		StrokeColor = Color3.fromRGB(74, 90, 100),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
	},
	["I Died To A Falling Dripstone"] = {
		Text = "I Died To A Falling Dripstone",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 63, 63)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21))
		}),
		StrokeColor = Color3.fromRGB(90, 90, 90),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
	},
	["I Died To One Hundred Falling Dripstones"] = {
		Text = "I Died To One Hundred Falling Dripstones",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 56, 56)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 16))
		}),
		StrokeColor = Color3.fromRGB(80, 80, 80),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
	},
	Lovestormer = {
		Text = "Lovestormer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 113, 233)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 169, 246))
		}),
		StrokeColor = Color3.fromRGB(217, 6, 213),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Balthazar.json")
	},
	Lovely = {
		Text = "Lovely",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(217, 133, 197)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 210, 243))
		}),
		StrokeColor = Color3.fromRGB(213, 94, 217),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Guru.json")
	},
	Wisher = {
		Text = "Wisher",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(217, 206, 121)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 254, 212))
		}),
		StrokeColor = Color3.fromRGB(217, 209, 92),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Guru.json")
	},
	Distraught = {
		Text = "Distraught",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		GradientRotation = 83,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	["🌌"] = {
		Text = "🌌",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 57, 158)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(207, 155, 0))
		}),
		StrokeColor = Color3.fromRGB(117, 75, 255),
		GradientRotation = 90
	},
	["No Sleep"] = {
		Text = "No Sleep",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 224, 146))
		}),
		StrokeColor = Color3.fromRGB(217, 189, 124),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Balthazar.json")
	},
	Ascendance = {
		Text = "Ascendance.",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 2,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	["Soul Snatcher"] = {
		Text = "Soul Snatcher",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(131, 190, 218)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 146, 166)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 1.5,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	VAMP = {
		Text = "^,.,^",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(189, 0, 3)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 2,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	MLG = {
		Text = "ML Frickin' G",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 79, 81)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 151, 90)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 242, 102)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(101, 255, 114)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 228, 255))
		}),
		Bold = true,
		Animated = true,
		StrokeColor = Color3.fromRGB(103, 36, 37),
		CustomFont = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
	},
	Gleebin = {
		Text = "Gleebin'",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 216, 120)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(222, 255, 112))
		}),
		StrokeColor = Color3.fromRGB(74, 103, 57)
	},
	["🎄"] = {
		Text = "🎄",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 158, 48)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 35, 35))
		}),
		StrokeColor = Color3.fromRGB(8, 30, 2),
		GradientRotation = 90
	},
	["On The Nice List"] = {
		Text = "On The Nice List",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 207, 207))
		}),
		StrokeColor = Color3.fromRGB(255, 106, 106),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Jolly = {
		Text = "Jolly",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 208, 73)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 76, 76))
		}),
		StrokeColor = Color3.fromRGB(93, 19, 19),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	["🔴 Honked 🔴"] = {
		Text = "🔴 Honked 🔴",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/LuckiestGuy.json")
	},
	["Witnessed Santa"] = {
		Text = "Witnessed Santa",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 207, 207))
		}),
		StrokeColor = Color3.fromRGB(255, 106, 106),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	["🦃"] = {
		Text = "🦃",
		TextColor = Color3.fromRGB(98, 63, 47),
		StrokeColor = Color3.fromRGB(38, 24, 18)
	},
	["🍂"] = {
		Text = "🍂",
		TextColor = Color3.fromRGB(255, 116, 52),
		StrokeColor = Color3.fromRGB(152, 67, 31)
	},
	["🥧"] = {
		Text = "🥧",
		TextColor = Color3.fromRGB(255, 200, 124),
		StrokeColor = Color3.fromRGB(124, 96, 60)
	},
	["🍁"] = {
		Text = "🍁",
		TextColor = Color3.fromRGB(252, 70, 64),
		StrokeColor = Color3.fromRGB(97, 26, 25)
	},
	["🔮"] = {
		Text = "🔮",
		TextColor = Color3.fromRGB(97, 84, 194),
		StrokeColor = Color3.fromRGB(30, 28, 39)
	},
	Glorply = {
		Text = "Glorply",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(179, 252, 111)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 251, 123))
		}),
		StrokeColor = Color3.fromRGB(80, 103, 47),
		Bold = true
	},
	["Nico's Meowfia"] = {
		Text = "Nico's Meowfia",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 140, 164)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(249, 202, 212)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(202, 233, 254)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 226, 195))
		}),
		StrokeColor = Color3.fromRGB(209, 106, 127),
		Bold = true
	},
	Fabulous = {
		Text = "Fabulous",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(167, 240, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(196, 188, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 178, 255))
		}),
		StrokeColor = Color3.fromRGB(80, 78, 93),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Glistening = {
		Text = "Glistening",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 249, 162)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 250, 208)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 249, 230))
		}),
		StrokeColor = Color3.fromRGB(80, 78, 93),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Hollowmaker = {
		Text = "Hollowmaker",
		TextColor = Color3.fromRGB(205, 134, 51),
		StrokeColor = Color3.fromRGB(39, 39, 39)
	},
	["Pumpkin Gatherer"] = {
		Text = "Pumpkin Gatherer",
		TextColor = Color3.fromRGB(205, 183, 109),
		StrokeColor = Color3.fromRGB(39, 39, 39)
	},
	["🧛"] = {
		Text = "🧛",
		TextColor = Color3.fromRGB(194, 51, 51),
		StrokeColor = Color3.fromRGB(39, 26, 26)
	},
	["💀"] = {
		Text = "💀",
		TextColor = Color3.fromRGB(194, 194, 194),
		StrokeColor = Color3.fromRGB(39, 39, 39)
	},
	["👻"] = {
		Text = "👻",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(81, 81, 81)
	},
	["🧟"] = {
		Text = "🧟",
		TextColor = Color3.fromRGB(69, 150, 88),
		StrokeColor = Color3.fromRGB(44, 61, 53)
	},
	["🎃"] = {
		Text = "🎃",
		TextColor = Color3.fromRGB(255, 146, 74),
		StrokeColor = Color3.fromRGB(35, 26, 19)
	},
	["🤡"] = {
		Text = "🤡",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(97, 0, 0)
	},
	["🍬"] = {
		Text = "🍬",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(255, 174, 174)
	},
	Rude = {
		Text = "Rude",
		TextColor = Color3.fromRGB(126, 103, 93),
		StrokeColor = Color3.fromRGB(50, 43, 41),
		Bold = true
	},
	Frightful = {
		Text = "Frightful",
		TextColor = Color3.fromRGB(123, 104, 165),
		StrokeColor = Color3.fromRGB(44, 37, 50),
		Bold = true
	},
	Spooky = {
		Text = "Spooky",
		TextColor = Color3.fromRGB(220, 151, 81),
		StrokeColor = Color3.fromRGB(50, 39, 28),
		Bold = true
	},
	Eerie = {
		Text = "Eerie",
		TextColor = Color3.fromRGB(84, 211, 114),
		StrokeColor = Color3.fromRGB(67, 84, 72),
		Bold = true
	},
	Him = {
		Text = "Him",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	Careless = {
		Text = "Careless",
		TextColor = Color3.fromRGB(248, 198, 190),
		StrokeColor = Color3.fromRGB(36, 22, 25)
	},
	["Mossjaw Conquerer"] = {
		Text = "Mossjaw Conquerer",
		TextColor = Color3.fromRGB(36, 244, 161),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	["Elder Slayer"] = {
		Text = "Elder Slayer",
		TextColor = Color3.fromRGB(36, 244, 161),
		StrokeColor = Color3.fromRGB(255, 255, 233)
	},
	["💵"] = {
		Text = "💵",
		TextColor = Color3.fromRGB(111, 255, 145),
		StrokeColor = Color3.fromRGB(194, 255, 199)
	},
	["🎂"] = {
		Text = "🎂",
		TextColor = Color3.fromRGB(255, 247, 205),
		StrokeColor = Color3.fromRGB(184, 180, 146)
	},
	["🎉🦈"] = {
		Text = "🎉🦈",
		TextColor = Color3.fromRGB(123, 152, 255),
		StrokeColor = Color3.fromRGB(254, 116, 116)
	},
	["🎈"] = {
		Text = "🎈",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(255, 255, 255)
	},
	["🎁"] = {
		Text = "🎁",
		TextColor = Color3.fromRGB(255, 233, 165),
		StrokeColor = Color3.fromRGB(184, 60, 60)
	},
	Birthday = {
		Text = "Birthday",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 246)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 236, 161)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 243, 255))
		}),
		StrokeColor = Color3.fromRGB(75, 75, 75),
		Bold = true
	},
	["❌🌿"] = {
		Text = "❌🌿",
		TextColor = Color3.fromRGB(71, 139, 70),
		StrokeColor = Color3.fromRGB(35, 57, 35)
	},
	["The Greatest"] = {
		Text = "The Greatest",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/IndieFlower.json")
	},
	["Sunken Sailor"] = {
		Text = "Sunken Sailor",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 115, 168)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 16, 24))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/RomanAntique.json")
	},
	Ruined = {
		Text = "Ruined",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 17, 17))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/RomanAntique.json")
	},
	Evil = {
		Text = "Evil",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 17, 17))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["Bone Prospector"] = {
		Text = "🦴 Bone Prospector 🦴",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 247, 207)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(98, 95, 80))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90
	},
	Spirit = {
		Text = "Spirit",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 48, 124)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 37, 52))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Dusk = {
		Text = "Dusk",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Destiny = {
		Text = "Destiny",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(252, 249, 205))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Wrath = {
		Text = "Wrath",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 9, 21)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 129, 145))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Forgotten = {
		Text = "Forgotten",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(46, 171, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["Ghostly Trapper"] = {
		Text = "Ghostly Trapper",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(69, 73, 143)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(79, 120, 72)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(43, 54, 58))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["⛰️"] = {
		Text = "⛰️",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(0, 0, 0)
	},
	Ethereal = {
		Text = "Ethereal",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(231, 189, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(167, 255, 152)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 181, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Blessing = {
		Text = "Blessing",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 251, 222)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 144))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["Lifeless Merchant"] = {
		Text = "Lifeless Merchant",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 0, 1))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Boomer = {
		Text = "Boomer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(41, 43, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 43, 43))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["Steady Conqueror"] = {
		Text = "Steady Conqueror",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 85, 67)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["King of the Seas"] = {
		Text = "King of the Seas",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(71, 240, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 243, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["Abyssal Fischer"] = {
		Text = "Abyssal Fischer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(218, 0, 4)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 0, 211))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["Heavenly Angler"] = {
		Text = "Heavenly Angler",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 157)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(254, 255, 226))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	Meteorologist = {
		Text = "Meteorologist",
		TextColor = Color3.fromRGB(184, 156, 227),
		StrokeColor = Color3.fromRGB(98, 101, 255),
		Bold = true
	},
	Starborn = {
		Text = "Starborn",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 157)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 31, 143))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		GradientRotation = 90,
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json")
	},
	["✨"] = {
		Text = "✨",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 17, 136)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 42, 153))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	Beached = {
		Text = "🌴Beached🌴",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(199, 172, 120)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(218, 218, 218)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(149, 186, 221)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(199, 172, 120)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(218, 218, 218)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(149, 186, 221))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		GradientRotation = 70,
		CustomFont = Font.new("rbxasset://fonts/families/HighwayGothic.json")
	},
	["Shoreline Scavenger"] = {
		Text = "🌴 Shoreline Scavenger",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 157)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 229, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 153, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["Beachy Crabber"] = {
		Text = "🦀 Beachy Crabber 🦀",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 81, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(184, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["The Crab Master"] = {
		Text = "🦀 The Crab Master 🦀",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 81, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(184, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	Shopkeeper = {
		Text = "Shopkeeper",
		TextColor = Color3.fromRGB(253, 255, 128),
		StrokeColor = Color3.fromRGB(113, 115, 92)
	},
	Nico = {
		Text = "Nico's Meowfia",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 140, 164)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(249, 202, 212)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(202, 233, 254)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 226, 195))
		}),
		StrokeColor = Color3.fromRGB(209, 106, 127),
		Bold = true
	},
	["🐡"] = {
		Text = "🐡",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 156, 128)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(191, 104, 77)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 32, 17))
		}),
		StrokeColor = Color3.fromRGB(41, 46, 50),
		Bold = true
	},
	["🐋"] = {
		Text = "🐋",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 136, 195)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(85, 172, 238)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 47, 51))
		}),
		StrokeColor = Color3.fromRGB(42, 96, 137),
		Bold = true
	},
	["🦈"] = {
		Text = "🦈",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(102, 117, 127)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 47, 51))
		}),
		StrokeColor = Color3.fromRGB(188, 188, 188),
		Bold = true
	},
	["🦑"] = {
		Text = "🦑",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 173, 187)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(234, 91, 109)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(191, 32, 52))
		}),
		StrokeColor = Color3.fromRGB(119, 20, 33),
		Bold = true
	},
	["😈"] = {
		Text = "😈",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(127, 0, 206)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 0, 57))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["🦇"] = {
		Text = "🦇",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 99, 99)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(53, 53, 53)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
		}),
		StrokeColor = Color3.fromRGB(137, 137, 137),
		Bold = true,
		Exclusive = true
	},
	["🍌"] = {
		Text = "i slipped on a banana peel for this AWESOME title",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 239, 16)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 228, 180))
		}),
		StrokeColor = Color3.fromRGB(158, 146, 10),
		Animated = true,
		Bold = true,
		Exclusive = true
	},
	FANG = {
		Text = "🦇",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(176, 145, 133)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 31, 31))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 1.5,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	dg4l = {
		Text = "drainer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 149, 204)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(252, 149, 204))
		}),
		StrokeColor = Color3.fromRGB(252, 146, 221),
		GradientRotation = 0,
		Bold = true,
		Exclusive = true,
		CustomFont = Font.new("rbxasset://fonts/families/PermanentMarker.json")
	},
	monkeyyay = {
		Text = "🐒",
		TextColor = Color3.fromRGB(247, 122, 32),
		StrokeColor = Color3.fromRGB(247, 168, 31),
		Italic = false,
		Bold = true,
		Exclusive = true
	},
	["🌙"] = {
		Text = "🌙",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(249, 194, 60)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(252, 213, 63)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(249, 219, 109))
		}),
		StrokeColor = Color3.fromRGB(249, 228, 152),
		Bold = true
	},
	["🥀"] = {
		Text = "🥀",
		TextColor = Color3.fromRGB(74, 227, 87),
		StrokeColor = Color3.fromRGB(255, 255, 255)
	},
	["🌹"] = {
		Text = "🌹",
		TextColor = Color3.fromRGB(190, 53, 53),
		StrokeColor = Color3.fromRGB(255, 255, 255)
	},
	Bloopster = {
		Text = "Bloopster",
		TextColor = Color3.fromRGB(187, 222, 255),
		StrokeColor = Color3.fromRGB(143, 197, 255)
	},
	["Timely Fisherman"] = {
		Text = "Timely Fisherman",
		TextColor = Color3.fromRGB(85, 85, 127),
		StrokeColor = Color3.fromRGB(50, 50, 74)
	},
	["Clock Lobster"] = {
		Text = "Clock Lobster",
		TextColor = Color3.fromRGB(255, 255, 127),
		StrokeColor = Color3.fromRGB(99, 83, 63)
	},
	["Reel Time Expert"] = {
		Text = "Reel Time Expert",
		TextColor = Color3.fromRGB(173, 173, 173),
		StrokeColor = Color3.fromRGB(99, 99, 99)
	},
	["Temporal Trawler"] = {
		Text = "Temporal Trawler",
		TextColor = Color3.fromRGB(255, 170, 127),
		StrokeColor = Color3.fromRGB(113, 38, 57)
	},
	["Temporal Tuna"] = {
		Text = "Temporal Tuna",
		TextColor = Color3.fromRGB(0, 85, 127),
		StrokeColor = Color3.fromRGB(0, 51, 75)
	},
	["Hourglass Speedrunner"] = {
		Text = "Hourglass Speedrunner",
		TextColor = Color3.fromRGB(170, 170, 127),
		StrokeColor = Color3.fromRGB(85, 85, 0)
	},
	["Borrowed Time"] = {
		Text = "Borrowed Time",
		TextColor = Color3.fromRGB(170, 170, 255),
		StrokeColor = Color3.fromRGB(79, 79, 118)
	},
	["Reel Late"] = {
		Text = "Reel Late",
		TextColor = Color3.fromRGB(85, 170, 255),
		StrokeColor = Color3.fromRGB(0, 68, 100)
	},
	["Master of Time"] = {
		Text = "Master of Time",
		TextColor = Color3.fromRGB(255, 211, 161),
		StrokeColor = Color3.fromRGB(94, 31, 31)
	},
	["Time Keeper"] = {
		Text = "Time Keeper",
		TextColor = Color3.fromRGB(198, 220, 255),
		StrokeColor = Color3.fromRGB(89, 100, 115)
	},
	["The Final Fishness"] = {
		Text = "⏳ The Final Fishness ⏳",
		TextColor = Color3.fromRGB(255, 176, 46),
		StrokeColor = Color3.fromRGB(131, 203, 255)
	},
	["Dreamer Revolution"] = {
		Text = "Dreamer Revolution",
		TextColor = Color3.fromRGB(0, 38, 255),
		StrokeColor = Color3.fromRGB(128, 0, 255)
	},
	["Kraken Collector"] = {
		Text = "Kraken Collector",
		TextColor = Color3.fromRGB(255, 170, 0),
		StrokeColor = Color3.fromRGB(0, 62, 0)
	},
	["Whale Collector"] = {
		Text = "Whale Collector",
		TextColor = Color3.fromRGB(170, 170, 255),
		StrokeColor = Color3.fromRGB(83, 83, 83)
	},
	["Orca Collector"] = {
		Text = "Orca Collector",
		TextColor = Color3.fromRGB(181, 181, 181),
		StrokeColor = Color3.fromRGB(12, 12, 12)
	},
	["Megalodon Collector"] = {
		Text = "Megalodon Collector",
		TextColor = Color3.fromRGB(87, 137, 172),
		StrokeColor = Color3.fromRGB(37, 78, 109)
	},
	Stormcaller = {
		Text = "Stormcaller",
		TextColor = Color3.fromRGB(255, 170, 127),
		StrokeColor = Color3.fromRGB(83, 55, 41)
	},
	Seafarer = {
		Text = "Seafarer",
		TextColor = Color3.fromRGB(163, 163, 163),
		StrokeColor = Color3.fromRGB(48, 48, 48),
		Bold = true
	},
	["Ocean's Champion"] = {
		Text = "Ocean's Champion",
		TextColor = Color3.fromRGB(0, 170, 255),
		StrokeColor = Color3.fromRGB(0, 85, 127)
	},
	["Abyssal Scavenger"] = {
		Text = "Abyssal Scavenger",
		TextColor = Color3.fromRGB(85, 0, 127),
		StrokeColor = Color3.fromRGB(39, 0, 59)
	},
	["Wave Conqueror"] = {
		Text = "Wave Conqueror",
		TextColor = Color3.fromRGB(170, 85, 127),
		StrokeColor = Color3.fromRGB(103, 51, 77)
	},
	["Coral Sovereign"] = {
		Text = "Coral Sovereign",
		TextColor = Color3.fromRGB(170, 170, 255),
		StrokeColor = Color3.fromRGB(75, 75, 113)
	},
	["Mythical Mariner"] = {
		Text = "Mythical Mariner",
		TextColor = Color3.fromRGB(255, 85, 127),
		StrokeColor = Color3.fromRGB(111, 37, 56)
	},
	["Novice of the Waters"] = {
		Text = "Novice of the Waters",
		TextColor = Color3.fromRGB(56, 153, 232),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	Waveshaper = {
		Text = "Waveshaper",
		TextColor = Color3.fromRGB(255, 255, 127),
		StrokeColor = Color3.fromRGB(97, 97, 48)
	},
	["Ancient Ocean King"] = {
		Text = "Ancient Ocean King",
		TextColor = Color3.fromRGB(0, 170, 255),
		StrokeColor = Color3.fromRGB(0, 79, 118)
	},
	["Titan of the Waters"] = {
		Text = "Titan of the Waters",
		TextColor = Color3.fromRGB(170, 255, 255),
		StrokeColor = Color3.fromRGB(102, 153, 153)
	},
	Abysswalker = {
		Text = "Abysswalker",
		TextColor = Color3.fromRGB(29, 48, 87),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	Thalassian = {
		Text = "Thalassian",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 128, 128)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["Sentinel of the Deep"] = {
		Text = "Sentinel of the Deep",
		TextColor = Color3.fromRGB(66, 13, 3),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["Master of the Waters"] = {
		Text = "Master of the Waters",
		TextColor = Color3.fromRGB(95, 2, 209),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["Sovereign of the Seas"] = {
		Text = "Sovereign of the Seas",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	["Tidal Lord"] = {
		Text = "👑 Tidal Lord",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(201, 240, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(117, 218, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 196, 255))
		}),
		StrokeColor = Color3.fromRGB(16, 159, 211),
		Bold = true
	},
	["Ghostly Angler"] = {
		Text = "Ghostly Angler",
		TextColor = Color3.fromRGB(106, 255, 156),
		StrokeColor = Color3.fromRGB(37, 57, 43)
	},
	["Glimmerfin's Pupil"] = {
		Text = "Glimmerfin's Pupil",
		TextColor = Color3.fromRGB(255, 170, 127),
		StrokeColor = Color3.fromRGB(173, 115, 86)
	},
	["The Hallowed"] = {
		Text = "The Hallowed",
		TextColor = Color3.fromRGB(255, 58, 58),
		StrokeColor = Color3.fromRGB(42, 22, 22),
		Bold = true
	},
	["Nightmare Angler"] = {
		Text = "Nightmare Angler",
		TextColor = Color3.fromRGB(111, 98, 255),
		StrokeColor = Color3.fromRGB(32, 27, 48),
		Bold = true
	},
	Haunted = {
		Text = "Haunted",
		TextColor = Color3.fromRGB(255, 122, 78),
		StrokeColor = Color3.fromRGB(75, 44, 38),
		Italic = true
	},
	["Davy Jones"] = {
		Text = "Davy Jones",
		TextColor = Color3.fromRGB(32, 255, 114),
		StrokeColor = Color3.fromRGB(21, 165, 74),
		Bold = true,
		Exclusive = true
	},
	None = {
		Text = "",
		TextColor = Color3.fromRGB(106, 106, 106),
		StrokeColor = Color3.fromRGB(57, 57, 57)
	},
	["The Creator"] = {
		Text = "Developer",
		TextColor = Color3.fromRGB(101, 129, 255),
		StrokeColor = Color3.fromRGB(26, 23, 42),
		Bold = true,
		RankInGroup = 252,
		Exclusive = true
	},
	Owner = {
		Text = "The Owner",
		TextColor = Color3.fromRGB(255, 80, 118),
		StrokeColor = Color3.fromRGB(109, 42, 71),
		Bold = true,
		Exclusive = true
	},
	Moderator = {
		Text = "Moderator",
		TextColor = Color3.fromRGB(255, 137, 155),
		StrokeColor = Color3.fromRGB(34, 25, 34),
		Bold = true,
		RankInGroup = 200,
		Exclusive = true
	},
	Contributor = {
		Text = "Contributor",
		TextColor = Color3.fromRGB(67, 255, 145),
		StrokeColor = Color3.fromRGB(11, 62, 38),
		Bold = true,
		Exclusive = true
	},
	Tester = {
		Text = "Tester",
		TextColor = Color3.fromRGB(166, 255, 172),
		StrokeColor = Color3.fromRGB(61, 88, 65),
		Bold = true,
		RankInGroup = 60,
		Exclusive = true
	},
	["Art Contest Winner"] = {
		Text = "🐳",
		TextColor = Color3.fromRGB(119, 223, 255),
		StrokeColor = Color3.fromRGB(18, 41, 54),
		Bold = true,
		Exclusive = true
	},
	Cat = {
		Text = "🐈",
		TextColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(26, 22, 0),
		Bold = true,
		Exclusive = true
	},
	["Art Contest Runner Up"] = {
		Text = "🎨🖌️",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	Vigilante = {
		Text = "Vigilante",
		TextColor = Color3.fromRGB(27, 31, 76),
		StrokeColor = Color3.fromRGB(19, 22, 54),
		Bold = true
	},
	Extinct = {
		Text = "Extinct",
		TextColor = Color3.fromRGB(255, 94, 0),
		StrokeColor = Color3.fromRGB(117, 27, 0),
		Bold = true
	},
	["Natural Selection"] = {
		Text = "Natural Selection",
		TextColor = Color3.fromRGB(77, 159, 0),
		StrokeColor = Color3.fromRGB(25, 52, 0),
		Bold = true
	},
	["Made in Heaven"] = {
		Text = "Made in Heaven",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(235, 175, 34),
		Italic = true
	},
	Veteran = {
		Text = "Veteran",
		TextColor = Color3.fromRGB(149, 123, 255),
		StrokeColor = Color3.fromRGB(46, 38, 79),
		Bold = true
	},
	["Content Creator"] = {
		Text = "Content Creator",
		TextColor = Color3.fromRGB(255, 61, 61),
		StrokeColor = Color3.fromRGB(57, 21, 21),
		Italic = true,
		RankInGroup = 59
	},
	["Prophet 1"] = {
		Text = "☆",
		TextColor = Color3.fromRGB(255, 253, 248),
		StrokeColor = Color3.fromRGB(255, 255, 255)
	},
	["The Angler"] = {
		Text = "The Angler",
		TextColor = Color3.fromRGB(129, 164, 197),
		StrokeColor = Color3.fromRGB(59, 75, 90)
	},
	["The Foolish"] = {
		Text = "The Foolish",
		TextColor = Color3.fromRGB(127, 188, 105),
		StrokeColor = Color3.fromRGB(39, 42, 39)
	},
	["The Lantern Keeper"] = {
		Text = "The Holy",
		TextColor = Color3.fromRGB(255, 251, 193),
		StrokeColor = Color3.fromRGB(90, 70, 50),
		Bold = true
	},
	["The Hunter"] = {
		Text = "The Hunter",
		TextColor = Color3.fromRGB(255, 166, 42),
		StrokeColor = Color3.fromRGB(57, 48, 36),
		Bold = true
	},
	["The Pupil"] = {
		Text = "The Pupil",
		TextColor = Color3.fromRGB(255, 255, 64),
		StrokeColor = Color3.fromRGB(42, 37, 16)
	},
	["The Hoarder"] = {
		Text = "The Hoarder",
		TextColor = Color3.fromRGB(255, 129, 90),
		StrokeColor = Color3.fromRGB(42, 32, 22)
	},
	["C$ Collector"] = {
		Text = "C$ Collector",
		TextColor = Color3.fromRGB(255, 198, 64),
		StrokeColor = Color3.fromRGB(54, 48, 36)
	},
	["C$ Loaded"] = {
		Text = "C$ Loaded",
		TextColor = Color3.fromRGB(252, 255, 48),
		StrokeColor = Color3.fromRGB(54, 49, 27),
		Bold = true
	},
	["The Clever"] = {
		Text = "The Clever",
		TextColor = Color3.fromRGB(124, 253, 255),
		StrokeColor = Color3.fromRGB(26, 42, 41)
	},
	["The Drowned"] = {
		Text = "The Drowned",
		TextColor = Color3.fromRGB(113, 135, 135),
		StrokeColor = Color3.fromRGB(16, 16, 16),
		Bold = true
	},
	["The Frozen"] = {
		Text = "The Frozen",
		TextColor = Color3.fromRGB(164, 235, 255),
		StrokeColor = Color3.fromRGB(16, 16, 16),
		Bold = true
	},
	Clumsy = {
		Text = "Clumsy",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(42, 26, 21),
		Italic = true
	},
	Supporter = {
		Text = "Supporter",
		TextColor = Color3.fromRGB(255, 234, 75),
		StrokeColor = Color3.fromRGB(113, 78, 78),
		Bold = true
	},
	["Initial Supporter"] = {
		Text = "Initial Supporter",
		TextColor = Color3.fromRGB(255, 111, 149),
		StrokeColor = Color3.fromRGB(88, 63, 64),
		Bold = true
	},
	Love2 = {
		Text = "♡",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(255, 137, 139),
		Bold = true,
		Exclusive = true
	},
	HeartFromBlackMarket = {
		Text = "♥",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	["Bobber Enthusiast"] = {
		Text = "Bobber Enthusiast",
		TextColor = Color3.fromRGB(247, 129, 255),
		StrokeColor = Color3.fromRGB(90, 55, 89),
		Bold = true
	},
	["Lucky Roller"] = {
		Text = "Lucky Roller",
		TextColor = Color3.fromRGB(76, 188, 93),
		StrokeColor = Color3.fromRGB(40, 53, 35),
		Bold = true
	},
	["Unlucky Better"] = {
		Text = "Unlucky Better",
		TextColor = Color3.fromRGB(78, 88, 72),
		StrokeColor = Color3.fromRGB(41, 44, 36),
		Italic = true
	},
	["True Hakari"] = {
		Text = "True Hakari",
		TextColor = Color3.fromRGB(83, 255, 198),
		StrokeColor = Color3.fromRGB(51, 130, 87),
		Italic = true
	},
	Enchanted = {
		Text = "Enchanted",
		TextColor = Color3.fromRGB(94, 145, 255),
		StrokeColor = Color3.fromRGB(29, 39, 54),
		Bold = true
	},
	Keeperbound = {
		Text = "Keeperbound",
		TextColor = Color3.fromRGB(134, 123, 255),
		StrokeColor = Color3.fromRGB(34, 32, 54),
		Bold = true
	},
	["Shark Slayer"] = {
		Text = "Shark Slayer",
		TextColor = Color3.fromRGB(147, 181, 255),
		StrokeColor = Color3.fromRGB(66, 77, 90),
		Bold = true
	},
	Web = {
		Text = "🕸",
		TextColor = Color3.fromRGB(72, 72, 72),
		StrokeColor = Color3.fromRGB(103, 103, 103),
		Bold = true,
		Exclusive = true
	},
	Money = {
		Text = "🤑",
		TextColor = Color3.fromRGB(255, 255, 64),
		StrokeColor = Color3.fromRGB(42, 37, 16)
	},
	["Smirk Cat"] = {
		Text = "😼",
		TextColor = Color3.fromRGB(221, 180, 33),
		StrokeColor = Color3.fromRGB(207, 163, 32),
		Bold = true,
		Exclusive = true
	},
	Ice = {
		Text = "🧊",
		TextColor = Color3.fromRGB(137, 229, 255),
		StrokeColor = Color3.fromRGB(168, 139, 255),
		Bold = true,
		Exclusive = true
	},
	KiwiGuitar = {
		Text = "🎸",
		TextColor = Color3.fromRGB(245, 137, 137),
		StrokeColor = Color3.fromRGB(255, 139, 139),
		Bold = true,
		Exclusive = true
	},
	kiwisnonewark = {
		Text = "☄️",
		TextColor = Color3.fromRGB(132, 211, 245),
		StrokeColor = Color3.fromRGB(143, 143, 255),
		Bold = true,
		Exclusive = true
	},
	Pluto = {
		Text = "🌠",
		TextColor = Color3.fromRGB(255, 85, 0),
		StrokeColor = Color3.fromRGB(97, 70, 134),
		Bold = true,
		Exclusive = true
	},
	["2016assassinwassopeakmeepcity"] = {
		Text = ":p",
		TextColor = Color3.fromRGB(0, 0, 0),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = false,
		Exclusive = true
	},
	["2017assassinwasalsosopeakmeepcity"] = {
		Text = "x_v",
		TextColor = Color3.fromRGB(0, 0, 0),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = false,
		Exclusive = true
	},
	["2018assassinwasalsosopeakmeepcity"] = {
		Text = "v_x",
		TextColor = Color3.fromRGB(0, 0, 0),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = false,
		Exclusive = true
	},
	abunchofkiwis = {
		Text = "🥝",
		TextColor = Color3.fromRGB(172, 247, 137),
		StrokeColor = Color3.fromRGB(138, 255, 139),
		Bold = true,
		Exclusive = true
	},
	redcircle = {
		Text = "🔴",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(67, 0, 0),
		Bold = true,
		Exclusive = true
	},
	Tryhard = {
		Text = "Tryhard",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(67, 0, 0),
		Bold = true
	},
	Street = {
		Text = "🐨💤",
		TextColor = Color3.fromRGB(110, 183, 255),
		StrokeColor = Color3.fromRGB(0, 58, 145),
		Bold = true,
		Exclusive = true
	},
	Demo = {
		Text = "Demolitionist Derby 💫",
		TextColor = Color3.fromRGB(25, 25, 112),
		StrokeColor = Color3.fromRGB(14, 14, 62),
		Bold = true
	},
	["Wiki Helper"] = {
		Text = "Wiki Helper",
		TextColor = Color3.fromRGB(120, 255, 129),
		StrokeColor = Color3.fromRGB(75, 166, 101),
		Bold = true,
		Exclusive = true
	},
	["10Mil"] = {
		Text = "10Mil",
		TextColor = Color3.fromRGB(255, 144, 93),
		StrokeColor = Color3.fromRGB(88, 61, 48),
		Bold = true
	},
	["1B"] = {
		Text = "1B",
		TextColor = Color3.fromRGB(255, 222, 90),
		StrokeColor = Color3.fromRGB(88, 76, 47),
		Bold = true
	},
	Muramasa = {
		Text = "Muramasa",
		TextColor = Color3.fromRGB(0, 0, 0),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Italic = true,
		Exclusive = true
	},
	Manager = {
		Text = "Manager",
		TextColor = Color3.fromRGB(221, 64, 64),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		RankInGroup = 202,
		Exclusive = true
	},
	["Nightmare Conqueror"] = {
		Text = "Nightmare Conqueror",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(67, 0, 0),
		Bold = true
	},
	["Terror of The Depths"] = {
		Text = "Terror of The Depths",
		TextColor = Color3.fromRGB(109, 23, 153),
		StrokeColor = Color3.fromRGB(55, 12, 79),
		Bold = true
	},
	["Ancient's Chosen One"] = {
		Text = "Ancient's Chosen One",
		TextColor = Color3.fromRGB(9, 208, 239),
		StrokeColor = Color3.fromRGB(3, 69, 79),
		Bold = true
	},
	["Deep Sea Phenomenon"] = {
		Text = "Deep Sea Phenomenon",
		TextColor = Color3.fromRGB(255, 164, 0),
		StrokeColor = Color3.fromRGB(84, 53, 0),
		Bold = true
	},
	["Sea Whisperer"] = {
		Text = "Sea Whisperer",
		TextColor = Color3.fromRGB(113, 196, 214),
		StrokeColor = Color3.fromRGB(80, 140, 152),
		Bold = true
	},
	["Volcanic Explorer"] = {
		Text = "Volcanic Explorer",
		TextColor = Color3.fromRGB(215, 20, 5),
		StrokeColor = Color3.fromRGB(160, 15, 5),
		Bold = true
	},
	["Volcanic Helper"] = {
		Text = "Volcanic Helper",
		TextColor = Color3.fromRGB(215, 165, 40),
		StrokeColor = Color3.fromRGB(160, 120, 30),
		Bold = true
	},
	["Novice Fisher"] = {
		Text = "Novice Fischer",
		TextColor = Color3.fromRGB(188, 188, 188),
		StrokeColor = Color3.fromRGB(42, 42, 42)
	},
	["Junior Angler"] = {
		Text = "Junior Angler",
		TextColor = Color3.fromRGB(188, 188, 188),
		StrokeColor = Color3.fromRGB(42, 42, 42)
	},
	["Skilled Fisher"] = {
		Text = "Skilled Fischer",
		TextColor = Color3.fromRGB(216, 202, 97),
		StrokeColor = Color3.fromRGB(132, 120, 62)
	},
	["Tested Tawler"] = {
		Text = "Adept Angler",
		TextColor = Color3.fromRGB(216, 136, 188),
		StrokeColor = Color3.fromRGB(122, 57, 92)
	},
	["Master Fischer"] = {
		Text = "Master Fischer",
		TextColor = Color3.fromRGB(165, 255, 123),
		StrokeColor = Color3.fromRGB(41, 63, 40)
	},
	["Expert Angler"] = {
		Text = "Expert Angler",
		TextColor = Color3.fromRGB(255, 56, 59),
		StrokeColor = Color3.fromRGB(90, 34, 35)
	},
	["Master Angler"] = {
		Text = "Master Angler",
		TextColor = Color3.fromRGB(255, 62, 171),
		StrokeColor = Color3.fromRGB(90, 33, 63),
		Bold = true
	},
	["Pro Fisherman"] = {
		Text = "Pro Fisherman",
		TextColor = Color3.fromRGB(93, 225, 126),
		StrokeColor = Color3.fromRGB(34, 63, 50),
		Italic = true
	},
	["Unstoppable Fischer"] = {
		Text = "Unstoppable Fischer",
		TextColor = Color3.fromRGB(93, 225, 126),
		StrokeColor = Color3.fromRGB(34, 63, 50),
		Italic = true
	},
	["Fishing Veteren"] = {
		Text = "Fisching Veteran",
		TextColor = Color3.fromRGB(99, 143, 225),
		StrokeColor = Color3.fromRGB(32, 43, 63),
		Italic = true
	},
	["Prophet Angler"] = {
		Text = "The Prophet Angler",
		TextColor = Color3.fromRGB(135, 98, 255),
		StrokeColor = Color3.fromRGB(29, 22, 42),
		Bold = true
	},
	["Legendary Fischer"] = {
		Text = "Legendary Fischer",
		TextColor = Color3.fromRGB(255, 178, 69),
		StrokeColor = Color3.fromRGB(90, 55, 39),
		Bold = true
	},
	["Famous Fischer"] = {
		Text = "Famous Fischer",
		TextColor = Color3.fromRGB(164, 255, 205),
		StrokeColor = Color3.fromRGB(59, 90, 71),
		Bold = true
	},
	["Lord Of The Sea"] = {
		Text = "Lord Of The Sea",
		TextColor = Color3.fromRGB(64, 121, 255),
		StrokeColor = Color3.fromRGB(21, 27, 42),
		Bold = true
	},
	["Lady Of The Sea"] = {
		Text = "Lady Of The Sea",
		TextColor = Color3.fromRGB(64, 121, 255),
		StrokeColor = Color3.fromRGB(21, 27, 42),
		Bold = true
	},
	["Mythical Angler"] = {
		Text = "Mythical Angler",
		TextColor = Color3.fromRGB(255, 93, 185),
		StrokeColor = Color3.fromRGB(42, 20, 30),
		Bold = true
	},
	["Eternal Fischer"] = {
		Text = "Eternal Fischer",
		TextColor = Color3.fromRGB(24, 24, 24),
		StrokeColor = Color3.fromRGB(20, 20, 20),
		Bold = true
	},
	["God Of The Seas"] = {
		Text = "God Of The Seas",
		TextColor = Color3.fromRGB(255, 129, 79),
		StrokeColor = Color3.fromRGB(47, 32, 20),
		Bold = true
	},
	["Goddess Of The Seas"] = {
		Text = "Goddess Of The Seas",
		TextColor = Color3.fromRGB(255, 129, 79),
		StrokeColor = Color3.fromRGB(47, 32, 20),
		Bold = true
	},
	["Fish Overlord"] = {
		Text = "Fish Overlord",
		TextColor = Color3.fromRGB(255, 48, 165),
		StrokeColor = Color3.fromRGB(47, 24, 35),
		Bold = true
	},
	["Countdown Caster"] = {
		Text = "Countdown Caster",
		TextColor = Color3.fromRGB(255, 255, 127),
		StrokeColor = Color3.fromRGB(44, 44, 44),
		Italic = true
	},
	["Orcs Best Friend"] = {
		Text = "Orcs Best Friend",
		TextColor = Color3.fromRGB(119, 145, 102),
		StrokeColor = Color3.fromRGB(34, 42, 31),
		Italic = true
	},
	["Albino Vendor"] = {
		Text = "Albino Vendor",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(44, 44, 44),
		Italic = true
	},
	["Santa's Helper"] = {
		Text = "Santa's Helper",
		TextColor = Color3.fromRGB(255, 133, 133),
		StrokeColor = Color3.fromRGB(44, 0, 0),
		Italic = true
	},
	["Elite Helper"] = {
		Text = "Elite Helper",
		TextColor = Color3.fromRGB(226, 180, 41),
		StrokeColor = Color3.fromRGB(66, 46, 0),
		Italic = true
	},
	Rookie = {
		Text = "Rookie",
		TextColor = Color3.fromRGB(188, 188, 188),
		StrokeColor = Color3.fromRGB(42, 42, 42)
	},
	["Novice Explorer"] = {
		Text = "Novice Explorer",
		TextColor = Color3.fromRGB(155, 166, 208),
		StrokeColor = Color3.fromRGB(74, 79, 99)
	},
	["Trusted Explorer"] = {
		Text = "Trusted Explorer",
		TextColor = Color3.fromRGB(208, 120, 102),
		StrokeColor = Color3.fromRGB(42, 29, 23)
	},
	["Sea Scout"] = {
		Text = "Sea Scout",
		TextColor = Color3.fromRGB(149, 255, 125),
		StrokeColor = Color3.fromRGB(26, 42, 23)
	},
	["Renowned Navigator"] = {
		Text = "Renowned Navigator",
		TextColor = Color3.fromRGB(208, 61, 61),
		StrokeColor = Color3.fromRGB(42, 12, 12)
	},
	["Famous Voyager"] = {
		Text = "Famous Voyager",
		TextColor = Color3.fromRGB(156, 52, 208),
		StrokeColor = Color3.fromRGB(38, 11, 42)
	},
	["Ocean Hero"] = {
		Text = "Ocean Hero",
		TextColor = Color3.fromRGB(40, 169, 208),
		StrokeColor = Color3.fromRGB(9, 18, 42)
	},
	["Legendary Explorer"] = {
		Text = "Legendary Explorer",
		TextColor = Color3.fromRGB(126, 86, 208),
		StrokeColor = Color3.fromRGB(39, 27, 66)
	},
	["Grand Pioneer"] = {
		Text = "Grand Pioneer",
		TextColor = Color3.fromRGB(255, 251, 125),
		StrokeColor = Color3.fromRGB(54, 52, 33)
	},
	["Mythical Seeker"] = {
		Text = "Mythical Seeker",
		TextColor = Color3.fromRGB(255, 83, 123),
		StrokeColor = Color3.fromRGB(54, 26, 38)
	},
	["Sea Sovereign"] = {
		Text = "Sea Sovereign",
		TextColor = Color3.fromRGB(255, 147, 69),
		StrokeColor = Color3.fromRGB(79, 45, 21),
		Bold = true
	},
	["Eternal Voyager"] = {
		Text = "Eternal Voyager",
		TextColor = Color3.fromRGB(9, 9, 25),
		StrokeColor = Color3.fromRGB(5, 5, 15),
		Bold = true
	},
	["Tidal Master"] = {
		Text = "Tidal Master",
		TextColor = Color3.fromRGB(255, 85, 0),
		StrokeColor = Color3.fromRGB(40, 40, 40),
		Bold = true
	},
	["Lucky Savior"] = {
		Text = "Lucky Savior",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(76, 255, 91)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 217, 66))
		}),
		GradientRotation = -90,
		StrokeColor = Color3.fromRGB(255, 116, 241),
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Bold)
	},
	["Treasure Master"] = {
		Text = "Treasure Master",
		TextColor = Color3.fromRGB(255, 200, 0),
		StrokeColor = Color3.fromRGB(40, 40, 40),
		Bold = true
	},
	["Poseidon's Blessing"] = {
		Text = "Poseidon's Blessing",
		TextColor = Color3.fromRGB(0, 170, 127),
		StrokeColor = Color3.fromRGB(40, 40, 40),
		Bold = true
	},
	["Chosen By Zeus"] = {
		Text = "Chosen By Zeus",
		TextColor = Color3.fromRGB(0, 95, 247),
		StrokeColor = Color3.fromRGB(40, 40, 40),
		Bold = true
	},
	["Lucky Collector"] = {
		Text = "Lucky Collector",
		TextColor = Color3.fromRGB(1, 193, 7),
		StrokeColor = Color3.fromRGB(193, 204, 78),
		Bold = false
	},
	Belle = {
		Text = "Belle",
		TextColor = Color3.fromRGB(255, 133, 239),
		StrokeColor = Color3.fromRGB(118, 87, 121),
		Bold = true,
		Exclusive = true
	},
	["Nates Favourite"] = {
		Text = "Nates Favourite",
		TextColor = Color3.fromRGB(255, 120, 156),
		StrokeColor = Color3.fromRGB(121, 49, 74),
		Bold = true,
		Exclusive = true
	},
	["Nick's Favorite"] = {
		Text = "nicks faovorite",
		TextColor = Color3.fromRGB(119, 214, 255),
		StrokeColor = Color3.fromRGB(60, 113, 121),
		Bold = true,
		Exclusive = true
	},
	["Co-Owner"] = {
		Text = "Co-Owner",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(36, 6, 6),
		Bold = true,
		Exclusive = true
	},
	["Real Developer Title"] = {
		Text = "Real Developer Title",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(0, 255, 204),
		Bold = true,
		Exclusive = true
	},
	["Not a Developer"] = {
		Text = "Not a Developer",
		TextColor = Color3.fromRGB(0, 85, 255),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	["I own dig"] = {
		Text = "I own dig",
		TextColor = Color3.fromRGB(109, 255, 65),
		StrokeColor = Color3.fromRGB(121, 49, 74),
		Bold = true,
		Exclusive = true
	},
	["Pirate King"] = {
		Text = "Pirate King 🏴‍☠️",
		TextColor = Color3.fromRGB(239, 184, 56),
		StrokeColor = Color3.fromRGB(63, 9, 117),
		Bold = true,
		Exclusive = true
	},
	Snow = {
		Text = "❄️",
		TextColor = Color3.fromRGB(0, 0, 0),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	nick = {
		Text = "🤍",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.557, Color3.fromRGB(70, 71, 72)),
			ColorSequenceKeypoint.new(0.687, Color3.fromRGB(44, 45, 47)),
			ColorSequenceKeypoint.new(0.791, Color3.fromRGB(17, 18, 21)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		GradientRotation = 62,
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Exclusive = true
	},
	["High Roller"] = {
		Text = "♥️ HIGH ROLLER ♠️",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	PRAE = {
		Text = "👁️",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 172, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 2.5,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json"),
		Exclusive = true
	},
	sillyfacetitle = {
		Text = "^_+",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(82, 32, 129)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true,
		AnimationSpeed = 2.5,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json"),
		Exclusive = true
	},
	["Mila's Family"] = {
		Text = "Mila's Family",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 124, 124)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 158, 247)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(231, 183, 101)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	hubert = {
		Text = "hubert fan :3",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 248, 248)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 154, 159))
		}),
		StrokeColor = Color3.fromRGB(67, 67, 67),
		Bold = true,
		Exclusive = true
	},
	IAmNotADevBroDontSayIAmOrElseIMightGetMadOrSomething = {
		Text = ":3",
		TextColor = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/ComicNeueAngular.json"),
		Exclusive = true
	},
	Oceanborn = {
		Text = "Oceanborn",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 138, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(117, 138, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Animated = true
	},
	["Musical Fish"] = {
		Text = "ミュージック:フィッシュ",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 114, 116)),
			ColorSequenceKeypoint.new(0.164, Color3.fromRGB(249, 120, 116)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(111, 255, 128)),
			ColorSequenceKeypoint.new(0.447, Color3.fromRGB(103, 255, 255)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(120, 134, 255)),
			ColorSequenceKeypoint.new(0.741, Color3.fromRGB(110, 43, 255)),
			ColorSequenceKeypoint.new(0.898, Color3.fromRGB(110, 43, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 114, 116))
		}),
		StrokeColor = Color3.fromRGB(165, 177, 207),
		GradientRotation = 0,
		Bold = true,
		Exclusive = true
	},
	["???"] = {
		Text = "???",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Animated = true,
		Exclusive = true
	},
	["$$$"] = {
		Text = "$$$",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 196, 93)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 196, 93),
		Bold = true,
		Animated = true
	},
	Gullible = {
		Text = "Gullible",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 0, 211))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	GUNTER = {
		Text = "GUNTER",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(211, 167, 255))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		CustomFont = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Bold),
		Exclusive = true
	},
	Frostiverse = {
		Text = "🧱",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 232, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	Lasagna = {
		Text = "Lasagna",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 119, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 0))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Exclusive = true
	},
	Feedback = {
		Text = "Feedback Team",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 169, 184)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(91, 206, 250))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	Balancing = {
		Text = "Balancing Team",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 212, 245)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(83, 122, 250))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	["Concept Artist"] = {
		Text = "Concept Artist",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 157, 234)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 250, 250))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	["Tester Lead"] = {
		Text = "Tester Lead",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(166, 255, 172)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 203, 250))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	["Feedback Lead"] = {
		Text = "Feedback Lead",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 255, 246)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 53, 157))
		}),
		Rotation = 0,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		Exclusive = true
	},
	sot = {
		Text = "🦝",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Exclusive = true
	},
	["🦅"] = {
		Text = "🦅",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255)
	},
	["Master Fisher"] = {
		Text = "Master Fisher",
		TextColor = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(40, 40, 40),
		Bold = true
	},
	["🐟"] = {
		Text = "🐟",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 231, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true
	},
	["🎣"] = {
		Text = "🎣",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 169, 255))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Animated = true
	},
	["The Blamed"] = {
		Text = "The Blamed",
		TextColor = ColorSequence.new(Color3.fromRGB(255, 213, 0), Color3.fromRGB(255, 136, 0)),
		StrokeColor = Color3.fromRGB(74, 53, 0),
		Bold = true,
		Exclusive = true
	},
	Castaway = {
		Text = "Castaway",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 181, 182))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Merriweather.json")
	},
	Seafarrer = {
		Text = "Seafarer",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 148, 168))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Merriweather.json")
	},
	Marauder = {
		Text = "Marauder",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 103, 164))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Merriweather.json")
	},
	Ironhook = {
		Text = "Ironhook",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 62, 136))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Merriweather.json")
	},
	Mythwalker = {
		Text = "Mythwalker",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 7, 94))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Merriweather.json")
	},
	["Coin-Bitten"] = {
		Text = "Coin-Bitten",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 252, 211))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Vaultbound = {
		Text = "Vaultbound",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 249, 181))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Crownforged = {
		Text = "Crownforged",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 234, 130))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Gildwarden = {
		Text = "Gildwarden",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 92))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	Vaultkeeper = {
		Text = "Vaultkeeper",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 191, 0))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/Fondamento.json")
	},
	["Lost Soul"] = {
		Text = "Lost Soul",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 243))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/SpecialElite.json")
	},
	["Cursed Deckhand"] = {
		Text = "Cursed Deckhand",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(184, 255, 237))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/SpecialElite.json")
	},
	["Phantom Corsair"] = {
		Text = "Phantom Corsair",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(166, 255, 230))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/SpecialElite.json")
	},
	["Dread Captain"] = {
		Text = "Dread Captain",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 255, 212))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/SpecialElite.json")
	},
	["Eternal Reaver"] = {
		Text = "Eternal Reaver",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 255, 195))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Bold = true,
		CustomFont = Font.new("rbxasset://fonts/families/SpecialElite.json")
	},
	["Smurf Helper"] = {
		Text = "Smurf Helper",
		TextColor = Color3.fromRGB(85, 170, 255),
		GradientRotation = 0,
		StrokeColor = Color3.fromRGB(48, 48, 48)
	},
	["💥🦐"] = {
		Text = "💥🦐",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(223, 113, 113)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(211, 110, 89))
		}),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true,
		Exclusive = true
	},
	["Lever Apprentice"] = {
		Text = "Lever Apprentice",
		TextColor = Color3.fromRGB(255, 106, 0),
		GradientRotation = 0,
		StrokeColor = Color3.fromRGB(34, 34, 34),
		Bold = true
	},
	["🏴‍☠️"] = {
		Text = "🏴‍☠️",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		GradientRotation = 90,
		StrokeColor = Color3.fromRGB(255, 255, 255),
		Bold = true
	},
	ILoveFisch = {
		Text = "I ♡ Fisch",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 99, 187)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(66, 110, 255))
		}),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Animated = true
	},
	["The Thinker"] = {
		Text = "The Thinker",
		TextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 114, 116)),
			ColorSequenceKeypoint.new(0.164, Color3.fromRGB(249, 120, 116)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(111, 255, 128)),
			ColorSequenceKeypoint.new(0.447, Color3.fromRGB(103, 255, 255)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(120, 134, 255)),
			ColorSequenceKeypoint.new(0.741, Color3.fromRGB(110, 43, 255)),
			ColorSequenceKeypoint.new(0.898, Color3.fromRGB(110, 43, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 114, 116))
		}),
		StrokeColor = Color3.fromRGB(165, 177, 207),
		CustomFont = Font.new("rbxassetid://12187367362", Enum.FontWeight.Regular),
		GradientRotation = 0,
		Animated = true,
		AnimationSpeed = 2
	}
}
local module = require("../SharedDataHelper")

function Titles.Has(_, p, p2: string)
	return module.readLegacyPath(p, { "Stats", "title", p2 }) ~= nil
end

function Titles.GetAllOwned(_, p)
	local legacy = module.fetchLegacy(p)

	if not legacy then
		return {}
	end

	local names = {}

	for _, child in legacy:WaitForChild("Stats"):WaitForChild("title"):GetChildren() do
		if typeof(Titles[child.Name]) == "table" then
			table.insert(names, child.Name)
		end
	end

	return names
end

function Titles.Give(_, player, childName, p)
	local RunService = game:GetService("RunService")

	if not RunService:IsServer() then
		return nil
	end

	local both, v = module.fetchBoth(player)

	if not both then
		return nil
	end

	if Titles[childName] then
		if typeof(Titles[childName]) ~= "table" then
			return nil
		end

		local title = both:WaitForChild("Stats"):WaitForChild("title")

		if title:FindFirstChild(childName) then
			if p then
				title:FindFirstChild(childName):Destroy()
				title.Value = "None"
				return false
			end
		else
			local stringValue = Instance.new("StringValue")
			stringValue.Name = childName
			stringValue.Value = childName
			stringValue.Parent = title
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_titleunlock"):FireClient(player, childName)
			return true
		end
	else
		if not v then
			return nil
		end

		for _, failedReward in v.FailedRewards do
			if failedReward.Type == "Title" and failedReward.Name == childName then
				return nil
			end
		end

		table.insert(v.FailedRewards, {
			Type = "Title",
			Name = childName,
			Amount = 1,
			Time = os.time()
		})
		return nil
	end

	return nil
end

function Titles.Remove(_, p, childName)
	local RunService = game:GetService("RunService")

	if not RunService:IsServer() then
		return false
	end

	local legacyPath = module.readLegacyPath(p, { "Stats", "title" })
	local child = legacyPath and legacyPath:FindFirstChild(childName)

	if not child then
		return false
	end

	child:Destroy()

	if legacyPath.Value == childName then
		legacyPath.Value = "None"
	end

	return true
end

function Titles.Resolve(_, p, p2: string?)
	local v = p2 or module.readLegacyPathValue(p, { "Stats", "title" }) or "None"

	if v ~= "Custom" then
		return Titles[v] or Titles.None
	end

	local indexNewFormat = module.indexNewFormat(p, { "CustomTitle" })

	if indexNewFormat and indexNewFormat.Text ~= "" then
		return {
			Text = indexNewFormat.Text,
			TextColor = Color3.fromRGB(
				indexNewFormat.TextColor.r,
				indexNewFormat.TextColor.g,
				indexNewFormat.TextColor.b
			),
			StrokeColor = Color3.fromRGB(
				indexNewFormat.StrokeColor.r,
				indexNewFormat.StrokeColor.g,
				indexNewFormat.StrokeColor.b
			),
			Bold = true,
			IsCustom = true
		}
	end

	return Titles.None
end

return Titles