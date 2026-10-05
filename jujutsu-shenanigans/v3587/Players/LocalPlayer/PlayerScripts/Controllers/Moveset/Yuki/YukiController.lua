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
	Name = "YukiController"
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
			if p2 == "Down" or p == 4 and not p2 then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 85, 255), 0.4)
			elseif p2 == "Up" and p == 4 or p == 1 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 85, 255), 0.3)
			elseif p == 2 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 85, 255), 0.3)
			elseif p == 3 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 85, 255), 0.3)
			else
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 85, 255), 0.3)
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
		BlackHole = function(instance)
			if not instance then
				return
			end

			local position = instance.Position
			local clone = utils.Yuki.BlackHole2:Clone()
			clone.Position = position
			clone.DustCollect.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 7)
			local highlight = Instance.new("Highlight", clone)
			highlight.FillColor = Color3.new(0, 0, 0)
			highlight.FillTransparency = 0
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			v3:PlaySound(sounds.Yuki.Hole.Hole, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 150 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(2)
			end

			local steppedConnection = nil
			local v5 = false
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			task.delay(3.8, function()
				steppedConnection:Disconnect()

				if v5 == true then
					v5 = false
					TweenService:Create(workspace.CurrentCamera, tweenInfo, {
						FieldOfView = 70
					}):Play()
				end
			end)
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if instance and instance.Parent then
					position = instance.Position
					clone.Position = position
					clone.DustCollect.Position = position
				end

				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				local magnitude = (humanoidRootPart.Position - position).Magnitude

				if magnitude > 100 then
					if v5 == true then
						v5 = false
						TweenService:Create(workspace.CurrentCamera, tweenInfo, {
							FieldOfView = 70
						}):Play()
					end
				else
					if v5 == false then
						v5 = true
						TweenService:Create(workspace.CurrentCamera, tweenInfo, {
							FieldOfView = 120
						}):Play()
					end

					local v6 = 1 - math.clamp(magnitude / 100, 0, 1)
					local cframe = CFrame.lookAt(humanoidRootPart.Position, position)

					if character.Humanoid.FloorMaterial == Enum.Material.Air then
						humanoidRootPart.AssemblyLinearVelocity += cframe.LookVector * (v6 * 300 * dt)
					else
						humanoidRootPart.AssemblyLinearVelocity += cframe.LookVector * (v6 * 2000 * dt)
					end

					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightLoop)
				end
			end)
			TweenService:Create(clone, TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(20, 20, 20)
			}):Play()
			task.wait(2.5)
			TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Size = createVector(0, 0, 0)
			}):Play()
			task.wait(1.3)

			for _, child in clone.DustCollect:GetChildren() do
				child.Enabled = false
			end

			task.wait(0.1)

			for _, child in clone.Absorb:GetChildren() do
				child.Enabled = false
			end

			task.wait(0.1)
			clone.Clear.Dust:Emit(100)
			clone.Clear.Ring:Emit(20)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 150 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)
				game.Lighting.ExposureCompensation = 2
				TweenService:Create(game.Lighting, TweenInfo.new(1), {
					ExposureCompensation = 0
				}):Play()
			end
		end,
		Absorbed = function(folder)
			if not folder:FindFirstChild("HumanoidRootPart") then
				return
			end

			local tweenInfo = TweenInfo.new(0.5)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					TweenService:Create(descendant, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end
		end,
		OhNo = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuki.Scream, humanoidRootPart, game.SoundService.Voice)
			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Hakari.EnergySurge.Teleport, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 10 do
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

			if localPlayer.Character == instance then
				task.spawn(function()
					local currentCamera = workspace.CurrentCamera
					local v5 = tick() + 0.5

					repeat
						humanoidRootPart.Velocity = currentCamera.CFrame.LookVector * 100
						task.wait()
					until v5 < tick()
				end)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		OhNo2 = function(instance, instance2, instance3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1), 2)
			local playSound = v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart2, game.SoundService.Effect)
			playSound.Volume = 5
			v3:PlaySound(sounds.Yuki.Grab, humanoidRootPart2, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart2.Position).Magnitude < 200 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local v5 = localPlayer.Character == instance or localPlayer.Character == instance2
			local v6 = v3:PlaySound(sounds.Yuki.GrabOST, humanoidRootPart, game.SoundService.Music)
			local clone

			if v5 then
				clone = utils.Hakari.IdleDeath.AudioVis:Clone()
				clone.Beat.ImageColor3 = Color3.new(0, 0, 0)
				clone.Beat.ImageTransparency = 1
				clone.Parent = localPlayer.PlayerGui
			end

			local clone2

			if localPlayer.Character == instance2 then
				clone2 = utils.Yuki.Buildup:Clone()
				clone2.Parent = instance.Torso
				TweenService:Create(clone2.BG, TweenInfo.new(0.2), {
					BackgroundTransparency = 0.5
				}):Play()
				TweenService:Create(clone2.Bar.Bar, TweenInfo.new(0.2), {
					BackgroundTransparency = 0
				}):Play()
			end

			while true do
				local v7 = (instance:GetAttribute("Charge") or 0) / 100

				if clone then
					clone.Beat.ImageTransparency = 1 - v7
					clone.Beat.Size = UDim2.new(2, 0, 2, 0):Lerp(UDim2.new(1, 0, 1, 0), v7)
				end

				if clone2 then
					clone2.Bar.Size = UDim2.new(1, 0, v7, 0)
					clone2.Bar.Bar.Size = UDim2.new(1, 0, 1 / v7, 0)
				end

				if v5 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightLoop)
				end

				task.wait()

				if instance.Parent and instance2.Parent and instance3:IsDescendantOf(workspace.Characters) then
					continue
				end

				if (instance:GetAttribute("Charge") or 0) >= 100 then
					Debris:AddItem(v6, 6)
					TweenService:Create(v6, TweenInfo.new(6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
						Volume = 0
					}):Play()
				else
					Debris:AddItem(v6, 1)
					TweenService:Create(v6, TweenInfo.new(1), {
						Volume = 0
					}):Play()
				end

				if clone then
					TweenService:Create(clone.Beat, TweenInfo.new(0.5), {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(clone, 0.5)
				end

				if clone2 then
					TweenService:Create(clone2.BG, TweenInfo.new(0.4), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(clone2.Bar.Bar, TweenInfo.new(0.4), {
						BackgroundTransparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.4)
				end

				break
			end
		end,
		Buildup = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				task.spawn(function()
					local clone = utils.Yuki.Buildup:Clone()
					clone.Parent = instance.Torso
					TweenService:Create(clone.BG, TweenInfo.new(0.2), {
						BackgroundTransparency = 0.5
					}):Play()
					TweenService:Create(clone.Bar.Bar, TweenInfo.new(0.2), {
						BackgroundTransparency = 0
					}):Play()

					repeat
						local v5 = (instance:GetAttribute("Charge") or 0) / 100
						clone.Bar.Size = UDim2.new(1, 0, v5, 0)
						clone.Bar.Bar.Size = UDim2.new(1, 0, 1 / v5, 0)
						task.wait()
					until not (instance.Parent and instance:GetAttribute("Charging"))

					TweenService:Create(clone.BG, TweenInfo.new(0.4), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(clone.Bar.Bar, TweenInfo.new(0.4), {
						BackgroundTransparency = 1
					}):Play()
					Debris:AddItem(clone, 0.4)
				end)
			end

			local clone

			if p then
				clone = utils.Yuki.Warp2:Clone()
				clone.Weld.Part0 = humanoidRootPart
				clone.Parent = workspace.Effects
				TweenService:Create(clone.Start.PointLight, TweenInfo.new(0.5), {
					Brightness = 15
				}):Play()
				local highlight = Instance.new("Highlight", clone)
				highlight.FillColor = Color3.fromRGB(103, 88, 135)
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
					Size = createVector(9, 9, 9)
				}):Play()
			end

			local clone2 = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone2:ScaleTo(instance:GetScale())
			end

			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.5)
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			for _, parent in clone2:GetChildren() do
				local child = instance:FindFirstChild(parent.Name)

				if child then
					local weld = Instance.new("Weld", parent)
					weld.Part0 = parent
					weld.Part1 = child
				end

				parent.Size *= 2
				parent.Transparency = 0
				parent.Color = Color3.fromRGB(170, 85, 255)
				TweenService:Create(parent, tweenInfo, {
					Transparency = 1,
					Size = parent.Size / 2
				}):Play()
			end

			v3:PlaySound(sounds.Yuki.Charge.Start, humanoidRootPart, game.SoundService.Effect)

			while true do
				if clone then
					local timeScale = (instance:GetAttribute("Charge") or 0) / 100
					local magnitude = (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude
					clone.Highlight.DepthMode = magnitude > 150 and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
					clone.Transparency = 1 + 3 * timeScale
					clone.Weld.C1 = CFrame.Angles(
						math.rad((math.random(0, 360))),
						math.rad((math.random(0, 360))),
						(math.rad((math.random(0, 360))))
					)

					if timeScale > 0.66 then
						local v6 = math.clamp((timeScale - 0.66) / 0.3, 0, 1)
						clone.Highlight.FillColor = Color3.fromRGB(103, 88, 135):Lerp(Color3.new(0, 0, 0), v6)

						for _, child in clone.Past:GetChildren() do
							child.Enabled = true
							child.TimeScale = timeScale
						end
					elseif timeScale > 0.33 then
						local v6 = math.clamp((timeScale - 0.33) / 0.66, 0, 1)
						clone.Start.Spark.Enabled = true
						clone.Past.Absorb.Enabled = true
						clone.Past.Absorb.TimeScale = math.lerp(0, 1, v6)
						clone.Highlight.FillTransparency = math.lerp(1, -5, v6)
					end
				end

				task.wait()

				if instance.Parent and instance:GetAttribute("Charging") then
					continue
				end

				if (instance:GetAttribute("Charge") or 0) >= 100 then
					v3:PlaySound(sounds.Yuki.Charge.Finish, humanoidRootPart, game.SoundService.Effect)
				else
					v3:PlaySound(sounds.Yuki.Charge.End, humanoidRootPart, game.SoundService.Effect)
				end

				if not clone then
					break
				end

				Debris:AddItem(clone, 1.5)

				for _, light in clone.Start:GetChildren() do
					if not light:IsA("PointLight") then
						light.Enabled = false
					end
				end

				for _, child in clone.Past:GetChildren() do
					child.Enabled = false
				end

				TweenService:Create(clone.Start.PointLight, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone:FindFirstChildWhichIsA("Highlight"), 0.2)
				break
			end
		end,
		MeterVis = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuki.Meter:Clone()
			clone.Parent = instance.Torso
			local clones = {}

			for i = 1, instance2:GetAttribute("Max") do
				local clone2 = utils.Yuki.MeterBar:Clone()
				clone2.Name = i
				clone2.Parent = clone
				TweenService:Create(clone2, TweenInfo.new(0.2), {
					BackgroundTransparency = 0.5
				}):Play()
				clones[i] = clone2
			end

			local clone2 = utils.Yuki.Buildup:Clone()
			clone2.Parent = instance.Torso
			TweenService:Create(clone2.BG, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.5
			}):Play()
			TweenService:Create(clone2.Bar.Bar, TweenInfo.new(0.2), {
				BackgroundTransparency = 0
			}):Play()
			clone2.Cost.Visible = true
			clone2.Cost.Size = UDim2.new(1, 0, instance2:GetAttribute("Cost") / 100, 0)
			TweenService:Create(clone2.Cost, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.5
			}):Play()
			instance2:GetPropertyChangedSignal("Value"):Connect(function()
				if instance2.Value == instance2:GetAttribute("Max") then
					v3:PlaySound(sounds.Yuki.Charge.ChargeFail, humanoidRootPart, game.SoundService.Effect)
				else
					v3:PlaySound(sounds.Yuki.Charge.Charge, humanoidRootPart, game.SoundService.Effect)
				end
			end)

			while true do
				for k, v5 in clones do
					if k <= instance2.Value then
						v5.Bar.Visible = true
					else
						v5.Bar.Visible = false
					end
				end

				local v5 = (instance:GetAttribute("Charge") or 0) / 100
				clone2.Bar.Size = UDim2.new(1, 0, v5, 0)
				clone2.Bar.Bar.Size = UDim2.new(1, 0, 1 / v5, 0)
				task.wait()

				if instance.Parent and instance2.Parent then
					continue
				end

				for _, v6 in clones do
					TweenService:Create(v6, TweenInfo.new(0.2), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(v6.Bar, TweenInfo.new(0.2), {
						BackgroundTransparency = 1
					}):Play()
				end

				Debris:AddItem(clone, 0.2)
				TweenService:Create(clone2.BG, TweenInfo.new(0.4), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone2.Bar.Bar, TweenInfo.new(0.4), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone2.Cost, TweenInfo.new(0.4), {
					BackgroundTransparency = 1
				}):Play()
				Debris:AddItem(clone2, 0.4)
				break
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
	local random = Random.new()
	v.Debree:Connect(function(items, position)
		if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 200 or not _G.Settings.DesPHY then
			return
		end

		for _, item in items do
			local part = Instance.new("Part")
			part.Massless = true
			part.CollisionGroup = "Effects"
			part.Position = item[1]
			part.Orientation = item[2]
			part.Color = item[3]
			part.Material = item[4]
			part.Size = item[5]
			part.Velocity = random:NextUnitVector() * random:NextInteger(60, 100)
			part.RotVelocity = Vector3.new(math.random(-40, 40), math.random(-40, 40), math.random(-40, 40))
			part.Parent = workspace.Effects.CamIgnore
			Debris:AddItem(part, 0.8)

			if math.random(1, 10) == 1 then
				v3:DebreeSound(part)
			end

			task.delay(0.2, function()
				local attachment = Instance.new("Attachment", part)
				attachment.Name = "BlueGrab"
				local alignPosition = Instance.new("AlignPosition", attachment)
				alignPosition.Responsiveness = 0
				TweenService:Create(alignPosition, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Responsiveness = 100
				}):Play()
				alignPosition.Attachment0 = attachment
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.Position = position
			end)
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("YukiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller