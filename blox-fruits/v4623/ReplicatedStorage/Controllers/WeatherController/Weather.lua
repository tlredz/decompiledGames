local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local WeatherUtil = require(game.ReplicatedStorage.Controllers.WeatherController.WeatherUtil)
local Weather = {}
Weather.__index = Weather

local function updateState(p, flag: boolean?)
	return WeatherUtil.updateState(p, flag)
end

function Weather:SetIntensity(intensity, p)
	if not self._enabled then
		return false
	end

	local v = typeof(intensity) == "number" and {
		Intensity = intensity
	} or intensity

	if not self._Update or self._Update(self, v, p) then
		self.lastUpdate = os.clock()
		WeatherUtil.updateState(self, nil)
		return true
	else
		self.lastUpdate = os.clock() + 0.2
		return false
	end
end

function Weather:Enable(...)
	if self._enabled then
		return
	end

	self._wasEnabled = true

	if WeatherUtil.locks[self.name]:IsLocked() then
		return
	end

	self._enabled = true

	if self._Start then
		self:_Start(...)
	end

	WeatherUtil.updateState(self, true)
end

function Weather:Disable(p)
	if not self._enabled then
		return
	end

	if self._Stop then
		self._Stop(self, p)
	end

	self._enabled = false
	self._wasEnabled = false
	WeatherUtil.updateState(self, true)
end

function Weather:Destroy()
	if self._destroyed then
		return
	end

	if WeatherData.cameraEffects[self.name] then
		warn("Trying to destroy something that shouldn't be destroyed", self, debug.traceback())
		return
	end

	WeatherUtil.components[self.uid] = nil
	self._destroyed = true
	self:Disable()

	if self._Cleanup then
		self._Cleanup(self)
	end
end

function Weather.new(weatherSettings)
	local name = assert(weatherSettings.Name, "bad weatherSettings.Name")
	local uid = assert(weatherSettings.UID, "bad weatherSettings.UID")
	assert(WeatherUtil.locks[name], "No lock for name: " .. name)
	local component = WeatherUtil.components[uid]

	if component then
		warn("Weather with UID already exists: ", uid, debug.traceback())
		return component
	end

	local v3 = {
		weatherSettings = weatherSettings,
		_enabled = false,
		_wasEnabled = false,
		_destroyed = false,
		subtype = WeatherData.precipitationTypes[name] and "Precipitation" or name,
		uid = uid,
		name = name,
		lastUpdate = 1,
		timeIn = workspace:GetServerTimeNow()
	}
	local object = setmetatable(v3, Weather)

	function object.new(...)
		if not object._enabled then
			return
		end

		if object._Instanciate ~= nil then
			return object._Instanciate(object, ...)
		end

		warn((`Component doesn't have _Instanciate: {v3.name}`))
		return nil
	end

	if WeatherData.cameraEffects[name] ~= nil then
		WeatherUtil.components[name] = object
		return object
	end

	WeatherUtil.components[uid] = object
	return object
end

return Weather