local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowColorPicker"
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

function v:Start()
	local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
	local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	self.colorPickerComponent = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	self.colorPickerComponent.OnColorConfirmed:Connect(function(color: Color3)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel == nil then
			return
		end

		local colorIndex = self:GetColorIndex()

		if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
			VehicleController.SetUnderglowColor(colorIndex, color)
			return
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_CUSTOMIZATION,
			nil,
			"car underglow",
			nil,
			nil,
			nil,
			"Vehicle Underglow",
			vehicleName,
			function()
				if VehicleController.GetCurrentDrivingVehicleModel() == currentDrivingVehicleModel then
					VehicleController.SetUnderglowColor(colorIndex, color)
				end
			end
		)
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v