local v = {
	Properties = {
		Ambient = Color3.fromRGB(64, 50, 98),
		Brightness = 2,
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ColorShift_Top = Color3.fromRGB(124, 124, 132),
		EnvironmentDiffuseScale = 0,
		EnvironmentSpecularScale = 0,
		ShadowSoftness = 0,
		OutdoorAmbient = Color3.fromRGB(140, 140, 140),
		ClockTime = 13,
		GeographicLatitude = 0,
		ExposureCompensation = 0
	},
	Instances = {
		Sky = {
			MoonAngularSize = 11,
			MoonTextureId = "rbxasset://sky/moon.jpg",
			SkyboxBk = "rbxassetid://13658265025",
			SkyboxDn = "rbxassetid://13658264839",
			SkyboxFt = "rbxassetid://13658264678",
			SkyboxLf = "rbxassetid://13658264537",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://13658264348",
			SkyboxUp = "rbxassetid://13658264120",
			StarCount = 3000,
			SunAngularSize = 21,
			SunTextureId = "rbxasset://sky/sun.jpg"
		},
		Atmosphere = {
			Density = 0.28,
			Offset = 1,
			Color = Color3.fromRGB(199, 199, 199),
			Decay = Color3.fromRGB(106, 112, 125),
			Glare = 0,
			Haze = 0
		},
		ColorCorrection = {
			Brightness = 0.1,
			Contrast = 0.3,
			Saturation = 0.35,
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
			FarIntensity = 0.5,
			FocusDistance = 280,
			InFocusRadius = 0,
			NearIntensity = 0
		}
	}
}
return table.freeze(v)