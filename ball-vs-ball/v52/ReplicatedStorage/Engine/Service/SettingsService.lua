local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local SettingsService = {
	server = {},
	client = {}
}
local remoteEvent = Net:RemoteEvent("SettingsService/SetMusicEnabled")
local remoteEvent2 = Net:RemoteEvent("SettingsService/SetSoundEffectsEnabled")

function SettingsService.server.init()
	remoteEvent.OnServerEvent:Connect(function(p, p2)
		if typeof(p2) ~= "boolean" then
			return
		end

		PlayerData.server[p].settings.musicEnabled(p2)
	end)
	remoteEvent2.OnServerEvent:Connect(function(p, p2)
		if typeof(p2) ~= "boolean" then
			return
		end

		PlayerData.server[p].settings.soundEffectsEnabled(p2)
	end)
end

function SettingsService.client.setMusicEnabled(flag: boolean)
	remoteEvent:FireServer(flag)
end

function SettingsService.client.setSoundEffectsEnabled(flag: boolean)
	remoteEvent2:FireServer(flag)
end

return SettingsService