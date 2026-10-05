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
	Name = "StabilizeController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.Stabilize.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Whoosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -6))
			clone.Parent = workspace.Effects
			clone.Shockwave:Destroy()
			Debris:AddItem(clone, 0.3)
			clone.Shock.Size = createVector(10, 2, 10)
			TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
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
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(p and CameraShaker.Presets.HeavyHit or CameraShaker.Presets.LightHit)
			end

			local clone = utils.Nanami.HitFX:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.5)
			Debris:AddItem(model, 0.1)
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position.X,
				humanoidRootPart.Position.Y,
				humanoidRootPart2.Position.Z
			)
			Debris:AddItem(clone, 2)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))

				if p then
					emitter.TimeScale = 0.35
				end
			end

			if p then
				for _ = 1, 20 do
					BloodyZee:Blood(instance2.Head.CFrame, math.random(5, 60), 20, 20)
				end
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(
				p and sounds.Nanami.CrossCut.RatioHit or sounds.Nanami.CrossCut.Hit2,
				humanoidRootPart2,
				game.SoundService.Effect
			)
		end,
		Spin = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v2:PlaySound(
				p and sounds.Nanami.Stabilize.Spin or sounds.Nanami.Stabilize.SpinShort,
				humanoidRootPart,
				game.SoundService.Effect
			)
			instance2.AncestryChanged:Once(function()
				v5:Destroy()
			end)
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
	v = Knit.GetService("StabilizeService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller