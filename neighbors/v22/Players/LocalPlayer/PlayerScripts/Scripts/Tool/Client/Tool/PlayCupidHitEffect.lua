local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
local hit = ReplicatedStorage.Assets.Tools.CupidBow.Hit
Network:listen("Tool/PlayCupidHitEffect", function(parent)
	local humanoidRootPart = parent.HumanoidRootPart
	local clone = hit:Clone()
	clone.Parent = parent
	clone.CFrame = humanoidRootPart.CFrame
	clone.Sound:Play()
	Debris:AddItem(clone, 5)

	for _, v in clone:QueryDescendants("ParticleEmitter") do
		v.Enabled = true
		local v2 = v
		task.delay(v:GetAttribute("EmitDuration") or 1, function()
			v2.Enabled = false
		end)
	end
end)