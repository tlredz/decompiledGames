local v = {
	Properties = {
		ClockTime = 13,
		Brightness = 3,
		ShadowSoftness = 1,
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
			MoonTextureId = "rbxasset://sky/moon.jpg",
			SkyboxBk = "rbxassetid://706982625",
			SkyboxDn = "rbxassetid://706983129",
			SkyboxFt = "rbxassetid://706982625",
			SkyboxLf = "rbxassetid://706982625",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://706982625",
			SkyboxUp = "rbxassetid://706983714",
			StarCount = 3000,
			SunAngularSize = 21,
			SunTextureId = "rbxasset://sky/sun.jpg"
		},
		Atmosphere = {
			Density = 0.3,
			Offset = 1,
			Color = Color3.fromRGB(255, 227, 203),
			Decay = Color3.fromRGB(255, 229, 211),
			Glare = 0.14,
			Haze = 1.81
		},
		ColorCorrection = {
			Brightness = 0.05,
			Contrast = 0.2,
			Saturation = 0.5,
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		BloomEffect = {
			Intensity = 1,
			Size = 56,
			Threshold = 2
		},
		SunRaysEffect = {
			Intensity = 0.1,
			Spread = 1
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