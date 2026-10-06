local v = {
	Properties = {
		ClockTime = 14,
		Brightness = 3.5,
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
			MoonTextureId = "rbxassetid://98064059332604",
			SkyboxBk = "rbxassetid://86567215327926",
			SkyboxDn = "rbxassetid://122060958830251",
			SkyboxFt = "rbxassetid://124390430910808",
			SkyboxLf = "rbxassetid://87042944403266",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://112728511822726",
			SkyboxUp = "rbxassetid://109506002280387",
			StarCount = 5000,
			SunAngularSize = 11,
			SunTextureId = "rbxassetid://92664568220979"
		},
		Atmosphere = {
			Density = 0.28,
			Offset = 1,
			Color = Color3.fromRGB(255, 227, 203),
			Decay = Color3.fromRGB(231, 229, 255),
			Glare = 0.45,
			Haze = 1.81
		},
		ColorCorrection = {
			Brightness = 0.05,
			Contrast = 0.2,
			Saturation = 1,
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