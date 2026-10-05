require(game.ReplicatedStorage.Modules.Weather.WeatherData.Clouds)
local Weather = require(script:FindFirstAncestor("Weather"))
local WeatherUtil = require(game.ReplicatedStorage.Controllers.WeatherController.WeatherUtil)
local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
local v = assert(WeatherData.properties.Clouds, "bad clouds?")
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local v2 = nil
local cloudsInstance = WeatherUtil.cloudsInstance
local v3 = nil
local object = setmetatable({}, Weather)
object.__index = object

function object.new(p)
	if not v2 then
		v2 = setmetatable(Weather.new(p), object)
	end

	return v2
end

function object:_Update(data, p2)
	local cover = data.Cover or self.weatherSettings.Cover
	local density = data.Density or self.weatherSettings.Density
	local color = data.Color or self.weatherSettings.Color
	local v4 = cloudsInstance.Cover == cover
	local v5 = cloudsInstance.Density == density
	local v6 = cloudsInstance.Color == color
	local v7

	if cover == 0 then
		v7 = density == 0
	else
		v7 = false
	end

	if v4 and v5 and v6 then
		if cloudsInstance.Enabled or cloudsInstance.Cover == 0 and cloudsInstance.Density == 0 and v7 then
			return false
		end
	end

	self.Intensity = math.clamp(data.Intensity or (cover + density) / 2, 0, 1)
	self.Cover = cover
	self.Density = density
	self.Color = color

	if not cloudsInstance.Enabled then
		cloudsInstance.Enabled = true
	end

	if p2 then
		if v3 then
			v3:Cancel()
			v3 = nil
		end

		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(cloudsInstance, p2, {
			Density = density,
			Cover = cover,
			Color = color
		})
		tween:Play()
		tween.Completed:Connect(function(p3)
			if p3 == Enum.PlaybackState.Completed and v7 then
				cloudsInstance.Enabled = false
			end
		end)
		v3 = tween
	else
		cloudsInstance.Density = density
		cloudsInstance.Cover = cover
		cloudsInstance.Color = color

		if v7 then
			cloudsInstance.Enabled = false
		end
	end

	return true
end

function object._Stop(object2, p)
	object2:SetIntensity({
		Intensity = v.Intensity,
		Cover = v.Cover,
		Density = v.Density,
		Color = v.Color
	}, p)
end

return object