local Weather = require(script:FindFirstAncestor("Weather"))
local WeatherUtil = require(game.ReplicatedStorage.Controllers.WeatherController.WeatherUtil)
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local object = setmetatable({}, Weather)
object.__index = object
local v = {}

function object.new(p)
	local name = p.Name

	if not v[name] then
		local v2 = Weather.new(p)
		v[name] = setmetatable(v2, object)
	end

	return v[name]
end

function object:_Stop(p2)
	self.Intensity = 0
	WeatherUtil.disablePrecipitation(self.name, p2)
	return nil
end

function object:_Update(p2, p3)
	local intensity = p2.Intensity
	local color = p2.Color
	WeatherUtil.setPrecipitationColor(self.name, color, p3)

	if not WeatherUtil.setPrecipitationIntensity(self.name, intensity, p3) then
		return false
	end

	self.Intensity = intensity
	return true
end

return object