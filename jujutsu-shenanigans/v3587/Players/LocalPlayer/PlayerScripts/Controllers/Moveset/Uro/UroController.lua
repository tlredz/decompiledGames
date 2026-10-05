local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
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
	Name = "UroController"
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
		Swing2 = function(data, p, p2, p3)
			local function tweenTrail(p4, duration)
				local color3Value = Instance.new("Color3Value")
				color3Value.Value = p4.Color.Keypoints[1].Value
				color3Value.Changed:Connect(function(p5)
					p4.Color = ColorSequence.new(p5)
				end)
				local tween = TweenService:Create(color3Value, TweenInfo.new(duration), {
					Value = Color3.fromRGB(255, 85, 127)
				})
				tween.Completed:Once(function()
					color3Value:Destroy()
				end)
				tween:Play()
			end

			if p3 then
				if p2 == "Down" then
					v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 133, 172), 0.4)
					return
				end

				if p == 1 then
					v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 133, 172), 0.3)
					return
				end

				if p == 2 or p2 == "Up" then
					v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 133, 172), 0.3)
					return
				end

				if p == 3 then
					v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 133, 172), 0.3)
					return
				end

				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 133, 172), 0.3)
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 133, 172), 0.3)
			elseif p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 133, 172), 0.4)
			elseif p == 1 or p == 3 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 133, 172), 0.3)
			elseif p == 2 or p == 4 or p2 == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 133, 172), 0.3)
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
		Chat = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.spawn(function()
				local torso = instance:FindFirstChild("Torso")

				if not torso then
					return
				end

				local clone = utils.Uro.Dialogue:Clone()
				clone.Parent = torso
				v3:PlaySound(sounds.Uro.Ultimate.Voice, torso, game.SoundService.Effect)
				local uDim = UDim2.new(0.4, 0, 0.6, 0)
				clone.Chat1.Position = uDim - UDim2.new(0, 0, 0.15, 0)
				clone.Chat1.Sub.Text = "ARE YOU THAT AFRAID?"
				TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = uDim
				}):Play()
				TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
					TextTransparency = 0
				}):Play()
				task.wait(1.5)
				Debris:AddItem(clone, 0.6)

				for _, guiObject in clone:GetDescendants() do
					if guiObject:IsA("Frame") then
						TweenService:Create(
							guiObject,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
								BackgroundTransparency = 1
							}
						):Play()
					elseif guiObject:IsA("TextLabel") then
						TweenService:Create(
							guiObject,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								TextTransparency = 1
							}
						):Play()
					end
				end
			end)
			local model = Instance.new("Model", workspace.Effects)
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = model
			Debris:AddItem(model, 0.65)
			local v5 = humanoidRootPart.Position - humanoidRootPart.CFrame.LookVector * 12 - humanoidRootPart.CFrame.RightVector * 5
			local clone = utils.Uro.AirDistort2:Clone()
			clone.Transparency = 1
			TweenService:Create(clone, TweenInfo.new(0.45), {
				Transparency = 10
			}):Play()
			clone.Parent = model
			local v6 = humanoidRootPart.Position - humanoidRootPart.CFrame.LookVector * 12 + humanoidRootPart.CFrame.RightVector * 5
			local clone2 = utils.Uro.AirDistort2:Clone()
			clone2.Transparency = 1
			TweenService:Create(clone2, TweenInfo.new(0.45), {
				Transparency = 10
			}):Play()
			clone2.Parent = model
			v3:PlaySound(sounds.Uro.Ultimate.Grab, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Uro.Ultimate.Voice, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
				task.delay(0.65, function()
					shakeSustain:StartFadeOut(0)
				end)
			end

			local now = tick()
			local v7 = 12

			while true do
				local position = (instance["Left Arm"].CFrame * CFrame.new(0, -1, 0)).Position
				local position2 = (instance["Right Arm"].CFrame * CFrame.new(0, -1, 0)).Position
				local magnitude = (position - v5).Magnitude
				local magnitude2 = (position2 - v6).Magnitude
				local cframe = CFrame.lookAt(v5, position)
				local cframe2 = CFrame.lookAt(v6, position2)
				clone.CFrame = cframe + cframe.LookVector * (magnitude / 2)
				clone.Size = Vector3.new(v7, v7, magnitude)
				clone2.CFrame = cframe2 + cframe2.LookVector * (magnitude2 / 2)
				clone2.Size = Vector3.new(v7, v7, magnitude2)
				local v8 = task.wait()
				local now2 = tick()

				if now + 0.2 < now2 then
					v7 = math.lerp(v7, 3, v8 * 2.2)
				end

				if model.Parent and instance.Parent then
					continue
				end

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end

				local v9 = humanoidRootPart.CFrame - humanoidRootPart.CFrame.LookVector * 6
				v3:PlaySound(sounds.Uro.Ultimate.Break, humanoidRootPart, game.SoundService.Effect)

				if not _G.Settings.DesPHY or (workspace.CurrentCamera.CFrame.Position - v9.Position).Magnitude > 200 then
					break
				end

				local model2 = Instance.new("Model", workspace.Effects)
				local highlight2 = Instance.new("Highlight")
				highlight2.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight2.FillTransparency = 1
				highlight2.OutlineTransparency = 1
				highlight2.Parent = model2
				Debris:AddItem(model2, 1)
				Random.new()
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 20 do
					local clone3 = utils.Gojo.Shard:Clone()
					local lookVector = (v9 * CFrame.Angles(
						math.rad((math.random(-60, 60))),
						math.rad((math.random(-60, 60))),
						0
					)).LookVector
					clone3.Size = Vector3.new(0.2, math.random(10, 80) / 10, math.random(10, 80) / 10)
					clone3.CFrame = v9 * CFrame.new(math.random(-10, 10), math.random(-5, 10), 0)
					clone3.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone3.CanCollide = true
					clone3.CollisionGroup = "Effects"
					clone3.Parent = model2
					clone3.Transparency = 5
					clone3.Material = Enum.Material.Glass
					clone3.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone3.Velocity = lookVector * math.random(30, 60) + humanoidRootPart.Velocity
					TweenService:Create(clone3, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone3, 1)
				end

				break
			end
		end,
		AirDistort = function(instance, instance2, p, p2, duration)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local model = Instance.new("Model", workspace.Effects)
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(170, 255, 255)
			highlight.FillTransparency = 0.9
			highlight.OutlineTransparency = 0.8
			highlight.Parent = model
			Debris:AddItem(model, p2 + duration)
			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local v5 = {}
			task.spawn(function()
				repeat
					for k, v6 in v5 do
						if k:IsDescendantOf(workspace.Effects) then
							local position = v6[1].Position
							local position2 = v6[2].Position
							local magnitude = (position - position2).Magnitude
							local v7 = (tick() - v6[3]) / duration
							local v8 = p - v7 * p
							local v9 = magnitude * 1.35 - magnitude
							k.Size = Vector3.new(v8, v8, magnitude + (v9 - v9 * v7))
							local cframe = CFrame.lookAt(position, position2)
							k.CFrame = cframe + cframe.LookVector * (magnitude / 2)
						else
							v5[k] = nil
						end
					end

					task.wait()
				until not model.Parent
			end)
			local v6 = duration / 0.5 * 5
			local now = tick()
			local position = instance2.Position
			local v7 = {}

			repeat
				local v8 = instance2.Position - position + humanoidRootPart.Velocity / 50
				position = instance2.Position
				local folder = Instance.new("Folder", model)
				Debris:AddItem(folder, duration)
				local part = Instance.new("Part")
				part.Transparency = 1
				part.Anchored = true
				part.CanCollide = false
				part.Name = "Attachment"
				part.CFrame = instance2.CFrame * CFrame.new(0, -2, 0)
				part.Parent = folder
				TweenService:Create(part, tweenInfo, {
					CFrame = part.CFrame + v8 * v6
				}):Play()
				table.insert(v7, folder)

				if #v7 > 1 then
					local v9 = v7[#v7 - 1]
					local clone = utils.Uro.AirDistort2:Clone()
					TweenService:Create(clone, tweenInfo, {
						Transparency = 1
					}):Play()
					clone.Parent = folder
					v5[clone] = { v9.Attachment, part, tick() }
					local position2 = v9.Attachment.Position
					local position3 = part.Position
					local magnitude = (position2 - position3).Magnitude
					clone.Size = Vector3.new(p, p, magnitude)
					local cframe = CFrame.lookAt(position2, position3)
					clone.CFrame = cframe + cframe.LookVector * (magnitude / 2)
				end

				task.wait(0.02)
				local now2 = tick()
			until now + p2 < now2 or not instance2:IsDescendantOf(workspace.Characters)
		end,
		Chat2 = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Uro.Dialogue:Clone()
			clone.Parent = torso
			v3:PlaySound(sounds.Uro.Ultimate.Voice1, torso, game.SoundService.Effect)
			v3:PlaySound(sounds.Uro.Ultimate.Fly, torso, game.SoundService.Effect)
			local position = clone.Chat1.Position
			clone.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.5)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()
				end
			end

			task.wait(0.5)
			v3:PlaySound(sounds.Uro.Ultimate.Voice2, torso, game.SoundService.Effect)
		end,
		UhOh = function()
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

			if _G.Settings.Flash == true then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
				colorCorrectionEffect.Contrast = -3
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Contrast = 0
					}
				):Play()
				Debris:AddItem(colorCorrectionEffect, 1)
			end
		end,
		TIB = function(p)
			local clone = utils.Uro.IceBreaker:Clone()
			clone:ScaleTo(8)
			clone.SmallShard.Anchored = true
			clone.SmallShard.CFrame = p - createVector(0, 3.5, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)
			local highlight = Instance.new("Highlight", clone)
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(170, 255, 255)
			highlight.FillTransparency = 0.9
			highlight.OutlineTransparency = 0.8
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded

			if (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 200 then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				task.delay(1.5, function()
					shakeSustain:StartFadeOut(0.3)
				end)
			end

			v3:PlaySound(sounds.Uro.ThinIceBreaker.Impact, clone.SmallShard, game.SoundService.Effect)
			local size = clone.SmallShard.Size * 1.1
			clone.SmallShard.Size = clone.SmallShard.Size * 0.3
			TweenService:Create(
				clone.SmallShard,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = size
				}
			):Play()
			task.wait(0.5)
			v3:PlaySound(sounds.Uro.ThinIceBreaker.Crack, clone.SmallShard, game.SoundService.Effect)
			TweenService:Create(
				clone.BigShard,
				TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = clone.BigShard.Size * 1.2
				}
			):Play()
			clone.SmallShard.Transparency = 7
			clone.BigShard.Material = Enum.Material.Glass
			clone.BigShard.Transparency = 5

			if (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			task.wait(0.5)
			v3:PlaySound(sounds.Uro.ThinIceBreaker.Explode, clone.SmallShard, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)

				if _G.Settings.Flash == true then
					task.spawn(function()
						local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone2.TintColor = Color3.new(1, 1, 1)
						clone2.Parent = game.Lighting
						task.wait(0.04)
						clone2.Brightness = 200
						clone2.Contrast = -1000
						task.wait(0.04)
						clone2:Destroy()
					end)
				end
			end

			local cFrame = clone.SmallShard.CFrame
			clone.SmallShard.Material = Enum.Material.Plastic
			clone.BigShard.Material = Enum.Material.Plastic

			for _, child in utils.Misc.M.Awk.mokultMeh["2"]:GetChildren() do
				child:PivotTo(cFrame)
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(cFrame)
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 200 then
					return
				end

				Random.new()
				local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 25 do
					local clone2 = utils.Gojo.Shard:Clone()
					local lookVector = (cFrame * CFrame.Angles(
						math.rad((math.random(-60, 60))),
						math.rad((math.random(-60, 60))),
						0
					)).LookVector
					clone2.Size = Vector3.new(0.2, math.random(10, 80) / 10, math.random(10, 80) / 10) * 8
					clone2.CFrame = cFrame * CFrame.new(math.random(-10, 10), math.random(-5, 10), 0)
					clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effects"
					clone2.Parent = clone
					clone2.Transparency = 5
					clone2.Material = Enum.Material.Glass
					clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone2.Velocity = lookVector * math.random(30, 60)
					TweenService:Create(clone2, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone2, 2)
				end
			end
		end,
		SkyGrab = function(parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Uro.GlassPlane:Clone()
			v3:PlaySound(sounds.Uro.Ultimate.Grab2, humanoidRootPart, game.SoundService.Effect)

			for _, part in clone:GetDescendants() do
				if not (part:IsA("BasePart") and part.Name ~= "GlassMain") then
					continue
				end

				part.Transparency = 1
				TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Transparency = 5
				}):Play()
			end

			Debris:AddItem(clone, 1.375)
			Debris:AddItem(clone.Weld, 1.375)
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.Part1 = clone.GlassMain
			clone.Weld.Parent = parent
			clone.AnimationController.Animator:LoadAnimation(animations.Uro.ThinIceBreaker2Sky):Play(0)
			local highlight = Instance.new("Highlight", clone)
			highlight.Enabled = true
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.OutlineColor = Color3.fromRGB(170, 255, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			TweenService:Create(highlight, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				OutlineTransparency = 0.8
			}):Play()
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 1.5
			numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				clone:ScaleTo(numberValue.Value)
			end)
			task.wait(0.5)
			TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Value = 0.6
			}):Play()
		end,
		Flight = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Locust.Flight, humanoidRootPart, game.SoundService.Effect)

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

			if localPlayer.Character == instance then
				local currentCamera = workspace.CurrentCamera
				local v5 = currentCamera.CFrame.LookVector:Dot(createVector(0, 1, 0)) < -0.8 and 300 or 100
				humanoidRootPart.Velocity = currentCamera.CFrame.LookVector * v5
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

		local v5 = nil

		while true do
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, -1, -3), 10)

			for _, v7 in sphereHitbox do
				local info = v7:FindFirstChild("Info")

				if not info then
					continue
				end

				local knockback = info:FindFirstChild("Knockback")

				if not (not knockback or knockback.Value ~= false) then
					continue
				end

				v5 = sphereHitbox
				break
			end

			if v5 then
				local numberValue = instance:FindFirstChildWhichIsA("NumberValue")

				if numberValue then
					TweenService:Create(numberValue, TweenInfo.new(0.1), {
						Value = 0
					}):Play()
				end
			else
				task.wait(0.05)

				if instance.Parent then
					continue
				end
			end

			object:FireServer(v5, humanoidRootPart.CFrame)
			break
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("UroService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller