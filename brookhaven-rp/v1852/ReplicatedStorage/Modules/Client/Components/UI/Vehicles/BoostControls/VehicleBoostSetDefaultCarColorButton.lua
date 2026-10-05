local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local VehicleBoostColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.BoostControls.VehicleBoostColorPicker)
local v = Component.new({
	Tag = "VehicleBoostSetDefaultCarColorButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"VehicleBoostColorPicker",
		VehicleBoostColorPicker
	)

	if waitForAncestorComponent then
		self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
			waitForAncestorComponent:SetDefaultColor()
		end))
	else
		warn("[VehicleBoostSetDefaultCarColorButton] >>>colorPickerComponent not found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v