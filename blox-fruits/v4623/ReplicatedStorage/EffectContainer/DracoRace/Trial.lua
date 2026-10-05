local createVector = vector.create
local Effect = require(game.ReplicatedStorage.Effect)
local FX = require(game.ReplicatedStorage.FX)
local trial = FX:WaitForChild("DracoRace").Trial
local v = {
	{
		RelicMetal = Color3.fromRGB(132, 203, 0),
		Particles = Color3.fromRGB(221, 255, 0),
		RelicGem = Color3.fromRGB(108, 119, 41)
	},
	{
		RelicMetal = Color3.fromRGB(232, 106, 110),
		Particles = Color3.fromRGB(255, 99, 102),
		RelicGem = Color3.fromRGB(141, 0, 2)
	},
	{
		RelicMetal = Color3.fromRGB(191, 153, 0),
		Particles = Color3.fromRGB(255, 255, 0),
		RelicGem = Color3.fromRGB(255, 213, 0)
	}
}
local now = 0

local function colorifySequence(color, particles)
	local R = particles.R
	local G = particles.G
	local B = particles.B
	local colorSequenceKeypoints = {}

	for _, keypoint in ipairs(color.Keypoints) do
		local value = keypoint.Value
		local R2 = value.R
		local G2 = value.G
		local B2 = value.B
		local v2 = R2 * 0.3 + G2 * 0.59 + B2 * 0.11
		local color2 = Color3.new(R * v2, G * v2, B * v2)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, color2))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function TeleportScene(brightness)
	local character = game.Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not character or not humanoid or humanoid.Health <= 0 then
		return
	end

	local lastTime = os.clock()
	local TweenService = game:GetService("TweenService")
	local blurEffect = Instance.new("BlurEffect", game.Lighting)
	blurEffect.Size = 0
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
	game.Debris:AddItem(blurEffect, 12)
	game.Debris:AddItem(colorCorrectionEffect, 12)
	TweenService:Create(blurEffect, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Size = 50
	}):Play()
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Brightness = brightness
	}):Play()

	while os.clock() - lastTime < 10 and character == game.Players.LocalPlayer.Character and character.Parent and humanoid.Health > 0 and not (os.clock() - now < 5) do
		task.wait()
	end

	TweenService:Create(blurEffect, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Size = 0
	}):Play()
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Brightness = 0
	}):Play()
	game.Debris:AddItem(blurEffect, 2)
	game.Debris:AddItem(colorCorrectionEffect, 2)
end

local Util = require(game.ReplicatedStorage.Util)
local cameraShaker = Util.CameraShaker
local maid = Util.Maid.new()
local maid2 = Util.Maid.new()
local dracoTrial = nil
local v2 = nil
local v3 = nil
local relic = nil
local v4 = nil
local v5 = nil
local v6 = nil

local function toHashmap(list, p)
	local result = {}

	for _, v7 in ipairs(list) do
		result[v7] = p or true
	end

	return result
end

