local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleBoatSplash"
})
local VehicleRoot = require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:SetSplashEnabled(flag: boolean)
	self._splashEnabled = flag

	if self._emitter then
		self._emitter.Enabled = flag
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if not self.Instance:IsA("ParticleEmitter") then
		warn("VehicleBoatSplash expects its Instance to be a ParticleEmitter, got", self.Instance.ClassName)
		return
	end

	self._emitter = self.Instance
	self._vehicleRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "VehicleRoot", VehicleRoot)

	if not self._vehicleRoot then
		warn("VehicleBoatSplash has no VehicleRoot component")
		return
	end

	local vehicleSeat = self._vehicleRoot.Instance:WaitForChild("Seats"):WaitForChild("VehicleSeat")
	self._Janitor:Add(task.spawn(function()
		while true do
			task.wait(0.2)
			local rate = 1 + (vehicleSeat:IsA("BasePart") and vehicleSeat.AssemblyLinearVelocity.Magnitude or 0) / 1
			self._emitter.Rate = rate
			self._emitter.Acceleration = Vector3.new(0, rate / 30, 0)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v