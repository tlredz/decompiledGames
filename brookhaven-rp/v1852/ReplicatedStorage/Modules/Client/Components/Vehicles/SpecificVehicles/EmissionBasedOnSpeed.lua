local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "EmissionBasedOnSpeed"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.particleEmitters = {}

	for _, emitter in self.Instance:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			table.insert(self.particleEmitters, emitter)
		end
	end

	local total = 0.15
	self._Janitor:Add(RunService.Stepped:Connect(function(_, dt: number)
		if total < 0.15 then
			total += dt
			return
		end

		total = 0
		local magnitude = self.Instance.Velocity.Magnitude
		local v2 = magnitude > 50 and 50 or magnitude

		for _, particleEmitter in self.particleEmitters do
			particleEmitter.Rate = v2 * 10
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v