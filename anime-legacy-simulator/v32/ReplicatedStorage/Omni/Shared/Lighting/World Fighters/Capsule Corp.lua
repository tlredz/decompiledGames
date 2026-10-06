local v = {
	Properties = {
		ClockTime = 14,
		Brightness = 3,
		ShadowSoftness = 0.2,
		GeographicLatitude = 0,
		ExposureCompensation = 0,
		EnvironmentDiffuseScale = 0.1,
		EnvironmentSpecularScale = 0.3,
		Ambient = Color3.fromRGB(64, 50, 98),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ColorShift_Top = Color3.fromRGB(124, 124, 132),
		OutdoorAmbient = Color3.fromRGB(89, 89, 89)
	},
	Instances = {
		Sky = {
			MoonAngularSize = 11,
			MoonTextureId = "rbxasset://sky/moon.jpg",
			SkyboxBk = "http://www.roblox.com/asset/?id=6778646360",
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
			Density = 0.3,
			Offset = 1,
			Color = Color3.fromRGB(138, 138, 138),
			Decay = Color3.fromRGB(106, 112, 125),
			Glare = 0,
			Haze = 0
		},
		ColorCorrection = {
			Brightness = 0.1,
			Contrast = 0.1,
			Saturation = 1.3,
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