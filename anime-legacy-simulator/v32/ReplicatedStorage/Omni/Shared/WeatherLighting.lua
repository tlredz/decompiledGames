local BerserkForest = require(script.Parent.Lighting["World Fighters"]["Berserk Forest"])
local v = {
	TransitionDuration = 3,
	Properties = {
		"Brightness",
		"ExposureCompensation",
		"Ambient",
		"OutdoorAmbient",
		"ClockTime",
		"GlobalShadows"
	},
	Instances = {
		Atmosphere = {
			"Density",
			"Haze",
			"Glare",
			"Color",
			"Decay"
		},
		ColorCorrection = { "TintColor", "Saturation", "Contrast" },
		BloomEffect = { "Intensity", "Enabled" },
		SunRaysEffect = { "Intensity", "Enabled" },
		DepthOfField = { "Enabled" },
		Sky = {
			"SkyboxBk",
			"SkyboxDn",
			"SkyboxFt",
			"SkyboxLf",
			"SkyboxRt",
			"SkyboxUp",
			"SkyboxOrientation",
			"StarCount",
			"CelestialBodiesShown",
			"SunTextureId",
			"MoonTextureId",
			"SunAngularSize",
			"MoonAngularSize"
		}
	},
	List = {
		Clear = {},
		Cloudy = {
			Brightness = 0.85,
			Exposure = -0.05,
			Density = 0.03,
			Haze = 0.6,
			Saturation = -0.1,
			Tint = Color3.fromRGB(238, 243, 250),
			AtmosphereBlend = 0.2,
			AmbientBlend = 0.15,
			SunRays = 0.25
		},
		Rain = {
			Brightness = 0.7,
			Exposure = -0.12,
			Density = 0.07,
			Haze = 1.2,
			Saturation = -0.18,
			Tint = Color3.fromRGB(218, 233, 255),
			AtmosphereBlend = 0.2,
			AmbientBlend = 0.15,
			SunRays = 0.1
		},
		Thunderstorm = {
			Brightness = 0.5,
			Exposure = -0.22,
			Density = 0.1,
			Haze = 1.8,
			Saturation = -0.25,
			Contrast = 0.04,
			Tint = Color3.fromRGB(205, 218, 245),
			AtmosphereBlend = 0.2,
			AmbientBlend = 0.25,
			SunRays = 0
		},
		Heatwave = {
			Brightness = 1.12,
			Exposure = 0.06,
			Density = 0.02,
			Haze = 0.7,
			Glare = 0.12,
			Saturation = 0.04,
			Tint = Color3.fromRGB(255, 234, 209),
			AtmosphereBlend = 0.2,
			AmbientBlend = 0.25,
			SunRays = 1.2
		},
		Blizzard = {
			Brightness = 0.8,
			Exposure = -0.03,
			Density = 0.14,
			Haze = 1.6,
			Saturation = -0.25,
			Tint = Color3.fromRGB(222, 241, 255),
			AtmosphereBlend = 0.35,
			AmbientBlend = 0.25,
			SunRays = 0
		},
		["Toxic Fog"] = {
			Brightness = 0.7,
			Exposure = -0.1,
			Density = 0.15,
			Haze = 2,
			Saturation = -0.08,
			Tint = Color3.fromRGB(218, 245, 190),
			AtmosphereBlend = 0.35,
			AmbientBlend = 0.25,
			SunRays = 0
		},
		Aurora = {
			ClockTime = 20.5,
			Brightness = 0.75,
			Exposure = -0.05,
			Density = 0.01,
			Haze = 0.35,
			Saturation = 0.05,
			Tint = Color3.fromRGB(205, 255, 240),
			AtmosphereBlend = 0.25,
			AmbientBlend = 0.25,
			Bloom = 1.1,
			SunRays = 0
		},
		Eclipse = {
			Lighting = BerserkForest
		},
		["Meteor Shower"] = {
			ClockTime = 0.5,
			Brightness = 0.65,
			Exposure = -0.08,
			Density = -0.03,
			Haze = 0.2,
			Contrast = 0.03,
			Tint = Color3.fromRGB(224, 218, 255),
			AtmosphereBlend = 0.25,
			AmbientBlend = 0.25,
			Bloom = 1.05,
			SunRays = 0
		}
	}
}

