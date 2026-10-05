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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RedScaleController"
})

function controller.KnitStart(_)
	local v4 = {
		Leap = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.HardHit.Ring:Clone()
			clone.RotSpeed = NumberRange.new(300, 600)
			clone.Speed = NumberRange.new(0.1, 20)
			clone.Enabled = true
			clone.Parent = instance.Torso
			task.delay(0.3, function()
				clone.Enabled = false
				Debris:AddItem(clone, 0.5)
			end)
			p.Position = humanoidRootPart.Position + createVector(0, 12, 0)
			v3:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
			v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(170, 0, 0), 0.9)
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.PointLight:Destroy()
			clone.Air:Destroy()
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 0, 0))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(1, 0, 0))
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if not p then
				humanoidRootPart.Velocity = createVector(0, 150, 0)
				return
			end

			local v5 = humanoidRootPart.Position - p.Position
			local v6 = (1 - v5.Magnitude / 20) * 200
			local v7 = v5.Unit * v6
			local vector2 = Vector3.new(v7.X, math.clamp(v7.Y, -100, 100), v7.Z)
			humanoidRootPart.Velocity += vector2
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.CursedStrikes.Startup, humanoidRootPart, game.SoundService.Effect)
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
			model:ScaleTo(0.6)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = p * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.1, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = (p - p.Position + humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
			end)
			v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(170, 0, 0), 0.3)
			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Gojo.ReversalRed.Aim, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(data, instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			if p then
				v3:PlaySound(sounds.Itadori.CursedStrikes.Hit, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(
					sounds.Itadori.M1:FindFirstChild("Hit" .. math.random(1, 4)),
					humanoidRootPart,
					game.SoundService.Effect
				)
			end

			if localPlayer.Character == data or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			if not data then
				return
			end

			if p then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(170, 0, 0), 0.4)
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(170, 0, 0), 0.4)
			elseif p2 == 1 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(170, 0, 0), 0.4)
				local clone = utils.Mahito.BodyRepel.Wind5:Clone()
				clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0.7853981633974483, 0, 0)
				clone.Size = createVector(2, 5, 2)
				clone.Transparency = 0
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.2), {
					Size = createVector(12, 0, 12),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.2)
			elseif p2 == 2 then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(170, 0, 0), 0.8)
			end
		end,
		FinalHit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CursedStrikes.Hit, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			if p then
				v3:PlaySound(sounds.Choso.BloodBurst2, humanoidRootPart, game.SoundService.Effect)
				local clone = utils.Choso.BloodExplode:Clone()
				clone.Position = humanoidRootPart2.Position
				clone.Parent = workspace.Effects
				clone.Blood:Emit(30)
				clone.Burst:Emit(1)
				clone.Wind:Emit(6)
				Debris:AddItem(clone, 2)
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
	v = Knit.GetService("RedScaleService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller