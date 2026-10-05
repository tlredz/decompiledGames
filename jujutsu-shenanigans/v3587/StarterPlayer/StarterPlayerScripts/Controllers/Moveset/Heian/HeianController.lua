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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HeianController"
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
			if p == 1 or p == 3 or p2 == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(85, 0, 0))
			elseif p == 2 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(85, 0, 0))
			elseif p == 4 then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(85, 0, 0), p2 == "Down" and 0.4 or false)
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
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Heian.MalevolentShrine.Voice, humanoidRootPart, game.SoundService.Voice)
			v3:DomainBurst(humanoidRootPart)
			v3:Domain(instance, function(p, instance2)
				instance2.Humanoid:LoadAnimation(animations.Heian.DomainWarn):Play(0)
				p.Panel.ImageLabel.Image = "rbxassetid://17668583842"
				instance2.HumanoidRootPart.CFrame *= CFrame.Angles(0, 0, 0.17453292519943295)
				TweenService:Create(
					instance2.HumanoidRootPart,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = instance2.HumanoidRootPart.CFrame * CFrame.Angles(
							0,
							-0.3490658503988659,
							0.3490658503988659
						)
					}
				):Play()
				p.Panel.Viewport.LightColor = Color3.fromRGB(255, 155, 155)
				p.Panel.Viewport.Ambient = Color3.fromRGB(0, 0, 0)
				p.Panel.Viewport.LightDirection = createVector(1, 0, 1)
			end)
		end,
		Chant = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Heian.Chant.Attachment:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2)
			clone.Dust:Emit(50)
			clone.Ring:Emit(10)
			clone.Attachment.Burst:Emit(1)
			clone.Attachment.Ring:Emit(1)
			local clone2 = utils.Heian.Chant.Chant:Clone()
			clone2.Parent = humanoidRootPart
			Debris:AddItem(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				StudsOffset = createVector(2, 4, 2)
			}):Play()
			task.delay(0.5, function()
				TweenService:Create(clone2.Chat, TweenInfo.new(0.5), {
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone2.Chat.Sub, TweenInfo.new(0.5), {
					TextTransparency = 1
				}):Play()
			end)
			local heianArms = instance.SetAssets:FindFirstChild("HeianArms")

			if heianArms then
				local heianArmsModel = heianArms:FindFirstChild("HeianArmsModel")

				if not heianArmsModel then
					return
				end

				heianArmsModel.Humanoid:LoadAnimation(animations.Heian.ChantArms):Play(0)
			end

			if p == 1 then
				v3:Flash(instance, Color3.fromRGB(255, 255, 255), 2)
				v3:PlaySound(sounds.Itadori.Dismantle.WorldSlash1, humanoidRootPart, game.SoundService.Effect)
			elseif p == 2 then
				v3:Flash(instance, Color3.fromRGB(255, 255, 127), 2)
				v3:PlaySound(sounds.Itadori.Dismantle.WorldSlash2, humanoidRootPart, game.SoundService.Effect)
				clone2.Chat.Sub.Text = "RECOIL..."
			elseif p == 3 then
				v3:Flash(instance, Color3.fromRGB(255, 85, 0), 2)
				v3:PlaySound(sounds.Itadori.Dismantle.WorldSlash1, humanoidRootPart, game.SoundService.Effect)
				clone2.Chat.Sub.Text = "TWIN METEORS."
			elseif p == 4 then
				v3:Flash(instance, Color3.fromRGB(255, 0, 0), 2)
				v3:PlaySound(sounds.Heian.WorldSlash3, humanoidRootPart, game.SoundService.Effect)
				clone2:Destroy()
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				v3:PlaySound(sounds.Heian.Dismantle.WCSCharge, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.3)
				v3:PlaySound(sounds.Heian.Dismantle.Start, humanoidRootPart, game.SoundService.Effect)
				v3:PlaySound(sounds.Heian.Dismantle4, humanoidRootPart, game.SoundService.Voice)
			end
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			v3:PlaySound(sounds.Heian.Dismantle.FireWCS, instance, game.SoundService.Effect)
			v3:PlaySound(sounds.Heian.Dismantle.Fire, instance, game.SoundService.Effect)
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (300 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		DebreeOverlay = function(instance, p, items)
			local colors = {}

			for k, _ in items do
				table.insert(colors, Color3.fromHex(k))
			end

			local currentCamera = workspace.CurrentCamera
			local v5 = tick() + 20
			local clone = utils.Heian.Slashes:Clone()
			clone.Parent = workspace.Effects
			clone.Position = currentCamera.CFrame.Position
			local v6 = {}
			local v7 = true

			local function handleChar(instance2)
				local humanoidRootPart = instance2.HumanoidRootPart
				local clone2 = utils.Itadori.MalevolantShrine.Hit:Clone()
				clone2.Parent = workspace.Effects
				clone2.Weld.Part1 = humanoidRootPart

				while true do
					task.wait(math.random(10, 20) / 100)

					if not humanoidRootPart.Parent then
						break
					end

					v3:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)

					if not v7 or instance2:GetAttribute("Dead") or instance:GetAttribute("Dead") or not (instance.Parent and humanoidRootPart.Parent) then
						break
					end
				end

				clone2:Destroy()

				if instance2:GetAttribute("Dead") and humanoidRootPart.Parent then
					v3:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
					v3:Bleed(instance2)
				end
			end

			local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
			local v8 = v3:PlaySound(sounds.Heian.MalevolentShrine.Slashes, workspace, game.SoundService.Effect)
			v3:PlaySound(sounds.Heian.MalevolentShrine.Voice3, workspace, game.SoundService.Voice)

			while true do
				clone.Position = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 100

				for _, child in workspace.Characters:GetChildren() do
					if not child:FindFirstChild("HumanoidRootPart") or v6[child] or child == instance then
						continue
					end

					v6[child] = true
					task.spawn(handleChar, child)
				end

				if _G.Settings.DesPHY and (currentCamera.CFrame.Position - p.Position).Magnitude < 250 then
					for _ = 1, 8 do
						local clone2 = utils.Damage.DebreeRef:Clone()
						clone2.Size = Vector3.new(math.random(5, 60) / 10, 2, math.random(5, 60) / 10)
						clone2.CFrame = currentCamera.CFrame * CFrame.new(
							math.random(-120, 120) / 10,
							math.random(-80, 80) / 10,
							10
						)
						clone2.CollisionGroup = "Effects"
						clone2.Anchored = false
						local v9 = currentCamera.CFrame * CFrame.Angles(
							math.random(-90, 90),
							math.random(-90, 90),
							math.random(-90, 90)
						)
						clone2.Color = colors[math.random(1, #colors)]
						task.delay(1.4, function()
							if clone2.Parent then
								clone2:Destroy()
							end
						end)
						clone2.Velocity = v9.LookVector * math.random(100, 400)
						clone2.RotVelocity = Vector3.new(
							math.random(-300, 300),
							math.random(-300, 300),
							math.random(-300, 300)
						)
						clone2.Parent = workspace.Effects
					end
				end

				task.wait(0.025)

				if not (v5 < tick() or not instance.Parent or instance:GetAttribute("Dead")) then
					continue
				end

				v7 = false
				clone.Slash1.Enabled = false
				clone.Slash2.Enabled = false
				clone.Sparks.Enabled = false
				Debris:AddItem(clone, 1)

				if shakeSustain then
					shakeSustain:StartFadeOut(1)
				end

				if v8 then
					TweenService:Create(v8, TweenInfo.new(1.5), {
						Volume = 0
					}):Play()
				end

				break
			end
		end,
		DomainOpen = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = tick() + 25.5
			local clone = utils.Heian.DomainFade:Clone()
			clone.Parent = localPlayer.PlayerGui
			v3:PlaySound(sounds.Heian.MalevolentShrine.UhohStart, workspace, game.SoundService.Effect)
			local v6 = v3:PlaySound(sounds.Heian.MalevolentShrine.Music, workspace, game.SoundService.Music, true)
			clone.BG.BackgroundTransparency = 1
			TweenService:Create(clone.BG, TweenInfo.new(0.2), {
				BackgroundTransparency = 0
			}):Play()
			task.delay(0.5, function()
				TweenService:Create(clone.BG.Bubble, TweenInfo.new(1.2), {
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.BG.Bubble.Texta, TweenInfo.new(1.2), {
					TextTransparency = 1
				}):Play()
				v3:PlaySound(sounds.Itadori.MalevolantShrine.Ring, workspace, game.SoundService.Effect)
				task.wait(1.2)
				clone.BG.Visible = false
				clone.Frame1.Visible = true
				clone.Frame2.Visible = true
				localPlayer.PlayerGui.Main.Enabled = false
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
				colorCorrectionEffect.Brightness = -1
				v3:DomainMapFade(Color3.new(1, 0, 0), 0, 0.5)
				task.delay(0.5, function()
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
						Brightness = 0,
						Saturation = -0.5
					}):Play()
				end)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				v3:PlaySound(sounds.Heian.MalevolentShrine.Uhoh, workspace, game.SoundService.Effect)

				if instance:GetAttribute("Moveset") == "Heian" then
					v3:PlaySound(sounds.Heian.MalevolentShrine.Voice2, humanoidRootPart, game.SoundService.Voice)
				end

				local clone2 = utils.Heian.Shrine:Clone()
				clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 11, 20))
				clone2.Parent = workspace.Effects
				local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

				for _, part in clone2:GetDescendants() do
					if not part:IsA("BasePart") then
						continue
					end

					local cFrame = part.CFrame
					part.CFrame = part.CFrame * CFrame.new(
						math.random(-30, 30),
						math.random(-30, 30),
						math.random(-30, 30)
					) * CFrame.Angles(
						math.rad((math.random(0, 360))),
						math.rad((math.random(0, 360))),
						(math.rad((math.random(0, 360))))
					)
					TweenService:Create(part, tweenInfo, {
						CFrame = cFrame
					}):Play()
				end

				task.delay(3, function()
					if colorCorrectionEffect then
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Brightness = 1
							}
						):Play()
						task.wait(0.5)
						colorCorrectionEffect.TintColor = Color3.new(1, 0, 0)
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Brightness = 0,
							Saturation = 0
						}):Play()
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(2, Enum.EasingStyle.Sine), {
							TintColor = Color3.new(1, 1, 1)
						}):Play()
						Debris:AddItem(colorCorrectionEffect, 2)
					end

					if clone then
						localPlayer.PlayerGui.Main.Enabled = true
						TweenService:Create(clone.Frame1, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Position = UDim2.new(0, 0, -0.15, 0)
						}):Play()
						TweenService:Create(clone.Frame2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Position = UDim2.new(0, 0, 1.15, 0)
						}):Play()
						Debris:AddItem(clone, 1)
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					end
				end)

				repeat
					task.wait()
				until v5 < tick() or not instance.Parent or instance:GetAttribute("Dead")

				clone2:Destroy()

				if v6 then
					TweenService:Create(v6, TweenInfo.new(2), {
						Volume = 0
					}):Play()
					Debris:AddItem(v6, 2)
				end
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
	v = Knit.GetService("HeianService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller