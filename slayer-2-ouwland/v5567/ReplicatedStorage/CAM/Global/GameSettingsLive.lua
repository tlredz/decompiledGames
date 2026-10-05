local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsLive = require(ReplicatedStorage.CAM.Global.SettingsLive)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local v = {
	IsRunning = true,
	IsStudio = true,
	IsTestPlace = true,
	IsMinigame = true,
	IsMenu = true,
	DataStoreKey = true,
	analyticsDisabledPlaces = true
}
local gameSettings2 = {}

for k, gameSetting in gameSettings do
	if not v[k] then
		gameSettings2[k] = gameSetting
	end
end

return SettingsLive.new("GameSettings", gameSettings, SettingsLive.surface(gameSettings2))