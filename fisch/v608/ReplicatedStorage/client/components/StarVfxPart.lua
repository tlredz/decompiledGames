local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local v = Component.new({
	Tag = "StarVfxPart",
	Ancestors = { Workspace },
	Extensions = nil
})
v.RenderPriority = Enum.RenderPriority.Last.Value

function v:Construct()
	self.SpawnedAt = self.Instance:GetAttribute("SpawnedAt")
	self.ReplicatedAt = DateTime.now().UnixTimestamp
	self.Duration = self.Instance:GetAttribute("Duration")
	self.Destination = self.Instance:GetAttribute("Destination")
	self.Origin = self.Instance:GetAttribute("Origin")
	self.DeltaTime = self.ReplicatedAt - self.SpawnedAt

	for _, emitter in self.Instance:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end
end

function v:RenderSteppedUpdate(p: number)
	self.DeltaTime += p
	local v2 = math.clamp(self.DeltaTime / self.Duration, 0, 1)
	local lerped = self.Origin:Lerp(self.Destination, v2)
	self.Instance.Position = lerped
end

return v