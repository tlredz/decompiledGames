game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local LightingController = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("LightingController"))
local Observers = {}

function Observers.brightness(_: number)
	LightingController.UpdateLighting(1)
end

function Observers.saturation(_: number)
	LightingController.UpdateLighting(1)
end

function Observers.musicVolume(p: number)
	local music = SoundService:WaitForChild("music")
	local music_special = SoundService:WaitForChild("music_special")
	local v = p / 100
	music.Volume = music:GetAttribute("DefaultVolume") * v
	music_special.Volume = music_special:GetAttribute("DefaultVolume") * v
end

function Observers.ambienceVolume(p: number)
	local ambience = SoundService:WaitForChild("ambience")
	local v = p / 100
	ambience.Volume = ambience:GetAttribute("DefaultVolume") * v
end

function Observers.weatherVolume(p: number)
	local weather = SoundService:WaitForChild("weather")
	local v = p / 100
	weather.Volume = weather:GetAttribute("DefaultVolume") * v
end

function Observers.radioVolume(p: number)
	local radio = SoundService:WaitForChild("radio")
	local volume = p / 100
	radio.Volume = radio:GetAttribute("DefaultVolume") * volume
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local rELICSxyz_Fader = currentCamera:FindFirstChild("RELICSxyz_Fader")

		if rELICSxyz_Fader and rELICSxyz_Fader:IsA("AudioFader") then
			rELICSxyz_Fader.Volume = volume
		end
	end
end

function Observers.showServerInfo(enabled: boolean)
	local serverInfo = localPlayer:WaitForChild("PlayerGui"):WaitForChild("serverInfo")
	serverInfo.Enabled = enabled
end

function Observers.splitTabs(enabled: boolean)
	TextChatService.ChannelTabsConfiguration.Enabled = enabled
end

return Observers