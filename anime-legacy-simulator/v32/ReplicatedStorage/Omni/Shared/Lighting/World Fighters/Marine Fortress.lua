local v = {
	Properties = {
		ClockTime = 14.3,
		Brightness = 3,
		ShadowSoftness = 0.2,
		GeographicLatitude = 0,
		ExposureCompensation = 0,
		EnvironmentDiffuseScale = 0.1,
		EnvironmentSpecularScale = 0.1,
		Ambient = Color3.fromRGB(64, 50, 98),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ColorShift_Top = Color3.fromRGB(124, 124, 132),
		OutdoorAmbient = Color3.fromRGB(147, 147, 147)
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
			Density = 0.45,
			Offset = 1,
			Color = Color3.fromRGB(192, 192, 222),
			Decay = Color3.fromRGB(88, 93, 125),
			Glare = 0,
			Haze = 4
		},
		ColorCorrection = {
			Brightness = 0.1,
			Contrast = 0,
			Saturation = 1.4,
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		BloomEffect = {
			Intensity = 0.75,
			Size = 12,
			Threshold = 1.5
		},
		SunRaysEffect = {
			Intensity = 0.1,
			Spread = 0.05
		},
		DepthOfField = {
			FarIntensity = 1,
			FocusDistance = 200,
			InFocusRadius = 38.3,
			NearIntensity = 0
		}
	}
}
return table.freeze(v)