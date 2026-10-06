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
			SkyboxBk = "rbxassetid://135413518795975",
			SkyboxDn = "rbxassetid://95882936696433",
			SkyboxFt = "rbxassetid://135057897000878",
			SkyboxLf = "rbxassetid://120214648848557",
			SkyboxOrientation = vector.create(0, 0, 0),
			SkyboxRt = "rbxassetid://74769174905050",
			SkyboxUp = "rbxassetid://119223784784293",
			StarCount = 3000,
			SunAngularSize = 21,
			SunTextureId = "rbxasset://sky/sun.jpg"
		},
		Atmosphere = {
			Density = 0.566,
			Offset = 0,
			Color = Color3.fromRGB(199, 199, 199),
			Decay = Color3.fromRGB(67, 0, 0),
			Glare = 0.2,
			Haze = 2.67
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
			Intensity = 0,
			Spread = 0
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