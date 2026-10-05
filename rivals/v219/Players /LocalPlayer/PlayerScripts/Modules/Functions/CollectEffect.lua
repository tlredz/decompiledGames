local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("CollectEffect"):WaitForChild("Attachment")
return function(position, p, p2, value)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	local clone = attachment:Clone()
	clone.Parent = part
	BetterDebris:AddItem(clone, 5)
	local v = value or 1

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		Utility:ScaleParticleEmitter(emitter, 3 * v)
		emitter.Color = p and ColorSequence.new(p) or emitter.Color
	end

	Utility:PlayParticles(clone)

	if p2 then
		Utility:CreateSound(p2, 1.5, 1, part, true, 10)
	end
end