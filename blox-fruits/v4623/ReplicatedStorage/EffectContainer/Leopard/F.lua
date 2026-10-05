local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fDashParticles = FX:WaitForChild("LeopardEffects").FDashParticles
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

local function insertSoundInto(p, p2)
	local clone = fDashParticles[p2]:Clone()
	return (Util.UtilSoundWrapper.Play(clone, p))
end

local v = {
	RightFoot = 0,
	RightLowerLeg = 1,
	RightUpperLeg = 1,
	LeftFoot = 0,
	LeftLowerLeg = 1,
	LeftUpperLeg = 1,
	UpperTorso = 1,
	LowerTorso = 1,
	Head = 1,
	LeftUpperArm = 1,
	LeftLowerArm = 1,
	LeftHand = 0,
	RightUpperArm = 1,
	RightLowerArm = 1,
	RightHand = 0
}

local function showTeleportParticles(parent, position, rotation)
	local rotation2 = rotation.Rotation
	local position2 = parent.HumanoidRootPart.Position
	local cFrame = parent.HumanoidRootPart.CFrame
	local model = Instance.new("Model")
	model.Name = "CharacterClone"
	local clones = {}

	for _, child in ipairs(parent:GetChildren()) do
		local v2 = v[child.Name]

		if not v2 then
			continue
		end

		local clone = child:Clone()

		if clone.ClassName == "MeshPart" then
			clone.TextureID = ""
		end

		local face = clone.Name == "Head" and clone:FindFirstChild("face")

		if face then
			face:Destroy()
		end

		clone.Transparency = 0.7
		clone.Color = Color3.new(0, 0, 0)
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone:ClearAllChildren()

		if v2 == 1 then
			local clone2 = script.TeleportLines1:Clone()
			clone2.Parent = clone
			clone2:Emit(clone2:GetAttribute("EmitCount"))
			local clone3 = script.TeleportLines2:Clone()
			clone3.Parent = clone
			clone3:Emit(clone3:GetAttribute("EmitCount"))
		end

		table.insert(clones, clone)
		clone.CFrame = cFrame:toWorldSpace(rotation2 * cFrame:toObjectSpace(clone.CFrame))
		clone.CFrame = clone.CFrame - clone.Position + position + (clone.Position - position2)
		clone.Parent = model
	end

	model.Parent = _WorldOrigin
	heartbeatLoopFor2(0.35, function(_, _, p)
		local transparency = 0.7 + 0.3 * p

		for _, v3 in ipairs(clones) do
			v3.Transparency = transparency
			v3.Position = position + (v3.Position - position) * 1.02
			v3.Size *= 1.02
		end
	end, function()
		task.wait(0.5)
		model:Destroy()
	end)
end

