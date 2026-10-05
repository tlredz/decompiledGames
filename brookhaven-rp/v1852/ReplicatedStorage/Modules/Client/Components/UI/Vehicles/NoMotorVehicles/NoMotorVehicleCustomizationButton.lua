local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "NoMotorVehicleCustomizationButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local currentNonMotorVehicle = VehicleController.GetCurrentNonMotorVehicle()

		if not currentNonMotorVehicle then
			return
		end

		local hideWrapsButton = currentNonMotorVehicle:GetAttribute("HideWrapsButton")
		PanelController.ToggleGroup("NoMotorVehicleControls", false)
		PanelController.OpenPanelByContext(
			"MainGUIHandler",
			hideWrapsButton and "NoMotorVehicleUnderglow" or "NoMotorVehicleCustomizationButtons"
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v