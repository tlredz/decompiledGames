local v = {
	Properties = {
		ClockTime = 14.3,
		Brightness = 1.5,
		ShadowSoftness = 0.2,
		GeographicLatitude = 0,
		ExposureCompensation = 0,
		EnvironmentDiffuseScale = 0,
		EnvironmentSpecularScale = 0,
		Ambient = Color3.fromRGB(64, 50, 98),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ColorShift_Top = Color3.fromRGB(124, 124, 132),
		OutdoorAmbient = Color3.fromRGB(147, 147, 147)
	},
	Instances = {
		Sky = {
			MoonAngularSize = 11,
			MoonTextureId = "rbxasset://sky/moon.jpg",
			SkyboxBk = "rbxassetid://120123694790724",
			SkyboxDn = "rbxassetid://122862955471051",
			SkyboxFt = "rbxassetid://115158292847131",
			SkyboxLf = "rbxassetid://118219778971052",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://93307600984916",
			SkyboxUp = "rbxassetid://105395734480253",
			StarCount = 3000,
			SunAngularSize = 21,
			SunTextureId = "rbxasset://sky/sun.jpg"
		},
		Atmosphere = {
			Density = 0.44,
			Offset = 0,
			Color = Color3.fromRGB(72, 0, 116),
			Decay = Color3.fromRGB(42, 3, 86),
			Glare = 0,
			Haze = 2.25
		},
		ColorCorrection = {
			Brightness = 0.09,
			Contrast = 0.13,
			Saturation = 1,
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		BloomEffect = {
			Intensity = 0.75,
			Size = 10,
			Threshold = 1.5
		},
		SunRaysEffect = {
			Intensity = 0.1,
			Spread = 0.05
		},
		DepthOfField = {
			FarIntensity = 0.22,
			FocusDistance = 275,
			InFocusRadius = 0,
			NearIntensity = 0
		}
	}
}
return table.freeze(v)