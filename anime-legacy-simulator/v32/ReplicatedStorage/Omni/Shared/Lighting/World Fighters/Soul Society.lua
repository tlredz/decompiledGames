local v = {
	Properties = {
		ClockTime = 12,
		Brightness = 3,
		ShadowSoftness = 1,
		GeographicLatitude = 0,
		ExposureCompensation = 0,
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		Ambient = Color3.fromRGB(70, 70, 70),
		ColorShift_Bottom = Color3.fromRGB(113, 110, 176),
		ColorShift_Top = Color3.fromRGB(83, 86, 156),
		OutdoorAmbient = Color3.fromRGB(70, 70, 70)
	},
	Instances = {
		Sky = {
			MoonAngularSize = 11,
			MoonTextureId = "rbxassetid://6444320592",
			SkyboxBk = "rbxassetid://6444884337",
			SkyboxDn = "rbxassetid://6444884785",
			SkyboxFt = "rbxassetid://6444884337",
			SkyboxLf = "rbxassetid://6444884337",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://6444884337",
			SkyboxUp = "rbxassetid://6412503613",
			StarCount = 3000,
			SunAngularSize = 11,
			SunTextureId = "rbxassetid://6196665106"
		},
		Atmosphere = {
			Density = 0.323,
			Offset = 0.25,
			Color = Color3.fromRGB(173, 168, 222),
			Decay = Color3.fromRGB(88, 93, 125),
			Glare = 0,
			Haze = 2.12
		},
		ColorCorrection = {
			Brightness = 0.028,
			Contrast = 0.24,
			Saturation = 0.5,
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		BloomEffect = {
			Intensity = 1,
			Size = 24,
			Threshold = 2
		},
		SunRaysEffect = {
			Intensity = 0.105,
			Spread = 0.1
		},
		DepthOfField = {
			FarIntensity = 0,
			FocusDistance = 0,
			InFocusRadius = 0,
			NearIntensity = 0
		}
	}
}
return table.freeze(v)