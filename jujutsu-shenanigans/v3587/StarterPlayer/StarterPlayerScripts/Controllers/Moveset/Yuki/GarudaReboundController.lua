local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
local controller = Knit.CreateController({
	Name = "GarudaReboundController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Rebound.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Punch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Rebound.Punch, humanoidRootPart, game.SoundService.Effect)
		end,
		Interp = function(instance, value, p)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local v4 = value or 160
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if instance.Parent then
					if instance:GetAttribute("Freeze") then
						instance.Trail.Lifetime = 20
						return
					end

					instance.Trail.Lifetime = p and 0.5 or 0.1
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (v4 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					instance.Attachment.CFrame *= CFrame.Angles(0, 0, math.random(0, 3.141592653589793))
					instance.GarudaBall.Weld.C1 *= CFrame.Angles(math.rad(400 * dt), math.rad(400 * dt), 0)
				else
					steppedConnection:Disconnect()
					positionChangedConnection:Disconnect()
				end
			end)
		end,
		Recall = function(instance, folder, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for _, effect in folder:GetDescendants() do
				if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end

			local lastTime = tick()

			if p2 == 0.1 then
				v2:PlaySound(sounds.Yuki.Rebound.Return, humanoidRootPart, game.SoundService.Effect)

				repeat
					task.wait()
					local v4 = (tick() - lastTime) / p2
					folder.Position = p:Lerp(humanoidRootPart.Position, v4)
				until not humanoidRootPart.Parent or p2 < tick() - lastTime
			else
				v2:PlaySound(sounds.Yuki.Rebound.Bounce, humanoidRootPart, game.SoundService.Effect)

				repeat
					task.wait()
					local v4 = (tick() - lastTime) / p2
					local v5 = p:Lerp(humanoidRootPart.Position, v4) + Vector3.new(0, math.sin(v4 * 3.14) * 15, 0)
					folder.CFrame = CFrame.lookAlong(v5, v5 - folder.Position)
				until not humanoidRootPart.Parent or p2 < tick() - lastTime
			end

			if folder then
				folder:Destroy()
			end
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Yuki.Rebound.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		HeavyHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Kick = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.CounterSwing.Shock:Clone()
			clone.Size = createVector(6, 30, 6)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()
			v2:PlaySound(sounds.Mahito.Stockpile.Swing2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Woosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.PointLight:Destroy()
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			Debris:AddItem(clone, 3)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(6, 30, 6)
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone2.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()
			v2:PlaySound(sounds.Mahito.Stockpile.Swing2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Impact = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
				Debris:AddItem(colorCorrectionEffect, 0.85)
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 50
					}
				):Play()
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Saturation = -0.5
					}
				):Play()
				task.delay(0.5, function()
					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
						{
							FieldOfView = 70
						}
					):Play()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Saturation = 0
						}
					):Play()
				end)

				if math.random(1, 20) == 1 then
					v2:PlaySound(sounds.Yuki.Secret, humanoidRootPart, game.SoundService.Voice)
					v2:PlaySound(sounds.Yuki.SecretSFX, humanoidRootPart, game.SoundService.Effect)
				end
			end

			local clone = utils.Yuki.KickWarp:Clone()
			clone.Weld.Part0 = instance["Left Leg"]
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			local highlight = Instance.new("Highlight", clone)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			Debris:AddItem(highlight, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Size = createVector(25, 1, 25),
				Transparency = 5
			}):Play()
			TweenService:Create(clone.Weld, TweenInfo.new(0.85, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				C1 = clone.Weld.C1 * CFrame.Angles(0, 179, 0)
			}):Play()
			task.delay(0.6, function()
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					Size = createVector(0, 50, 0),
					Transparency = 1
				}):Play()
				clone.impactframelines1.Enabled = true
				clone.impactframeines3.Enabled = true
				task.wait(0.25)
				clone.impactframelines1.Enabled = false
				clone.impactframeines3.Enabled = false
				clone.Flare:Destroy()
			end)
			clone.Flare.Flare:Emit(8)
			clone.Flare.Wind2:Emit(10)

			for _, child in clone.Hit:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
				TweenService:Create(child, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					TimeScale = 1
				}):Play()
			end

			v2:PlaySound(sounds.Yuki.Rebound.Slow, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)
			end
		end,
		TrueFinish = function(p, folder, p2)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == folder or localPlayer == p then
				v2:PlaySound(sounds.Yuki.Freeze, workspace, game.SoundService.Effect)
				game.Lighting.ExposureCompensation = 3
				task.wait(0.3)
				game.Lighting.ExposureCompensation = 0
			else
				v2:PlaySound(sounds.Yuki.Freeze, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.3)
			end

			v2:PlaySound(sounds.Yuki.Explode, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuki.Explode2, humanoidRootPart, game.SoundService.Effect)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			local cframe = CFrame.lookAlong(humanoidRootPart.Position, p2)

			for _ = 1, 100 do
				BloodyZee:Blood(cframe, math.random(200, 300), 40, 40)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = folder.Head
				clone:Emit(60)
				Debris:AddItem(clone, 2)
			end

			for _ = 1, 20 do
				local clone = utils.Damage.Chunk:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.CollisionGroup = "Effects"
				clone.Velocity = p2 * math.random(50, 200)
				clone.CanCollide = true
				clone.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
				task.delay(2, function()
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
					clone.Blood.Enabled = false
					clone.Trail.Enabled = false
				end)

				if _G.Settings.Gore ~= false then
					continue
				end

				clone.Color = Color3.fromRGB(255, 85, 255)
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
				clone.Blood.Color = clone.Trail.Color
			end

			if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 40 or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
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
	v = Knit.GetService("GarudaReboundService")
	v2 = Knit.GetController("FXController")
end

return controller