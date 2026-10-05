local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleMultipleColorParts"
})
local v2 = false
local VehicleUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleUtil)

function v:PopulateFromVehicle(populatedVehicle)
	if self.populatedVehicle == populatedVehicle then
		return
	end

	local colorPartNames = populatedVehicle:GetAttribute("ColorPartNames")

	if typeof(colorPartNames) ~= "string" or colorPartNames == "" then
		return
	end

	local template = self.Instance:WaitForChild("Template")

	if self._Janitor == nil then
		return
	end

	self._optionsJanitor:Cleanup()
	self.populatedVehicle = populatedVehicle

	for k, childName in VehicleUtil.ParseColorPartNames(colorPartNames) do
		local clone = template:Clone()
		clone.Name = childName
		clone.Text = childName
		clone.LayoutOrder = k
		clone.Visible = true
		local checkmark = clone:FindFirstChild("Checkmark")
		checkmark.Visible = k == 1
		local part = populatedVehicle:FindFirstChild(childName, true)

		if part ~= nil and part:IsA("BasePart") then
			local colorValue = clone:FindFirstChild("Button"):FindFirstChild("ColorValue")
			colorValue.Value = part.Color
		end

		clone.Parent = self.Instance
		self._optionsJanitor:Add(clone)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._optionsJanitor = self._Janitor:Add(Janitor.new())
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	v2 = VehicleController
end

function v:Start()
	local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()

	if currentDrivingVehicleModel ~= nil then
		self:PopulateFromVehicle(currentDrivingVehicleModel)
	end

	if self._Janitor == nil then
		return
	end

	self._Janitor:Add(v2.OnPlayerStartedDriving:Connect(function()
		local currentDrivingVehicleModel2 = v2.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel2 == nil then
			return
		end

		self:PopulateFromVehicle(currentDrivingVehicleModel2)
	end))
end

function v:Stop()
	local _Janitor = self._Janitor
	self._Janitor = nil
	_Janitor:Destroy()
end

return v