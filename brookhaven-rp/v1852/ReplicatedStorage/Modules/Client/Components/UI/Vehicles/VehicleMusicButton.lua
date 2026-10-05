local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)
local v = Component.new({
	Tag = "VehicleMusicButton"
})

function v:UpdateChecked()
	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

	if self.musicPanel == nil or not self.musicPanel.Visible then
		self.Instance:RemoveTag("Checked")
	else
		self.Instance:AddTag("Checked")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	local mainGUIHandler = playerGui:FindFirstChild("MainGUIHandler")

	if not mainGUIHandler then
		return
	end

	self.musicPanel = mainGUIHandler:FindFirstChild("MainAudio")

	if not self.musicPanel then
		warn("Music panel not found")
		return
	end

	self:UpdateChecked()
	self._Janitor:Add(self.musicPanel:GetPropertyChangedSignal("Visible"):Connect(function()
		self:UpdateChecked()
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self.vehiclePanel = VehicleController.GetVehiclePanel()

		if not self.vehiclePanel then
			return
		end

		self:UpdateChecked()
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		self.Instance:RemoveTag("Checked")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		MusicController.OpenMusicMenu("CarControlPorted", AdFeatures.CAR_MUSIC)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v