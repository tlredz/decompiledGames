local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local ParticipantDirectory = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("ParticipantDirectory"))
local movement = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Movement")
local BodyFacingConfig = require(movement:WaitForChild("BodyFacingConfig"))
local BodyFacingModel = require(movement:WaitForChild("BodyFacingModel"))
local AnimationPolicy = require(game.ReplicatedStorage.ChickenOrHero:WaitForChild("Animation"):WaitForChild("AnimationPolicy"))
local AnimationLibrary = require(game.ReplicatedStorage.ChickenOrHero.Animation.AnimationLibrary)
local v = AnimationLibrary.prepare()
local animationId = v.Stop and v.Stop.animation.AnimationId
local v2 = {}

for _, v3 in {
	"Idle",
	"Walk",
	"Run",
	"Left",
	"Right",
	"Back"
} do
	local v4 = v[v3]

	if v4 then
		v2[v4.animation.AnimationId] = true
	end
end

local DashAnimationPolicy = require(game.ReplicatedStorage.ChickenOrHero.Animation:WaitForChild("DashAnimationPolicy"))
local v3 = {}

for k, v4 in v do
	if DashAnimationPolicy.isName(k) then
		v3[v4.animation.AnimationId] = true
	end
end

local v4 = {}
local connections = {}
local v5 = {}
local v6 = {}
local total = 1

local function restore(p)
	for _, joint in p.joints do
		if joint.motor.Parent and joint.applied and joint.motor.Transform == joint.applied then
			joint.motor.Transform = joint.base
		end

		joint.applied = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(value)
	local v7 = type(value) == "number" and value or value.UserId
	local v8 = v4[v7]

	if v8 then
		restore(v8)
		v4[v7] = nil
	end
end

local function record(player)
	local character = player.Character
	local v7 = v4[player.UserId]

	if v7 and v7.character == character and character:IsDescendantOf(workspace) then
		local v8

		if v7.humanoid.Parent == character then
			v8 = v7.root.Parent == character
		else
			v8 = false
		end

		for _, joint in v7.joints do
			v8 = v8 and joint.motor:IsDescendantOf(character)
		end

		if v8 then
			return v7
		end
	end

	remove(player) -- equivalent call inferred; original call site unknown

	if not (character and character:IsDescendantOf(workspace)) then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("Torso")

	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 or not (humanoidRootPart and torso) then
		return
	end

	local rootJoint = humanoidRootPart:FindFirstChild("RootJoint")
	local neck = torso:FindFirstChild("Neck")
	local leftHip = torso:FindFirstChild("Left Hip")
	local rightHip = torso:FindFirstChild("Right Hip")

	if not (rootJoint and neck and leftHip and rightHip) then
		return
	end

	local v8 = {
		character = character,
		humanoid = humanoid,
		root = humanoidRootPart,
		state = {},
		joints = {},
		version = character:GetAttribute("MovementReset")
	}

	for k, motor in {
		torso = rootJoint,
		head = neck,
		left = leftHip,
		right = rightHip
	} do
		v8.joints[k] = {
			motor = motor,
			base = motor.Transform
		}
	end

	v4[player.UserId] = v8
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function overlay(state, p)
	local motor = state.motor
	state.base = motor.Transform
	local rotation = motor.C0.Rotation
	motor.Transform = rotation:Inverse() * p * rotation * state.base
	state.applied = motor.Transform
end

