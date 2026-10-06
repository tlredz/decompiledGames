local v = {
	Properties = {
		ClockTime = 8.243,
		Brightness = 2,
		ShadowSoftness = 1,
		GeographicLatitude = -17.822,
		ExposureCompensation = 0,
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 0,
		Ambient = Color3.fromRGB(70, 70, 70),
		ColorShift_Bottom = Color3.fromRGB(188, 255, 247),
		ColorShift_Top = Color3.fromRGB(83, 86, 156),
		OutdoorAmbient = Color3.fromRGB(93, 93, 93)
	},
	Instances = {
		Sky = {
			MoonAngularSize = 11,
			MoonTextureId = "rbxassetid://129209067158459",
			SkyboxBk = "rbxassetid://127199736717314",
			SkyboxDn = "rbxassetid://125584044522688",
			SkyboxFt = "rbxassetid://125719740556153",
			SkyboxLf = "rbxassetid://132298454518117",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://136701361849414",
			SkyboxUp = "rbxassetid://87091865421419",
			StarCount = 0,
			SunAngularSize = 5,
			SunTextureId = "rbxassetid://129209067158459"
		},
		Atmosphere = {
			Density = 0.4,
			Offset = 0,
			Color = Color3.fromRGB(172, 255, 218),
			Decay = Color3.fromRGB(48, 62, 53),
			Glare = 0.6,
			Haze = 10
		},
		ColorCorrection = {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = 0.1,
			TintColor = Color3.fromRGB(240, 255, 235)
		},
		BloomEffect = {
			Intensity = 1,
			Size = 40,
			Threshold = 2
		},
		SunRaysEffect = {
			Intensity = 0.04,
			Spread = 0.01
		},
		DepthOfField = {
			FarIntensity = 0.1,
			FocusDistance = 0.05,
			InFocusRadius = 30,
			NearIntensity = 0.75
		}
	}
}
return table.freeze(v)