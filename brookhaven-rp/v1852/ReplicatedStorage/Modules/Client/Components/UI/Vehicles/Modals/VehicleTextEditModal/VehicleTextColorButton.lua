local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleTextColorButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleTextEditModal = require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.Modals.VehicleTextEditModal.VehicleTextEditModal)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"VehicleTextEditModal",
		VehicleTextEditModal
	)

	if waitForAncestorComponent then
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			VehicleController.SetTextColor(
				waitForAncestorComponent:GetVehicleUuid(),
				self.Instance:FindFirstChild("Color").Value
			)
		end))
	else
		warn("VehicleColorButton must be a descendant of VehicleTextEditModal")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v