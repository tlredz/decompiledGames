local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "PressingChargesController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hiromi.Twirl.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local model = Instance.new("Model")
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = p * CFrame.new(0, -1, 0)
			clone.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.8)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.LockedToPart = true
				end
			end

			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			TweenService:Create(clone, TweenInfo.new(0.6), {
				CFrame = clone.CFrame * CFrame.new(0, 0, -7)
			}):Play()
			Debris:AddItem(model, 2)
			v2:ArmFlash(instance["Right Leg"], Color3.fromRGB(179, 130, 61), 0.4)
			v2:PlaySound(sounds.Gojo.ReversalRed.Aim, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash2 = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:DustTrail(instance, 0.6, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Twirl.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local playSound = v2:PlaySound(sounds.Hiromi.JudgeReachFinisher, humanoidRootPart, game.SoundService.Effect)
			playSound.TimePosition = 0.733
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("PressingChargesService")
	v2 = Knit.GetController("FXController")
end

return controller