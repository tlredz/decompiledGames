local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.567332, 0.56875),
	NumberSequenceKeypoint.new(1, 1)
})
return {
	TRAILS = {
		GreenTrail = {
			Multiplier = 1.5,
			Price = 500,
			Gamepass = 1705638621,
			Color = ColorSequence.new(Color3.fromRGB(4, 182, 10)),
			Icon = "rbxassetid://116315544877519"
		},
		BlueTrail = {
			Multiplier = 2,
			Price = 1500,
			Gamepass = 1705790528,
			Color = ColorSequence.new(Color3.fromRGB(0, 73, 190)),
			Icon = "rbxassetid://72675186287041"
		},
		PurpleTrail = {
			Multiplier = 3,
			Price = 5000,
			Gamepass = 1705766445,
			Color = ColorSequence.new(Color3.fromRGB(136, 0, 190)),
			Icon = "rbxassetid://126782245837521"
		},
		RedTrail = {
			Multiplier = 4,
			Price = 25000,
			Gamepass = 1705880432,
			Color = ColorSequence.new(Color3.fromRGB(186, 0, 3)),
			Icon = "rbxassetid://131298799241304"
		},
		RainbowTrail = {
			Multiplier = 5,
			Price = 100000,
			Gamepass = 1705872346,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
			}),
			Icon = "rbxassetid://132750347496620"
		},
		GalaxyTrail = {
			Multiplier = 10,
			Price = 0,
			Gamepass = 1705684677,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 50)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
			}),
			Icon = "rbxassetid://74943114716072"
		},
		CosmicTrail = {
			Multiplier = 100,
			Price = 5000000,
			Gamepass = 1826883825,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 100, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
			}),
			Icon = "rbxassetid://129213243546149"
		},
		VoidTrail = {
			Multiplier = 1000,
			Price = 50000000,
			Gamepass = 1829431034,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 0, 100)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
			}),
			Icon = "rbxassetid://139930714433891"
		},
		SupernovaTrail = {
			Multiplier = 10000,
			Price = 500000000,
			Gamepass = 1828536440,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
			}),
			Icon = "rbxassetid://82185160246144"
		},
		GodlikeTrail = {
			Multiplier = 100000,
			Price = 5000000000,
			Gamepass = 1825327908,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.25, Color3.fromRGB(200, 0, 30)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 0)),
				ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 200))
			}),
			Icon = "rbxassetid://92114716678863"
		},
		DivineTrail = {
			Multiplier = 200000,
			Price = 10000000000,
			Gamepass = 1898660800,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 50)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 250, 200)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
			}),
			Icon = "rbxassetid://94173433829519"
		},
		CelestialTrail = {
			Multiplier = 400000,
			Price = 20000000000,
			Gamepass = 1900232827,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 180)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 240, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 250, 255))
			}),
			Icon = "rbxassetid://102715274333816"
		},
		EternalTrail = {
			Multiplier = 1000000,
			Price = 50000000000,
			Gamepass = 1898888828,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 30, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 110, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 210, 80))
			}),
			Icon = "rbxassetid://88373259466873"
		},
		AscendantTrail = {
			Multiplier = 1500000,
			Price = 75000000000,
			Gamepass = 1898900881,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 60)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 60, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 220))
			}),
			Icon = "rbxassetid://127792880565531"
		},
		TranscendentTrail = {
			Multiplier = 3000000,
			Price = 150000000000,
			Gamepass = 1898384825,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 255))
			}),
			Icon = "rbxassetid://136230578407229"
		},
		InfinityTrail = {
			Multiplier = 5000000,
			Price = 0,
			Gamepass = 1829496998,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 220, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 180, 255))
			}),
			Icon = "rbxassetid://73598304145234"
		},
		OrangeTrail = {
			Multiplier = 1.5,
			Price = 500,
			galaxy = 2,
			Color = ColorSequence.new(Color3.fromRGB(255, 120, 0)),
			Icon = "rbxassetid://125951962131169",
			Gamepass = 1963812500
		},
		PinkTrail = {
			Multiplier = 2,
			Price = 1500,
			galaxy = 2,
			Color = ColorSequence.new(Color3.fromRGB(255, 100, 200)),
			Icon = "rbxassetid://114176947882343",
			Gamepass = 1965390463
		},
		CyanTrail = {
			Multiplier = 3,
			Price = 5000,
			galaxy = 2,
			Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)),
			Icon = "rbxassetid://88720701729597",
			Gamepass = 1962948494
		},
		YellowTrail = {
			Multiplier = 4,
			Price = 25000,
			galaxy = 2,
			Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)),
			Icon = "rbxassetid://123469450190967",
			Gamepass = 1965054501
		},
		CaramelTrail = {
			Multiplier = 5,
			Price = 100000,
			galaxy = 2,
			Color = ColorSequence.new(Color3.fromRGB(255, 166, 125)),
			Icon = "rbxassetid://134204881006815",
			TextureLength = 7,
			TextureMode = Enum.TextureMode.Wrap,
			Texture = "rbxassetid://88813281812051",
			Gamepass = 1962480504
		},
		WhiteChocolateTrail = {
			Multiplier = 10,
			Price = 500000,
			galaxy = 2,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
			Icon = "rbxassetid://122791185151363",
			TextureLength = 7,
			TextureMode = Enum.TextureMode.Wrap,
			Texture = "rbxassetid://133219362075427",
			Gamepass = 1963986467
		},
		FadeTrail = {
			Multiplier = 100,
			Price = 5000000,
			galaxy = 2,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 100)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 100, 150)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 120))
			}),
			Icon = "rbxassetid://107738625645281",
			Gamepass = 1965830417
		},
		CookieDoughTrail = {
			Multiplier = 1000,
			Price = 50000000,
			galaxy = 2,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(228, 207, 179)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(236, 197, 148)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 96, 64))
			}),
			Icon = "rbxassetid://77672686055692",
			Gamepass = 1976474375,
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Texture = "rbxassetid://10892190283"
		},
		SpookyTrail = {
			Multiplier = 10000,
			Price = 500000000,
			galaxy = 2,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(228, 207, 179)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(236, 197, 148)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 96, 64))
			}),
			Icon = "rbxassetid://109502817101737",
			Gamepass = 1998662643,
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Texture = "rbxassetid://104078846775893"
		},
		BbnoTrail = {
			Multiplier = 1.5,
			Price = 500,
			DevProduct = 3611368827,
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Icon = "rbxassetid://82552316132333",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://98739338819526",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = true,
			WidthScale = NumberSequence.new(5),
			Transparency = numberSequence
		},
		DollarsTrail = {
			Multiplier = 2,
			Price = 1500,
			DevProduct = 3611368877,
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Icon = "rbxassetid://87065456379711",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://76885375161041",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = false,
			WidthScale = NumberSequence.new(10),
			Transparency = numberSequence
		},
		BrazilTrail = {
			Multiplier = 3,
			Price = 5000,
			DevProduct = 3611368918,
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Icon = "rbxassetid://130207591020983",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://137135894436203",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = false,
			WidthScale = NumberSequence.new(5),
			Transparency = numberSequence
		},
		LarperTrail = {
			Multiplier = 5,
			Price = 100000,
			DevProduct = 3611368959,
			Color = ColorSequence.new(Color3.new(1, 1, 0)),
			Icon = "rbxassetid://111459278322703",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://85620276526779",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = false,
			WidthScale = NumberSequence.new(5),
			Transparency = numberSequence
		},
		CanadaTrail = {
			Multiplier = 10,
			Price = 500000,
			DevProduct = 3611368993,
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Icon = "rbxassetid://119977971187426",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://74071544945323",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = false,
			WidthScale = NumberSequence.new(5),
			Transparency = numberSequence
		},
		BurgerTrail = {
			Multiplier = 20,
			Price = 1000000,
			DevProduct = 3611369023,
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Icon = "rbxassetid://122606289396707",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://118608893276160",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = false,
			WidthScale = NumberSequence.new(5),
			Transparency = numberSequence
		},
		BbnoFaceTrail = {
			Multiplier = 50,
			Price = 5000000,
			DevProduct = 3611369066,
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Icon = "rbxassetid://134642135365486",
			EventKey = "Bbno2026",
			Texture = "rbxassetid://113084042197119",
			TextureLength = 5,
			TextureMode = Enum.TextureMode.Static,
			Lifetime = 1,
			MaxLength = 50,
			MinLength = 1,
			FaceCamera = false,
			WidthScale = NumberSequence.new(5),
			Transparency = numberSequence
		}
	},
	DEFAULT_TRAIL = "None"
}