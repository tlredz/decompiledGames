local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local MusicABTestController = require(ReplicatedStorage.Modules.Client.Music.MusicABTestController)
local v = {
	CarMusic = AdFeatures.CAR_MUSIC,
	BoomboxMusic = AdFeatures.TOOL_MUSIC
}
local v2 = Component.new({
	Tag = "MusicSettingsFrame"
})
local playerGui = nil
local mainGUIHandler = nil
local mainAudio = nil

function v2:Construct()
	self._Janitor = Janitor.new()
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
	mainAudio = mainGUIHandler:WaitForChild("MainAudio")
	self._ToggleButton = self.Instance:WaitForChild("LeftSide"):WaitForChild("Button")
	self._FeatureId = self.Instance:GetAttribute("FeatureID")
end

function v2.IsOnNoMotorVehicle(_)
	if VehicleController.GetCurrentNonMotorVehicle() then
		return true
	end

	return false
end

function v2:Start()
	self._Janitor:Add(self._ToggleButton.Activated:Connect(function()
		if mainAudio.Visible == false then
			self:AttemptToOpenMenu()
		else
			MusicController.CloseMusicMenu()
		end
	end))
end

function v2:AttemptToOpenMenu()
	local expect = MusicABTestController.ShouldRunABTest():expect()
	ABTest.GetExperimentVariable("music-purchase-flow", "prompt-on-button-interact"):timeout(3):andThen(function(flag: boolean)
		local v3 = v[self._FeatureId]

		if flag and expect and not v3 then
			warn("ad feature not found: " .. self._FeatureId)
		else
			MusicController.OpenMusicMenu(self._FeatureId, v3)
		end
	end):catch(warn)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2