local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local BallInputControls = require(script.Parent.BallInputControls)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local VehicleRoot = require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleRoot)
local v = Component.new({
	Tag = "BallVehicle"
})
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local flag = false
	self._vehicleRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "VehicleRoot", VehicleRoot)
	local ballInputControls = BallInputControls(instance)
	self._Janitor:Add(VehicleController.OnMaxSpeedChanged:Connect(function(p: string, p2: number)
		if p ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		ballInputControls.setSpeed(p2)
	end))
	self._Janitor:Add(self._vehicleRoot.OnBoostChanged:Connect(function(flag2: boolean)
		ballInputControls.setBoostMultiplier(flag2 and 1.5 or 1)
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startControlling()
		if flag then
			return
		end

		flag = true
		ballInputControls.enable()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopControlling()
		if not flag then
			return
		end

		flag = false
		ballInputControls.disable()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onDriverChanged()
		if instance:GetAttribute("DriverUserId") == localPlayer.UserId then
			startControlling() -- equivalent call inferred; original call site unknown
		else
			stopControlling() -- equivalent call inferred; original call site unknown
		end
	end

	self._Janitor:Add(instance:GetAttributeChangedSignal("DriverUserId"):Connect(onDriverChanged))
	onDriverChanged() -- equivalent call inferred; original call site unknown
	self.engineSound = instance:WaitForChild("Body"):WaitForChild("SoundEmmiter"):WaitForChild("Engine")
	ballInputControls.setEngineSound(self.engineSound)
	self._Janitor:Add(function()
		if not flag then
			return
		end

		flag = false
		ballInputControls.disable()
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v