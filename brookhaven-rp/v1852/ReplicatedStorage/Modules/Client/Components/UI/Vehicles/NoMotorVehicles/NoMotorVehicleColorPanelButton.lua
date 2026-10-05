local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleColorPanelButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		if not VehicleController.GetCurrentNonMotorVehicle() then
			return
		end

		local currentNonMotorVehicle = VehicleController.GetCurrentNonMotorVehicle()
		local colorLimits = currentNonMotorVehicle:FindFirstChild("ColorLimits")
		instance.Visible = currentNonMotorVehicle:HasTag("RecolorableNoMotorVehicle")

		if colorLimits then
			instance:SetAttribute("TargetPanel", "NoMotorControlColorLimits")
		else
			instance:SetAttribute("TargetPanel", "NoMotorColorPicks")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v