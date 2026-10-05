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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "NanamiController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2, p, p2, _)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local inUlt = instance:GetAttribute("InUlt")
			v3:Flash(instance2, Color3.new(1, 1, 1))

			if p2 == "Down" or p2 == "Up" and inUlt or p2 ~= "Up" and inUlt and (p == 1 or p == 3) then
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
			elseif p2 == "Up" then
				v3:PlaySound(sounds.Nanami.M1.Up, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Nanami.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
			end
		end,
		BlackFlashHit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.PerfectHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Nanami.BlackFlash, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			clone.Lightning:Emit(6)
			clone.Sparks:Emit(15)
			clone.Sparks2:Emit(20)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
			v3:PlaySound(
				instance:GetAttribute("InUlt") and sounds.Gojo.M1:FindFirstChild("Hit3") or sounds.Nanami.M1:FindFirstChild("Hit3"),
				humanoidRootPart2,
				game.SoundService.Effect
			)
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
		Ultimate = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Nanami.Ultimate, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(instance, p, p2)
			local function swingCleaver(value)
				local nanamiCleaver = instance.SetAssets:FindFirstChild("NanamiCleaver")

				if not nanamiCleaver then
					return
				end

				local clone = utils.Nanami.CombatTrail:Clone()
				clone.Weld.Part0 = nanamiCleaver.Blade
				clone.Parent = workspace.Effects
				task.wait(value or 0.35)
				clone.Trail.Enabled = false
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.2)
			end

			if p2 == "Down" then
				if instance:GetAttribute("InUlt") then
					v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(129, 168, 203), 0.4)
				else
					v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(129, 168, 203), 0.4)
				end
			elseif not instance:GetAttribute("InUlt") then
				swingCleaver(p == 4 and 0.45 or false)
			elseif p == 1 or p == 3 or p == 4 and p2 == "Air" then
				v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(129, 168, 203), p == 4 and 0.45 or false)
			else
				swingCleaver()
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
		EyeFlash = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = replicatedStorage.Utils.Itadori.EyeTrails:Clone()
			clone.Eye1:Destroy()
			clone.Trail1:Destroy()
			clone.Weld.Part0 = instance.Head
			clone.Parent = workspace.Effects
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(129, 168, 203))
			clone.Eye2.Glow.Color = ColorSequence.new(Color3.fromRGB(129, 168, 203))
			clone.Glow:Emit(1)
			clone.Trail2.Trail.Enabled = false
			clone.Eye2.Glow.Enabled = false
			clone.Sparks:Emit(15)
			clone.Eye2.Glow:Emit(1)
			Debris:AddItem(clone, 0.5)
			v3:PlaySound(sounds.Nanami.EyeFlash, humanoidRootPart, game.SoundService.Effect)
		end,
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Nanami.Dialogue:Clone()
			clone.Parent = torso
			local position = clone.Text1.Position
			clone.Text1.Position = position - UDim2.new(0, 0, 0.1, 0)
			clone.Text1.TextTransparency = 0
			TweenService:Create(clone.Text1, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Text1, TweenInfo.new(2), {
				TextTransparency = 1
			}):Play()
			task.wait(0.75)
			local position2 = clone.Chat1.Position
			clone.Chat1.Position = position2 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.5)
			Debris:AddItem(clone, 4)
			local position3 = clone.Chat2.Position
			clone.Chat2.Position = position3 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position3
			}):Play()
			TweenService:Create(clone.Chat2, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat2.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.1, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()
				end
			end
		end,
		SpawnRatio = function(p, instance, instance2, instance3, duration, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p ~= localPlayer then
				instance2.Enabled = false
				return
			end

			instance2.Enabled = true
			instance2.StudsOffset = createVector(0, 3.5, 3)
			v3:PlaySound(sounds.Nanami.Ratio.Appear, humanoidRootPart, game.SoundService.Effect)
			local v5 = math.random(1, 2) == 1 and -1 or 1
			local v6 = math.clamp(
				(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude / 35,
				1,
				5.5
			)

			if p ~= localPlayer then
				v6 = math.clamp(
					(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude / 10,
					1,
					5.5
				) * 0.25
			end

			instance2.Bar.Rotation = -180 * v5
			instance2.Size = UDim2.fromScale(v6 * 15, v6 * 2.25)
			local tween = TweenService:Create(instance2.Bar, TweenInfo.new(duration, Enum.EasingStyle.Exponential), {
				Rotation = 90 * v5
			})
			tween:Play()
			local tween2 = TweenService:Create(instance2, TweenInfo.new(0.4), {
				Size = UDim2.fromScale(v6 * 10, v6 * 1.5)
			})
			tween2:Play()
			TweenService:Create(instance2.Bar.Cursor, TweenInfo.new(0.2), {
				ImageTransparency = 0.15
			}):Play()
			tween2.Completed:Connect(function()
				task.spawn(function()
					repeat
						v6 = math.clamp(
							(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude / 35,
							1,
							5.5
						)

						if p ~= localPlayer then
							v6 = math.clamp(
								(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude / 10,
								1,
								5.5
							) * 0.25
						end

						instance2.Size = UDim2.fromScale(v6 * 10, v6 * 1.5)
						task.wait()
					until instance2.Parent == nil
				end)
			end)
			local bar = instance2:WaitForChild("Bar")
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if instance2.Parent and instance3.Value ~= true and instance3.Parent ~= nil then
					local v7 = (workspace:GetServerTimeNow() - p2) / duration
					bar.Cursor.Position = UDim2.fromScale(0.5, 1 - v7)
				else
					if instance2.Parent then
						bar.Cursor.Position = UDim2.fromScale(0.5, 1 - instance3:GetAttribute("CurrentTiming"))
					end

					if instance3.Value and instance2.Parent then
						tween:Cancel()
						instance2.Bar.Cursor.Size = UDim2.fromScale(
							instance2.Bar.Cursor.Size.X.Scale * 2,
							instance2.Bar.Cursor.Size.Y.Scale * 2
						)
						TweenService:Create(instance2.Bar.Cursor, TweenInfo.new(0.25), {
							Position = UDim2.fromScale(0.5, 0.30000000000000004),
							Size = UDim2.fromScale(
								instance2.Bar.Cursor.Size.X.Scale * 0.5,
								instance2.Bar.Cursor.Size.Y.Scale * 0.5
							)
						}):Play()
						TweenService:Create(instance2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
							StudsOffset = createVector(0, 0, 3)
						}):Play()
						TweenService:Create(instance2.Bar, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
							Rotation = (90 + math.random(-15, 15)) * v5
						}):Play()
						v3:PlaySound(sounds.Nanami.Ratio.Success, humanoidRootPart, game.SoundService.Effect)
					end

					renderSteppedConnection:Disconnect()
				end
			end)
		end,
		DestroyRatio = function(p, instance, instance2, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p2 then
				local clone = instance2:Clone()
				clone.Name = "RatioVisual"
				instance2:Destroy()
				local clone2 = utils.Nanami.SplitRatio:Clone()

				if p == localPlayer or instance == localPlayer.Character then
					clone2.Left.Ratio.AlwaysOnTop = true
					clone2.Part.Ratio.AlwaysOnTop = true
					clone.AlwaysOnTop = true

					if _G.Settings.Flash == true then
						local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone3.TintColor = Color3.fromRGB(60, 60, 60)
						clone3.Brightness = -0.8
						clone3.Contrast = 0
						clone3.Saturation = 0
						clone3.Parent = game.Lighting
						task.spawn(function()
							task.wait(0.04)
							task.wait(0.04)
							clone3.Brightness = -0.6
							TweenService:Create(clone3, TweenInfo.new(0.2), {
								Brightness = 0,
								TintColor = Color3.new(1, 1, 1)
							}):Play()
							Debris:AddItem(clone3, 0.2)
							CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
							task.wait(0.2)
							clone2.Left.Ratio.AlwaysOnTop = false
							clone2.Part.Ratio.AlwaysOnTop = false
						end)
					else
						task.spawn(function()
							CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
							task.wait(0.2)
							clone2.Left.Ratio.AlwaysOnTop = false
							clone2.Part.Ratio.AlwaysOnTop = false
						end)
					end
				end

				clone.Enabled = true
				clone.Parent = humanoidRootPart
				clone.Bar.Visible = true
				clone.Bar.Cursor.ImageColor3 = Color3.fromRGB(255, 0, 0)
				local studsOffset = clone.StudsOffset
				local v5 = 1

				for _ = 1, 3 do
					clone.StudsOffset = Vector3.new(math.random(-5, 5) / 10, math.random(-5, 5) / 10, studsOffset.Z)
					clone.Size = UDim2.fromScale(clone.Size.X.Scale * 1.04, clone.Size.Y.Scale * 1.04)
					v5 *= 1.04
					task.wait(0.02666666666666667)
				end

				clone:Destroy()
				v3:PlaySound(sounds.Nanami.Ratio.Break, humanoidRootPart, game.SoundService.Effect)
				local clone3 = utils.Nanami.RatioBreak:Clone()
				clone3.Parent = humanoidRootPart
				Debris:AddItem(clone3, 2)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local v6 = math.clamp(
					(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude / 35,
					1,
					5.5
				)

				if p ~= localPlayer then
					v6 = math.clamp(
						(workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude / 10,
						1,
						5.5
					) * 0.25
				end

				clone2.Parent = workspace.Effects
				clone2:PivotTo(humanoidRootPart.CFrame)

				for _, child in pairs(clone2:GetChildren()) do
					local v7 = child.Name == "Left" and -1 or 1
					child.Ratio.Size = UDim2.fromScale(v6 * 5 * v5, v6 * 1.5 * v5)
					child.AssemblyLinearVelocity = CFrame.lookAt(
						workspace.CurrentCamera.CFrame.Position,
						humanoidRootPart.Position
					).RightVector * (v7 * 25) + createVector(0, 40, 0)
					TweenService:Create(child.Ratio.Bar, TweenInfo.new(0.8), {
						Rotation = 90 - v7 * math.random(90, 360)
					}):Play()
				end

				Debris:AddItem(clone2, 1)
				clone:Destroy()
			elseif localPlayer == p then
				v3:PlaySound(sounds.Nanami.Ratio.Disappear, humanoidRootPart, game.SoundService.Effect)
				instance2.Bar.Cursor.Visible = false
				TweenService:Create(instance2.Bar.Bar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					ImageTransparency = 1,
					Size = UDim2.fromScale(0, instance2.Bar.Bar.Size.Y)
				}):Play()
			end
		end,
		Dismember = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Nanami.Dismember, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("NanamiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller