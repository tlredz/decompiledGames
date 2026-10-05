local createVector = vector.create
local NPPClientEffectRunner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CameraShakeController = require(ReplicatedStorage.Modules.Client.PlayerController.CameraShakeController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
require(ReplicatedStorage.Modules.Shared.Utils.Frustums)
local CannonLaunchEffect = require(ReplicatedStorage.Modules.Client.Util.CannonLaunchEffect)

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function NPPClientEffectRunner.Boom(instance)
	if instance.Parent == nil then
		return
	end

	local maid = Janitor.new()
	local v = Janitor.new()
	maid:Add(v)
	local flag = false
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function abortBoom()
		if flag then
			return
		end

		flag = true

		if v2 then
			v2:StartFadeOut(0.1)
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			currentCamera.FieldOfView = 70
		end

		maid:Destroy()
	end

	maid:Add(instance.Destroying:Connect(abortBoom))
	maid:Add(instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			abortBoom() -- equivalent call inferred; original call site unknown
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function waitUnlessAborted(duration: number)
		if flag then
			return true
		end

		task.wait(duration)
		return flag
	end

	local nuclearRod = instance:WaitForChild("NuclearRod")

	if flag then
		return
	end

	local function addGeiger(value: number)
		if flag then
			return
		end

		local sound = Instance.new("Sound")
		v:Add(sound)
		sound.SoundId = "rbxassetid://94429388550803"
		sound.Volume = value or 1
		sound.Parent = workspace.CurrentCamera
		sound.TimePosition = math.random(0, sound.TimeLength)
		sound.Looped = true
		sound.Playing = true
	end

	addGeiger()

	-- equivalent call inferred; original call site unknown
	if waitUnlessAborted(2) then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	maid:Add(screenGui)
	screenGui.Name = "NPPBoomUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	local frame = Instance.new("Frame")
	maid:Add(frame)
	frame.Name = "NPPBoomTopFrame"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Size = UDim2.fromScale(1, 0.1)
	frame.Position = UDim2.fromScale(0.5, -0.1)
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.ZIndex = 2
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	maid:Add(frame2)
	frame2.Name = "NPPBoomBottomFrame"
	frame2.AnchorPoint = Vector2.new(0.5, 1)
	frame2.Size = UDim2.fromScale(1, 0.1)
	frame2.Position = UDim2.fromScale(0.5, 1.1)
	frame2.BackgroundTransparency = 0
	frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 2
	frame2.Parent = screenGui
	TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, 0)
	}):Play()
	TweenService:Create(frame2, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, 1)
	}):Play()
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local humanoidRootPart = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

	if humanoidRootPart and not flag then
		local tagged = CollectionService:GetTagged("NPPExplosionCastIgnore")
		table.insert(tagged, Players.LocalPlayer.Character)
		local cFrame = humanoidRootPart.CFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = tagged
		local raycastResult = workspace:Raycast(
			nuclearRod.CFrame.Position,
			(cFrame.Position - nuclearRod.CFrame.Position).Unit * (cFrame.Position - nuclearRod.CFrame.Position).Magnitude,
			raycastParams
		)
		local preExplosionGlow = nuclearRod:WaitForChild("PreExplosionGlow")

		if flag then
			return
		end

		preExplosionGlow.Enabled = true
		TweenService:Create(preExplosionGlow, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Brightness = 4,
			Range = 15
		}):Play()
		v2 = CameraShakeController.CamShake:StartShake(
			15,
			100,
			4,
			createVector(0.25, 0.25, 0.25),
			createVector(0.25, 0.25, 0.25)
		)
		local sound = Instance.new("Sound")
		maid:Add(sound)
		sound.SoundId = "rbxassetid://100518394718300"
		sound.Volume = 0.75
		sound.Parent = workspace.CurrentCamera
		sound.Looped = true
		sound.Playing = true
		maid:Add(task.delay(2, function()
			if flag or sound.Parent == nil then
				return
			end

			TweenService:Create(sound, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Volume = 4
			}):Play()
		end))
		local sound2 = Instance.new("Sound")
		maid:Add(sound2)
		sound2.SoundId = "rbxassetid://118995289055214"
		sound2.Volume = 1
		sound2.Parent = workspace.CurrentCamera
		sound2.Looped = false
		maid:Add(task.delay(3, function()
			if flag or sound2.Parent == nil then
				return
			end

			sound2:Play()
		end))
		addGeiger()
		maid:Add(task.delay(1, addGeiger))
		maid:Add(task.delay(1.5, addGeiger))

		for i = 1, 15 do
			maid:Add(task.delay(i * 0.1 + 1.75, addGeiger, i * 0.2 + 1))
		end

		local now = tick()
		local renderSteppedConnection = nil
		local colorCorrectionEffect = nil
		local bloomEffect = Instance.new("BloomEffect")
		maid:Add(bloomEffect)
		bloomEffect.Size = 10
		bloomEffect.Threshold = 0.5
		bloomEffect.Intensity = 1
		bloomEffect.Parent = workspace.CurrentCamera
		local blurEffect = Instance.new("BlurEffect")
		maid:Add(blurEffect)
		blurEffect.Size = 0
		blurEffect.Parent = workspace.CurrentCamera

		if raycastResult and raycastResult.Instance then
			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					FieldOfView = 35
				}
			):Play()
		else
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			maid:Add(colorCorrectionEffect)
			colorCorrectionEffect.Name = "NPPBoomColorCorrection"
			colorCorrectionEffect.Parent = workspace.CurrentCamera
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
				{
					Brightness = 0.25,
					Saturation = -0.75,
					Contrast = 0.3
				}
			):Play()
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				if flag or nuclearRod.Parent == nil then
					return
				end

				local unit = ((workspace.CurrentCamera.CFrame.Position - nuclearRod.CFrame.Position) * createVector(
					1,
					0,
					1
				)).Unit
				local v3 = math.abs((math.deg(((workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)):Angle(
					unit,
					createVector(0, 1, 0)
				)))))
				TweenService:Create(frame, TweenInfo.new(0.075, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.fromScale(0.5, -0.1 + 0.1 * (math.clamp(v3 - 90, 0, 90) / 90))
				}):Play()
				TweenService:Create(frame2, TweenInfo.new(0.075, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.fromScale(0.5, 1.1 + -0.10000000000000009 * (math.clamp(v3 - 90, 0, 90) / 90))
				}):Play()

				if math.abs(v3 - 180) > 1 then
					workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
						CFrame.new(workspace.CurrentCamera.CFrame.Position, nuclearRod.CFrame.Position),
						dt * (math.abs(v3 - 180) / 75 + 1)
					)
				end

				local v4 = math.abs(v3 - 180) / 180
				local currentCamera = workspace.CurrentCamera
				local fieldOfView = workspace.CurrentCamera.FieldOfView
				local v5 = math.clamp(v4 / 2 + math.clamp((now - tick()) / 20, 0, 0.5), 0, 1)
				currentCamera.FieldOfView = fieldOfView + (35 - fieldOfView) * v5
			end)
			maid:Add(renderSteppedConnection)
		end

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(2.5) then
			return
		end

		local frame3 = Instance.new("Frame")
		maid:Add(frame3)
		frame3.Name = "NPPBoomWhiteScreen"
		frame3.BackgroundTransparency = 1
		frame3.BackgroundColor3 = Color3.new(1, 1, 1)
		frame3.Size = UDim2.fromScale(1, 1)
		frame3.Position = UDim2.fromScale(0.5, 0.5)
		frame3.AnchorPoint = Vector2.new(0.5, 0.5)
		frame3.BorderSizePixel = 0
		frame3.Parent = screenGui
		TweenService:Create(frame3, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			BackgroundTransparency = 0
		}):Play()

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(0.5) then
			return
		end

		v2:StartFadeOut(0.25)

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
		end

		TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = 20
		}):Play()
		TweenService:Create(bloomEffect, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = 30,
			Threshold = 0,
			Intensity = 10
		}):Play()
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{
				FieldOfView = 25
			}
		):Play()
		TweenService:Create(preExplosionGlow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Brightness = 10,
			Range = 30
		}):Play()
		TweenService:Create(sound, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			Volume = 1.25
		}):Play()

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(0.5) then
			return
		end

		sound:Stop()
		bloomEffect:Destroy()

		if v then
			v:Cleanup()
		end

		if frame3 then
			TweenService:Create(frame3, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
		end

		TweenService:Create(preExplosionGlow, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()
		TweenService:Create(frame, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(0.5, -0.1)
		}):Play()
		TweenService:Create(frame2, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(0.5, 1.1)
		}):Play()
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(1.75, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
			{
				FieldOfView = 70
			}
		):Play()
		v2:StartFadeOut(0.1)
		CameraShakeController.CamShake:ShakeOnce(25, 80, 0, 6.5, createVector(1, 1, 1), createVector(4, 1, 1))

		if colorCorrectionEffect then
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Brightness = 1,
					TintColor = Color3.fromRGB(175, 255, 175),
					Saturation = 2
				}
			):Play()
		end

		TweenService:Create(blurEffect, TweenInfo.new(7.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = 0
		}):Play()
		local flyAwayParts = instance:FindFirstChild("FlyAwayParts")

		if flyAwayParts then
			for _, child in flyAwayParts:GetChildren() do
				if flag or child.Parent == nil then
					break
				end

				local abs = child.CFrame:ToObjectSpace(Players.LocalPlayer.Character.HumanoidRootPart.CFrame).Position:Abs()

				if not (abs.X < child.Size.X / 2 and abs.Z < child.Size.Z / 2 and abs.Y < child.Size.Y / 2) then
					continue
				end

				local impulseVector = child:GetAttribute("ImpulseVector")

				if not Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") then
					continue
				end

				local v4 = impulseVector
				local v5 = child
				task.spawn(function()
					local character = Players.LocalPlayer.Character
					local humanoidRootPart2 = character:WaitForChild("HumanoidRootPart")

					if humanoidRootPart2 then
						task.spawn(CannonLaunchEffect, character, v4, 150, 1)

						if v5:GetAttribute("EnablePlantPassthrough") then
							local overlapParams = OverlapParams.new()
							overlapParams.FilterType = Enum.RaycastFilterType.Exclude
							overlapParams.FilterDescendantsInstances = { Players.LocalPlayer.Character }
							local partBoundsInBox = workspace:GetPartBoundsInBox(
								CFrame.new(humanoidRootPart2.CFrame.Position, humanoidRootPart2.CFrame.Position + v4),
								humanoidRootPart2.Size * 25 + createVector(0, 0, 200),
								overlapParams
							)

							for k, part in partBoundsInBox do
								if not (part:IsA("BasePart") and part.CanCollide) then
									continue
								end

								part.CanCollide = false
								part:SetAttribute("CollisionMasked", true)
							end

							task.delay(1, function()
								for k, part in partBoundsInBox do
									if not (part:IsA("BasePart") and part:GetAttribute("CollisionMasked")) then
										continue
									end

									part.CanCollide = true
									part:SetAttribute("CollisionMasked", nil)
								end
							end)
						end
					end
				end)
				break
			end
		end

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(0.75) then
			return
		end

		if colorCorrectionEffect then
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(1.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Brightness = 0.25,
					Saturation = 0,
					Contrast = 0,
					TintColor = Color3.fromRGB(186, 190, 115)
				}
			):Play()
		end

		TweenService:Create(sound2, TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			Volume = 0.5
		}):Play()

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(0.9) then
			return
		end

		if colorCorrectionEffect then
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(1.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Brightness = 0.25,
					Saturation = 0,
					Contrast = 0,
					TintColor = Color3.fromRGB(209, 126, 111)
				}
			):Play()
		end

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(4) then
			return
		end

		if colorCorrectionEffect then
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Brightness = 0,
					Saturation = 0,
					Contrast = 0,
					TintColor = Color3.new(1, 1, 1)
				}
			):Play()
		end

		TweenService:Create(sound2, TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			Volume = 0
		}):Play()

		-- equivalent call inferred; original call site unknown
		if waitUnlessAborted(2.5) then
			return
		end

		abortBoom() -- equivalent call inferred; original call site unknown
	else
		abortBoom() -- equivalent call inferred; original call site unknown
	end
