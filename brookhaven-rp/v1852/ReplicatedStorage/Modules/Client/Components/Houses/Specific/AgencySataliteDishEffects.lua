local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local v = Component.new({
	Tag = "AgencySataliteDishEffects"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	Remotes.connectComponentRemote(self.Instance, "AgencySataliteDishEffects", function(_)
		for _, emitter in self.Instance:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v2 = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(cframe: CFrame)
			workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * cframe
		end)
		v2:Start()
		v2:ShakeOnce(1, 45, 0.1, 1, 0.2, 1)
		task.wait(5)
		v2:Stop()
		task.wait(3)

		if not self.Instance then
			return
		end

		for _, emitter in self.Instance:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v