local function ToggleForcefield(enabled)
	if not (v3 ~= enabled and v2.Forcefield) then
		return
	end

	v3 = enabled

	if enabled == true and not v5 then
		Util.Sound:Play("BF_Trial_Shield_Activate_01", v2.Forcefield.Parent)
		v5 = Util.Sound:Play("BF_Shielded_Loop_01", v2.Forcefield.Parent)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(v5, TweenInfo.new(0.7), {
			Volume = 0.7
		}):Play()
	elseif enabled == false and v5 then
		Util.Sound:FadeOut(v5, 0.2)
		task.delay(0.2, function()
			v5 = nil
		end)
	end

	for _, emitter in pairs(v2.Forcefield:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function TeleportFloor(p)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart and humanoid and dracoTrial then
		local v7 = p or humanoidRootPart.CFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { dracoTrial }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(v7.Position, createVector(-0, -50, -0), raycastParams)

		if raycastResult and raycastResult.Instance then
			return v7 + createVector(0, 1, 0) * (raycastResult.Position.Y - v7.Position.Y + humanoid.HipHeight + humanoidRootPart.Size.Y / 2 + 0.0005)
		end
	end
end

local function TeleportTrial()
	maid:DoCleaning()
	maid:GiveTask(coroutine.running())
	local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local v7 = nil
	maid:GiveTask(function()
		v7 = os.clock() + 5
	end)
	task.spawn(function()
		if not humanoidRootPart then
			return
		end

		local position = humanoidRootPart.Position

		while not v7 or v7 > os.clock() do
			if 1 / task.wait() * (position - humanoidRootPart.Position).Magnitude > 3000 then
				now = os.clock()
			end

			position = humanoidRootPart.Position
		end
	end)
	v4 = 0
	maid:GiveTask(function()
		v4 = 0
		v3 = false
		relic = nil
		v2 = {}
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
	v2 = {}
	dracoTrial = workspace:WaitForChild("Map"):WaitForChild("DracoTrial")

	if (dracoTrial:WaitForChild("Center").Position - humanoidRootPart.Position).Magnitude < 1000 then
		now = os.clock()
	end

	for _, childName in pairs({
		"Relic1",
		"Relic2",
		"Relic3",
		"EndRelic1",
		"EndRelic2",
		"EndRelic3",
		"Door1",
		"Door2",
		"Door3",
		"Brazier1",
		"Brazier2",
		"Brazier3",
		"Center",
		"EndPlatform",
		"TeleportOut"
	}) do
		v2[childName] = dracoTrial:FindFirstChild(childName, true)
	end

	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart2 and humanoid then
		TeleportScene(-1)
		local sound = Util.Sound
		local Players = game:GetService("Players")
		v6 = sound:Play("BF_Cave_Trial_Ambience_01", Players.LocalPlayer)
		local v8 = Util.Sound:Get("TrialSounds.DracoV4TrialMusic")

		for _, child in workspace._WorldOrigin.Locations:GetChildren() do
			if child.Name == "Prehistoric Island" then
				child.Sound:SetAttribute("SoundId", v8:GetAttribute("SoundId"))
			end
		end

		for _, child in pairs(v2.TeleportOut.Parent:GetChildren()) do
			child.CanQuery = false
			child.CanCollide = false
		end

		local cFrame = TeleportFloor(v2.TeleportOut.CFrame * CFrame.new(0, -4, 0))
		humanoidRootPart2.CFrame = cFrame
		local v10 = false
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("MoveDracoTrial", Enum.RenderPriority.Character.Value + 1, function()
			local cFrame2 = TeleportFloor()

			if humanoidRootPart2.Position.Y > cFrame2.Y + 0.1 then
				humanoidRootPart2.CFrame = cFrame2
			end

			humanoid:ChangeState(Enum.HumanoidStateType.Running)
			humanoid:Move(cFrame.LookVector)
		end)
		maid:GiveTask(function()
			if not v10 then
				local RunService2 = game:GetService("RunService")
				RunService2:UnbindFromRenderStep("MoveDracoTrial")
			end
		end)
		task.wait(1.4)
		v10 = true
		local RunService2 = game:GetService("RunService")
		RunService2:UnbindFromRenderStep("MoveDracoTrial")

		for _, child in pairs(v2.TeleportOut.Parent:GetChildren()) do
			child.CanQuery = true
			child.CanCollide = true
		end
	end
end

local function StartTrial()
	local function ChildAdded(folder)
		if v4 ~= 0 and not relic then
			return
		end

		if folder.Name == "Brazier" or folder.Name == "Chain" then
			for _, part in pairs(folder:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = true
				part.CanTouch = false
				part.CanQuery = false
				part.Transparency = 1
			end

			local descendantAddedConnection = folder.DescendantAdded:Connect(function(part)
				if not part:IsA("BasePart") then
					return
				end

				part.CanCollide = true
				part.CanTouch = false
				part.CanQuery = false
				part.Transparency = 1
			end)
			task.delay(5, function()
				descendantAddedConnection:Disconnect()
			end)
		elseif folder.Name == "Platform" then
			folder.CanCollide = true
			folder.CanTouch = false
			folder.CanQuery = false
			folder.Transparency = 1
		end
	end

	for _, child in pairs(dracoTrial:GetChildren()) do
		ChildAdded(child)
	end

	maid:GiveTask(dracoTrial.ChildAdded:Connect(ChildAdded))

	for i = 1, 3 do
		local meshescaveprops_Cube015 = v2["Relic" .. i]:FindFirstChild("Meshes/caveprops_Cube.015", true)
		local v7 = v[i]
		local clone = trial.Relic:Clone()
		maid:GiveTask(clone)
		v2["RelicModel" .. i] = clone

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = true

				if descendant:IsA("MeshPart") then
					descendant.Color = v7.RelicMetal
				end
			elseif descendant:IsA("SurfaceAppearance") and descendant.Parent.Name == "Cylinder.035" then
				descendant.Color = v7.RelicGem
			end
		end

		local clone2 = trial.RelicFires:FindFirstChild("Relic" .. i):Clone()
		clone2.Parent = clone
		clone2.Weld.Part0 = clone.PrimaryPart
		clone2.Name = "RelicFire"
		clone:ScaleTo(2)
		clone.Parent = workspace._WorldOrigin
		local boundingBox, v8 = clone:GetBoundingBox()
		local objectSpace = (boundingBox * CFrame.new(0, -v8.Y / 2, 0)):ToObjectSpace(clone.PrimaryPart.CFrame)
		clone:PivotTo(meshescaveprops_Cube015.CFrame * CFrame.new(0, meshescaveprops_Cube015.Size.Y / 2 + 0.5, 0) * objectSpace)
	end

	local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	v2.Forcefield = trial.BrazierFires.Forcefield:Clone()
	v2.Forcefield.Parent = humanoidRootPart
	maid:GiveTask(v2.Forcefield)
	local lastTime = os.clock()
	local position = humanoidRootPart.CFrame.Position
	local v7 = nil
	maid:GiveTask(function()
		v7 = true
	end)

	while not v7 and task.wait() do
		if (humanoidRootPart.Position - position).Magnitude > 0.3 then
			lastTime = os.clock()
			position = humanoidRootPart.Position
		end

		ToggleForcefield(relic and os.clock() - lastTime >= 1)
	end
end

local function CollectRelic(p)
	if v4 < 4 then
		local v7 = { "Red", "Blue", "Yellow" }

		for _, folder in pairs(dracoTrial:GetChildren()) do
			if folder.Name == "Brazier" or folder.Name == "Chain" then
				for _, part in pairs(folder:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.CanCollide = true
					part.CanTouch = true
					part.CanQuery = true
					part.Transparency = 0
				end
			elseif folder.Name == "Platform" then
				folder.CanCollide = true
				folder.CanTouch = true
				folder.CanQuery = true
				folder.Transparency = 0
			end
		end

		task.spawn(function()
			local Cutscene = require(script.Cutscene)
			Cutscene(dracoTrial, v7[p.Relic])
		end)
	end

	relic = p.Relic
	local v7 = relic
	local v8 = v2["RelicModel" .. relic]
	local primaryPart = v8.PrimaryPart
	local attachment = Instance.new("Attachment", primaryPart)

	for _, part in pairs(v8:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = false

		if not (part ~= primaryPart and part:IsA("MeshPart")) then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint", primaryPart)
		weldConstraint.Part0 = primaryPart
		weldConstraint.Part1 = part
	end

	local alignPosition = Instance.new("AlignPosition", primaryPart)
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment
	alignPosition.MaxForce = 5000000000
	alignPosition.Responsiveness = 15
	local alignOrientation = Instance.new("AlignOrientation", primaryPart)
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	Util.Sound:Play("TrialSounds.BF_Trial_Relic_Interact_01", humanoidRootPart)

	for _, child in pairs(v2.Forcefield:GetChildren()) do
		child.Color = colorifySequence(trial.BrazierFires.Forcefield[child.Name].Color, v[relic].Particles)
	end

	while v7 == relic do
		local position = (CFrame.new(humanoidRootPart.Position, primaryPart.Position) * CFrame.new(0, 0, -5)).Position
		alignPosition.Position = position
		local cframe = CFrame.new(
			primaryPart.Position - createVector(0, 1, 0) * primaryPart.Position.Y,
			humanoidRootPart.Position - createVector(0, 1, 0) * humanoidRootPart.Position.Y
		)
		local magnitude = (position - primaryPart.Position).Magnitude
		alignOrientation.CFrame = (CFrame.new(primaryPart.Position, humanoidRootPart.Position) * CFrame.Angles(
			math.min(primaryPart.AssemblyLinearVelocity.Magnitude / 30, 1) * -0.5235987755982988,
			0,
			0
		)):Lerp(
			cframe,
			1 - math.min(magnitude / 4, 1)
		)
		task.wait()
	end
end

local function DeliverRelic(_)
	local folder = v2["RelicModel" .. relic]
	local meshescaveprops_Cube015 = v2["EndRelic" .. relic]:FindFirstChild("Meshes/caveprops_Cube.015", true)
	local v7 = relic
	relic = nil
	local boundingBox, v8 = folder:GetBoundingBox()
	local objectSpace = (boundingBox * CFrame.new(0, -v8.Y / 2 / 2, 0)):ToObjectSpace(folder.PrimaryPart.CFrame)
	local cFrame2 = meshescaveprops_Cube015.CFrame * CFrame.new(0, meshescaveprops_Cube015.Size.Y / 2 + 0.5, 0) * objectSpace
	folder.PrimaryPart.AlignPosition.Position = cFrame2.Position
	folder.PrimaryPart.AlignOrientation.CFrame = cFrame2
	task.spawn(function()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 2
		maid:GiveTask(numberValue.Changed:Connect(function()
			folder:ScaleTo(numberValue.Value)
		end))
		maid:GiveTask(numberValue)
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(numberValue, TweenInfo.new(1), {
			Value = 1
		})
		maid:GiveTask(tween.Completed:Once(function()
			pcall(function()
				numberValue:Destroy()
			end)
		end))
		tween:Play()
	end)
	maid:GiveTask(coroutine.running())

	while folder.PrimaryPart.AssemblyLinearVelocity.Magnitude + folder.PrimaryPart.AssemblyAngularVelocity.Magnitude <= 0.05 and (folder.PrimaryPart.Position - cFrame2.Position).Magnitude < 0.01 do
		task.wait()
	end

	Util.Sound:Play("TrialSounds.BF_Trial_Relic_Redeem_01", cFrame2.Position)

	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone = trial.BrazierFires:FindFirstChild("Relic" .. v7):Clone()
	clone.Parent = v2["Brazier" .. v7]
	clone.WorldCFrame = v2["Brazier" .. v7].CFrame * CFrame.new(0, -0.6, 0)
	maid:GiveTask(clone)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.TimeScale = 0
		local TweenService = game:GetService("TweenService")
		TweenService:Create(emitter, TweenInfo.new(1), {
			TimeScale = 1
		}):Play()
	end

	v4 += 1
	local v10 = v2["Door" .. v4]
	local cFrame = v10.PrimaryPart.CFrame
	Util.Debris:AddItem(Util.Sound:Play("StoneDoor", v10.PrimaryPart, 100), 5)
	local total = 0
	maid:GiveTask(function()
		total = 6
		v10.PrimaryPart.CFrame = cFrame
	end)
	local v11 = v4 - 1
	local rightVector = (cFrame * CFrame.Angles(0, math.rad(-30 + 120 * v11), 0)).RightVector

	while total < 4 do
		if total > 5 then
			break
		end

		local primaryPart = v10.PrimaryPart
		primaryPart.CFrame = (cFrame + rightVector * total / 4 * 18) * CFrame.Angles(0, math.rad(total / 4 * 180), 0)
		total += task.wait()
	end
end

local function Explode(data)
	maid2:DoCleaning()
	local _ = data.StartAt
	local v7 = data.StartAt - workspace:GetServerTimeNow()
	local fillDuration = data.FillDuration
	local drainDuration = data.DrainDuration
	local drainDelay = data.DrainDelay

	if not v2.Lava then
		v2.Lava = Instance.new("Part", workspace._WorldOrigin)
		v2.Lava.Anchored = true
		v2.Lava.Material = Enum.Material.Neon
		v2.Lava.CanCollide = false
		v2.Lava.CanQuery = false
		v2.Lava.Color = Color3.fromRGB(170, 79, 0)
		v2.Lava.CFrame = v2.Center.CFrame * CFrame.new(0, -10, 0)
		v2.Lava.Size = createVector(2000, 10, 2000)
		maid:GiveTask(v2.Lava)
	end

	local lava = v2.Lava
	local center = v2.Center
	local TweenService = game:GetService("TweenService")
	Util.Sound:Play("TrialSounds.BF_Trial_Volcano_Explosion_01", lava)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(2), {
		TintColor = Color3.fromRGB(255, 186, 146)
	}):Play()
	local bloomEffect = Instance.new("BloomEffect", game.Lighting)
	bloomEffect.Intensity = 0
	TweenService:Create(bloomEffect, TweenInfo.new(2), {
		Intensity = 1,
		Threshold = 0.2
	}):Play()
	local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect", game.Lighting)
	colorCorrectionEffect2.TintColor = Color3.fromRGB(255, 94, 0)
	colorCorrectionEffect2.Enabled = false
	local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
	local v8 = false
	local TweenService2 = game:GetService("TweenService")
	local colorCorrectionEffect3 = Instance.new("ColorCorrectionEffect", game.Lighting)
	local fn
	local v9 = false
	maid2:GiveTask(task.spawn(function()
		while task.wait() do
			colorCorrectionEffect2.Enabled = workspace.CurrentCamera.CFrame.Position.Y < lava.CFrame.Position.Y

			if colorCorrectionEffect2.Enabled and not v9 then
				v9 = true
				Effect.new("DracoRace.ScreenBurn"):play({
					Duration = 2
				})
			end

			if v3 or not (humanoidRootPart.CFrame.Position.Y < (lava.CFrame * CFrame.new(0, lava.Size.Y / 2, 0)).Position.Y) or v8 then
				continue
			end

			v8 = true
			TweenService2:Create(
				colorCorrectionEffect3,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					TintColor = Color3.fromRGB(255, 72, 0)
				}
			):Play()
			TweenService2:Create(
				colorCorrectionEffect3,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Brightness = 1,
					Contrast = -1
				}
			):Play()
			task.wait(1)
			local teleportFloor = TeleportFloor(dracoTrial.Center.CFrame)
			game.Players.LocalPlayer.Character:PivotTo(teleportFloor)
			local v12 = Util.BodyMover.new(game.Players.LocalPlayer.Character):Create("BodyPosition", {
				Priority = 10000000,
				Position = teleportFloor.Position,
				Duration = 10.5
			})

			fn = function()
				v12:Destroy()
				TweenService2:Create(
					colorCorrectionEffect3,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.5),
					{
						TintColor = Color3.fromRGB(255, 255, 255)
					}
				):Play()
				local tween = TweenService2:Create(
					colorCorrectionEffect3,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Contrast = 0
					}
				)
				tween.Completed:Once(function()
					task.wait(1)
					colorCorrectionEffect3:Destroy()
				end)
				tween:Play()
			end
		end
	end))
	local shakeOnce = cameraShaker:ShakeOnce(2, 2, 9, 0)
	cameraShaker:ShakeSustain(shakeOnce)
	maid2:GiveTask(function()
		cameraShaker:StopSustained(2)
		TweenService2:Create(bloomEffect, TweenInfo.new(1), {
			Intensity = 0
		}):Play()
		TweenService2:Create(colorCorrectionEffect, TweenInfo.new(1), {
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		TweenService2:Create(lava, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			CFrame = center.CFrame * CFrame.new(0, -30, 0)
		}):Play()
		colorCorrectionEffect2:Destroy()
		task.delay(2, function()
			bloomEffect:Destroy()
			colorCorrectionEffect:Destroy()
			colorCorrectionEffect3:Destroy()
		end)
	end)
	maid2:GiveTask(task.delay(v7 - 1, function()
		shakeOnce:StartFadeOut(2)
		cameraShaker:ShakeSustain(cameraShaker:ShakeOnce(4, 4, 2, 0))
	end))
	task.wait(v7)
	local v10 = Util.Sound:Play("ExplosionHeavy", lava, 300)
	maid2:GiveTask(function()
		Util.Sound:FadeOut(v10, 1)
		task.delay(1, function()
			v10:Destroy()
		end)
	end)
	local tween = TweenService2:Create(lava, TweenInfo.new(fillDuration, Enum.EasingStyle.Sine), {
		CFrame = center.CFrame + createVector(0, 1, 0) * (v2.EndPlatform.Position.Y + v2.EndPlatform.Size.Y / 2 - center.Position.Y - 6)
	})
	tween:Play()
	tween.Completed:Wait()
	task.wait(drainDelay)
	TweenService2:Create(lava, TweenInfo.new(drainDuration, Enum.EasingStyle.Linear), {
		CFrame = center.CFrame * CFrame.new(0, -30, 0)
	}):Play()
	task.wait(drainDuration - 1)
	cameraShaker:StopSustained(2)
	Util.Sound:FadeOut(v10, 2)
	TweenService2:Create(bloomEffect, TweenInfo.new(1), {
		Intensity = 0
	}):Play()
	TweenService2:Create(colorCorrectionEffect, TweenInfo.new(2), {
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	task.wait(1)

	if fn then
		task.spawn(fn)
	end

	task.wait(1)
	maid2:DoCleaning()
end

local function TeleportOut()
	if v6 then
		Util.Sound:FadeOut(v6, 0.1)
	end

	TeleportScene(1)
end

local function CompleteTrial(_)
	_G.BlockingClickToMove = false

	if v6 then
		Util.Sound:FadeOut(v6, 0.1)
	end

	maid2:DoCleaning()
	maid:DoCleaning()
end

local part = nil

local function ShowDoor(data)
	local on = data.On
	local door = data.Door
	local trialOn = data.TrialOn

	if on then
		if part then
			print("had door")
			return
		end

		local child = game.ReplicatedStorage:WaitForChild(trialOn, 2)

		if not child then
			print("no trial lol")
			return
		end

		part = Instance.new("Part", workspace)
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = true
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Size = createVector(33.849, 77.018, 34.287)
		part.CFrame = door.CFrame * CFrame.new(0, 0, 0.1)
		child:GetAttributeChangedSignal("Player"):Connect(function()
			if child:GetAttribute("Player") ~= game.Players.LocalPlayer.Name and part then
				part:Destroy()
				part = nil
			end
		end)
		child.AncestryChanged:Once(function()
			if part then
				part:Destroy()
				part = nil
			end
		end)
	elseif part then
		part:Destroy()
		part = nil
	end
end

local v7 = {
	StartTrial = StartTrial,
	CollectRelic = CollectRelic,
	DeliverRelic = DeliverRelic,
	Explode = Explode,
	TeleportOut = TeleportOut,
	CompleteTrial = CompleteTrial,
	ShowDoor = ShowDoor,
	TeleportTrial = TeleportTrial
}
return function(p)
	if v7[p.Mode] then
		v7[p.Mode](p)
	end
end