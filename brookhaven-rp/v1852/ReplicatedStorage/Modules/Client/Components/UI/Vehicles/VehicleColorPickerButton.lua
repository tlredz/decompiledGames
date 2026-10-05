local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local v = Component.new({
	Tag = "VehicleColorPickerButton"
})
local v2 = false
local UIColorLimitedPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorLimitedPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)
local VehicleRequests = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleRequests)
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function v:UpdateChecked()
	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

	if self.colorPickerPanel == nil or not self.colorPickerPanel.Visible then
		self.Instance:RemoveTag("Checked")
	else
		self.Instance:AddTag("Checked")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	v2 = VehicleController
end

function v:Start()
	self._Janitor:Add(v2.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and v2.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self.vehiclePanel = v2.GetVehiclePanel()

		if not self.vehiclePanel then
			return
		end

		local colorLimits = currentDrivingVehicleModel:FindFirstChild("ColorLimits")

		if colorLimits then
			self.colorPickerPanel = self.Instance.PanelLimited.Value
			local v3 = {}

			for _, child in colorLimits:GetChildren() do
				table.insert(v3, child.Value)
			end

			local component = ComponentUtil.GetComponentFromInstance(
				self.Instance.PanelLimited.Value,
				UIColorLimitedPicker
			)
			component:SetColors(v3)
			self.colorLimitedPickerComponent = component
		else
			self.colorPickerPanel = self.Instance.Panel.Value
		end

		if self.colorPickerPanel then
			self.colorPickerPanel:AddTag("Panel")
			self:UpdateChecked()
			self._Janitor:Add(self.colorPickerPanel:GetPropertyChangedSignal("Visible"):Connect(function()
				self:UpdateChecked()
			end), "Disconnect", "ColorPickerVisible")
		elseif self.colorLimitedPickerComponent then
			self.colorLimitedPickerComponent:SetColors({})
		end
	end))
	self._Janitor:Add(v2.OnPlayerStoppedDriving:Connect(function()
		self.Instance:RemoveTag("Checked")

		if not self.colorPickerPanel then
			return
		end

		self.colorPickerPanel:RemoveTag("Panel")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("DisableColorChange") == true then
			NotificationController.NotifyCenter("You cannot change the color of this vehicle")
			return
		end

		if not self.colorPickerPanel then
			return
		end

		self.vehiclePanel:SetCurrentOpenPanel(self.colorPickerPanel)
	end))
	self._Janitor:Add(v2.OnPromptColorGamepassNeeded:Connect(function(p, p2)
		if p ~= v2.GetCurrentDrivingVehicleUuid() then
			return
		end

		if self.colorPickerPanel then
			self.colorPickerPanel.Visible = false
		end

		if UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_COLOUR.id, Gamepasses.VEHICLE_CUSTOMIZATION) then
			return
		end

		local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel then
			return
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_CUSTOMIZATION,
			"5122248968",
			"car colour",
			nil,
			AdFeatures.CAR_COLOUR,
			nil,
			"Vehicle Inventory",
			vehicleName,
			function()
				if p == v2.GetCurrentDrivingVehicleUuid() then
					Remotes.invokeServer(VehicleRequests.SET_COLOR, p, p2)
				end
			end
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v