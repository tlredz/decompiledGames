local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ArsonController"
})

function controller.KnitStart(_)
	local v4 = {
		GasolineBurst = function(_, p)
			v3:PlaySound(sounds.Kurourushi.InsectTrance.BugExplode, p, game.SoundService.Effect)
			local clone = utils.Reggie.Gas_Burst:Clone()
			clone.CFrame = p.CFrame
			clone.Parent = workspace.Effects
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
		end,
		Explosion = function(_, p)
			local clone = utils.Reggie.Gas_Ignite:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(p.Position)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 3)
		end,
		Gas = function(_, parent, instance)
			if not parent:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Reggie.Gas:Clone()
			clone.Parent = parent
			clone.Weld.Part0 = parent.Torso
			Debris:AddItem(clone, 10)
			instance.Destroying:Connect(function()
				for _, emitter in clone:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Debris:AddItem(clone, 1)
			end)
		end,
		Burn = function(_, parent, instance)
			if not parent:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Reggie.Burn_Asset:Clone()
			clone.Parent = parent
			clone.Weld.Part0 = parent.Torso
			Debris:AddItem(clone, 10)
			instance.Destroying:Connect(function()
				for _, emitter in clone:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Debris:AddItem(clone, 1)
			end)
		end,
		BurnTick = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:Flash(instance, Color3.fromRGB(255, 113, 12), 0.5)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("ArsonService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller