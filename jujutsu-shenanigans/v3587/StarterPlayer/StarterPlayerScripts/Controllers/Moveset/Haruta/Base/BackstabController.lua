local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BackstabController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Haruta.Backstab, humanoidRootPart, game.SoundService.Effect)
		end,
		Whoosh = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				local playSound = v2:PlaySound(
					sounds.Haruta.BackstabFinisher.Whoosh,
					humanoidRootPart,
					game.SoundService.Effect
				)
				playSound.PlaybackSpeed = math.random(90, 110) / 100
			else
				v2:PlaySound(sounds.Haruta.Backstab, humanoidRootPart, game.SoundService.Effect)
			end

			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(-1, 0, -8) * CFrame.Angles(0, 0.17453292519943295, 0))
			clone.Parent = workspace.Effects
			clone.Shockwave:Destroy()
			Debris:AddItem(clone, 0.3)
			clone.Shock.Size = createVector(10, 2, 10)
			TweenService:Create(clone.Shock, TweenInfo.new(0.125), {
				Size = createVector(2, 15, 2),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
		end,
		Stab = function(instance, instance2, p, p2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance2, Color3.new(0.745098, 0, 0.0117647))

			if p2 then
				v2:PlaySound(sounds.Haruta.BackstabFinisher["Stab" .. p2], humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(
					p and sounds.Haruta.BackstabBack or sounds.Haruta.BackstabFront,
					humanoidRootPart,
					game.SoundService.Effect
				)
			end

			for _ = 1, 20 do
				BloodyZee:Blood(instance2.Torso.CFrame, math.random(5, 80), 25, 25)
			end

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				if p then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				else
					CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(0.4)
				end
			end
		end,
		Crush = function(instance, instance2, position)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.Shockwave:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.65)
			Debris:AddItem(model, 0.1)
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(12, 0, 12)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(4)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Haruta.BackstabFinisher.Slam, humanoidRootPart, game.SoundService.Effect)
		end,
		Kick = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Haruta.BackstabFinisher.Kick, humanoidRootPart2, game.SoundService.Effect)
			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position + createVector(0, 2, 0))
			local clone = utils.Gojo.HardHit:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.8)
			Debris:AddItem(model, 0.1)
			clone.CFrame = cframe + cframe.LookVector * 3.5
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
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
	v = Knit.GetService("BackstabService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller