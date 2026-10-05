local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("../ui/state")
local module2 = require("../legacyControllers/SettingsController")
local world = ReplicatedStorage:WaitForChild("world")
local uptime = world:WaitForChild("uptime")
local region_region = world:WaitForChild("region_region")
local region_city = world:WaitForChild("region_city")
local region_country = world:WaitForChild("region_country")
local version = world:WaitForChild("version")
local ServerInfoSync = {}

function ServerInfoSync.init()
	ServerInfoSync._updateUptime()
	ServerInfoSync._updateCity()
	ServerInfoSync._updateRegion()
	ServerInfoSync._updateCountryCode()
	module.serverVersion(version.Value)
	uptime.Changed:Connect(ServerInfoSync._updateUptime)
	region_region.Changed:Connect(ServerInfoSync._updateRegion)
	region_city.Changed:Connect(ServerInfoSync._updateCity)
	region_country.Changed:Connect(ServerInfoSync._updateCountryCode)
	module.serverInfoEnabled(module2:GetSettingValue("showServerInfo"))
	module2:GetSettingChangedSignal("showServerInfo"):Connect(function(p)
		module.serverInfoEnabled(p)
	end)
end

function ServerInfoSync._updateUptime()
	module.serverUptime(uptime.Value)
end

function ServerInfoSync._updateRegion()
	module.serverRegion(region_region.Value)
end

function ServerInfoSync._updateCity()
	module.serverCity(region_city.Value)
end

function ServerInfoSync._updateCountryCode()
	module.serverCountryCode(region_country.Value)
end

return ServerInfoSync