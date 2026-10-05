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
local controller = Knit.CreateController({
	Name = "VeilstepController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Sound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Yuta.Veilstep, humanoidRootPart, game.SoundService.Effect)
		end,
		Sound2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Yuta.VeilstepJump, humanoidRootPart, game.SoundService.Effect)
		end,
		Dust = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:DustTrail(instance, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
			local raycastResult = workspace:Raycast(
				p.Position - createVector(0, 2, 0),
				Vector3.new(0, -humanoidRootPart.Size.Y * 1.6, 0),
				_G.MapParams
			)

			if raycastResult then
				local clone = utils.Yuta.Veilstep.Dust:Clone()
				clone.CFrame = CFrame.lookAlong(
					raycastResult.Position + createVector(0, 2, 0),
					p.LookVector,
					createVector(0, 1, 0)
				)
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)

				for _, emitter in clone:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter.Name == "Smoke2" then
						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
					end

					local v4 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v4:Emit(v4:GetAttribute("EmitCount"))
					end)
				end
			end
		end,
		SecondWind = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Yuta.SecondWind.Dash, humanoidRootPart, game.SoundService.Effect)
			v:DustTrail(instance, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
			local v4 = p * CFrame.new(0, -3.5, 0)
			local clone = utils.Yuta.SecondWind:Clone()
			clone.CFrame = CFrame.lookAlong(v4.Position, p.LookVector, createVector(0, 1, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			task.wait(0.14)
			clone.CFrame = CFrame.lookAlong(clone.Position, humanoidRootPart.CFrame.LookVector)
		end,
		SecondWindGrab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.Veilstep.Spin.SpinRing:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.5)
			clone.Ring:Emit(10)
			v:PlaySound(sounds.Yuta.SecondWind.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		DiveFloorHit = function(p)
			local v4 = -p.LookVector
			local raycastResult = workspace:Raycast(p.Position - v4, v4 * 10, _G.MapParams)

			if raycastResult then
				local clone = utils.Hiromi.Shockwave:Clone()
				clone.Position = raycastResult.Position
				clone.Parent = workspace.Effects
				clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
				TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Scale = createVector(15, 0, 15)
				}):Play()
				TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()
				clone.Floor.Glow:Emit(1)
				clone.Floor.Ring:Emit(10)
				Debris:AddItem(clone, 1.5)
				local clone2 = utils.Yuta.Veilstep.CEImpact:Clone()
				clone2.Position = raycastResult.Position
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 2)
				TweenService:Create(clone2.PointLight, TweenInfo.new(0.6), {
					Brightness = 0
				}):Play()
				clone2.Glow:Emit(1)
				clone2.Sparks:Emit(50)
				clone2.Sparks2:Emit(20)
				clone2.Wind2:Emit(7)
				TweenService:Create(clone2.Air, TweenInfo.new(0.2), {
					Position = createVector(0, 0, 0)
				}):Play()
				v:PlaySound(sounds.Hakari.Shock, clone2, game.SoundService.Effect)
				v:PlaySound(sounds.Yuta.VeilstepHit, clone2, game.SoundService.Effect)
				v:PlaySound(sounds.Hakari.Impact, clone2, game.SoundService.Effect)

				if (workspace.CurrentCamera.CFrame.Position - raycastResult.Position).Magnitude < 150 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end
			end

			if (p.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 25 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		SpinRing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.Veilstep.Spin.SpinRing:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.5)
			clone.Ring:Emit(10)
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:Flash(instance, p and Color3.fromRGB(255, 170, 255) or Color3.new(1, 1, 1))
			local v4 = v:PlaySound(sounds.Yuta.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
			v4.Volume *= 2
		end,
		DiveHitbox = function(instance, instance2, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local rightArm = instance:FindFirstChild("Right Arm")

			if not rightArm then
				return
			end

			local v4 = v:PlaySound(sounds.Yuta.VeilstepDive, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Once(function()
				v4:Destroy()
			end)

			if instance == localPlayer.Character then
				repeat
					local raycastResult = workspace:Raycast(
						rightArm.Position,
						instance2.Velocity.Unit * 10,
						raycastParams
					)

					if not raycastResult and humanoid.FloorMaterial ~= Enum.Material.Air then
						raycastResult = workspace:Raycast(
							rightArm.Position + instance2.Velocity.Unit,
							createVector(0, -6, 0),
							raycastParams
						)
					end

					if raycastResult then
						object:FireServer(raycastResult.Position, raycastResult.Normal)
						instance2:Destroy()
					end

					task.wait(0.025)
				until not instance2.Parent
			end
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetService("VeilstepService")
	v = Knit.GetController("FXController")
end

return controller