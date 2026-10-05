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
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "CursedStrikesController"
})

function controller.KnitStart(_)
	local v4 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.CursedStrikes.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Leap = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.9198621771937625, 0, 0)
			clone.Ring.RotSpeed = NumberRange.new(300, 600)
			clone.Ring.Speed = NumberRange.new(0.1, 20)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(15)
			Debris:AddItem(clone, 0.5)
			p.Position = humanoidRootPart.Position + createVector(0, 12, 0)
			v3:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p == true then
				local clone = utils.Gojo.HardHit:Clone()
				clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(-0.7853981633974483, 0, 0)
				clone.Ring.RotSpeed = NumberRange.new(500, 1000)
				clone.Ring.Speed = NumberRange.new(0.1, 60)
				clone.Ring.Drag = 2
				clone.Ring.Lifetime = NumberRange.new(0.2, 0.5)
				clone.Parent = workspace.Effects
				clone.Sparks:Emit(20)
				clone.Ring:Emit(30)
				Debris:AddItem(clone, 0.5)
				task.delay(0.05, function()
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0.7853981633974483, 0, 0)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						Size = createVector(8, 0, 8),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.2)
					task.wait(0.05)
					local clone3 = utils.Itadori.Shock:Clone()
					clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0.7853981633974483, 0, 0)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3, TweenInfo.new(0.2), {
						Size = createVector(8, 0, 8),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone3, 0.2)
				end)
			else
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
					clone3.CFrame = (p - p.Position + humanoidRootPart.Position) * CFrame.Angles(
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
			end

			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, p)
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

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		FinalHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)
			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position + createVector(0, 2, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 3.5
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		BlackFlashHit = function(instance, instance2, p)
			local WAIT_INTERVAL = 0.04

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			local clone2 = utils.Itadori.DivergentFist.FinisherDrag:Clone()
			clone2.Parent = humanoidRootPart
			Debris:AddItem(clone2, 0.3)
			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if not (p and _G.Settings.Flash == true) then
					return
				end

				local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone3.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone3.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone3.Brightness = 200
				clone3.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone3:Destroy()
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
	v.Hitbox:Connect(function(instance, p, object)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		repeat
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				instance.Velocity.Unit * 7,
				raycastParams
			)
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, -5, -5), 12)

			if #sphereHitbox > 0 or raycastResult then
				object:FireServer(sphereHitbox, raycastResult and raycastResult.Position)

				if raycastResult then
					instance:Destroy()
				end
			end

			task.wait(0.025)
		until not instance.Parent
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CursedStrikesService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller