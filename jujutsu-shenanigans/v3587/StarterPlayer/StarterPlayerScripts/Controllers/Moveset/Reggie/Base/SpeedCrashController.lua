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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "SpeedCrashController"
})

function controller.KnitStart(_)
	local v4 = {
		Throw = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = instance2:Clone()
			clone.Parent = workspace.Effects
			clone.CanCollide = true
			clone.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			Debris:AddItem(clone, 2)
		end,
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.SpeedCrash.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Drive = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(
				p and sounds.Reggie.SpeedCrash.DriveBoost or sounds.Reggie.SpeedCrash.Drive,
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Explode = function(instance, instance2, position, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			for _ = 1, 5 do
				local clone = utils.Hiromi.GavelShard:Clone()
				clone.Position = (instance2.CFrame * CFrame.new((Vector3.new(
					(math.random() - 0.5) * instance2.Size.X,
					(math.random() - 0.5) * instance2.Size.Y,
					(math.random() - 0.5) * instance2.Size.Z
				)))).Position
				clone.Size *= instance2.Size.Magnitude / 5
				clone.Color = instance2.Color
				clone.Velocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
				task.delay(1, function()
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end

			local clone = utils.Reggie.BikeExplode:Clone()

			if p then
				local model = Instance.new("Model")
				clone.Parent = model
				model:ScaleTo(1.5)
				Debris:AddItem(model, 0.2)
			end

			clone.Parent = workspace.Effects
			clone.Position = position
			Debris:AddItem(clone, 6)
			v3:PlayParticles(clone)
			v3:PlaySound(sounds.Reggie.SpeedCrash.Explode, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 35 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit = function(p, instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			if p == localPlayer.Character or instance == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Hit2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.SpeedCrash.Hit, humanoidRootPart2, game.SoundService.Effect)
			local cFrame = humanoidRootPart.CFrame
			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.75)
			Debris:AddItem(model, 0.2)
			clone.CFrame = cFrame * CFrame.new(0, 0, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(10)
			clone.PointLight:Destroy()
			clone.Wind.Lifetime = NumberRange.new(0.9, 1.5)
			clone.Back1.Back.Size = NumberSequence.new(0)
			clone.Back2.Back.Size = NumberSequence.new(0)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(3, 15, 3)
			clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(17.5, 0, 17.5),
				Transparency = 1,
				Position = clone2.Position + cFrame.LookVector * 12.5
			}):Play()

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Slide = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.SpeedCrash.Slide, humanoidRootPart, game.SoundService.Effect)
			local v5 = p and 0.5 or 0.3
			v3:DustTrail(instance, v5, CFrame.new(1.872, -0, -1.132) * CFrame.Angles(0, -1.5707963267948966, 0))
			v3:DustTrail(instance, v5, CFrame.new(-2.734, -0, -0.24) * CFrame.Angles(0, -1.5707963267948966, 0))
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
	v = Knit.GetService("SpeedCrashService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller