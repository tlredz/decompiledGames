local WeatherUtilShared = require(game.ReplicatedStorage.Modules.Weather.WeatherUtilShared)
local v = {
	Precipitation = WeatherUtilShared.createRainProperties({
		Intensity = 0
	}),
	Clouds = 0
}
local createCloudProperties = WeatherUtilShared.createCloudProperties
local Clouds = require(script.Clouds)
v.Clouds = createCloudProperties({
	Intensity = 1,
	Cover = 0,
	Density = 0,
	Color = Clouds.Clouds.Color
})
local WeatherData = {
	types = {},
	singletons = {},
	properties = {},
	precipitationTypes = {},
	cameraEffects = {},
	Zero = function(_, items)
		for k, item in pairs(items) do
			if typeof(item) == "number" then
				items[k] = 0
			elseif typeof(item) == "Color3" then
				items[k] = Color3.new(1, 1, 1)
			end
		end
	end
}
local types = WeatherData.types
types.Rain = require(script.Rain)
local types2 = WeatherData.types
types2.Snow = require(script.Snow)
local types3 = WeatherData.types
types3.Ash = require(script.Ash)
local types4 = WeatherData.types
types4.Clouds = require(script.Clouds)
local types5 = WeatherData.types
types5.Lightning = require(script.Lightning)
local types6 = WeatherData.types
types6.Tornado = require(script.Tornado)
local types7 = WeatherData.types
types7.Thunderstorm = require(script.Thunderstorm)
local types8 = WeatherData.types
types8.Rainy = require(script.Rainy)
local RunService = game:GetService("RunService")

if RunService:IsStudio() then
	for _, child in pairs(script:GetChildren()) do
		assert(WeatherData.types[child.Name] ~= nil, child.Name)
	end
end

for _, type in pairs(WeatherData.types) do
	for k, v3 in pairs(type) do
		WeatherData.singletons[k] = true

		if v3._PrecipitationType then
			WeatherData.precipitationTypes[k] = true
		end

		if v[k] then
			WeatherData.properties[k] = v[k]
		elseif WeatherData.precipitationTypes[k] then
			WeatherData.properties[k] = v.Precipitation
		end

		if v3._CameraEffect then
			WeatherData.cameraEffects[k] = true
		end
	end
end

return WeatherData