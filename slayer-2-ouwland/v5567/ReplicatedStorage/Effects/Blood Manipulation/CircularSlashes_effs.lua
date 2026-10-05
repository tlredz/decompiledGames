game:GetService("CollectionService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ImpactFrames = require(ReplicatedStorage.CAM.Client.Modules.Effects.ImpactFrames)
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
local localPlayer = Players.LocalPlayer

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function QuadBezier(p, p2, p3, p4)
	local v2 = p2 + (p3 - p2) * p
	return v2 + (p3 + (p4 - p3) * p - v2) * p
end

local function TransparencyTween(beam, numberSequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in ipairs(numberSequence.Keypoints) do
		local v2 = math.clamp(keypoint.Value + 1, 0, 1)
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v2))
	end

	local time = numberSequence.Keypoints[#numberSequence.Keypoints].Time
	local lastTime = tick()
	local v2 = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		v2 = tick() - lastTime
		local v3 = math.min(time, v2)
		local v4 = v3 / time * p
		local numberSequenceKeypoints2 = {}

		for i, keypoint in ipairs(numberSequence.Keypoints) do
			local v5 = keypoint.Value + (numberSequenceKeypoints[i].Value - keypoint.Value) * v4
			table.insert(numberSequenceKeypoints2, NumberSequenceKeypoint.new(keypoint.Time, v5))
		end

		beam.Transparency = NumberSequence.new(numberSequenceKeypoints2)

		if time <= v3 then
			heartbeatConnection:Disconnect()
		end
	end)
end