local function ApplyProperties(p, options)
	for k, v2 in options or {} do
		p[k] = v2
	end
end

function v.Compose(p, p2, value: string?, flag: boolean?, options)
	local v2 = {
		Properties = table.clone(p.Properties),
		Instances = {}
	}

	for k, instance in p.Instances do
		v2.Instances[k] = table.clone(instance)
	end

	if p2 then
		local properties = v2.Properties

		for k, v3 in p2.Properties or {} do
			properties[k] = v3
		end

		for k, v3 in p2.Instances or {} do
			v2.Instances[k] = v2.Instances[k] or {}
			local instance = v2.Instances[k]

			for k2, v4 in v3 or {} do
				instance[k2] = v4
			end
		end
	end

	local v3 = v.List[value or "Clear"] or v.List.Clear

	if v3.Lighting then
		local properties = v2.Properties

		for k, v4 in v3.Lighting.Properties or {} do
			properties[k] = v4
		end

		for k, v4 in v3.Lighting.Instances or {} do
			v2.Instances[k] = v2.Instances[k] or {}
			local instance = v2.Instances[k]

			for k2, v5 in v4 or {} do
				instance[k2] = v5
			end
		end
	end

	if options then
		v2.Instances.Sky = v2.Instances.Sky or {}
		local sky = v2.Instances.Sky

		for k, v4 in options or {} do
			sky[k] = v4
		end
	end

	local properties = v2.Properties
	local instances = v2.Instances

	if v3.Tint then
		properties.Brightness = math.clamp(properties.Brightness * v3.Brightness, 0, 10)
		properties.ExposureCompensation = math.clamp(properties.ExposureCompensation + v3.Exposure, -5, 5)
		properties.Ambient = properties.Ambient:Lerp(v3.Tint, v3.AmbientBlend)
		properties.OutdoorAmbient = properties.OutdoorAmbient:Lerp(v3.Tint, v3.AmbientBlend)
		properties.ClockTime = v3.ClockTime or properties.ClockTime
		local atmosphere = instances.Atmosphere

		if atmosphere then
			atmosphere.Density = math.clamp(atmosphere.Density + v3.Density, 0, 1)
			atmosphere.Haze = math.clamp(atmosphere.Haze + v3.Haze, 0, 10)
			atmosphere.Glare = math.clamp(atmosphere.Glare + (v3.Glare or 0), 0, 10)
			atmosphere.Color = atmosphere.Color:Lerp(v3.Tint, v3.AtmosphereBlend)
			atmosphere.Decay = atmosphere.Decay:Lerp(v3.Tint, v3.AtmosphereBlend)
		end

		local colorCorrection = instances.ColorCorrection

		if colorCorrection then
			local tintColor = colorCorrection.TintColor
			colorCorrection.TintColor = Color3.new(
				tintColor.R * v3.Tint.R,
				tintColor.G * v3.Tint.G,
				tintColor.B * v3.Tint.B
			)

			if v3.Saturation then
				colorCorrection.Saturation = math.clamp(colorCorrection.Saturation + v3.Saturation, -1, 1)
			end

			if v3.Contrast then
				colorCorrection.Contrast = math.clamp(colorCorrection.Contrast + v3.Contrast, -1, 1)
			end
		end

		if instances.BloomEffect and v3.Bloom then
			instances.BloomEffect.Intensity = math.clamp(instances.BloomEffect.Intensity * v3.Bloom, 0, 10)
		end

		if instances.SunRaysEffect then
			instances.SunRaysEffect.Intensity = math.clamp(instances.SunRaysEffect.Intensity * v3.SunRays, 0, 1)
		end
	end

	if not flag then
		return v2
	end

	properties.GlobalShadows = false

	if instances.Atmosphere then
		instances.Atmosphere.Haze = 0
		instances.Atmosphere.Glare = 0
	end

	for _, v4 in { "BloomEffect", "DepthOfField", "SunRaysEffect" } do
		if instances[v4] then
			instances[v4].Enabled = false
		end
	end

	return v2
end

function v.LerpClock(p: number, p2: number, p3: number)
	return (p + ((p2 - p + 12) % 24 - 12) * p3) % 24
end

return table.freeze(v)