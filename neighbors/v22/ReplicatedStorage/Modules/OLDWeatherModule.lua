local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local OLDWeatherModule = {}
local v = {
	RainChance = 30,
	ThunderstormChance = 40,
	WeatherChangeRate = 10,
	TemperatureMin = 74,
	TemperatureMax = 74,
	Weather_Changed = false,
	ExtraFog = 0
}
local v2 = {
	{
		RainChance = 30,
		ThunderstormChance = 40,
		WeatherChangeRate = 10,
		TemperatureMin = 74,
		TemperatureMax = 74,
		Weather_Changed = false,
		ExtraFog = 0
	},
	{
		RainChance = 0,
		ThunderstormChance = 0,
		WeatherChangeRate = 10,
		TemperatureMin = 50,
		TemperatureMax = 85,
		Weather_Changed = false,
		ExtraFog = 0
	},
	{
		RainChance = 100,
		ThunderstormChance = 0,
		WeatherChangeRate = 10,
		TemperatureMin = 50,
		TemperatureMax = 60,
		Weather_Changed = false,
		ExtraFog = 0
	},
	{
		RainChance = 100,
		ThunderstormChance = 100,
		WeatherChangeRate = 10,
		TemperatureMin = 50,
		TemperatureMax = 65,
		Weather_Changed = false,
		ExtraFog = 0
	},
	{
		RainChance = 100,
		ThunderstormChance = 0,
		WeatherChangeRate = 10,
		TemperatureMin = 15,
		TemperatureMax = 32,
		Weather_Changed = false,
		ExtraFog = 0
	}
}
local clone = table.clone(v)
local _ = {
	0,
	0.3,
	0.5,
	0.7
}

local function FahrenheitToCelsius(p: number)
	return (math.floor((p - 32) * 5 / 9 + 0.5))
end

function OLDWeatherModule.UpdateSettings()
	local v3 = {
		RainChance = game.ReplicatedStorage:GetAttribute("Weather_RainChance") or clone.RainChance,
		ThunderstormChance = game.ReplicatedStorage:GetAttribute("Weather_ThunderstormChance") or clone.ThunderstormChance,
		WeatherChangeRate = game.ReplicatedStorage:GetAttribute("Weather_WeatherChangeRate") or clone.WeatherChangeRate,
		TemperatureMin = game.ReplicatedStorage:GetAttribute("Weather_TemperatureMin") or clone.TemperatureMin,
		TemperatureMax = game.ReplicatedStorage:GetAttribute("Weather_TemperatureMax") or clone.TemperatureMax,
		Weather_Changed = game.ReplicatedStorage:GetAttribute("Weather_Changed") or false,
		ExtraFog = game.ReplicatedStorage:GetAttribute("Weather_ExtraFog") or 0
	}

	if v3 then
		for k, v4 in v3 do
			v[k] = v4
		end
	end
end

function OLDWeatherModule.GetCurrentSeed()
	return (math.floor(os.time(os.date("!*t")) / (v.WeatherChangeRate * 60)))
end

function OLDWeatherModule.SeedToRegularTime(p: number)
	return p * v.WeatherChangeRate * 60
end

function OLDWeatherModule.GetCurrentWeather(p: number?)
	local weatherChoice

	if RunService:IsClient() then
		repeat
			task.wait()
		until Players.LocalPlayer:GetAttribute("WeatherChoice") ~= nil

		weatherChoice = Players.LocalPlayer:GetAttribute("WeatherChoice") or 1
	else
		weatherChoice = 1
	end

	if weatherChoice > 1 then
		for k, v3 in pairs(v2[weatherChoice]) do
			v[k] = v3
		end
	else
		OLDWeatherModule.UpdateSettings()
	end

	local v3 = (p or OLDWeatherModule.GetCurrentSeed()) * 0.1
	local midpoint = (math.noise(v3) + 1) / 2
	local v5 = v.TemperatureMax - v.TemperatureMin
	local v6 = math.round(v.TemperatureMin + v5 * midpoint)
	local v7 = midpoint * 100
	local v8 = (math.noise(v3 / (v.WeatherChangeRate * 0.5)) + 1.1) / 2 * 100
	local v9 = 100 - v.RainChance <= v7
	local v10 = v9 and 100 - v.ThunderstormChance <= v8
	local snowing

	if v6 <= 32 then
		snowing = v9
	else
		snowing = false
	end

	local cloudCoverage

	if v10 then
		cloudCoverage = math.min(1, midpoint + 0.6)
	elseif v9 then
		cloudCoverage = math.min(1, midpoint + 0.4)
	else
		cloudCoverage = snowing and 1 or 0.7 - midpoint / 4
	end

	local v13 = v10 and midpoint * 2 or v9 and midpoint or 0
	local windSpeed = 10 * midpoint
	local unit = Vector3.new(math.sin(v3), 0, (math.cos(v3))).Unit
	local atmosphereDensity = 0.25 + (not v9 and 0 or 0.35 * midpoint or 0) + (not snowing and 0 or 0.45 * midpoint or 0)
	local haze = (v9 and 5 * midpoint or 0) + v.ExtraFog * 10
	local identifier = (("" .. (snowing and "S" or v10 and "T" or v9 and "R" or "C")) .. tostring((math.floor(v6)))) .. "_" .. tostring(weatherChoice)
	return {
		Temperature = {
			F = v6,
			C = math.floor((v6 - 32) * 5 / 9 + 0.5)
		},
		WindSpeed = windSpeed,
		WindDirection = unit,
		Raining = v9 and not snowing,
		Snowing = snowing,
		Thunder = v10 and not snowing,
		CloudCoverage = cloudCoverage,
		RainDensity = (snowing or not v13) and 0 or v13,
		AtmosphereDensity = atmosphereDensity,
		Haze = haze,
		Identifier = identifier
	}
end

return OLDWeatherModule