local ImpactBall = require(script.Parent:WaitForChild("Modules").ImpactBall)
return function(data)
	local player = data.player
	local hrp = data.hrp
	local origin = data.origin
	local fireDir = data.fireDir
	local forwardCylinderRadius = data.forwardCylinderRadius
	local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint
	local victimExists = data.victimExists
	local endPoint = data.endPoint
	local transformedRig = data.transformedRig

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local v2 = origin + createVector(0, 2, 0)
	hrp.CFrame += createVector(0, 2, 0)
	local v3 = endPoint + createVector(0, 1, 0)

	if (v2 - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	local leopardDashPoseTransformed = nil
	local leopardCDash

	if player == localPlayer and hrp.Anchored == false then
		leopardCDash = Util.Anims:Get(hrp.Parent, "LeopardCDash")
		leopardCDash.Looped = true
		leopardCDash.Priority = Enum.AnimationPriority.Action
		leopardCDash:Play()
		leopardCDash:AdjustWeight(11, 0)

		if transformedRig then
			leopardDashPoseTransformed = Util.Anims:Get(transformedRig, "LeopardDashPoseTransformed")
			leopardDashPoseTransformed.Looped = true
			leopardDashPoseTransformed.Priority = Enum.AnimationPriority.Action2
			leopardDashPoseTransformed:Play()
			leopardDashPoseTransformed:AdjustWeight(11, 0)
		end
	else
		leopardCDash = nil
	end

	task.wait()
	local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
	local v4 = CharacterTransparency:AddStack(hrp.Parent, "LeopardFInvis", 2)
	task.delay(timeUntilReachedEndPoint, function()
		v4:Destroy()
	end)
	local forwardCylinderLength = data.forwardCylinderLength
	local distTravelledForward = data.distTravelledForward
	local v5 = transformedRig and 6 or 4
	local v6 = {}
	local v7

	if victimExists == true then
		v7 = math.clamp(math.ceil(distTravelledForward / forwardCylinderLength * v5), 1, v5)
	else
		v7 = v5
	end

	local v8 = 2 * random:NextInteger(0, 1) - 1

	for i = 1, v7 - 1 do
		local v9 = (0.4 + 0.6 * math.random()) * forwardCylinderRadius
		v6[i] = CFrame.lookAt(v2, v2 + fireDir):PointToWorldSpace((Vector3.new(
			v9 * v8,
			0,
			-forwardCylinderLength * i / v5
		)))
		v8 *= -1
	end

	v6[v7] = v3
	local position = hrp.Position
	local v9 = 1
	local v10 = v6[v9]
	showTeleportParticles(hrp.Parent, hrp.CFrame.Position, hrp.CFrame.Rotation)
	heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
		local v11 = math.clamp(math.ceil(p * #v6), 1, v5)

		if v9 ~= v11 then
			v9 = v11
			position = v10
			v10 = v6[v9]
			local cframe = CFrame.lookAt(position, position + 2 * (v10 - position))
			showTeleportParticles(hrp.Parent, cframe.Position, cframe.Rotation)
			local clone = FX:WaitForChild("LeopardEffects").FDashParticles:Clone()
			clone.CFrame = cframe
			clone.Parent = _WorldOrigin
			destroyAfter(clone, 2)
			local position2 = clone.Position
			local clone2 = fDashParticles.FWoosh:Clone()
			Util.UtilSoundWrapper.Play(clone2, position2)

			if transformedRig then
				clone.TeleportLines1.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
				clone.TeleportLines2.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
				clone.TeleportLines3.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))

				for _, child in ipairs(clone.AttachmentEmitters:GetChildren()) do
					child.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
				end
			end

			clone.TeleportLines1:Emit(clone.TeleportLines1:GetAttribute("EmitCount"))
			clone.TeleportLines2:Emit(clone.TeleportLines2:GetAttribute("EmitCount"))
			clone.TeleportLines3:Emit(clone.TeleportLines3:GetAttribute("EmitCount"))

			for _, child in ipairs(clone.AttachmentEmitters:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end)

	if player == localPlayer and hrp.Anchored == false then
		local position2 = hrp.Position
		local position3 = hrp.Position
		local v11 = 1
		local v12 = v6[v11]
		local connection = nil
		connection = heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
			local v13 = math.clamp(math.ceil(p * #v6), 1, v5)

			if v11 ~= v13 then
				v11 = v13
				position3 = v12
				v12 = v6[v11]
			end

			local v14 = position3 + (v12 - position3) * (p - (v11 - 1) / #v6) * #v6
			local cframe = CFrame.lookAt(v14, position3 + 2 * (v12 - position3))
			local ray, _, _ = Util.Ray(
				position2,
				cframe.Position - position2,
				{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
				false
			)

			if ray == nil then
				hrp.CFrame = cframe
				position2 = cframe.Position
			else
				connection:Disconnect()
				connection = nil
			end
		end, function()
			local cframe = CFrame.lookAt(v3, v3 + fireDir)
			local ray, _, _ = Util.Ray(
				position2,
				cframe.Position - position2,
				{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
				false
			)

			if ray == nil then
				hrp.CFrame = cframe
				position2 = cframe.Position
			else
				connection:Disconnect()
				connection = nil
			end
		end)
		task.delay(timeUntilReachedEndPoint, function()
			if leopardCDash then
				leopardCDash:Stop()
			end

			if leopardDashPoseTransformed then
				leopardDashPoseTransformed:Stop()
			end

			if victimExists then
				if transformedRig then
					local leopardKickTransformed = Util.Anims:Get(transformedRig, "LeopardKickTransformed")
					leopardKickTransformed.Looped = false
					leopardKickTransformed.Priority = Enum.AnimationPriority.Action2
					leopardKickTransformed:Play()
					leopardKickTransformed:AdjustWeight(11, 0)
					leopardKickTransformed:AdjustSpeed(2.5)
				else
					local leopardXKick = Util.Anims:Get(hrp.Parent, "LeopardXKick")
					local stoppedConnection = nil
					stoppedConnection = leopardXKick.Stopped:Connect(function()
						stoppedConnection:Disconnect()
						leopardXKick:Play(100)
						leopardXKick:Stop()
					end)
					leopardXKick.Looped = false
					leopardXKick.Priority = Enum.AnimationPriority.Action2
					leopardXKick:Play()
					leopardXKick:AdjustWeight(11, 0)
				end
			end
		end)
	end

	task.wait(timeUntilReachedEndPoint)

	if victimExists == false then
		return
	end

	if (v3 - Workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
		Util.CameraShaker:ShakeOnce(9, 9, 0.01, 0.4)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "LeopardCBloom"
		bloomEffect.Intensity = 4
		bloomEffect.Threshold = 0.4
		bloomEffect.Size = 64
		bloomEffect.Parent = Lighting
		heartbeatLoopFor2(0.4, function(_, _, p)
			bloomEffect.Intensity = 4 - 4 * p
			bloomEffect.Threshold = 0.4 + 0.6 * p
			bloomEffect.Size = 64 - 64 * p
		end, function()
			bloomEffect:Destroy()
		end)
	end

	local clone = FX:WaitForChild("LeopardEffects").ImpactBall:Clone()
	clone.CFrame = CFrame.lookAt(v3, v3 + fireDir)
	clone.Parent = _WorldOrigin
	local position2 = clone.Position
	local clone2 = fDashParticles.FExplosion:Clone()
	Util.UtilSoundWrapper.Play(clone2, position2)
	ImpactBall(
		clone,
		FX:WaitForChild("LeopardEffects").ImpactBallFX,
		0.25,
		clone.CFrame.Position,
		clone.CFrame.LookVector * 1480,
		0
	)
end