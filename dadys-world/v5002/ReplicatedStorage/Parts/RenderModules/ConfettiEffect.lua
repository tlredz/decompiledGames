local ConfettiEffect = {}
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function ConfettiEffect.RenderObject(list)
	local parent = list[1]
	local v2 = list[2]

	if not (parent and parent:FindFirstChild("HumanoidRootPart")) then
		warn("[ConfettiEffect] Unable to find character or HumanoidRootPart")
		return
	end

	local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
	local clone = ReplicatedStorage.Parts.RenderParts.ConfettiEffect.Confetti:Clone()
	clone.Parent = parent
	clone.CFrame = humanoidRootPart.CFrame
	Debris:AddItem(clone, v2 + 1)
	Audio:Play("Sounds.Effects.Confetti", {
		Parent = humanoidRootPart
	})

	local function emitAllParticles(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
			end
		end
	end

	emitAllParticles(clone)
	task.delay(v2, function()
		if clone and clone.Parent then
			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)
end

return ConfettiEffect