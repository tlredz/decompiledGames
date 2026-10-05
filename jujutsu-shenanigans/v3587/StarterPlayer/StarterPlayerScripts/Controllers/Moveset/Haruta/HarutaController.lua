local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HarutaController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))

			if not instance.SetAssets:FindFirstChild("HarutaSword") then
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
				return
			end

			local v5 = p2 == "Up" and 1 or p
			v3:PlaySound(sounds.Haruta.M1:FindFirstChild("Hit" .. v5), humanoidRootPart2, game.SoundService.Effect)

			if p2 == "Down" then
				return
			end

			local clone = utils.Yuta.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector)
			local v6 = {
				[2] = CFrame.Angles(0, 0, 0.2617993877991494),
				[3] = CFrame.Angles(0, 0, 0.4363323129985824)
			}

			if v6[p] then
				clone.CFrame *= v6[p]
			elseif p2 == "Up" then
				clone.CFrame *= CFrame.Angles(0, 0, -1.3089969389957472)
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
		end,
		ChaseHit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if instance.SetAssets:FindFirstChild("HarutaSword") and not p then
				v3:Flash(instance2, Color3.new(1, 1, 1))
				v3:PlaySound(
					sounds.Haruta.M1:FindFirstChild("Hit" .. math.random(1, 3)),
					humanoidRootPart2,
					game.SoundService.Effect
				)
			else
				v3:Flash(instance2, Color3.new(1, 1, 1))
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			end

			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
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
		Swing = function(instance, value, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if not instance.SetAssets:FindFirstChild("HarutaSword") then
				v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
				return
			end

			local v5 = (p == "Up" or p == "Down") and 1 or value or 4
			v3:PlaySound(sounds.Haruta.M1:FindFirstChild("Swing" .. v5), humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, p2)
			local harutaSword = data.SetAssets:FindFirstChild("HarutaSword")

			if harutaSword then
				local clone = utils.Haruta.CombatTrail:Clone()
				clone.Weld.Part0 = harutaSword.Blade
				clone.Parent = workspace.Effects
				task.wait(p == 4 and 0.425 or 0.325)
				clone.Trail.Enabled = false
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.2)
			elseif p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(167, 125, 203), 0.4)
			elseif p == 1 or p == 4 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(167, 125, 203), 0.3)
			else
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(167, 125, 203), 0.3)
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

				local playSound = v3:PlaySound(
					sounds.Choso.BloodEdge.StabHit,
					humanoidRootPart,
					game.SoundService.Effect
				)
				playSound.PlaybackSpeed = math.random(90, 110) / 100

				for _ = 1, 8 do
					BloodyZee:Blood(
						CFrame.lookAt(instance.Torso.Position, instance.Torso.Position + createVector(0, 10, 0)),
						math.random(20, 40),
						math.random(20, 40),
						math.random(20, 40)
					)
				end
			end
		end,
		Miracles = function(instance)
			task.spawn(function()
				repeat
					task.wait()
				until _G.Settings ~= nil and _G.Settings.UIS ~= nil and instance:FindFirstChild("UIScale")

				instance.UIScale.Scale = _G.Settings.UIS
			end)
		end,
		UpdateMiracles = function(instance, p)
			for i = 1, 6 do
				local findFirstChild = instance:FindFirstChild("Mir" .. i, true)
				findFirstChild.Fill.Visible = i <= p
			end
		end,
		Stab = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Choso.BloodEdge.StabHit, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				BloodyZee:Blood(instance2.Torso.CFrame, math.random(5, 80), 25, 25)
			end
		end,
		Kick = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit4"), humanoidRootPart, game.SoundService.Effect)
		end,
		DodgeAttempt = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(167, 125, 203), 0.2)
			v3:PlaySound(sounds.Itadori.ManjiKick.Startup, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				local clone = utils.Itadori.CounterHit.Feint:Clone()

				for _, child in clone:GetChildren() do
					child.Color = ColorSequence.new(Color3.fromRGB(167, 125, 203))
				end

				clone.Parent = humanoidRootPart
				clone.Ring:Emit(1)
				clone.Ring.Lifetime = NumberRange.new(0.2)
				Debris:AddItem(clone, 0.2)
			end
		end,
		MiracleGain = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(209, 157, 255), 0.4)
			sounds.Haruta.Gain.PlaybackSpeed = math.random(90, 110) / 100
			v3:PlaySound(sounds.Haruta.Gain, humanoidRootPart, game.SoundService.Effect)
		end,
		MiracleUse = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(126, 91, 154), 0.4)

			if localPlayer.Character == instance then
				sounds.Haruta.Lose.PlaybackSpeed = math.random(90, 110) / 100
				v3:PlaySound(sounds.Haruta.Lose, humanoidRootPart, game.SoundService.Effect)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Dodge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.fromRGB(167, 125, 203)
				child.Anchored = true
				child.Transparency = 0.1
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v3:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
			local v5 = {
				"Dodge1",
				"Dodge2",
				"Dodge3",
				"Dodge4",
				"Dodge5"
			}

			for _, v6 in instance.Humanoid:GetPlayingAnimationTracks() do
				if table.find(v5, v6.Name) then
					v6:Stop(0.02)
				end
			end

			instance.Humanoid:LoadAnimation(animations.Hiromi.Dodge:GetChildren()[math.random(1, 5)]):Play(0.02)
		end,
		SwordCatch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Haruta.Catch, humanoidRootPart, game.SoundService.Effect)
			v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(167, 125, 203))
			local clone = replicatedStorage.Utils.Haruta.SwordGrab:Clone()
			clone.Parent = instance["Right Arm"]
			clone.Ring:Emit(5)
			clone.Star:Emit(1)
			Debris:AddItem(clone, 0.8)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Taunt = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v3:PlaySound(sounds.Haruta.Taunt, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Connect(function()
				v5:Destroy()
			end)
		end,
		HandMode = function(instance, instance2)
			if not (instance2 and instance) then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.Enabled = false
			highlight.Adornee = instance2.Value
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.FillColor = Color3.fromRGB(167, 125, 203)
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = instance2.Value
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local value = instance2.Value

				if not (value and value.PrimaryPart and instance and instance.PrimaryPart) then
					return
				end

				local position = value.PrimaryPart.Position
				local position2 = instance.PrimaryPart.Position
				local raycastResult = workspace:Raycast(position, position2 - position, _G.MapParams)

				if highlight then
					highlight.Enabled = raycastResult
				end
			end)
			instance2.AncestryChanged:Once(function()
				renderSteppedConnection:Disconnect()
				highlight:Destroy()
			end)
		end,
		JawbreakerStart = function(instance, p, instance2, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hiromi.Execution.Curb, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Hiromi.Execution.Step, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Locust.Slam:Clone()
			clone.Position = instance2.Head.Position
			clone.Parent = workspace.Effects

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone, 0.5)
			local clone2 = utils.Mechamaru.Dust:Clone()
			clone2.bigimpact:Destroy()
			clone2.Smoke2:Destroy()
			clone2.Position = humanoidRootPart2.Position - createVector(0, 3, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2.5)

			for _, child in clone2:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
				TweenService:Create(child, TweenInfo.new(0.3), {
					TimeScale = 0.1
				}):Play()
			end

			task.delay(1.7, function()
				v3:PlaySound(sounds.Hiromi.Execution.Curb, humanoidRootPart, game.SoundService.Effect)

				for _, child in clone2:GetChildren() do
					child:Emit(child:GetAttribute("EmitCount"))
					child.TimeScale = 1
				end
			end)

			if localPlayer.Character ~= instance2 then
				v3:PlaySound(sounds.Haruta.Jawbreaker, humanoidRootPart2, game.SoundService.Effect)
			end

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				task.wait(1.7)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			elseif localPlayer.Character == instance2 then
				local currentCamera = workspace.CurrentCamera
				local cFrame = currentCamera.CFrame
				v3:PlaySound(sounds.Haruta.Jawbreaker, workspace, game.SoundService.Effect)
				local clone3 = replicatedStorage.Utils.Haruta.JawbreakerUI:Clone()
				clone3.BG.CurrentCamera = workspace.CurrentCamera
				clone3.Skull.CurrentCamera = workspace.CurrentCamera
				clone3.Parent = localPlayer.PlayerGui
				local clone4 = replicatedStorage.Utils.Damage.Skeleton.Head:Clone()
				clone4.Anchored = true
				clone4.Mesh.Scale = createVector(0.8, 0.8, 0.8)
				clone4.Parent = clone3.Skull
				v3:WorldModelChar(instance2, clone3.BG)
				local numberValue = Instance.new("NumberValue", clone3)
				TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Value = 1
				}):Play()
				Debris:AddItem(numberValue, 0.5)
				TweenService:Create(clone3.BG, TweenInfo.new(0.5), {
					ImageTransparency = 0.1
				}):Play()
				TweenService:Create(clone3.BG, TweenInfo.new(0.85), {
					BackgroundTransparency = 0.65
				}):Play()
				TweenService:Create(clone3.BG.Vignette, TweenInfo.new(0.85), {
					ImageTransparency = 0
				}):Play()
				TweenService:Create(clone3.Skull, TweenInfo.new(1), {
					ImageTransparency = 0
				}):Play()
				task.delay(0.85, function()
					TweenService:Create(clone3.BG, TweenInfo.new(0.85), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(clone3.BG.Vignette, TweenInfo.new(0.85), {
						ImageTransparency = 1
					}):Play()
					task.wait(0.15)
					local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
					TweenService:Create(clone3.Skull, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					TweenService:Create(clone3.BG, tweenInfo, {
						ImageTransparency = 1
					}):Play()
				end)
				local total = 0
				local renderSteppedConnection = nil
				tick()
				local jawbreakerCutscene = utils.Haruta.JawbreakerCutscene
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v5 = dt * 120
					total += v5
					local child = jawbreakerCutscene.Frames:FindFirstChild((tonumber((math.ceil(total)))))

					if child and instance and instance.Parent and humanoidRootPart and p2.Parent then
						currentCamera.CFrame = cFrame:Lerp(humanoidRootPart2.CFrame * child.Value, numberValue.Value)
						currentCamera.CameraType = Enum.CameraType.Scriptable
					else
						renderSteppedConnection:Disconnect()
						currentCamera.CameraType = Enum.CameraType.Custom
						currentCamera.FieldOfView = 70
						currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
						game.Lighting.ExposureCompensation = -2
						TweenService:Create(game.Lighting, TweenInfo.new(1), {
							ExposureCompensation = 0
						}):Play()
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
						clone3:Destroy()
						local blurEffect = Instance.new("BlurEffect", game.Lighting)
						Debris:AddItem(blurEffect, 8)
						blurEffect.Size = 64
						TweenService:Create(
							blurEffect,
							TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Size = 0
							}
						):Play()

						if _G.Settings.Flash == true then
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
							Debris:AddItem(colorCorrectionEffect, 9)
							colorCorrectionEffect.TintColor = Color3.new(1, 0, 0)
							colorCorrectionEffect.Contrast = 200
							task.wait(0.05)
							colorCorrectionEffect.Contrast = -200
							colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
							task.wait(0.05)
							colorCorrectionEffect.Contrast = 0
							colorCorrectionEffect.TintColor = Color3.new(1, 0.3, 0.3)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									TintColor = Color3.fromRGB(255, 201, 201)
								}
							):Play()
							task.wait(8)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									TintColor = Color3.fromRGB(255, 255, 255)
								}
							):Play()
						end
					end

					clone4.CFrame = instance2.Head.CFrame
				end)
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
	v = Knit.GetService("HarutaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller