local v = {
	Properties = {
		ClockTime = 13,
		Brightness = 4,
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
			SkyboxBk = "http://www.roblox.com/asset/?id=67786463605",
			SkyboxDn = "http://www.roblox.com/asset/?id=6778658683",
			SkyboxFt = "http://www.roblox.com/asset/?id=6778648039",
			SkyboxLf = "http://www.roblox.com/asset/?id=6778649136",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "http://www.roblox.com/asset/?id=6778650519",
			SkyboxUp = "http://www.roblox.com/asset/?id=6778658364",
			StarCount = 3000,
			SunAngularSize = 20,
			SunTextureId = "rbxassetid://6679618752"
		},
		Atmosphere = {
			Density = 0.426,
			Offset = 1,
			Color = Color3.fromRGB(199, 199, 199),
			Decay = Color3.fromRGB(106, 112, 125),
			Glare = 0.1,
			Haze = 0.1
		},
		ColorCorrection = {
			Brightness = 0.1,
			Contrast = 0.15,
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