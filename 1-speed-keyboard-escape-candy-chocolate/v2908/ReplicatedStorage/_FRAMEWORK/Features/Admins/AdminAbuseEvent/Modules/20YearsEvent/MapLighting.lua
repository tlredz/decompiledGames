local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {
	Ambient = "Color3Value",
	Brightness = "NumberValue",
	ClockTime = "NumberValue",
	ColorShift_Bottom = "Color3Value",
	ColorShift_Top = "Color3Value",
	EnvironmentDiffuseScale = "NumberValue",
	EnvironmentSpecularScale = "NumberValue",
	ExposureCompensation = "NumberValue",
	FogColor = "Color3Value",
	FogEnd = "NumberValue",
	FogStart = "NumberValue",
	GeographicLatitude = "NumberValue",
	GlobalShadows = "BoolValue",
	OutdoorAmbient = "Color3Value",
	ShadowSoftness = "NumberValue"
}
local v2 = nil
local clones = {}
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isLightingEffect(instance)
	return instance:IsA("Sky") or instance:IsA("Atmosphere") or instance:IsA("PostEffect")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearActiveEffects()
	for _, v4 in clones do
		v4:Destroy()
	end

	table.clear(clones)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addEffect(instance)
	local clone = instance:Clone()
	table.insert(clones, clone)
	clone.Parent = Lighting
end

local function checkPropertyValue(instance)
	local v4 = v[instance.Name]

	if v4 and instance.ClassName == v4 then
		return true, instance.Value
	end

	logger:warn(string.format("Ignoring unsupported map lighting property %s (%s)", instance.Name, instance.ClassName))
	return false, nil
end

local MapLighting = {
	startClient = function()
		if not v2 then
			local properties = {}
			local effects = {}

			for k in v do
				properties[k] = Lighting[k]
			end

			for _, child in Lighting:GetChildren() do
				if isLightingEffect(child) then
					table.insert(effects, {
						original = child,
						template = child:Clone()
					})
				end
			end

			v2 = {
				properties = properties,
				effects = effects
			}
		end
	end,
	apply = function(instance)
		local v4 = v2
		clearActiveEffects() -- equivalent call inferred; original call site unknown

		for _, effect in v4.effects do
			effect.original.Parent = nil
		end

		for k, property in v4.properties do
			Lighting[k] = property
		end

		local v5 = {}

		if instance then
			local properties = instance:FindFirstChild("Properties")

			if properties then
				for _, child in properties:GetChildren() do
					local v6 = v[child.Name]
					local value, flag

					if v6 and child.ClassName == v6 then
						value = child.Value
						flag = true
					else
						logger:warn(string.format(
							"Ignoring unsupported map lighting property %s (%s)",
							child.Name,
							child.ClassName
						))
						flag = false
					end

					if flag then
						Lighting[child.Name] = value
					end
				end
			end

			for _, child in instance:GetChildren() do
				if not isLightingEffect(child) then
					continue
				end

				v5[child.ClassName] = true
				addEffect(child) -- equivalent call inferred; original call site unknown
			end
		end

		for _, effect in v4.effects do
			if v5[effect.template.ClassName] then
				continue
			end

			addEffect(effect.template) -- equivalent call inferred; original call site unknown
		end

		v3 = true
	end,
	restore = function()
		local v4 = v2

		if v4 and v3 then
			clearActiveEffects() -- equivalent call inferred; original call site unknown

			for k, property in v4.properties do
				Lighting[k] = property
			end

			for _, effect in v4.effects do
				effect.original.Parent = Lighting
			end

			v3 = false
		end
	end
}

function MapLighting.cleanupClient()
	MapLighting.restore()

	if v2 then
		for _, effect in v2.effects do
			effect.template:Destroy()
		end

		v2 = nil
	end
end

return MapLighting