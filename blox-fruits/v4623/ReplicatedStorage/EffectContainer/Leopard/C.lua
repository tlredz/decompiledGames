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
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cEnemyHit = FX:WaitForChild("LeopardEffects").CEnemyHit
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

-- equivalent calls inferred from this helper; original call sites unknown
local function randPointHalfCircle(p)
	local v = p * math.sqrt((math.random()))
	local v2 = 3.141592653589793 * math.random()
	return (Vector3.new(math.cos(v2) * v, math.sin(v2) * v, 0))
end

local function randPointHalfCylinder(p, p2, p3, p4)
	local v = randPointHalfCircle(p3) -- equivalent call inferred; original call site unknown
	return p + CFrame.lookAt(createVector(0, 0, 0), p2):VectorToWorldSpace(v) + p2 * p4 * math.random()
end

local function insertSoundInto(p, p2)
	local clone = cEnemyHit[p2]:Clone()
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
	local position3 = clones[1].Position
	local clone = cEnemyHit.Teleport:Clone()
	Util.UtilSoundWrapper.Play(clone, position3)
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

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v2 = modelScale2 == nil and 1 or modelScale2
	local v3 = p or folder:GetPivot().Position
	local v4 = modelScale / v2

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v5 = part.CFrame - position
		local v6 = position - v3
		part.Size *= Vector3.new(v4, v4, v4)
		part.CFrame = v5 + v3 + v6 * v4
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local GroundCrack = require(script.Parent:WaitForChild("Modules"):WaitForChild("GroundCrack"))
local v2 = { "rbxassetid://9921859745" }
local v3 = { "rbxassetid://9929703731" }
local WindBall = require(script.Parent:WaitForChild("Modules").WindBall)
return function(data)
	local player = data.player
	local hrp = data.hrp
	local origin = data.origin
	local fireDir = data.fireDir
	local forwardCylinderRadius = data.forwardCylinderRadius
	local forwardCylinderLength = data.forwardCylinderLength
	local endsAfter = data.endsAfter
	local transformedRig = data.transformedRig
	local v4 = origin + createVector(0, 4, 0)

	if hrp == nil or hrp.Parent == nil or (v4 - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
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
	local parent

	if transformedRig then
		parent = FX:WaitForChild("LeopardEffects").LeopardRig:Clone()
		parent.Name = "LeopardRigClone"
		parent.PrimaryPart = parent.RootPart
	else
		parent = Instance.new("Model")
		parent.Name = "CharacterClone"

		for _, child in ipairs(hrp.Parent:GetChildren()) do
			if v[child.Name] and child:IsA("BasePart") then
				local clone = child:Clone()

				if clone.ClassName == "MeshPart" then
					clone.TextureID = ""
				end

				clone.Anchored = true
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone:ClearAllChildren()
				clone.Parent = parent
			elseif child:IsA("Accessory") and child:FindFirstChild("Handle") ~= nil then
				local clone = child:Clone()
				clone.Handle.Anchored = true

				for _, child2 in ipairs(clone.Handle:GetChildren()) do
					if child2.ClassName == "WrapLayer" then
						clone.Handle:Destroy()
						break
					elseif child2.ClassName ~= "SurfaceAppearance" then
						child2:Destroy()
					end
				end

				clone.Parent = parent
			end
		end

		parent.PrimaryPart = parent.UpperTorso
	end

	parent.Parent = _WorldOrigin
	destroyAfter(parent, endsAfter * 2)

	if transformedRig then
		local leopardDashPoseTransformed2 = Util.Anims:Get(parent, "LeopardDashPoseTransformed")
		leopardDashPoseTransformed2.Looped = true
		leopardDashPoseTransformed2.Priority = Enum.AnimationPriority.Action2
		leopardDashPoseTransformed2:Play()
		leopardDashPoseTransformed2:AdjustWeight(11, 0)
	end

	local cFrame = hrp.CFrame
	local v6 = 0.05 * forwardCylinderLength
	local v7 = randPointHalfCircle(forwardCylinderRadius) -- equivalent call inferred; original call site unknown
	local v9 = CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	) + v4 + CFrame.lookAt(createVector(0, 0, 0), fireDir):VectorToWorldSpace(v7) + fireDir * v6
	showTeleportParticles(hrp.Parent, cFrame.Position, cFrame.Rotation)
	local v10 = math.floor(endsAfter * 0.9 * 10)
	local v11 = 1 / (v10 + 1)
	local v12 = 0
	heartbeatLoopFor2(endsAfter * 0.9, function(_, _, p)
		if not (v12 <= p and p < v11) then
			v12 = v11
			v11 += 1 / (v10 + 1)
			local v13 = p * forwardCylinderLength
			local v14 = randPointHalfCircle(forwardCylinderRadius) -- equivalent call inferred; original call site unknown
			cFrame = v9
			v9 = CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			) + v4 + CFrame.lookAt(createVector(0, 0, 0), fireDir):VectorToWorldSpace(v14) + fireDir * v13
			showTeleportParticles(hrp.Parent, cFrame.Position, cFrame.Rotation)

			if math.random() < 0.5 then
				local clone = cEnemyHit:Clone()
				clone.CFrame = cFrame
				clone.Parent = _WorldOrigin
				destroyAfter(clone, 1)

				for _, child in ipairs(clone.Attachment:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
					Util.CameraShaker:ShakeOnce(3, 3, 0.01, 0.1)
				end

				local position = clone.Position
				local clone2 = cEnemyHit.CAirShockwave:Clone()
				Util.UtilSoundWrapper.Play(clone2, position)
			end
		end

		local v13 = (p - v12) / (v11 - v12)
		local v14 = createVector(0, 10, 0) * math.abs(-1 + (2 * v13 + 1) % 2)
		parent:SetPrimaryPartCFrame(cFrame:Lerp(v9, v13) + v14)
	end, function()
		heartbeatLoopFor2(endsAfter * 0.1, function(_, _, p)
			parent:SetPrimaryPartCFrame(v9:Lerp(hrp.CFrame, p))
		end, function()
			for _, part in ipairs(parent:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		end)
	end)
	local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
	local v13 = CharacterTransparency:AddStack(hrp.Parent, "LeopardCInvis", 2)
	task.delay(endsAfter, function()
		v13:Destroy()
		local clone = cEnemyHit.CLaunch:Clone()
		Util.UtilSoundWrapper.Play(clone, hrp)

		if not transformedRig then
			local clone2 = cEnemyHit.Parent.CHand.HandAttach:Clone()
			clone2.Parent = hrp.Parent.RightHand
			task.wait(data.timeUntilFinalBlast)
			clone2:Destroy()
		end
	end)

	if player == localPlayer and hrp.Anchored == false then
		local position = hrp.Position
		local connection = nil
		connection = heartbeatLoopFor2(endsAfter, function(_, _, p)
			local v14 = p * forwardCylinderLength
			local cFrame2 = CFrame.lookAt(v4, v4 + fireDir) * CFrame.new(0, 0, -v14)
			local ray, _, _ = Util.Ray(
				position,
				cFrame2.Position - position,
				{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
				false
			)

			if ray == nil then
				hrp.CFrame = cFrame2
				position = cFrame2.Position
			else
				connection:Disconnect()
				connection = nil
			end
		end)
		task.delay(endsAfter, function()
			if leopardCDash then
				leopardCDash:Stop()
			end

			if leopardDashPoseTransformed then
				leopardDashPoseTransformed:Stop()
			end

			local leopardCDive = Util.Anims:Get(hrp.Parent, "LeopardCDive")
			leopardCDive.Looped = false
			leopardCDive.Priority = Enum.AnimationPriority.Action
			leopardCDive:Play()
			local position2 = hrp.Position
			local position3 = hrp.Position
			local connection2 = nil
			connection2 = heartbeatLoopFor2(data.timeUntilFinalBlast, function(_, _, p)
				local cFrame2

				if p < 0.75 then
					local v15 = (p / 0.75) ^ 0.5
					cFrame2 = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -p * 45) * CFrame.Angles(
						-1.0995574287564276 * v15,
						0,
						0
					) + Vector3.new(0, 45 * v15 * (2 - v15), 0)
				else
					local v15 = (p - 0.75) / 0.25
					cFrame2 = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -p * 45) * CFrame.Angles(
						-1.7278759594743864,
						0,
						0
					) + Vector3.new(0, 45 * (1 - v15), 0)
				end

				local ray, _, _ = Util.Ray(
					position3,
					cFrame2.Position - position3,
					{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
					false
				)

				if ray == nil then
					hrp.CFrame = cFrame2
					position3 = cFrame2.Position
				else
					connection2:Disconnect()
					connection2 = nil
				end
			end, function()
				local cFrame2 = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -45)
				local ray, _, _ = Util.Ray(
					position3,
					cFrame2.Position - position3,
					{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
					false
				)

				if ray == nil then
					hrp.CFrame = cFrame2
					position3 = cFrame2.Position
				else
					connection2:Disconnect()
					connection2 = nil
				end
			end)
		end)
	end

	task.wait(endsAfter + data.timeUntilFinalBlast)

	if (hrp.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
		Util.CameraShaker:ShakeOnce(9, 9, 0.01, 0.6)
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

	local ray = Util.Ray
	local v14 = hrp.Position + createVector(0, 2, 0)
	local v15 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v16, v17, v18 = ray(v14, createVector(-0, -40, -0), v15, false)

	if v16 ~= nil then
		local v19 = CFrame.lookAt(createVector(0, 0, 0), v18) * inverse + v17
		local v20, v21 = GroundCrack(v3, v19, createVector(150, 0.075, 150), 0.15, Color3.fromRGB(765, 255, 0), 0.2)
		heartbeatLoopFor2(0.1, function(_, _, p)
			v21.Color3 = Color3.fromRGB(765 * (1 - 0.8 * p), 255 * (1 - 0.8 * p), 0)
		end, function()
			v21.Color3 = Color3.fromRGB(152.99999999999997, 50.999999999999986, 0)
			heartbeatLoopFor2(0.25, function(_, _, p)
				v21.Color3 = Color3.fromRGB(152.99999999999997 * (1 - p), 50.999999999999986 * (1 - p), 0)
			end)
		end)
		heartbeatLoopFor2(0.35, function(_, _, p)
			v20.Size = createVector(150, 0.075, 150) * (1 + 1.4 * p ^ 0.5)
		end)
		local parent2, v23 = GroundCrack(v2, v19, createVector(100, 0.05, 100), 1, Color3.fromRGB(765, 255, 0), 0.35)
		local position = parent2.Position
		local clone = cEnemyHit.CExplosion:Clone()
		Util.UtilSoundWrapper.Play(clone, position)
		task.delay(0.02, function()
			local clone2 = script.RockEmitter:Clone()
			clone2.Parent = parent2

			for _ = 1, 4 do
				task.wait()
				clone2:Emit(14)
			end
		end)
		task.delay(0.5, function()
			heartbeatLoopFor2(0.5, function(_, _, p)
				v23.Color3 = Color3.fromRGB(765 * (1 - p), 255 * (1 - p), 0)
			end, function()
				v23.Color3 = Color3.fromRGB(0, 0, 0)
			end)
		end)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent2

		for _, child in ipairs(script.AttachmentEmitters:GetChildren()) do
			local clone2 = child:Clone()
			clone2.Parent = attachment
			clone2:Emit(clone2:GetAttribute("EmitCount"))
		end

		local groundSpike = FX:WaitForChild("LeopardEffects").GroundSpike

		for i = 0, 9 do
			local number = random:NextNumber(i * 2 * 3.141592653589793 / 10, (i + 1) * 2 * 3.141592653589793 / 10)
			local v24 = math.random()
			local v25 = 25 + 15 * v24
			local clone2 = groundSpike:Clone()
			local v26 = 0.5 + 2 * v24
			ScaleModel(clone2, v26)
			local v27 = v19 * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v25) * CFrame.Angles(
				-math.rad(20 + 25 * v24),
				0,
				0
			) * CFrame.new(0, -22 * v26, 0)
			clone2:PivotTo(v27)
			clone2.Parent = _WorldOrigin
			destroyAfter(clone2, 2)
			task.delay(random:NextNumber(0.4, 0.6), function()
				heartbeatLoopFor2(0.5, function(p, p2, p3)
					clone2.lavaGradient.Color = Color3.fromRGB(255 * (1 - p3), 128 * (1 - p3), 0)
				end, function()
					clone2.lavaGradient.Color = Color3.fromRGB(0, 0, 0)
				end)
			end)
			local v29 = clone2
			task.delay(1, function()
				heartbeatLoopFor2(0.35, function(p, p2, transparency)
					v29.lavaGradient.Transparency = transparency
					v29.Rocks.Transparency = transparency
				end, function()
					v29.lavaGradient.Transparency = 1
					v29.Rocks.Transparency = 1
				end)
			end)
			local v30 = clone2
			task.delay(random:NextNumber(0, 0.1), function()
				heartbeatLoopFor2(0.3, function(p, p2, p3)
					v30:PivotTo(v27 * CFrame.new(0, 22 * v26 * p3, 0))
				end)
			end)
		end
	end

	local clone = FX:WaitForChild("LeopardEffects").WindBall:Clone()
	clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), hrp.CFrame.LookVector * createVector(1, 0, 1)) + hrp.Position
	clone.Parent = _WorldOrigin
	WindBall(
		clone,
		FX:WaitForChild("LeopardEffects").FieryWindBallFX,
		1,
		clone.CFrame.Position,
		clone.CFrame.Rotation * (createVector(0, 0.7, -1)).Unit * 720,
		1224.8
	)
	local clone2 = cEnemyHit.FieryWindBall:Clone()
	Util.UtilSoundWrapper.Play(clone2, clone)
	local clone3 = FX:WaitForChild("LeopardEffects").WindBall:Clone()
	clone3.CFrame = CFrame.lookAt(createVector(0, 0, 0), hrp.CFrame.LookVector * createVector(1, 0, 1)) * CFrame.Angles(
		0,
		0.5235987755982988,
		0
	) + hrp.Position
	clone3.Parent = _WorldOrigin
	WindBall(
		clone3,
		FX:WaitForChild("LeopardEffects").FieryWindBallFX,
		1,
		clone3.CFrame.Position,
		clone3.CFrame.Rotation * (createVector(0, 0.7, -1)).Unit * 720,
		1224.8
	)
	local clone4 = FX:WaitForChild("LeopardEffects").WindBall:Clone()
	clone4.CFrame = CFrame.lookAt(createVector(0, 0, 0), hrp.CFrame.LookVector * createVector(1, 0, 1)) * CFrame.Angles(
		0,
		-0.5235987755982988,
		0
	) + hrp.Position
	clone4.Parent = _WorldOrigin
	WindBall(
		clone4,
		FX:WaitForChild("LeopardEffects").FieryWindBallFX,
		1,
		clone4.CFrame.Position,
		clone4.CFrame.Rotation * (createVector(0, 0.7, -1)).Unit * 720,
		1224.8
	)
end