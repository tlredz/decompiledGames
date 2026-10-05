local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleMusicButton"
})
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		PanelController.ToggleGroup("NoMotorVehicleControls", false)
		PanelController.Close("MainGUIHandler", "NoMotorVehicleCustomizationOptions")
		MusicController.OpenMusicMenu("NoMotorVehicleMusicButton", AdFeatures.CAR_MUSIC)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v