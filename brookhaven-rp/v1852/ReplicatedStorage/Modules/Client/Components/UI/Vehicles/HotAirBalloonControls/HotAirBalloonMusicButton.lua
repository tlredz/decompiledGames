local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HotAirBalloonMusicButton"
})
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		MusicController.OpenMusicMenu("hot air balloon audio", AdFeatures.CAR_MUSIC)
	end))
	self._Janitor:Add(HotAirBalloon.OnReleaseControl:Connect(function(_)
		MusicController.CloseMusicMenu()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v