local State = require(game.ReplicatedStorage.Modules.State)
local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local Lock = require(game.ReplicatedStorage.Modules.Util.Lock)
local global = Lock.new()
global:Lock("_Init")
local WeatherUtil = {
	precipitationIgnoreList = {
		workspace:WaitForChild("Characters"),
		workspace:WaitForChild("Enemies"),
		workspace:WaitForChild("NPCs"),
		workspace:WaitForChild("_WorldOrigin"),
		workspace:FindFirstChild("WaterStudio")
	},
	SCAN_HEIGHT = 500,
	precipitationTypes = {},
	components = {},
	singletons = {},
	locks = {
		Global = global,
		Precipitation = global:Extend()
	},
	states = {},
	stateReplicators = {},
	precipitationState = State.new({
		Inside = false,
		Ceiling = 0,
		TimeNotUnderCeiling = 0,
		TimeWentInside = 0,
		TimeWentOutside = 0,
		TimeUnderCeiling = 0
	})
}
local cloudsInstance = workspace.Terrain:FindFirstChildOfClass("Clouds")

if not cloudsInstance then
	cloudsInstance = Instance.new("Clouds")
	cloudsInstance.Enabled = false
	cloudsInstance.Cover = WeatherData.properties.Clouds.Cover
	cloudsInstance.Density = WeatherData.properties.Clouds.Density
	cloudsInstance.Color = WeatherData.properties.Clouds.Color
	cloudsInstance.Name = debug.traceback()
	cloudsInstance.Parent = workspace.Terrain
end

WeatherUtil.cloudsInstance = cloudsInstance
local precipitationTypes = WeatherUtil.precipitationTypes

function WeatherUtil.setPrecipitationColor(p: string, color: Color3, p2)
	if WeatherUtil.locks[p]:IsLocked() then
		return false
	end

	if precipitationTypes[p] then
		return precipitationTypes[p]:SetColor(color, p2)
	end

	return false
end

function WeatherUtil.setPrecipitationIntensity(p: string, p2: number, p3)
	if WeatherUtil.locks[p]:IsLocked() then
		return false
	end

	if precipitationTypes[p] then
		return precipitationTypes[p]:_SetIntensity(p2, p3)
	end

	return false
end

function WeatherUtil.disablePrecipitation(p: string, p2)
	if not precipitationTypes[p] then
		return false
	end

	precipitationTypes[p]:_Disable(p2)
	return true
end

function WeatherUtil:updateState(flag: boolean?)
	local name = self.name
	local state = WeatherUtil.states[name]

	if not state then
		return
	end

	if flag ~= nil then
		if self._enabled then
			state:Set("Enabled", true)
			state:Set("TimeEnabled", os.clock())
		else
			state:Set("Enabled", false)
			state:Set("TimeDisabled", os.clock())
		end
	end

	local property = WeatherData.properties[name]

	if property then
		for k in property do
			state:Set(k, self[k])
		end
	end
end

return WeatherUtil