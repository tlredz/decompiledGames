local replicatedStorage = game:WaitForChild("ReplicatedStorage")
local Signal = require(replicatedStorage.packages.Signal)
local weather = replicatedStorage:WaitForChild("world"):WaitForChild("weather")
local children = weather:GetChildren()
local weathers = require(replicatedStorage.shared.modules.library.weathers)
local SharedWeather = {
	GetPossibleGroupWeathers = function(p, p2: string)
		local weathers2 = {}

		for k, weather2 in weathers do
			if not (weather2.Group == p and (weather2.TimeOfDay == "Both" or weather2.TimeOfDay == p2) and weather2.Chance > 0) then
				continue
			end

			if not weather2.AllowTradePlaza then
				local FischUtils = require(replicatedStorage.shared.utils.FischUtils)

				if FischUtils.IsTradePlaza() then
					continue
				end
			end

			weathers2[k] = weather2
		end

		return weathers2
	end,
	GetActiveGroupWeather = function(childName)
		if childName == "main" then
			return weather.Value
		end

		return weather:WaitForChild(childName).Value
	end,
	GetGroupValueObject = function(childName)
		if childName == "main" then
			return weather
		end

		return weather:WaitForChild(childName)
	end
}

function SharedWeather.IsActive(p: string)
	local weather2 = weathers[p]

	if weather2 then
		return SharedWeather.GetActiveGroupWeather(weather2.Group) == p
	end

	return false
end

function SharedWeather.GetAllActive()
	local result = { SharedWeather.GetActiveGroupWeather("main") }

	for _, v in children do
		if weathers[v.Value] then
			table.insert(result, v.Value)
		end
	end

	return result
end

function SharedWeather.IsAnyActive(items)
	for _, item in items do
		if SharedWeather.IsActive(item) then
			return true
		end
	end

	return false
end

function SharedWeather.AreAllActive(items)
	for _, item in items do
		if not SharedWeather.IsActive(item) then
			return false
		end
	end

	return true
end

function SharedWeather.IsProtected()
	local allActive = SharedWeather.GetAllActive()

	for _, v in allActive do
		if weathers[v].Protected then
			return true, weathers[v].ProtectedMessage
		end
	end

	return false, nil
end

function SharedWeather.IsGroupProtected(p)
	local activeGroupWeather = SharedWeather.GetActiveGroupWeather(p)

	if weathers[activeGroupWeather] and weathers[activeGroupWeather].Protected then
		return true, weathers[activeGroupWeather].ProtectedMessage
	end

	return false, nil
end

SharedWeather.WeatherChanged = Signal.new()

local function listenWeatherValue(data)
	data.Changed:Connect(function(p)
		SharedWeather.WeatherChanged:Fire(data.Name, p)
	end)
	SharedWeather.WeatherChanged:Fire(data.Name, data.Value)

	if data ~= weather and not table.find(children, data) then
		table.insert(children, data)
	end

	table.sort(children, function(a, b)
		return a.Name < b.Name
	end)
end

weather.ChildAdded:Connect(listenWeatherValue)
listenWeatherValue(weather)

for _, child in weather:GetChildren() do
	listenWeatherValue(child)
end

return SharedWeather