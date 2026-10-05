local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleStateUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleStateUtil)
local v = Component.new({
	Tag = "VehicleSpeedInput"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local instance = self.Instance

	if not instance:IsA("TextBox") then
		warn("VehicleSpeedInput must be a TextBox")
		return
	end

	instance.Text = tostring(25)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function syncInputToVehicleState(currentDrivingVehicleUuid: string)
		local vehicleState = VehicleStateUtil.GetVehicleState(currentDrivingVehicleUuid)

		if vehicleState == nil then
			return
		end

		instance.Text = tostring(vehicleState.Performance.MaxSpeed)
	end

	local currentDrivingVehicleUuid = VehicleController.GetCurrentDrivingVehicleUuid()

	if currentDrivingVehicleUuid ~= nil then
		syncInputToVehicleState(currentDrivingVehicleUuid) -- equivalent call inferred; original call site unknown
	end

	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(syncInputToVehicleState))
	self._Janitor:Add(instance.FocusLost:Connect(function(_)
		local text = tonumber(instance.Text)

		if not t.number(text) then
			instance.Text = tostring(25)
			return
		end

		local v2, v3 = VehicleController.SetMaxSpeed(text)

		if v2 then
			instance.Text = tostring(v3)
		else
			instance.Text = tostring(25)
		end
	end))
	self._Janitor:Add(VehicleController.OnMaxSpeedChanged:Connect(function(p2: string, p3: number)
		if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		instance.Text = tostring(p3)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v