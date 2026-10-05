local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("../ZoneController")
local module2 = require("../LightingController")
local weathers = require(ReplicatedStorage.shared.modules.library.weathers)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
return {
	Start = function(_)
		ReplicatedStorage:WaitForChild("world"):WaitForChild("weather")
		SharedWeather.WeatherChanged:Connect(function()
			module2.UpdateLighting(14)
		end)
		module2.HookLighting:BindAtPriority(1000, function(p)
			local currentZone = module.CurrentZone

			if currentZone and currentZone:FindFirstChild("underground") and currentZone.underground.Value then
				return p
			end

			debug.profilebegin("WeatherLighting")

			for _, v in SharedWeather.GetAllActive() do
				local weather = weathers[v]

				if not weather then
					continue
				end

				for k, v2 in weather.LightingConfig do
					for k2, v3 in v2 do
						p[k][k2] = v3
					end
				end
			end

			debug.profileend()
			return p
		end)
	end
}