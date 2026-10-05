local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleBoostConstants = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleBoostConstants)
local v = Component.new({
	Tag = "VehicleBoostColorPicker"
})
local Signal = require(ReplicatedStorage.Packages.Signal)

function v:SetColorIndex(colorIndex: number)
	self.colorIndex = colorIndex
	self.OnColorIndexChanged:Fire(colorIndex)
end

function v:GetColorIndex()
	return self.colorIndex or 1
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnColorIndexChanged = Signal.new()
end

function v.SetDefaultColor(_)
	VehicleController.SetDefaultBoostColor()
end

function v:Start()
	local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
	local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	self.colorPickerComponent = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	self._Janitor:Add(self.colorPickerComponent.OnColorConfirmed:Connect(function(color: Color3)
		if not GamepassController.IsOwned(Gamepasses.VEHICLE_BOOST) then
			NotificationController.NotifyCenter(VehicleBoostConstants.VEHICLE_BOOST_NOT_OWNED)
			return
		end

		if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
			VehicleController.SetBoostColor(self:GetColorIndex(), color)
			return
		end

		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel then
			return
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_CUSTOMIZATION,
			nil,
			"car boost Color",
			nil,
			nil,
			nil,
			"Vehicle Boost Color",
			vehicleName,
			function()
				if VehicleController.GetCurrentDrivingVehicleModel() == currentDrivingVehicleModel then
					VehicleController.SetBoostColor(self:GetColorIndex(), color)
				end
			end
		)
	end))
	local closeButton = self.Instance:WaitForChild("ColorPicks"):WaitForChild("ColorPicksFrame"):WaitForChild("CloseButton")
	self._Janitor:Add(closeButton.MouseButton1Click:Connect(function()
		self.Instance.Visible = false
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v