table.insert(connections, Players.PlayerRemoving:Connect(remove))
table.insert(connections, RunService.PreAnimation:Connect(function()
	for _, v7 in v4 do
		restore(v7)
	end
end))
table.insert(connections, RunService.PreSimulation:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		table.clear(v5)
		table.clear(v6)

		for _, v7 in ParticipantDirectory.list() do
			if type(v7.UserId) ~= "number" then
				continue
			end

			table.insert(v5, v7)
			v6[v7.UserId] = v7
		end

		for k, v7 in v4 do
			if v6[k] and v7.character:IsDescendantOf(workspace) then
				continue
			end

			remove(k) -- equivalent call inferred; original call site unknown
		end
	end

	for _, v7 in v5 do
		local v8 = record(v7)

		if not v8 then
			continue
		end

		restore(v8)
		local character = v8.character
		local humanoid = v8.humanoid
		local root = v8.root
		local sit = type(v7) == "table" and v7.IsBot and v7:GetAttribute("GameRole") ~= "Catcher" or not BodyFacingConfig.Enabled

		if not sit then
			if humanoid.Health <= 0 then
				sit = true
			else
				sit = humanoid.Sit or humanoid.PlatformStand or root.Anchored

				if not sit then
					if character:GetAttribute("MovementLocked") == true or character:GetAttribute("TackleActive") == true then
						sit = true
					elseif v7 == localPlayer then
						sit = v7:GetAttribute("ReleaseCameraForUI") == true or game.GuiService.MenuIsOpen
					else
						sit = false
					end
				end
			end
		end

		local movementReset = character:GetAttribute("MovementReset")

		if sit or movementReset ~= v8.version then
			v8.state = {}
			v8.lastTravel = nil
			v8.gazePitch = nil
			v8.version = movementReset
		end

		if sit then
			continue
		end

		local v10 = root.CFrame.LookVector * createVector(1, 0, 1)

		if v10.Magnitude < 0.001 then
			continue
		end

		local lastTravel = root.AssemblyLinearVelocity * createVector(1, 0, 1)
		local gazePitch = (v7 ~= localPlayer or not workspace.CurrentCamera) and 0 or math.asin((math.clamp(
			workspace.CurrentCamera.CFrame.LookVector.Y,
			-1,
			1
		)))

		if type(v7) == "table" and v7.IsBot then
			local reachPhase = character:GetAttribute("ReachPhase")
			local v11

			if reachPhase == "Windup" or reachPhase == "Active" then
				v11 = false
			else
				v11 = v6[character:GetAttribute("BotPursuitTarget")]
			end

			local character2 = v11 and v11.Character
			local head = character2 and (character2:FindFirstChild("Head") or character2:FindFirstChild("HumanoidRootPart"))
			local head2 = character:FindFirstChild("Head")
			local v12

			if head and head2 and v11:GetAttribute("RunState") == "Active" then
				local v13 = head.Position - head2.Position
				v12 = math.atan2(v13.Y, (v13 * createVector(1, 0, 1)).Magnitude)
			else
				v12 = 0
			end

			v8.gazePitch = (v8.gazePitch or 0) + (v12 - (v8.gazePitch or 0)) * (1 - math.exp(-BodyFacingConfig.BodyFollowRate * math.min(
				dt,
				0.1
			)))
			gazePitch = v8.gazePitch
		end

		local playingAnimationTracks = nil
		local v11

		if v7 == localPlayer then
			v11 = character:GetAttribute("AnimationPackActive") == true
		else
			v11 = false
		end

		if v7 ~= localPlayer then
			local animator = humanoid:FindFirstChildOfClass("Animator")

			if animator then
				playingAnimationTracks = animator:GetPlayingAnimationTracks()

				for _, playingAnimationTrack in playingAnimationTracks do
					if not (playingAnimationTrack.Animation and v2[playingAnimationTrack.Animation.AnimationId] and playingAnimationTrack.WeightCurrent > 0.01) then
						continue
					end

					v11 = true
					break
				end
			end
		end

		local v12 = character:GetAttribute("AnimationAction") == "Stop"

		if v11 and v7 ~= localPlayer then
			for _, v14 in playingAnimationTracks or {} do
				if not ((v14.Name == "CoH_Stop" or animationId and v14.Animation.AnimationId == animationId) and v14.WeightCurrent > 0.05) then
					continue
				end

				v12 = true
				break
			end
		end

		if v12 and v8.lastTravel then
			lastTravel = v8.lastTravel
		elseif lastTravel.Magnitude >= BodyFacingConfig.MovementThreshold then
			v8.lastTravel = lastTravel
		end

		local v13 = not v11 and 1 or AnimationPolicy.poseScale(AnimationPolicy.angle(lastTravel, v10)) or 1
		local v14 = BodyFacingModel.step(v8.state, lastTravel, v10.Unit, gazePitch, dt, BodyFacingConfig)
		v14.torso *= v13
		v14.hip *= v13
		v14.head *= v13
		local dashVisualFacing = character:GetAttribute("DashVisualFacing")

		if typeof(dashVisualFacing) == "Vector3" and dashVisualFacing.Magnitude > 0.01 then
			local animator = humanoid:FindFirstChildOfClass("Animator")
			local v15 = 0

			if animator then
				for _, v16 in animator:GetPlayingAnimationTracks() do
					if v16.Animation and v3[v16.Animation.AnimationId] then
						v15 = math.max(v15, v16.WeightCurrent)
					end
				end
			end

			if v15 > 0 then
				local v16 = math.clamp(v15, 0, 1)
				local yaw = DashAnimationPolicy.yaw(v10.Unit, dashVisualFacing)
				local v17 = math.atan2(math.sin(yaw - v14.torso), (math.cos(yaw - v14.torso)))
				v14.torso += v17 * v16
				v14.hip *= 1 - v16
				v14.head *= 1 - v16
				v14.pitch *= 1 - v16
			end
		end

		overlay(v8.joints.torso, CFrame.Angles(0, v14.torso, 0)) -- equivalent call inferred; original call site unknown
		local motor = v8.joints.torso.motor
		local cframe2 = motor.C0 * motor.Transform * motor.C1:Inverse()
		local vectorToObjectSpace = cframe2:VectorToObjectSpace(createVector(0, 1, 0))
		local vectorToObjectSpace2 = cframe2:VectorToObjectSpace(createVector(1, 0, 0))
		overlay(
			v8.joints.head,
			CFrame.fromAxisAngle(vectorToObjectSpace, v14.head) * CFrame.fromAxisAngle(vectorToObjectSpace2, v14.pitch)
		) -- equivalent call inferred; original call site unknown
		overlay(v8.joints.left, CFrame.fromAxisAngle(vectorToObjectSpace, v14.hip)) -- equivalent call inferred; original call site unknown
		overlay(v8.joints.right, CFrame.fromAxisAngle(vectorToObjectSpace, v14.hip)) -- equivalent call inferred; original call site unknown

		if v7 ~= localPlayer then
			continue
		end

		character:SetAttribute("FacingTravelAngle", v14.angle)
		character:SetAttribute("FacingGait", v14.gait)
		character:SetAttribute("FacingTorsoYaw", (math.deg(v14.torso)))
	end
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	for _, v7 in v4 do
		restore(v7)
	end

	table.clear(v4)
	table.clear(v5)
	table.clear(v6)
end)