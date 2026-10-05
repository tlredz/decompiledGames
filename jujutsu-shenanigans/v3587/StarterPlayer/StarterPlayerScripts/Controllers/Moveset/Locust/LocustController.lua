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
	Name = "LocustController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)

			if p == 3 then
				v3:PlaySound(sounds.Locust.Slash.Punch, humanoidRootPart, game.SoundService.Effect)
			elseif p ~= 4 then
				v3:PlaySound(sounds.Locust.Slash.Slash, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
		end,
		AerialHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position - createVector(0, 4, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 4
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, p2)
			if p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(85, 170, 0), 0.4)
			elseif p == 1 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(85, 170, 0), 0.3)
				local clone = utils.Locust.Claws:Clone()
				clone.Parent = workspace.Effects
				clone.Weld.Part0 = data["Right Arm"]
				task.wait(0.3)
				Debris:AddItem(clone, 0.7)
				clone.Trail1.Enabled = false
				clone.Trail2.Enabled = false
				clone.Trail3.Enabled = false
			else
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(85, 170, 0), 0.3)

				if p ~= 4 and p ~= 3 then
					local clone = utils.Locust.Claws:Clone()
					clone.Parent = workspace.Effects
					clone.Weld.Part0 = data["Left Arm"]
					task.wait(0.3)
					Debris:AddItem(clone, 0.7)
					clone.Trail1.Enabled = false
					clone.Trail2.Enabled = false
					clone.Trail3.Enabled = false
				end
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Flight = function(instance, p, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Locust.Flight, humanoidRootPart, game.SoundService.Effect)

			if not p then
				for i = 1, 5 do
					task.delay(i * 0.075, function()
						local clone = utils.Itadori.Shock:Clone()
						clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						)
						clone.Transparency = 0.3
						clone.Parent = workspace.Effects
						TweenService:Create(clone, TweenInfo.new(0.15), {
							Size = createVector(20, 0, 20),
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, 0.15)
					end)
				end
			end

			if localPlayer.Character == instance and p and p.Parent then
				local currentCamera = workspace.CurrentCamera
				humanoidRootPart.CFrame = CFrame.lookAlong(
					humanoidRootPart.Position,
					currentCamera.CFrame.LookVector,
					createVector(0, 1, 0)
				)
				p.Position = humanoidRootPart.Position + currentCamera.CFrame.LookVector * 40 * createVector(1, 0.5, 1)
			end
		end,
		StingerOut = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.ForceGrab.Retract, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.Variants.Transform3, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Locust.Victory, humanoidRootPart, game.SoundService.Voice)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		StingerFire = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Locust.MucusFire:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 10
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 10
			}):Play()
			Debris:AddItem(clone, 2)
			v3:PlaySound(sounds.Mahito.ForceGrab.Swing, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Locust.Chomp.Dash, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.4, function()
				v3:PlaySound(sounds.Mahito.Variants.Transform1, humanoidRootPart, game.SoundService.Effect)
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		PoisonHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			v3:PlaySound(sounds.Mahito.Soulfire.Hit, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("LocustService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller