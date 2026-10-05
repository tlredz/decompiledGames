local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSpeedLabel"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("TextLabel") then
		warn("VehicleSpeedLabel must be a TextLabel")
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setText(p2: number)
		instance.Text = tostring((math.floor(p2 + 0.5)))
	end

	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
		if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		setText(VehicleController.GetCurrentMaxSpeed()) -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(VehicleController.OnMaxSpeedChanged:Connect(function(p2: string, value: number)
		if not (p2 == VehicleController.GetCurrentDrivingVehicleUuid() and typeof(value) == "number") then
			return
		end

		setText(value) -- equivalent call inferred; original call site unknown
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v