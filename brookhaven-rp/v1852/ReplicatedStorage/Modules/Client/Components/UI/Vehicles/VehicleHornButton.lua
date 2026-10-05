local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleHornButton"
})
local v2 = false
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)
local flag = false

local function onButtonPressed()
	if flag then
		return
	end

	flag = true
	v2.PlayHorn()
	flag = false
end

local function onButtonReleased()
	if VehicleUIImprovementABTest.IsEnabled() then
		local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()
		local equippedHorn = currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("EquippedHorn")

		if equippedHorn ~= nil and equippedHorn ~= "" then
			return
		end
	end

	v2.StopHorn()
end

function v:UpdateEquippedHornIcon(p2: string?)
	local duke1 = self.Instance:FindFirstChild("Duke1")
	local duke2 = self.Instance:FindFirstChild("Duke2")

	if duke1 then
		duke1.Visible = p2 == "Duke1"
	end

	if duke2 then
		duke2.Visible = p2 == "Duke2"
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

		self.vehiclePanel:RegisterButtonCallback(self.Instance, Enum.KeyCode.F, onButtonPressed, onButtonReleased)

		if not VehicleUIImprovementABTest.IsEnabled() then
			self:UpdateEquippedHornIcon(nil)
			return
		end

		self:UpdateEquippedHornIcon(currentDrivingVehicleModel:GetAttribute("EquippedHorn"))
		self._Janitor:Add(currentDrivingVehicleModel:GetAttributeChangedSignal("EquippedHorn"):Connect(function()
			self:UpdateEquippedHornIcon(currentDrivingVehicleModel:GetAttribute("EquippedHorn"))
		end), "Disconnect", "EquippedHorn")
	end))
	self._Janitor:Add(v2.OnPlayerStoppedDriving:Connect(function()
		self:UpdateEquippedHornIcon(nil)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v