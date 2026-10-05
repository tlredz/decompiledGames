local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "RaceTrackConfettiMachine"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._funnel = self.Instance:WaitForChild("Funnel", 15)
	assert(self._funnel, (`RaceTrackConfettiMachine: Funnel not found in {self.Instance:GetFullName()}`))
	self._fxAttachment = self._funnel:WaitForChild("FX", 15)
	assert(self._funnel, (`RaceTrackConfettiMachine: FX not found in {self._funnel:GetFullName()}`))
	self._blowhorn = self._funnel:WaitForChild("Blowhorn", 15)
	assert(self._funnel, (`RaceTrackConfettiMachine: Blowhorn not found in {self._funnel:GetFullName()}`))
end

function v:Enable()
	self._blowhorn:Play()

	for _, emitter in self._fxAttachment:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end
end

function v:Disable()
	for _, emitter in self._fxAttachment:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

function v:EnableForSeconds(duration: number)
	self:Enable()
	task.delay(duration, function()
		self:Disable()
	end)
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v