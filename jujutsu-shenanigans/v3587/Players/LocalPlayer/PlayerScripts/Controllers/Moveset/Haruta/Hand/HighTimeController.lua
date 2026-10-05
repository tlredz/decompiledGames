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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HighTimeController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(0.745098, 0, 0.0117647))
			v2:PlaySound(sounds.Choso.BloodEdge.StabHit, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 5 do
				BloodyZee:Blood(instance["Right Leg"].CFrame * CFrame.new(0, 0.5, 0), -math.random(20, 70), 25, 25)
			end

			for _ = 1, 5 do
				BloodyZee:Blood(instance["Left Leg"].CFrame * CFrame.new(0, 0.5, 0), -math.random(20, 70), 25, 25)
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Haruta.Hightime, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Haruta.SlashEmit:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1.5)
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
	v = Knit.GetService("HighTimeService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller