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
local controller = Knit.CreateController({
	Name = "TwofoldKickController"
})

function controller.KnitStart(_)
	local v3 = {
		Swing1 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, -2) * CFrame.Angles(-0.2617993877991494, 0, 0)
			clone.Transparency = 0.5
			clone.Parent = workspace.Effects
			clone.Swing2.Swing1:Emit(10)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				CFrame = clone.CFrame + clone.CFrame.UpVector * 3,
				Size = createVector(0, 10, 0)
			}):Play()
			Debris:AddItem(clone, 0.4)
			v2:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.wait(0.15)
			v2:PlaySound(sounds.Misc.Swing.Fist2, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Rush.RushBreak, humanoidRootPart, game.SoundService.Effect)
		end,
		FinalHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.DivergentFist.DivergentHit, humanoidRootPart, game.SoundService.Effect)
		end,
		Domain = function(self)
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			local v4 = v2:PlaySound(sounds.Gojo.InfiniteVoid.ShortOpen, workspace, game.SoundService.Effect)
			TweenService:Create(v4, TweenInfo.new(4, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Volume = 0
			}):Play()
			Debris:AddItem(v4, 4)
			local clone = utils.Gojo.InfiniteVoid.ShortVoid:Clone()
			clone.BG.CurrentCamera = workspace.CurrentCamera
			clone.Players.CurrentCamera = workspace.CurrentCamera
			clone.Stuff.CurrentCamera = workspace.CurrentCamera
			local stuff = clone.Stuff.Stuff
			clone.Parent = localPlayer.PlayerGui
			Debris:AddItem(clone, 3)
			task.spawn(function()
				local numberValue = Instance.new("NumberValue", clone)
				numberValue.Value = 7
				local tween = TweenService:Create(
					numberValue,
					TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
					{
						Value = 250
					}
				)
				tween:Play()

				repeat
					local cFrame = workspace.CurrentCamera.CFrame
					clone.BG.Create.Size = createVector(1, 1, 1) * numberValue.Value
					clone.BG.Create.CFrame = cFrame - cFrame.Position + humanoidRootPart.Position
					task.wait()
				until tween.PlaybackState == Enum.PlaybackState.Completed or not clone.Parent

				clone.BG.Skybox:ScaleTo(400)
				clone.BG.Create.Transparency = 1
				local lookVector = workspace.CurrentCamera.CFrame.LookVector
				local unit = Vector3.new(lookVector.X, 0, lookVector.Z).Unit

				if unit ~= unit then
					unit = workspace.CurrentCamera.CFrame.LookVector
				end

				local cframe = CFrame.Angles(0, 0, 0)
				local cframe2 = CFrame.Angles(0, 0, 0)
				TweenService:Create(clone.BG, TweenInfo.new(0.7, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					ImageColor3 = Color3.new(1, 1, 1)
				}):Play()
				TweenService:Create(
					clone.Players,
					TweenInfo.new(0.7, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Ambient = Color3.fromRGB(87, 108, 127),
						LightColor = Color3.fromRGB(170, 255, 255)
					}
				):Play()

				while true do
					local v5 = RunService.RenderStepped:Wait()
					cframe *= CFrame.Angles(math.rad(v5 * 7), math.rad(v5 * 5), (math.rad(v5 * 2)))
					cframe2 *= CFrame.Angles(0, 0, (math.rad(v5 * 100)))

					if not clone.Parent then
						break
					end

					local cFrame = workspace.CurrentCamera.CFrame
					local v6 = cFrame - cFrame.Position + humanoidRootPart.Position
					stuff:PivotTo(CFrame.lookAlong(v6.Position, unit) * CFrame.new(0, 0, -200))
					clone.BG.Skybox:PivotTo(CFrame.new(v6.Position) * cframe)

					if cFrame.LookVector:Dot(CFrame.lookAt(cFrame.Position, humanoidRootPart.Position).LookVector) < 0 then
						clone.BG.Close:PivotTo((cFrame - cFrame.Position + localPlayer.Character.Head.Position) * cframe2)
					else
						clone.BG.Close:PivotTo((cFrame - cFrame.Position + self.Head.Position) * cframe2)
					end

					if not clone.Parent then
						break
					end
				end
			end)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			for _, child in stuff.Model:GetChildren() do
				local size = child.Size
				child.Size = createVector(0, 0, 0)
				local v5 = child
				task.delay(0.55, function()
					TweenService:Create(v5, tweenInfo, {
						Size = size * 2.5
					}):Play()
				end)
			end

			stuff.Splatter.Size = createVector(0, 0, 0)
			task.delay(0.1, function()
				local tweenInfo2 = TweenInfo.new(0.1)
				TweenService:Create(stuff.Splatter, tweenInfo2, {
					Size = createVector(250, 250, 0.001)
				}):Play()
				task.wait(0.1)
				local tweenInfo3 = TweenInfo.new(1.65, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
				TweenService:Create(stuff.Splatter, tweenInfo3, {
					Size = createVector(300, 300, 0.001)
				}):Play()
				task.wait(0.65)
				stuff.Parent = clone.BG
			end)
			local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

			for _, child in clone.BG.Close:GetChildren() do
				if child.Name ~= "Core" then
					TweenService:Create(child, tweenInfo2, {
						Size = createVector(200, 200, 1)
					}):Play()
				end
			end

			for _, child in workspace.Characters:GetChildren() do
				if child == self then
					v2:WorldModelChar(self, clone.Players)
				end

				local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 and (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude < 37.5 then
					v2:WorldModelChar(child, clone.Players)
				end
			end

			task.wait(0.3)
			clone.Fade.Visible = true
			task.wait(0.7)
			TweenService:Create(clone.Players, TweenInfo.new(1.2), {
				Ambient = Color3.new(1, 1, 1),
				LightColor = Color3.new(1, 1, 1)
			}):Play()
			TweenService:Create(clone.Fade, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			}):Play()
			task.wait(1)
			TweenService:Create(clone.Players, TweenInfo.new(0.2), {
				ImageTransparency = 1
			}):Play()
		end,
		DomainWind = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Gojo.InfiniteVoid.ShortDomain, humanoidRootPart, game.SoundService.Voice)
			v2:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v2:Domain(instance, function(p, instance2)
						instance2.Humanoid:LoadAnimation(animations.Gojo.DomainWarn2):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://6938945464"
						p.Panel.ImageLabel.Size = UDim2.new(0.8, 0, 0.4, 0)
						p.Panel.Camera.CFrame *= CFrame.new(0, 0.5, 0)
						p.Panel.Camera.FieldOfView = 30
						TweenService:Create(p.Panel.ImageLabel, TweenInfo.new(1.5), {
							ImageColor3 = Color3.new(0.1, 0.1, 0.1)
						}):Play()
						TweenService:Create(p.Panel.Viewport, TweenInfo.new(1.5), {
							Ambient = Color3.fromRGB(87, 108, 127),
							LightColor = Color3.fromRGB(170, 255, 255)
						}):Play()
					end)
				end
			end
		end,
		Music = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.InfiniteVoid.FlashDomain:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			clone.Surround:Emit(100)
			task.delay(0.8, function()
				clone.Space:Emit(60)
			end)
			task.delay(1.5, function()
				v2:PlaySound(sounds.Gojo.InfiniteVoid.Startup, humanoidRootPart, game.SoundService.Effect)
				task.wait(1)
				v2:PlaySound(sounds.Gojo.InfiniteVoid.ShortDomain2, humanoidRootPart, game.SoundService.Voice)
			end)
			local v4 = v2:PlaySound(sounds.Gojo.InfiniteVoid.Music, humanoidRootPart, game.SoundService.Music)
			local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect", v4)
			pitchShiftSoundEffect.Octave = 5
			v4.PlaybackSpeed = 0.2
			local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(v4, tweenInfo, {
				PlaybackSpeed = 1.25
			}):Play()
			TweenService:Create(pitchShiftSoundEffect, tweenInfo, {
				Octave = 0.8
			}):Play()
		end,
		Boost = function(instance, instance2, fieldOfView)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)

				if fieldOfView == 90 then
					game.Lighting.ExposureCompensation = 1
					TweenService:Create(game.Lighting, TweenInfo.new(0.2), {
						ExposureCompensation = 0
					}):Play()
				end

				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = fieldOfView
					}
				):Play()
				task.spawn(function()
					repeat
						task.wait()
					until not instance2:IsDescendantOf(workspace.Characters)

					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					shakeSustain:StartFadeOut(1)
				end)
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

			if fieldOfView == 90 then
				v2:PlaySound(sounds.Gojo.InfiniteVoid.Boost1, humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Gojo.InfiniteVoid.Boost2, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Trail = function(instance, p, _)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = replicatedStorage.Utils.Gojo.HandTrail:Clone()
			clone.Parent = workspace.Effects
			clone.Trail.FaceCamera = true
			clone.Weld.Part0 = instance["Right Leg"]
			Debris:AddItem(clone, 10)
			local clone2 = replicatedStorage.Utils.Gojo.HandTrail:Clone()
			clone2.Parent = workspace.Effects
			clone2.Trail.Color = ColorSequence.new(instance["Left Arm"].Color)
			clone2.Weld.Part0 = instance["Left Arm"]
			Debris:AddItem(clone2, 10)
			local clone3 = replicatedStorage.Utils.Gojo.HandTrail:Clone()
			clone3.Parent = workspace.Effects
			clone3.Trail.Color = ColorSequence.new(instance["Right Arm"].Color)
			clone3.Weld.C1 *= CFrame.Angles(0, 3.141592653589793, 0)
			clone3.Weld.Part0 = instance["Right Arm"]
			Debris:AddItem(clone3, 10)
			local clone4 = replicatedStorage.Utils.Gojo.HandTrail:Clone()
			clone4.Parent = workspace.Effects
			clone4.Trail.FaceCamera = true
			clone4.Weld.C1 *= CFrame.Angles(0, 3.141592653589793, 0)
			clone4.Weld.Part0 = instance["Right Leg"]
			Debris:AddItem(clone4, 10)

			repeat
				task.wait()
			until not (instance.Parent and p.Parent)

			clone.Trail.Enabled = false
			Debris:AddItem(clone, 0.5)
			clone2.Trail.Enabled = false
			Debris:AddItem(clone2, 0.5)
			clone3.Trail.Enabled = false
			Debris:AddItem(clone3, 0.5)
			clone4.Trail.Enabled = false
			Debris:AddItem(clone4, 0.5)
		end,
		Smear = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = replicatedStorage.Utils.Gojo.InfiniteVoid.Speed:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			local clone2 = replicatedStorage.Utils.Itadori.EyeTrails:Clone()
			clone2.Trail1.Trail.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
			clone2.Trail2.Trail.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
			clone2.Eye1.Glow:Destroy()
			clone2.Eye2.Glow:Destroy()
			clone2.Weld.Part0 = instance.Head
			clone2.Parent = workspace.Effects
			clone2.Glow:Emit(1)
			Debris:AddItem(clone2, 3)
			task.delay(2.5, function()
				clone2.Trail1.Trail.Enabled = false
				clone2.Trail2.Trail.Enabled = false
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap)
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 120
					}
				):Play()
				task.spawn(function()
					repeat
						task.wait()
					until not (instance.Parent and p.Parent)

					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					shakeSustain:StartFadeOut(0.2)
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
					game.Lighting.ExposureCompensation = 2
					TweenService:Create(game.Lighting, TweenInfo.new(0.4), {
						ExposureCompensation = 0
					}):Play()
				end)
			end

			local now = tick()
			local track = instance.Humanoid:LoadAnimation(animations.Mahito.WideStrike)
			track:Play(0, 5, 1)
			track.TimePosition = 7
			track.Priority = Enum.AnimationPriority.Action4
			v2:PlaySound(sounds.Gojo.InfiniteVoid.Barrage, humanoidRootPart, game.SoundService.Effect)

			while true do
				clone.CFrame = humanoidRootPart.CFrame
				local now2 = tick()

				if now + 0.05 < now2 then
					v2:DustBreak(humanoidRootPart.Position, createVector(0, 1, 0), 20, 1, 0.5, 1, 4)
					now = tick()
				end

				RunService.RenderStepped:Wait()

				if instance.Parent and p.Parent then
					continue
				end

				track:Stop(0)

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end

				local clone3 = utils.Misc.M.WingFly:Clone()
				clone3:PivotTo(clone.CFrame)
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, 3)
				clone3.WHAT:Destroy()
				TweenService:Create(
					clone3.Mesh.Start,
					TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone3.Mesh.End.Size,
						Transparency = 1,
						CFrame = clone3.Mesh.End.CFrame
					}
				):Play()
				TweenService:Create(
					clone3.Mesh2.Start,
					TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone3.Mesh2.End.Size,
						Transparency = 1,
						CFrame = clone3.Mesh2.End.CFrame
					}
				):Play()
				TweenService:Create(
					clone3.Mesh3.Start,
					TweenInfo.new(2.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone3.Mesh3.End.Size,
						Transparency = 1,
						CFrame = clone3.Mesh3.End.CFrame
					}
				):Play()
				clone3.Mesh.End:Destroy()
				clone3.Mesh2.End:Destroy()
				clone3.Mesh3.End:Destroy()
				break
			end
		end,
		SpeedHit = function(instance, instance2, _)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Gojo.InfiniteVoid.Hits["Hit" .. math.random(1, 3)],
				humanoidRootPart,
				game.SoundService.Effect
			)
			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(
				math.random(0, 3.141592653589793),
				math.random(0, 3.141592653589793),
				math.random(0, 3.141592653589793)
			))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
				Size = createVector(0, 25, 0),
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + clone.Shock2.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shockwave, TweenInfo.new(0.2), {
				Size = createVector(0, 30, 0),
				Transparency = 1,
				CFrame = clone.Shockwave.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
		end,
		Slow = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if not p then
				v2:PlaySound(sounds.Gojo.InfiniteVoid.ShortDomain3, humanoidRootPart, game.SoundService.Effect)
			end

			if p2 then
				v2:PlaySound(sounds.Nanami.Sharpen.Basic, humanoidRootPart, game.SoundService.Effect)
			end

			v2:PlaySound(sounds.Gojo.InfiniteVoid.Slowdown, humanoidRootPart, game.SoundService.Effect)
			v2:DustTrail(instance, 1)

			for _ = 1, 10 do
				v2:DustBreak(humanoidRootPart.Position, createVector(0, 1, 0), 3, 2, 0.4, 1, 4)
				task.wait(0.05)
			end
		end,
		SpeedFinish = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Bleed(p)
		end,
		Cut = function(data, p)
			local humanoidRootPart = data.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local gojoMask = data.SetAssets:FindFirstChild("GojoMask")

			if gojoMask then
				local attachment = Instance.new("Attachment", gojoMask)
				attachment.Position = createVector(0, 0, 0.5)
				local clone_2 = utils.Gojo.InfiniteVoid.Glow:Clone()
				clone_2.Parent = attachment
				local clone_3 = utils.Gojo.InfiniteVoid.Speed.PointLight:Clone()
				clone_3.Parent = attachment
				gojoMask.Eye1.Glow.ZOffset = 0.1
				gojoMask.Eye2.Glow.ZOffset = 0.1
				task.delay(7, function()
					gojoMask.Eye1.Glow.ZOffset = 0.5
					gojoMask.Eye2.Glow.ZOffset = 0.5
					attachment:Destroy()
				end)
			end

			local clone = utils.Gojo.InfiniteVoid.Fade:Clone()
			clone.Parent = localPlayer.PlayerGui
			task.wait(1)
			TweenService:Create(clone.Frame, TweenInfo.new(1), {
				BackgroundTransparency = 1
			}):Play()
			Debris:AddItem(clone, 1)
			local clone2 = utils.Misc.M.WingFly:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 3)
			clone2.WHAT:Destroy()
			TweenService:Create(
				clone2.Mesh.Start,
				TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone2.Mesh.End.Size,
					Transparency = 1,
					CFrame = clone2.Mesh.End.CFrame
				}
			):Play()
			TweenService:Create(
				clone2.Mesh2.Start,
				TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone2.Mesh2.End.Size,
					Transparency = 1,
					CFrame = clone2.Mesh2.End.CFrame
				}
			):Play()
			TweenService:Create(
				clone2.Mesh3.Start,
				TweenInfo.new(2.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone2.Mesh3.End.Size,
					Transparency = 1,
					CFrame = clone2.Mesh3.End.CFrame
				}
			):Play()
			clone2.Mesh.End:Destroy()
			clone2.Mesh2.End:Destroy()
			clone2.Mesh3.End:Destroy()
			v2:PlaySound(sounds.Gojo.InfiniteVoid.Breathe, humanoidRootPart, game.SoundService.Voice)
			task.delay(0.6, function()
				local head = data.Head
				local clone3 = utils.Gojo.InfiniteVoid.Puddle.Breath:Clone()
				clone3.Parent = head
				Debris:AddItem(clone3, 8)

				for _ = 1, 6 do
					clone3.Breath:Emit(2)
					clone3.BreathL:Emit(3)
					clone3.BreathR:Emit(3)
					task.wait(1.05)
				end
			end)
			local currentCamera = workspace.CurrentCamera
			local total = 0
			local renderSteppedConnection = nil
			tick()
			local cutscene = utils.Gojo.InfiniteVoid.Cutscene
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				local v4 = dt * 60
				total += v4
				local child = cutscene.Frames:FindFirstChild((tonumber((math.ceil(total)))))
				local child2 = cutscene.FOV:FindFirstChild((tonumber((math.ceil(total)))))

				if child and child2 and data.Parent and humanoidRootPart.Parent and p.Parent then
					currentCamera.CFrame = humanoidRootPart.CFrame * child.Value
					currentCamera.FieldOfView = child2.Value
					currentCamera.CameraType = Enum.CameraType.Scriptable
				else
					renderSteppedConnection:Disconnect()
					currentCamera.CameraType = Enum.CameraType.Custom
					currentCamera.FieldOfView = 70
					currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
					game.Lighting.ExposureCompensation = 1
					TweenService:Create(game.Lighting, TweenInfo.new(0.2), {
						ExposureCompensation = 0
					}):Play()
				end
			end)
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
	v = Knit.GetService("TwofoldKickService")
	v2 = Knit.GetController("FXController")
end

return controller