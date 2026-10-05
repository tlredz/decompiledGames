local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Net = require(ReplicatedStorage.packages.Net)
Net:RemoteFunction("AmbienceCheck")
local _ = ReplicatedStorage:WaitForChild("client").modules
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local _ = game.Players.LocalPlayer
local v = {}

local function update(p: number)
	for sound, _ in pairs(v) do
		if not sound:IsA("Sound") then
			continue
		end

		if sound.IsPlaying == true and p <= 0 then
			sound:Stop()
		elseif sound.IsPlaying == false and p > 0 then
			sound:Play()
		end

		if v[sound].connection then
			continue
		end

		local v2 = sound
		v[sound].connection = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function(p2)
			if p2 == true and SettingsController:GetSettingValue("ambienceVolume") <= 0 then
				v2:Stop()
			end
		end)
	end
end

SettingsController:GetSettingChangedSignal("ambienceVolume"):Connect(function(p: number)
	update(p)
end)
update(SettingsController:GetSettingValue("ambienceVolume"))
CollectionService:GetInstanceAddedSignal("AmbienceSetting"):Connect(function(p)
	v[p] = {
		active = true,
		connection = nil
	}
end)