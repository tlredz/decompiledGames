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
local v3 = nil
local controller = Knit.CreateController({
	Name = "BodyDisfigureController"
})

function controller.KnitStart(_)
	local v4 = {
		Pierce = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = {
				instance["Left Leg"].LeftFootAttachment,
				instance["Right Leg"].RightFootAttachment,
				instance.Torso.BodyFrontAttachment,
				instance["Left Arm"].LeftGripAttachment,
				instance["Right Arm"].RightGripAttachment
			}
			local attachment2 = v5[math.random(1, #v5)]
			local parent = attachment2.Parent

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 300 then
				for _ = 1, 2 do
					local clone = utils.Mahito.Worms.Morph2:Clone()
					clone.Decal:Destroy()
					clone.Weld.Part0 = parent
					clone.Color = parent.Color
					clone.Weld.C1 = CFrame.new(
						math.random(-50, 50) / 100,
						math.random(-100, 100) / 100,
						math.random(-50, 50) / 100
					)
					clone.Parent = workspace.Effects
					local v7 = math.random(15, 30) / 10
					clone.Size = createVector(1, 1, 1) * v7
					TweenService:Create(
						clone,
						TweenInfo.new(math.random(40, 60) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone, 0.6)
				end
			end

			local clone = utils.Mahito.Pierce:Clone()
			clone.Position = humanoidRootPart.Position - Vector3.new(math.random(-15, 15), 6, math.random(-15, 15)) + humanoidRootPart.CFrame.LookVector * 10
			clone.Attachment.WorldPosition = parent.Position
			clone.Pierce.Attachment0 = attachment2
			clone.Pierce.Color = ColorSequence.new(parent.Color)
			clone.Pierce.CurveSize0 = math.random(-25, 25)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			local v7 = math.random(1, 3)

			if v7 == 1 then
				v3:PlaySound(sounds.Mahito.DrillSplit.Morph, humanoidRootPart, game.SoundService.Effect)
			elseif v7 == 2 then
				v3:PlaySound(sounds.Mahito.DrillSplit.Unmorph, humanoidRootPart, game.SoundService.Effect)
			end

			local attachment = clone.Attachment
			TweenService:Create(attachment, TweenInfo.new(0.1), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.Pierce, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				CurveSize0 = 0
			}):Play()
			task.wait(0.2)
			local worldPosition = attachment.WorldPosition
			attachment.Parent = parent
			attachment.WorldPosition = worldPosition
			TweenService:Create(attachment, TweenInfo.new(0.3), {
				Position = createVector(0, 0, 0)
			}):Play()
			Debris:AddItem(attachment, 0.3)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Mahito.Variants.M3:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Arm = function(instance, part)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local C1 = part.Hand.Weld.C1
			local C12 = part.Hand2.Weld.C1
			part.Hand.Weld.C1 = C1 * CFrame.new(10, 2, 0) * CFrame.Angles(
				0.3490658503988659,
				0.3490658503988659,
				0.3490658503988659
			)
			part.Hand2.Weld.C1 = C12 * CFrame.new(10, 2, 0) * CFrame.Angles(
				0.3490658503988659,
				0.3490658503988659,
				0.3490658503988659
			)
			TweenService:Create(part.Hand.Weld, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				C1 = C1
			}):Play()
			TweenService:Create(part.Hand2.Weld, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				C1 = C12
			}):Play()
			v3:PlaySound(sounds.Mahito.ForceGrab.Fire, part, game.SoundService.Effect)
			v3:PlaySound(sounds.Itadori.Rush.RushBreak, part, game.SoundService.Effect)
			part.Hand.Beam.CurveSize0 = -10
			part.Hand.Beam.CurveSize1 = -10
			TweenService:Create(part.Hand.Beam, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			part.Destroying:Connect(function()
				if not instance.Parent then
					return
				end

				local v5 = part.Velocity * 0.1

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end

				local attachment = Instance.new("Attachment")
				attachment.Position = createVector(0, -0.5, 0)
				attachment.Parent = instance["Right Arm"]
				local clone = part:Clone()
				clone.Anchored = true
				clone.Hand.Beam.Attachment1 = attachment
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)
				Debris:AddItem(attachment, 1)
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
				TweenService:Create(clone.Hand, tweenInfo, {
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone.Hand2, tweenInfo, {
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone.Hand.Beam, tweenInfo, {
					Width0 = 0
				}):Play()
				local cFrame = clone.CFrame
				local lastTime = tick()
				local steppedConnection = nil
				steppedConnection = RunService.Stepped:Connect(function()
					local v6 = (tick() - lastTime) / 0.5

					if v6 > 1 or not instance.Parent then
						clone:Destroy()
						attachment:Destroy()
						steppedConnection:Disconnect()
					else
						clone.CFrame = cFrame:Lerp(CFrame.new(instance["Right Arm"].Position, cFrame.Position), v6) + v5 * math.sin(v6 * 3.141592653589793)
					end
				end)
				v3:PlaySound(sounds.Mahito.ForceGrab.Retract, humanoidRootPart, game.SoundService.Effect)
				TweenService:Create(
					clone.Hand.Beam,
					TweenInfo.new(0.125, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						CurveSize0 = -10,
						CurveSize1 = -10
					}
				):Play()
				task.delay(0.125, function()
					TweenService:Create(
						clone.Hand.Beam,
						TweenInfo.new(0.125, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							CurveSize0 = 10,
							CurveSize1 = 10
						}
					):Play()
					task.wait(0.125)
					TweenService:Create(
						clone.Hand.Beam,
						TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
						{
							CurveSize0 = 0,
							CurveSize1 = 0
						}
					):Play()
				end)

				for _ = 1, 15 do
					local clone2 = utils.Mahito.Morph:Clone()
					clone2.Weld.Part0 = clone
					clone2.Color = clone.Hand.Color
					clone2.Weld.C1 = CFrame.new(
						math.random(-10, 10) / 2,
						math.random(-10, 10) / 2,
						math.random(-10, 10) / 2
					)
					clone2.Shape = Enum.PartType.Block
					clone2.Parent = workspace.Effects
					local v6 = math.random(10, 20) / 10
					clone2.Size = createVector(1, 1, 1) * v6
					TweenService:Create(
						clone2,
						TweenInfo.new(math.random(40, 60) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone2, 0.6)
					clone2.Weld:Destroy()
					clone2.Velocity = Vector3.new(math.random(-40, 40), math.random(-20, 40), math.random(-40, 40))
					task.wait()
				end
			end)

			for _ = 1, 15 do
				if not part:FindFirstChild("Hand") then
					break
				end

				local clone = utils.Mahito.Morph:Clone()
				clone.Weld.Part0 = part
				clone.Color = part.Hand.Color
				clone.Weld.C1 = CFrame.new(math.random(-10, 10) / 2, math.random(-10, 10) / 2, math.random(-10, 10) / 2)
				clone.Shape = Enum.PartType.Block
				clone.Parent = workspace.Effects
				local v5 = math.random(10, 30) / 10
				clone.Size = createVector(1, 1, 1) * v5
				TweenService:Create(
					clone,
					TweenInfo.new(math.random(40, 60) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				Debris:AddItem(clone, 0.6)
				clone.Weld:Destroy()
				clone.Velocity = Vector3.new(math.random(-40, 40), math.random(-20, 40), math.random(-40, 40))
				task.wait()
			end
		end,
		Grab = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				local humanoid = instance.Humanoid
				instance2.Enabled = true
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				local lastTime = tick()
				local jump = false
				local v5 = 0

				repeat
					if jump == false and humanoid.Jump == true and tick() - lastTime > 0.025 then
						local v6 = v5 + 1
						v5 = v6 > 20 and 20 or v6
						lastTime = tick()
						instance2:FindFirstChildWhichIsA("UnreliableRemoteEvent"):FireServer()
						v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
						instance2.StudsOffset = createVector(1, 0, 0)
						TweenService:Create(instance2, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
							StudsOffset = createVector(0, 0, 0)
						}):Play()
					end

					jump = humanoid.Jump
					instance2.Bar.Size = UDim2.new(v5 / 20, 0, 0.3, 0)
					task.wait()
				until not instance2.Parent
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.ForceGrab.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Throw, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, instance2, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.DrillSplit.Morph, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.DrillSplit.Leap, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 20 do
				local clone = utils.Mahito.Morph:Clone()

				if i > 10 then
					clone.Weld.Part0 = instance["Right Leg"]
					clone.Color = instance["Right Leg"].Color
				else
					clone.Weld.Part0 = instance["Left Leg"]
					clone.Color = instance["Left Leg"].Color
				end

				clone.Weld.C1 = CFrame.new(
					math.random(-50, 50) / 100,
					math.random(100, 400) / 100,
					math.random(-50, 50) / 100
				)
				clone.Parent = workspace.Effects
				local v5 = math.random(5, 25) / 10
				clone.Size = createVector(1, 1, 1) * v5
				TweenService:Create(
					clone,
					TweenInfo.new(math.random(20, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone.Weld,
					TweenInfo.new(math.random(30, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						C1 = CFrame.new(0, 0, 0)
					}
				):Play()
				Debris:AddItem(clone, 0.5)
			end

			instance2.Destroying:Connect(function()
				if not instance.Parent then
					return
				end

				v3:PlaySound(sounds.Mahito.DrillSplit.Unmorph, humanoidRootPart, game.SoundService.Effect)

				for i = 1, 20 do
					local clone = utils.Mahito.Morph:Clone()

					if i > 10 then
						clone.Weld.Part0 = instance["Right Leg"]
						clone.Color = instance["Right Leg"].Color
					else
						clone.Weld.Part0 = instance["Left Leg"]
						clone.Color = instance["Left Leg"].Color
					end

					clone.Weld.C1 = CFrame.new(
						math.random(-50, 50) / 100,
						math.random(100, 400) / 100,
						math.random(-50, 50) / 100
					)
					clone.Parent = workspace.Effects
					local v5 = math.random(5, 15) / 10
					clone.Size = createVector(1, 1, 1) * v5
					TweenService:Create(
						clone,
						TweenInfo.new(math.random(20, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone, 0.5)
				end
			end)
		end,
		Drill = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.Drill.DrillArm:Clone()
			clone.Weld.Part0 = instance["Right Arm"]

			for _, part in clone:GetChildren() do
				if part:IsA("BasePart") then
					part.Color = instance["Right Arm"].Color
				end
			end

			clone.Parent = workspace.Effects
			local v5 = v3:PlaySound(sounds.Mahito.DrillSplit.DrillWind, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.DrillSplit.Morph, humanoidRootPart, game.SoundService.Effect)
			task.delay(1.8, function()
				clone.Attachment.ParticleEmitter.Enabled = false
				v5.TimePosition = 16
			end)

			for _ = 1, 20 do
				local clone2 = utils.Mahito.Morph:Clone()
				clone2.Weld.Part0 = instance["Right Arm"]
				clone2.Color = instance["Right Arm"].Color
				clone2.Weld.C1 = CFrame.new(
					math.random(-150, 150) / 100,
					math.random(100, 400) / 100,
					math.random(-150, 150) / 100
				)
				clone2.Parent = workspace.Effects
				local v6 = math.random(10, 40) / 10
				clone2.Size = createVector(1, 1, 1) * v6
				TweenService:Create(
					clone2,
					TweenInfo.new(math.random(20, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone2.Weld,
					TweenInfo.new(math.random(30, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						C1 = CFrame.new(0, 0, 0)
					}
				):Play()
				Debris:AddItem(clone2, 0.5)
			end

			repeat
				clone.Weld.C0 *= CFrame.Angles(0, 1.0471975511965976, 0)
				task.wait()
			until not p.Parent

			clone:Destroy()
			v3:PlaySound(sounds.Mahito.DrillSplit.Unmorph, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				local clone2 = utils.Mahito.Morph:Clone()
				clone2.Weld.Part0 = instance["Right Arm"]
				clone2.Color = instance["Right Arm"].Color
				clone2.Weld.C1 = CFrame.new(
					math.random(-150, 150) / 100,
					math.random(100, 400) / 100,
					math.random(-150, 150) / 100
				)
				clone2.Parent = workspace.Effects
				local v6 = math.random(10, 40) / 10
				clone2.Size = createVector(1, 1, 1) * v6
				TweenService:Create(
					clone2,
					TweenInfo.new(math.random(20, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone2.Weld,
					TweenInfo.new(math.random(30, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						C1 = CFrame.new(0, 0, 0)
					}
				):Play()
				Debris:AddItem(clone2, 0.5)
			end
		end,
		DrillHit = function(p, p2, instance, p3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.Drill.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			task.spawn(function()
				clone.Wind.Enabled = true
				v3:PlaySound(sounds.Mahito.DrillSplit.Drill, humanoidRootPart, game.SoundService.Effect)

				repeat
					v3:Flash(instance, Color3.new(1, 1, 1))
					v3:PlaySound(sounds.Mahito.DrillSplit.DrillHit, humanoidRootPart, game.SoundService.Effect)
					clone.Position = humanoidRootPart.Position
					task.wait(0.1)
				until not (p3.Parent and instance.Parent and p2.Parent and p3.Parent.Parent)

				clone.Wind.Enabled = false
			end)

			if _G.Settings.Gore == true then
				clone.Blood.Enabled = true
				clone.Hit.Enabled = true
				task.spawn(function()
					repeat
						BloodyZee:Blood(clone.CFrame, 70, 180, 180)
						task.wait()
					until not (p3.Parent and instance.Parent and p2.Parent and p3.Parent.Parent)

					clone.Blood.Enabled = false
					clone.Hit.Enabled = false
				end)
			end

			if localPlayer == p or localPlayer.Character == p2 then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap)

				repeat
					task.wait()
				until not p3.Parent

				shakeSustain:StartFadeOut(1)
			end
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.DrillSplit.Leap, humanoidRootPart, game.SoundService.Effect)
			local v5 = humanoidRootPart.CFrame.LookVector * 5 - createVector(0, 2, 0)

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 70000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					local v6 = humanoidRootPart.CFrame - humanoidRootPart.Position + p.Position - v5
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v6, 0.15)
					task.wait()
				until not (p2.Parent and p)
			end

			TweenService:Create(p2, TweenInfo.new(0.5), {
				P = 70000
			}):Play()

			repeat
				p2.Position = p.Position - v5
				task.wait()
			until not (p2.Parent and p)
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
	v = Knit.GetService("BodyDisfigureService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller