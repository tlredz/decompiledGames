local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleToggleLightsButton"
})
local v2 = false
local v3 = false
local flag = false

local function onButtonPressed()
	if flag then
		return
	end

	flag = true

	if not v3 then
		return
	end

	v2.ToggleHeadLights()
	task.delay(0.5, function()
		flag = false
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	v2 = VehicleController
end

function v:Start()
	local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()
	self._Janitor:Add(v2.OnPlayerStartedDriving:Connect(function(p)
		currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and v2.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		v3 = true
		self.vehiclePanel = v2.GetVehiclePanel()

		if not self.vehiclePanel then
			return
		end

		self.vehiclePanel:RegisterButtonCallback(self.Instance, Enum.KeyCode.V, onButtonPressed)
	end))
	self._Janitor:Add(v2.OnPlayerStoppedDriving:Connect(function()
		v3 = false
	end))

	if not currentDrivingVehicleModel then
		self.Instance.Visible = false
		return
	end

	local body = currentDrivingVehicleModel:FindFirstChild("Body")

	if body then
		self.Instance.Visible = body:FindFirstChild("Lights") and true or false
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v