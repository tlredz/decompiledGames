local createVector = vector.create
local WeatherUtilShared = require(game.ReplicatedStorage.Modules.Weather.WeatherUtilShared)
local EnvironmentUtilShared = {
	MIN_RENDER_DISTANCE = 2000,
	DEBUG_RENDER_DISTANCE = 0,
	DEBUG_WEATHER_REGION = 0,
	DEBUG_BOUNDS = 0,
	ENVIRONMENT_GROUPS = 0
}
local RunService = game:GetService("RunService")
EnvironmentUtilShared.DEBUG_RENDER_DISTANCE = RunService:IsStudio() and false
local RunService2 = game:GetService("RunService")
EnvironmentUtilShared.DEBUG_WEATHER_REGION = RunService2:IsStudio() and false
local RunService3 = game:GetService("RunService")
EnvironmentUtilShared.DEBUG_BOUNDS = RunService3:IsStudio() and false
EnvironmentUtilShared.ENVIRONMENT_GROUPS = {
	"Island",
	"Sea",
	"SeaEvent",
	"IslandEvent"
}

function EnvironmentUtilShared.mapGroups()
	local result = {}

	for _, v in pairs(EnvironmentUtilShared.ENVIRONMENT_GROUPS) do
		result[v] = {}
	end

	return result
end

function EnvironmentUtilShared.environmentTornadoProperties(p)
	local tornadoProperties = WeatherUtilShared.createTornadoProperties(p)
	local v = {
		Name = tornadoProperties.Name,
		Id = tornadoProperties.Id,
		Bounds = p.Bounds or NumberRange.new(1, 1),
		_CameraEffect = tornadoProperties._CameraEffect,
		_PrecipitationType = tornadoProperties._PrecipitationType
	}
	assert(typeof(v.Bounds) == "NumberRange")
	return v
end

function EnvironmentUtilShared.environmentRainProperties(data)
	local rainProperties = WeatherUtilShared.createRainProperties(data)
	local v = {
		Name = rainProperties.Name,
		Id = rainProperties.Id,
		Bounds = data.Bounds or NumberRange.new(1, 1),
		Inverse = data.Inverse == true or nil,
		RadiusType = not data.RadiusType and createVector(1, 1, 1) or data.RadiusType,
		PrimaryVolumeModifier = rainProperties.PrimaryVolumeModifier,
		Color = rainProperties.Color,
		Intensity = rainProperties.Intensity,
		_CameraEffect = rainProperties._CameraEffect,
		_PrecipitationType = rainProperties._PrecipitationType
	}
	assert(typeof(v.Bounds) == "NumberRange")
	assert(typeof(v.RadiusType) == "Vector3")

	if v.Inverse then
		assert(typeof(v.Inverse) == "boolean")
	end

	return v
end

function EnvironmentUtilShared.environmentSnowProperties(data)
	local snowProperties = WeatherUtilShared.createSnowProperties(data)
	local v = {
		Name = "Snow",
		Id = snowProperties.Id,
		Bounds = data.Bounds or NumberRange.new(1, 1),
		Inverse = data.Inverse == true or nil,
		RadiusType = not data.RadiusType and createVector(1, 1, 1) or data.RadiusType,
		PrimaryVolumeModifier = snowProperties.PrimaryVolumeModifier,
		Color = snowProperties.Color,
		Intensity = snowProperties.Intensity,
		_CameraEffect = snowProperties._CameraEffect,
		_PrecipitationType = snowProperties._PrecipitationType
	}
	assert(typeof(v.Bounds) == "NumberRange")
	assert(typeof(v.RadiusType) == "Vector3")

	if v.Inverse then
		assert(typeof(v.Inverse) == "boolean")
	end

	return v
end

function EnvironmentUtilShared.environmentAshProperties(data)
	local ashProperties = WeatherUtilShared.createAshProperties(data)
	local v = {
		Name = "Ash",
		Id = ashProperties.Id,
		Bounds = data.Bounds or NumberRange.new(1, 1),
		Inverse = data.Inverse == true or nil,
		RadiusType = not data.RadiusType and createVector(1, 1, 1) or data.RadiusType,
		PrimaryVolumeModifier = ashProperties.PrimaryVolumeModifier,
		Color = ashProperties.Color,
		Intensity = ashProperties.Intensity,
		_CameraEffect = ashProperties._CameraEffect,
		_PrecipitationType = ashProperties._PrecipitationType
	}
	assert(typeof(v.Bounds) == "NumberRange")
	assert(typeof(v.RadiusType) == "Vector3")

	if v.Inverse then
		assert(typeof(v.Inverse) == "boolean")
	end

	return v
end

function EnvironmentUtilShared.environmentCloudProperties(data)
	local cloudProperties = WeatherUtilShared.createCloudProperties(data)
	local v = {
		Name = cloudProperties.Name,
		Id = cloudProperties.Id,
		Bounds = data.Bounds or NumberRange.new(1, 1),
		Inverse = data.Inverse == true or nil,
		RadiusType = not data.RadiusType and createVector(1, 1, 1) or data.RadiusType,
		Color = cloudProperties.Color,
		Intensity = cloudProperties.Intensity,
		Cover = cloudProperties.Cover,
		Density = cloudProperties.Density,
		_CameraEffect = cloudProperties._CameraEffect,
		_PrecipitationType = cloudProperties._PrecipitationType
	}
	assert(typeof(v.Bounds) == "NumberRange")
	assert(typeof(v.RadiusType) == "Vector3")

	if v.Inverse then
		assert(typeof(v.Inverse) == "boolean")
	end

	return v
end

function EnvironmentUtilShared.environmentLightningProperties(p)
	local lightningProperties = WeatherUtilShared.createLightningProperties(p)
	local v = {
		Name = lightningProperties.Name,
		Id = lightningProperties.Id,
		Height = lightningProperties.Height,
		Interval = lightningProperties.Interval,
		Radius = lightningProperties.Radius,
		Bounds = p.Bounds or NumberRange.new(1, 1),
		Damage = lightningProperties.Damage,
		_CameraEffect = lightningProperties._CameraEffect,
		_PrecipitationType = lightningProperties._PrecipitationType
	}
	assert(typeof(v.Bounds) == "NumberRange")
	return v
end

return EnvironmentUtilShared