local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
return function(instance, p, list)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 and p ~= "Cancel" then
		return
	end

	local upperTorso = instance:FindFirstChild("UpperTorso")
	local leftHand = instance:FindFirstChild("LeftHand")

	if p == "Success" then
		local playSound = vfxUtility.PlaySound
		local v4

		if table.find(list, localPlayer.Character) then
			v4 = workspace.CurrentCamera or humanoidRootPart
		else
			v4 = humanoidRootPart
		end

		playSound(sounds, "PS2bloodsickCIRCULARSLASHEScine", v4, true)
		local clone = assets.Bullet:Clone()
		clone.CFrame = upperTorso.CFrame
		clone.Parent = parent
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = upperTorso
		weldConstraint.Parent = clone
		local clone2 = assets.UltVFX:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3.192424774169922, -11.68400764465332) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		))
		vfxUtility.WeldConstraint(humanoidRootPart, clone2.PrimaryPart)
		clone2.Parent = parent
		task.delay(0.45, function()
			vfxUtility.EmitAll(clone2.Drift1, vfxUtility.Owned(instance))
		end)
		task.delay(0.68, function()
			local clone3 = assets.Wind:Clone()
			clone3.CFrame = upperTorso.CFrame
			clone3.Parent = parent
			vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
			local weldConstraint2 = Instance.new("WeldConstraint")
			local upperTorso2 = instance:FindFirstChild("UpperTorso")
			weldConstraint2.Part0 = clone3
			weldConstraint2.Part1 = upperTorso2
			weldConstraint2.Parent = clone3
			task.wait(0.5)
			vfxUtility.EnableAll(clone3, false)
			DebrisModule:AddItem(clone3, 2)
		end)
		task.delay(0.866, function()
			vfxUtility.EmitAll(clone2.Drift2, vfxUtility.Owned(instance))
			task.wait(0.3)
			vfxUtility.EnableAll(clone, false)
			local clone3 = assets.HandVFX:Clone()
			clone3.CFrame = leftHand.CFrame
			clone3.Parent = parent
			local weldConstraint2 = Instance.new("WeldConstraint")
			weldConstraint2.Part0 = clone3
			weldConstraint2.Part1 = leftHand
			weldConstraint2.Parent = clone3
			task.wait(0.3)

			if localPlayer.Character and table.find(list, localPlayer.Character) then
				ImpactFrames.PlaySet({
					FrameRate = 0.016666666666666666,
					FramesSetName = "BloodSickles_Part1"
				})
			end

			for _, beam in clone3:GetDescendants() do
				if beam:IsA("Beam") then
					TransparencyTween(beam, NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.0261519, 1),
						NumberSequenceKeypoint.new(0.420922, 0.51875),
						NumberSequenceKeypoint.new(0.803238, 0.95),
						NumberSequenceKeypoint.new(0.858032, 0.975),
						NumberSequenceKeypoint.new(1, 1)
					}), 2)
				end
			end

			DebrisModule:AddItem(clone3, 1)
			task.wait(0.4)
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		end)
		task.delay(2.2, function()
			vfxUtility.EmitAll(clone2["First Slash"], vfxUtility.Owned(instance))
		end)
		task.delay(2.25, function()
			vfxUtility.EmitAll(clone2.GroundLand, vfxUtility.Owned(instance))
		end)
		task.delay(2.85, function()
			vfxUtility.EmitAll(clone2["Second Slash"], vfxUtility.Owned(instance))
		end)
		task.delay(2.8, function()
			vfxUtility.EmitAll(clone2.Drift3, vfxUtility.Owned(instance))
		end)
		task.delay(3.2659, function()
			vfxUtility.EmitAll(clone2.Drift4, vfxUtility.Owned(instance))
		end)
		task.delay(3.417, function()
			vfxUtility.EnableAll(clone2["Third Slash ( Enable )"], true, vfxUtility.Owned(instance))
			task.wait(0.566)
			vfxUtility.EnableAll(clone2["Third Slash ( Enable )"], false)
		end)
		task.delay(3.983, function()
			vfxUtility.EmitAll(clone2.Drift5, vfxUtility.Owned(instance))
		end)
		task.delay(4.667, function()
			vfxUtility.EnableAll(clone2["Ground ( Enable )"], true, vfxUtility.Owned(instance))
			task.delay(0.3, function()
				vfxUtility.EnableAll(clone2["Ground ( Enable )"], false)
			end)
		end)
		task.delay(5.2, function()
			vfxUtility.EmitAll(clone2["Final Slash"], vfxUtility.Owned(instance))

			if localPlayer.Character and table.find(list, localPlayer.Character) then
				ImpactFrames.PlaySet({
					FrameRate = 0.01818181818181818,
					FramesSetName = "BloodSickles_Part2"
				})
			end
		end)
		task.delay(5.82, function()
			DebrisModule:AddItem(clone2, 1)
			vfxUtility.EnableAll(clone, false)
			DebrisModule:AddItem(clone, 3)
		end)
	elseif p == "Throw" then
		local clone = assets.ThrowEffect:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Parent = parent
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(sounds, "PS2bloodsickCIRCULARSLASHESthrow", clone, true)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")

		for _, v2 in pairs({ "Left", "Right" }) do
			local v3 = v2
			task.spawn(function()
				local clone2 = assets.Sickles:Clone()
				clone2.Parent = parent
				clone2.CFrame = humanoidRootPart.CFrame
				DebrisModule:AddItem(clone2, 3)
				local total = 0
				local cFrame = humanoidRootPart.CFrame
				local cframe = CFrame.lookAlong(list, humanoidRootPart.CFrame.LookVector)
				local v4 = CFrame.new((cframe.Position + humanoidRootPart.Position) / 2, cframe.LookVector) * CFrame.new(
					v3 == "Right" and 15 or -15,
					0,
					0
				)
				local v5 = false
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					total += dt * 2.2222222222222223
					local quadBezier = Bezier.QuadBezier(total, cFrame.Position, v4.Position, cframe.Position)
					local quadBezier2 = Bezier.QuadBezier(total + 0.01, cFrame.Position, v4.Position, cframe.Position)

					if total > 0.7 and not v5 then
						v5 = true
						vfxUtility.EnableAll(clone2, false)
					end

					if not (total >= 1) then
						clone2.CFrame = CFrame.new(quadBezier, quadBezier2)
						return
					end

					heartbeatConnection:Disconnect()
					clone2.CFrame = cframe
					DebrisModule:AddItem(clone2, 2)
					vfxUtility.EnableAll(clone2, false)
				end)
			end)
		end
	elseif p == "Comeback" then
		for _, v2 in pairs({ "Left", "Right" }) do
			local v3 = v2
			task.spawn(function()
				local cframe = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * -1)
				local clone = assets.Sickles:Clone()
				clone.Parent = parent
				clone.CFrame = cframe
				DebrisModule:AddItem(clone, 3)
				vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
				local total = 0
				local v4 = list
				local v5 = CFrame.new((cframe.Position + v4) / 2, cframe.LookVector) * CFrame.new(
					v3 == "Right" and 15 or -15,
					0,
					0
				)
				local v6 = false
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					total += dt * 2.857142857142857
					cframe = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * -1)
					local quadBezier = Bezier.QuadBezier(total, v4, v5.Position, cframe.Position)
					local quadBezier2 = Bezier.QuadBezier(total + 0.01, v4, v5.Position, cframe.Position)

					if total > 0.7 and not v6 then
						v6 = true
						vfxUtility.EnableAll(clone, false)
					end

					if not (total >= 1) then
						clone.CFrame = CFrame.new(quadBezier, quadBezier2)
						return
					end

					heartbeatConnection:Disconnect()
					clone.CFrame = cframe
					DebrisModule:AddItem(clone, 2)
					vfxUtility.EnableAll(clone, false)
				end)
				task.delay(0.35, function()
					local clone2 = assets.Startup:Clone()
					clone2.CFrame = humanoidRootPart.CFrame
					clone2.Parent = parent
					vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
					DebrisModule:AddItem(clone2, 1.25)
					vfxUtility.PlaySound(sounds, "PS2bloodsickBENDreturn", humanoidRootPart, true)
				end)
			end)
		end
	end
end