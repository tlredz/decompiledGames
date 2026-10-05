local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Tool = require(ReplicatedStorage.Modules.Tool)
return Tool.Event(function(p, instance)
	local clone = p.Handle:FindFirstChild("HitEffect"):Clone()

	if not clone then
		return
	end

	local particleEmitter = clone:FindFirstChildWhichIsA("ParticleEmitter")

	if not particleEmitter then
		return
	end

	clone.Parent = instance.PrimaryPart
	particleEmitter.Enabled = true
	Debris:AddItem(clone, 1.5)
end)