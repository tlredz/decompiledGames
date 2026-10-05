local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehiclePanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		PanelController.ToggleGroup("NoMotorVehicleControls", false)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v