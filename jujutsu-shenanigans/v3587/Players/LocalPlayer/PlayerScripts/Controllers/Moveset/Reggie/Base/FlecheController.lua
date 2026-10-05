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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "FlecheController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -9) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(67, 67, 67))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks.SpreadAngle = Vector2.new(45, -45)
			clone.Sparks:Emit(20)
			clone.Wind2:Emit(7)
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.Fleche.Hit, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.Fleche.HitOpen, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Fleche.Dash, humanoidRootPart, game.SoundService.Effect)
			local model = Instance.new("Model")
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.1, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = (humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position + humanoidRootPart.Position) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
			end)
		end,
		Pull = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.Fleche.PullOut, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 8 do
				BloodyZee:Blood(instance2.Torso.CFrame, math.random(5, 55), 25, 25)
			end
		end,
		Drop = function(instance)
			local clone = instance:Clone()
			clone.Weld:Destroy()

			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.CollisionGroup = "NoPlayerCollision"
				part.AssemblyLinearVelocity = createVector(0, 0, 0)

				if part.Name == "Open" and part.Transparency ~= 1 then
					part.CanCollide = true
				elseif part.Name ~= "Open" then
					part.CanCollide = true
				end
			end

			clone:PivotTo(instance:GetPivot())
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
		end,
		Open = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			p.Open.Transparency = 0
			p.Closed.Transparency = 1
			local v5 = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.5)
			Debris:AddItem(model, 0.2)
			clone.CFrame = v5 * CFrame.new(0, 0, -6.5) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(10)
			clone.PointLight:Destroy()
			clone.Wind.Lifetime = NumberRange.new(0.9, 1.5)
			clone.Back1.Back.Size = NumberSequence.new(0)
			clone.Back2.Back.Size = NumberSequence.new(0)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(3, 15, 3)
			clone2.CFrame = v5 * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(17.5, 0, 17.5),
				Transparency = 1,
				Position = clone2.Position + v5.LookVector * 10
			}):Play()
			v3:PlaySound(sounds.Reggie.Fleche.Unleash, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Reggie.Fleche.UnleashWhoosh, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("FlecheService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller