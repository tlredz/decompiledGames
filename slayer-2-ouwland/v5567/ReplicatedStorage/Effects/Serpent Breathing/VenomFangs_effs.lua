local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.ParticleTween)
local Bezier = require(ReplicatedStorage.CAM.Client.Modules.Effects.Bezier)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")

local function TrailWidthTweenDown(folder, p: number)
	for _, descendant in folder:GetDescendants() do
		if descendant.ClassName ~= "Trail" then
			continue
		end

		local numberSequenceKeypoints = {}
		local v2 = {}

		for _, keypoint in descendant.WidthScale.Keypoints do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value, keypoint.Envelope)
			)
		end

		local numberSequence = NumberSequence.new(numberSequenceKeypoints)

		for _, keypoint in ipairs(numberSequence.Keypoints) do
			local v3 = math.clamp(keypoint.Value + 1, 0, 1)
			table.insert(v2, NumberSequenceKeypoint.new(keypoint.Time, v3))
		end

		local time = numberSequence.Keypoints[#numberSequence.Keypoints].Time
		local v3 = 0
		local heartbeatConnection = nil
		local v4 = tick()
		local v7 = descendant
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			v3 = tick() - v4
			local v8 = math.min(time, v3)
			local v9 = v8 / time / p
			local numberSequenceKeypoints2 = {}

			for i, keypoint in ipairs(numberSequence.Keypoints) do
				local v10 = keypoint.Value + (0 - keypoint.Value) * v9
				table.insert(numberSequenceKeypoints2, NumberSequenceKeypoint.new(keypoint.Time, v10))
			end

			v7.WidthScale = NumberSequence.new(numberSequenceKeypoints2)

			if time <= v8 then
				heartbeatConnection:Disconnect()
			end
		end)
	end
end

local AuraEffects = require(script.Parent.AuraEffects)
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
return function(instance, p, vector: Vector3, vector2: Vector3, vector3: Vector3)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 and p ~= "Cancel" then
		return
	end

	instance:FindFirstChild("RightHand")
	instance:FindFirstChild("LeftHand")
	string.format("%s VenomFangsKatanaEffects", instance.Name)

	if p == "Start" then
		AuraEffects.TurnOnAura(instance)
	elseif p == "Cancel" then
		AuraEffects.TurnOffAura(instance)
	elseif p == "Teleport" then
		AuraEffects.TurnOffAura(instance)
		local cframe = CFrame.lookAlong(vector, vector3)
		local cframe2 = CFrame.new(vector2, vector3)
		local clone = assets.Teleport:Clone()
		clone:PivotTo(cframe)
		clone.Parent = parent
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		local clone2 = assets.Teleport:Clone()
		clone2:PivotTo(cframe2)
		clone2.Parent = parent
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 2)
		vfxUtility.PlaySound(sounds, "PS2snakeVFtele1", clone.PrimaryPart, true)
		vfxUtility.PlaySound(sounds, "PS2snakeVFtele2", clone2.PrimaryPart, true)
		Cam_Shaker(cframe2.Position, "tinyshake_preset")
	elseif p == "Slash" then
		local clone = assets.Slash:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2snakeVFslashup", clone.PrimaryPart, true)

		for _, beam in clone:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(0.2), {
				Width0 = width0,
				Width1 = width1
			}):Play()
			local v2 = beam
			task.delay(beam:GetAttribute("EmitDuration"), function()
				TweenService:Create(v2, TweenInfo.new(0.3), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		Cam_Shaker(humanoidRootPart.Position, "activate_shake")

		for _ = 1, 6 do
			local clone2 = assets.SnakeTrail:Clone()
			clone2.Parent = parent
			vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
			local v2 = math.random(5, 7)
			local total = 0
			local v3 = humanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), -3, math.random(-8, -3))
			local v4 = humanoidRootPart.CFrame * CFrame.new(math.random(-5, 5), math.random(8, 12), 3)
			local heartbeatConnection = nil
			local v9 = humanoidRootPart.CFrame * CFrame.new(math.random(-6, 6), 4, math.random(-13, -9))
			local v10 = humanoidRootPart.CFrame * CFrame.new(math.random(-6, 6), 8, math.random(-8, -5))
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt * v2
				local cubicBezier = Bezier.CubicBezier(total, v3.Position, v9.Position, v10.Position, v4.Position)
				local cubicBezier2 = Bezier.CubicBezier(
					total + 0.01,
					v3.Position,
					v9.Position,
					v10.Position,
					v4.Position
				)

				if not (total >= 1) then
					clone2.CFrame = CFrame.new(cubicBezier, cubicBezier2)
					return
				end

				heartbeatConnection:Disconnect()
				clone2.Position = v4.Position
				DebrisModule:AddItem(clone2, 2)
			end)
		end
	elseif p == "Success" then
		AuraEffects.TurnOnAura(instance)
		local clone = assets.Snake:Clone()
		clone.Cube.CFrame = humanoidRootPart.CFrame * CFrame.new(3.95166015625, -2.8153228759765625, 9.244232177734375) * CFrame.fromEulerAnglesYXZ(
			0.09455974400043488,
			-2.851161003112793,
			-0.0006289904122240841
		)
		vfxUtility.WeldConstraint(humanoidRootPart, clone.PrimaryPart)
		clone.Parent = parent
		clone.Cube.Transparency = 1
		local snake = script.Animations.Snake
		clone.AnimationController:LoadAnimation(snake):Play()
		local clone2 = assets["Snake Head"]:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2, 0))
		vfxUtility.WeldConstraint(humanoidRootPart, clone2.PrimaryPart)
		clone2.Parent = parent
		local skeletonSnake = script.Animations["Skeleton Snake"]
		local track = clone2.AnimationController:LoadAnimation(skeletonSnake)
		track:Play()
		track:AdjustSpeed(1)
		task.wait(0.38333333333333336)
		local clone3 = assets.SwordThrust:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		clone3.Parent = parent
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 2)

		for _, part in clone2:GetChildren() do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
			end
		end

		DebrisModule:AddItem(clone2, 2)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
		TweenService:Create(clone.Cube, TweenInfo.new(0.45), {
			Transparency = 0
		}):Play()
		vfxUtility.PlaySound(sounds, "PS2snakeVFsnakebite", humanoidRootPart, true)
		task.wait(0.45)
		local clone4 = assets.SnakeBiteHitEffect:Clone()
		clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		clone4.Parent = parent
		vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 3)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		TweenService:Create(clone.Cube, TweenInfo.new(0.4), {
			Transparency = 1
		}):Play()
		DebrisModule:AddItem(clone, 1)
		AuraEffects.TurnOffAura(instance)
	end
end