end

function NPPClientEffectRunner.ExternalBoom(parent)
	local DELAY_DURATION = 2.25
	local v = Janitor.new()
	local v2 = 1 - math.clamp(
		(workspace.CurrentCamera.CFrame.Position - parent.PointToSet.CFrame.Position).Magnitude,
		0,
		750
	) / 750
	local v3 = 1 - v2

	local function SendDebrisFlying()
		local clone = parent.ExternalExplosion.ExplosionFling:Clone()
		local debris = clone:WaitForChild("Debris")
		debris.Transparency = 0
		clone:ScaleTo(math.random(1, 100) / 50)
		clone:PivotTo(CFrame.new(parent.PointToSet.CFrame.Position + Vector3.new(
			math.random(-100, 100),
			-25,
			math.random(-100, 100)
		)))
		clone.Parent = parent

		for _, emitter in debris:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local vector2 = Vector3.new(math.random(-100, 100), math.random(100, 200), math.random(-100, 100))
		local v4 = math.random(25, 100) / 100
		debris.AssemblyLinearVelocity = vector2
		debris.AssemblyAngularVelocity = Vector3.new(
			math.random(-100, 100) / 50,
			math.random(-100, 100) / 50,
			math.random(-100, 100) / 50
		)
		TweenService:Create(debris, TweenInfo.new(v4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			CFrame = (debris.CFrame + vector2 * v4) * CFrame.Angles(
				math.random(1, 100) / 10,
				math.random(1, 100) / 10,
				math.random(1, 100) / 10
			)
		}):Play()
		task.delay(v4, function()
			debris.CanCollide = true
			debris.Anchored = false
			task.delay(math.random(100, 800) / 100, function()
				if not debris then
					return
				end

				for _, emitter in debris:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(debris, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
				task.delay(5, function()
					if debris then
						debris:Destroy()
					end
				end)
			end)
		end)
	end

	local screenGui = Instance.new("ScreenGui")
	v:Add(screenGui)
	screenGui.Name = "NPPBoomUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	local frame = Instance.new("Frame")
	v:Add(frame)
	frame.Name = "NPPBoomTopFrame"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Size = UDim2.fromScale(1, 0.1)
	frame.Position = UDim2.fromScale(0.5, -0.1)
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.ZIndex = 2
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	v:Add(frame2)
	frame2.Name = "NPPBoomBottomFrame"
	frame2.AnchorPoint = Vector2.new(0.5, 1)
	frame2.Size = UDim2.fromScale(1, 0.1)
	frame2.Position = UDim2.fromScale(0.5, 1.1)
	frame2.BackgroundTransparency = 0
	frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 2
	frame2.Parent = screenGui
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local bloomEffect = Instance.new("BloomEffect")
	bloomEffect.Size = 0
	bloomEffect.Threshold = 0
	bloomEffect.Intensity = 0
	bloomEffect.Parent = workspace.CurrentCamera
	TweenService:Create(bloomEffect, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = 1,
		Threshold = 0.5,
		Intensity = 0.5
	}):Play()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://923073285"
	sound.Volume = 1
	sound.Parent = workspace.CurrentCamera
	sound.Looped = false
	sound:Play()
	local v4 = CameraShakeController.CamShake:StartShake(
		v2 * 7.5,
		v2 * 50,
		3,
		createVector(0.25, 0.25, 0.25),
		createVector(0.25, 0.25, 0.25)
	)
	TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			FieldOfView = 70 + -20 * v2
		}
	):Play()
	TweenService:Create(frame, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, -0.1 + 0.1 * v2)
	}):Play()
	TweenService:Create(frame2, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, 1.1 + -0.10000000000000009 * v2)
	}):Play()
	task.delay(1, SendDebrisFlying)
	task.delay(1.75, SendDebrisFlying)
	task.delay(DELAY_DURATION, SendDebrisFlying)
	task.delay(DELAY_DURATION, SendDebrisFlying)
	task.delay(DELAY_DURATION, SendDebrisFlying)
	task.wait(2.5)
	TweenService:Create(bloomEffect, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Size = 20,
		Threshold = 0,
		Intensity = 5
	}):Play()
	local sound2 = Instance.new("Sound")
	v:Add(sound2)
	sound2.SoundId = "rbxassetid://118995289055214"
	sound2.Volume = 1 + -1 * v3
	sound2.Parent = workspace.CurrentCamera
	sound2.Looped = false
	sound2:Play()
	local currentCamera = workspace.CurrentCamera
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local v7 = 70 + -20 * v2
	TweenService:Create(currentCamera, tweenInfo, {
		FieldOfView = v7 + (30 - v7) * v2
	}):Play()
	task.wait(0.5)

	if sound then
		sound:Stop()
	end

	v4:StartFadeOut(0.01)
	CameraShakeController.CamShake:ShakeOnce(v2 * 20, v2 * 70, 0, 5, createVector(1, 1, 1), createVector(0.7, 0.7, 0.7))
	task.spawn(function()
		for _ = 1, math.random(4, 15) do
			SendDebrisFlying()
			task.wait(math.random(0, 100) / 1500)
		end
	end)
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		FieldOfView = 70
	}):Play()
	TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, -0.1)
	}):Play()
	TweenService:Create(frame2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 1.1)
	}):Play()
	TweenService:Create(bloomEffect, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Size = 0,
		Threshold = 1,
		Intensity = 0
	}):Play()
	task.wait(2)
	TweenService:Create(sound2, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Volume = 0
	}):Play()
	task.wait(3)
	v:Destroy()
end

function NPPClientEffectRunner.FrameworkInit() end

function NPPClientEffectRunner.FrameworkStart()
	Remotes.connect("PowerPlant::Boom", NPPClientEffectRunner.Boom)
	Remotes.connect("PowerPlant::ExternalBoom", NPPClientEffectRunner.ExternalBoom)
end

return NPPClientEffectRunner