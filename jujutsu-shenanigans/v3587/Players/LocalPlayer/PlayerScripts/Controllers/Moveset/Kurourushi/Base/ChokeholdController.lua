local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ChokeholdController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Kurourushi.Chokehold.Start, humanoidRootPart, game.SoundService.Effect)
			local v5, v6 = v3:PlayArms(instance, animations.Kurourushi.Chokehold, animations.Kurourushi.Chokehold)

			if not v6 then
				return
			end

			v6.Parent.Attach.Value = humanoidRootPart

			repeat
				task.wait()
			until v5.IsPlaying == false or humanoidRootPart.Parent == nil

			v6.Parent.Attach.Value = nil
		end,
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(
				p and sounds.Kurourushi.Chokehold.PunchGrab or sounds.Kurourushi.Chokehold.CleaveGrab,
				humanoidRootPart,
				game.SoundService.Effect
			)

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local _, v5 = v3:PlayArms(
				instance,
				animations.Kurourushi.ChokeholdHitArms,
				animations.Kurourushi.ChokeholdHit
			)

			if v5 then
			end
		end,
		Hit2 = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(101, 35, 44))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v2:Flash(instance2, Color3.new(1, 1, 1))

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			v2:PlaySound(
				p and sounds.Kurourushi.Chokehold.PunchHit1 or sounds.Kurourushi.Chokehold.CleaveHit1,
				humanoidRootPart,
				game.SoundService.Effect
			)
			task.wait(0.025)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.TimeScale = 0
				end
			end

			task.wait(0.1225)
			v2:PlaySound(
				p and sounds.Kurourushi.Chokehold.PunchHit2 or sounds.Kurourushi.Chokehold.CleaveHit2,
				humanoidRootPart,
				game.SoundService.Effect
			)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.TimeScale = 1
				end
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Slash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Kurourushi.FesteringStrikes["Swing" .. p], humanoidRootPart, game.SoundService.Effect)
			local festeringSword = instance.SetAssets:FindFirstChild("FesteringSword")

			if not festeringSword then
				return
			end

			local clone = utils.Kurourushi.CombatTrail:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(festeringSword:GetScale())
			Debris:AddItem(model, 0.1)
			clone.Weld.Part0 = festeringSword.Union
			clone.Parent = workspace.Effects
			clone.Trail.FaceCamera = false
			task.wait(0.5)
			clone.Trail.Enabled = false
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
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
	v = Knit.GetService("ChokeholdService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("KurourushiController")
end

return controller