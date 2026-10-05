local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleTextEditModal"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

function v.GetVehicleUuid(p)
	return p.vehicleUuid
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(VehicleController.OnTextEditRequested:Connect(function(vehicleUuid: string)
		self.vehicleUuid = vehicleUuid
		PanelController.Open("MainGUIHandler", "ModalVehicleTextEdit")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v