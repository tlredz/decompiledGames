local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSpeedCategoryButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

function v:UpdateChecked()
	if self.menu == nil or not self.menu.Visible then
		self.Instance:RemoveTag("Checked")
	else
		self.Instance:AddTag("Checked")
	end
end

function v:HideSiblingMenus()
	local parent = self.menu.Parent

	if not parent then
		return
	end

	for _, guiObject in parent:GetChildren() do
		if not guiObject:IsA("GuiObject") or guiObject == self.menu or guiObject == self.Instance or self.Instance:IsDescendantOf(guiObject) then
			continue
		end

		guiObject.Visible = false
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.menu = self.Instance.Panel.Value

	if not self.menu then
		return
	end

	self:UpdateChecked()
	self._Janitor:Add(self.menu:GetPropertyChangedSignal("Visible"):Connect(function()
		self:UpdateChecked()
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		local name = self.Instance.Name

		if name == "Drift" then
			self.Instance.Visible = currentDrivingVehicleModel:GetAttribute("IsBike") ~= true
		elseif name == "Suspension" then
			local instance = self.Instance
			instance.Visible = currentDrivingVehicleModel:GetAttribute("IsBike") ~= true and VehicleController.GetSuspensionLevelCount(currentDrivingVehicleModel) > 1
		elseif name == "Wheel" then
			self.Instance.Visible = currentDrivingVehicleModel:GetAttribute("HideWheelDecalButton") ~= true
		end

		self.menu.Visible = false
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if not self.menu then
			return
		end

		if self.menu.Visible then
			self.menu.Visible = false
			return
		end

		self:HideSiblingMenus()
		self.menu.Visible = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v