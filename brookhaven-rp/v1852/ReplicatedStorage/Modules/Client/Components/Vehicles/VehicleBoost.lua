local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleBoost"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local VehicleRoot = require(script.Parent.VehicleRoot)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:GetBoostParticles()
	if self.boostParticles then
		return self.boostParticles
	end

	self.boostParticles = {}

	for _, emitter in self.Instance:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			table.insert(self.boostParticles, emitter)
		end
	end

	return self.boostParticles
end

function v:SetBoostEnabled(enabled: boolean)
	local boostParticles = self:GetBoostParticles()

	for _, boostParticle in boostParticles do
		boostParticle.Enabled = enabled
	end
end

function v:Start()
	self._vehicleRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "VehicleRoot", VehicleRoot)
	self._Janitor:Add(self._vehicleRoot.OnBoostChanged:Connect(function(flag: boolean)
		self:SetBoostEnabled(flag)
	end))
	self:SetBoostEnabled(false)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v