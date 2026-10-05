local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Modules.Component)
local LastInput = require(ReplicatedStorage.Modules.LastInput)
local Maid = require(ReplicatedStorage.Util.Maid)
local Net = require(ReplicatedStorage.Modules.Net)
local Sound = require(ReplicatedStorage.Util.Sound)
local v = {
	TAG = "ZiplineActiveRider",
	RIDE_WELD_NAME = "ZiplineRideWeld",
	TROLLEY_NAME = "Cylinder",
	ROPE_POINT_NAME = "RopePoint",
	HAND_POINT_NAME = "HandPoint",
	RIDE_START_CFRAME_ATTRIBUTE = "ZiplineRideStartCFrame",
	RIDE_TARGET_CFRAME_ATTRIBUTE = "ZiplineRideTargetCFrame",
	RIDE_START_TIME_ATTRIBUTE = "ZiplineRideStartTime",
	RIDE_DURATION_ATTRIBUTE = "ZiplineRideDuration",
	RIDE_SEGMENT_START_TIME_ATTRIBUTE = "ZiplineRideSegmentStartTime",
	RIDE_SEGMENT_START_ALPHA_ATTRIBUTE = "ZiplineRideSegmentStartAlpha",
	RIDE_SPEED_MULTIPLIER_ATTRIBUTE = "ZiplineRideSpeedMultiplier",
	RIDE_SEGMENT_VERSION_ATTRIBUTE = "ZiplineRideSegmentVersion",
	RIDE_INPUT_REMOTE = Net:RemoteEvent("SetZiplineRideInput"),
	RIDE_INPUT_RESEND_INTERVAL = 0.15,
	HAND_PRIORITY = 200,
	LEG_PRIORITY = 150,
	HAND_SMOOTH_TIME = 0.03,
	HAND_TARGET_Y_OFFSET = -0.35,
	ELBOW_POLE_DISTANCE = 2.5,
	ELBOW_BIAS_OUTWARD = 1,
	ELBOW_BIAS_DOWN = 0.75,
	ELBOW_BIAS_FORWARD = 0.35,
	MIN_REACH_FRACTION = 0.4,
	MAX_REACH_FRACTION = 0.97,
	MIN_ARM_REACH = 0.5,
	LEG_IK_WEIGHT = 0.75,
	LEG_SMOOTH_TIME = 0.05,
	BASE_LEG_TRAIL = 0.65,
	LEG_DRAG_PER_SPEED = 0.03,
	MAX_LEG_DRAG = 2.25,
	LEG_DRAG_STIFFNESS = 42,
	LEG_DRAG_DAMPING = 9,
	FORWARD_SPEED_MULTIPLIER = 1.6,
	DEFAULT_LEAN_ANGLE = 0.4188790204786391,
	BOOST_LEAN_ANGLE = 0.6632251157578453,
	LEAN_STIFFNESS = 30,
	LEAN_DAMPING = 5,
	SWING_MAX_ANGLE = 0.5235987755982988,
	SWING_STIFFNESS = 28,
	SWING_DAMPING = 4.5,
	SPRING_TIME_STEP = 0.004166666666666667,
	MAX_SPRING_CATCH_UP = 0.1,
	INPUT_DEAD_ZONE = 0.35,
	RIDE_SOUND = "JungleBonusMoments.BF_Jungle_Zipline_Loop_01",
	RIDE_SOUND_FADE_IN_DURATION = 0.1,
	RIDE_SOUND_FADE_OUT_DURATION = 0.15,
	LEAN_SOUND_INTERVAL = 0.25,
	LEAN_SOUNDS = table.freeze({
		"JungleBonusMoments.BF_Jungle_Zipline_Player_Leans_LeftRight_01",
		"JungleBonusMoments.BF_Jungle_Zipline_Player_Leans_LeftRight_02",
		"JungleBonusMoments.BF_Jungle_Zipline_Player_Leans_LeftRight_03"
	}),
	TOUCH_BUTTONS = table.freeze({ table.freeze({
			action = "ZiplineLeanLeft",
			label = "Lean L",
			input = "left",
			position = UDim2.fromScale(0.15, 0.3)
		}), table.freeze({
			action = "ZiplineBoost",
			label = "Speed",
			input = "boost",
			position = UDim2.fromScale(0.5, 0.3)
		}), table.freeze({
			action = "ZiplineLeanRight",
			label = "Lean R",
			input = "right",
			position = UDim2.fromScale(0.85, 0.3)
		}) })
}
local v2 = Component.new({
	Tag = v.TAG
})
local v3 = nil

local function getMoveVector()
	if not v3 then
		local success, result = pcall(function()
			local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
			local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

			if not playerModule then
				return nil
			end

			local module = require(playerModule)
			return (module:GetControls())
		end)

		if success and result then
			v3 = result
		else
			return createVector(0, 0, 0)
		end
	end

	local success, result = pcall(function()
		return v3:GetMoveVector()
	end)

	if success and typeof(result) == "Vector3" then
		return result
	end

	return createVector(0, 0, 0)
end

local function bindTouchControls(maid)
	if not LastInput.IsMobile() then
		return nil
	end

	local success, result = pcall(function()
		return require(ReplicatedStorage.Controllers.UI.MobileUIController)
	end)

	if not (success and result) then
		return nil
	end

	local v4 = {}

	for _, v5 in v.TOUCH_BUTTONS do
		local action = v5.action
		local input = v5.input
		local success2, result2 = pcall(function()
			result:UnbindContextButton(action)
			return result:CreateContextButton(action, function(p, p2)
				if p2 == Enum.UserInputState.Begin then
					v4[input] = true
				elseif p2 ~= Enum.UserInputState.Change then
					v4[input] = false
				end
			end)
		end)
		local v8 = input
		local v9 = action
		maid:GiveTask(function()
			v4[v8] = false
			pcall(function()
				result:UnbindContextButton(v9)
			end)
		end)

		if not (success2 and result2) then
			continue
		end

		result2.Position = v5.position
		result2.Button.Label.Text = v5.label
	end

	return function()
		return (Vector3.new((v4.right and 1 or 0) - (v4.left and 1 or 0), 0, v4.boost and -1 or 0))
	end
end

local function getPart(instance, childName: string)
	local part = instance:FindFirstChild(childName)

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function stepSpring(p: number, p2: number, p3: number, p4: number, p5: number, min: number, max: number, p6: number)
	local v4 = (p2 + (p3 - p) * p4 * p6) * math.exp(-p5 * p6)
	local v5 = math.clamp(p + v4 * p6, min, max)
	return v5, max <= v5 and v4 > 0 and 0 or v5 <= min and v4 < 0 and 0 or v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createFixedStepper()
	local v4 = 0
	return function(p, callback)
		v4 = math.min(v4 + p, v.MAX_SPRING_CATCH_UP)

		while v4 >= v.SPRING_TIME_STEP do
			v4 -= v.SPRING_TIME_STEP
			callback(v.SPRING_TIME_STEP)
		end
	end
end

local function createAttachmentTarget(maid, parent, name: string, cframe: CFrame)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.CFrame = parent.CFrame:ToObjectSpace(cframe)
	attachment.Parent = parent
	maid:GiveTask(attachment)
	return attachment
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createPositionIK(maid, parent, name: string, chainRoot, endEffector, attachment, attachment2, LEG_PRIORITY: number, LEG_SMOOTH_TIME: number, LEG_IK_WEIGHT: number?)
	local iKControl = Instance.new("IKControl")
	iKControl.Name = name
	iKControl.Type = Enum.IKControlType.Position
	iKControl.ChainRoot = chainRoot
	iKControl.EndEffector = endEffector
	iKControl.Target = attachment
	iKControl.Pole = attachment2
	iKControl.Priority = LEG_PRIORITY
	iKControl.SmoothTime = LEG_SMOOTH_TIME
	iKControl.Weight = LEG_IK_WEIGHT == nil and 1 or LEG_IK_WEIGHT
	iKControl.Parent = parent
	maid:GiveTask(iKControl)
end

local function getRide(humanoidRootPart)
	local instance = humanoidRootPart:FindFirstChild(v.RIDE_WELD_NAME)

	if not (instance and (instance:IsA("Weld") or instance:IsA("WeldConstraint"))) then
		return nil, nil
	end

	local part1

	if instance.Part0 == humanoidRootPart then
		part1 = instance.Part1
	else
		part1 = instance.Part0
	end

	if instance.Part0 ~= humanoidRootPart and instance.Part1 ~= humanoidRootPart then
		return nil, nil
	end

	if part1 and part1:IsA("BasePart") and part1.Name == v.TROLLEY_NAME then
		return part1, instance
	end

	return nil, nil
end

local function getRideRootCFrame(ride, weld, humanoidRootPart)
	if not weld:IsA("Weld") then
		return humanoidRootPart.CFrame
	end

	if weld.Part0 == ride and weld.Part1 == humanoidRootPart then
		return ride.CFrame * weld.C0 * weld.C1:Inverse()
	end

	if weld.Part1 == ride and weld.Part0 == humanoidRootPart then
		return ride.CFrame * weld.C1 * weld.C0:Inverse()
	end

	return humanoidRootPart.CFrame
end

local function readRideSegment(weld, attribute: number)
	local attribute2 = weld:GetAttribute(v.RIDE_SEGMENT_START_TIME_ATTRIBUTE)
	local attribute3 = weld:GetAttribute(v.RIDE_SEGMENT_START_ALPHA_ATTRIBUTE)
	local attribute4 = weld:GetAttribute(v.RIDE_SPEED_MULTIPLIER_ATTRIBUTE)
	local attribute5 = weld:GetAttribute(v.RIDE_SEGMENT_VERSION_ATTRIBUTE)

	if type(attribute2) ~= "number" then
		attribute2 = attribute
	end

	local v4 = type(attribute3) ~= "number" and 0 or attribute3
	local selected = type(attribute4) ~= "number" and 1 or attribute4

	if type(attribute5) == "number" then
		return attribute2, v4, selected, attribute5
	end

	return attribute2, v4, selected, 0
end

local function bindTrolleyMotion(maid, instance, weld, ride)
	local attribute = weld:GetAttribute(v.RIDE_START_CFRAME_ATTRIBUTE)
	local attribute2 = weld:GetAttribute(v.RIDE_TARGET_CFRAME_ATTRIBUTE)
	local attribute3 = weld:GetAttribute(v.RIDE_START_TIME_ATTRIBUTE)
	local attribute4 = weld:GetAttribute(v.RIDE_DURATION_ATTRIBUTE)

	if typeof(attribute) ~= "CFrame" or typeof(attribute2) ~= "CFrame" or type(attribute3) ~= "number" or type(attribute4) ~= "number" or attribute4 <= 0 then
		return nil
	end

	local v4, v5, playbackSpeed, v7 = readRideSegment(weld, attribute3)
	local v8 = Players.LocalPlayer.Character == instance
	local v9

	if v8 and weld:IsA("Weld") then
		v9 = weld
	else
		v9 = nil
	end

	local attachment = ride:FindFirstChild(v.ROPE_POINT_NAME)
	local v10 = attribute2.Position - attribute.Position
	local C0

	if v9 then
		C0 = v9.C0
	else
		C0 = nil
	end

	local position

	if attachment and attachment:IsA("Attachment") then
		position = attachment.Position
	else
		position = nil
	end

	local v11

	if v10.Magnitude > 0.01 then
		v11 = attribute.Rotation:VectorToObjectSpace(v10.Unit)
	else
		v11 = nil
	end

	local fixedStepper = createFixedStepper() -- equivalent call inferred; original call site unknown
	local v12

	if v8 then
		v12 = bindTouchControls(maid)
	else
		v12 = nil
	end

	local v13 = 0
	local v14 = 0
	local DEFAULT_LEAN_ANGLE = v.DEFAULT_LEAN_ANGLE
	local v15 = 0
	local v16 = false
	local v17 = 0
	local v18 = 0
	local v19 = 0
	local v20 = Sound:Play(v.RIDE_SOUND, ride, {
		fadeIn = v.RIDE_SOUND_FADE_IN_DURATION,
		group = "LowPriority"
	})
	maid:GiveTask(function()
		Sound:FadeOut(v20, v.RIDE_SOUND_FADE_OUT_DURATION)

		if v16 then
			v.RIDE_INPUT_REMOTE:FireServer(false)
		end

		if v9 and C0 and v9.Parent then
			v9.C0 = C0
		end
	end)
	return function(p)
		local serverTimeNow = workspace:GetServerTimeNow()
		local moveVector = getMoveVector()

		if v12 then
			local v21 = v12()
			local X

			if v21.X == 0 then
				X = moveVector.X
			else
				X = v21.X
			end

			local v23

			if v21.Z == 0 then
				v23 = moveVector.Z
			else
				v23 = v21.Z
			end

			moveVector = Vector3.new(X, 0, v23)
		end

		local attribute5 = weld:GetAttribute(v.RIDE_SEGMENT_VERSION_ATTRIBUTE)

		if (type(attribute5) ~= "number" and 0 or attribute5) ~= v7 then
			v4, v5, playbackSpeed, v7 = readRideSegment(weld, attribute3)
		end

		local v21 = math.clamp(v5 + (serverTimeNow - v4) / attribute4 * playbackSpeed, 0, 1)

		if v8 then
			local v22 = moveVector.Z <= -v.INPUT_DEAD_ZONE
			local v23 = not v22 and 1 or v.FORWARD_SPEED_MULTIPLIER
			local v24

			if playbackSpeed == v23 then
				v24 = false
			else
				v24 = serverTimeNow - v17 >= v.RIDE_INPUT_RESEND_INTERVAL
			end

			if v22 ~= v16 or v24 then
				v16 = v22
				v17 = serverTimeNow
				v.RIDE_INPUT_REMOTE:FireServer(v16)
			end
		end

		v20.PlaybackSpeed = playbackSpeed
		ride.CFrame = attribute:Lerp(attribute2, v21)

		if not (v9 and C0 and position and v11) then
			return
		end

		local X = moveVector.X
		local v22 = X <= -v.INPUT_DEAD_ZONE and 1 or v.INPUT_DEAD_ZONE <= X and -1 or 0

		if v22 ~= 0 and v22 ~= v18 and serverTimeNow - v19 >= v.LEAN_SOUND_INTERVAL then
			v19 = serverTimeNow
			Sound:Play(v.LEAN_SOUNDS[math.random(1, #v.LEAN_SOUNDS)], ride)
		end

		v18 = v22
		local v23 = v22 * v.SWING_MAX_ANGLE
		local BOOST_LEAN_ANGLE

		if v16 then
			BOOST_LEAN_ANGLE = v.BOOST_LEAN_ANGLE
		else
			BOOST_LEAN_ANGLE = v.DEFAULT_LEAN_ANGLE
		end

		fixedStepper(p, function(p2)
			local v24 = v13
			local v25 = v14
			local SWING_STIFFNESS = v.SWING_STIFFNESS
			local SWING_DAMPING = v.SWING_DAMPING
			local v27 = -v.SWING_MAX_ANGLE
			local SWING_MAX_ANGLE = v.SWING_MAX_ANGLE
			local v28 = (v25 + (v23 - v24) * SWING_STIFFNESS * p2) * math.exp(-SWING_DAMPING * p2)
			local v29 = math.clamp(v24 + v28 * p2, v27, SWING_MAX_ANGLE)
			local v30 = SWING_MAX_ANGLE <= v29 and v28 > 0 and 0 or v29 <= v27 and v28 < 0 and 0 or v28
			v13 = v29
			v14 = v30
			local v31 = DEFAULT_LEAN_ANGLE
			local v32 = v15
			local LEAN_STIFFNESS = v.LEAN_STIFFNESS
			local LEAN_DAMPING = v.LEAN_DAMPING
			local BOOST_LEAN_ANGLE2 = v.BOOST_LEAN_ANGLE
			local v34 = (v32 + (BOOST_LEAN_ANGLE - v31) * LEAN_STIFFNESS * p2) * math.exp(-LEAN_DAMPING * p2)
			local v35 = math.clamp(v31 + v34 * p2, 0, BOOST_LEAN_ANGLE2)
			local v36 = BOOST_LEAN_ANGLE2 <= v35 and v34 > 0 and 0 or v35 <= 0 and v34 < 0 and 0 or v34
			DEFAULT_LEAN_ANGLE = v35
			v15 = v36
		end)
		v9.C0 = CFrame.new(position) * CFrame.fromAxisAngle(v11, v13) * CFrame.new(-position) * C0 * CFrame.Angles(
			-DEFAULT_LEAN_ANGLE,
			0,
			0
		)
	end
end

local function getHandPoints(instance, p)
	local attachments = {}

	for _, attachment in instance:GetChildren() do
		if attachment:IsA("Attachment") and attachment.Name == v.HAND_POINT_NAME then
			table.insert(attachments, attachment)
		end
	end

	if #attachments ~= 2 then
		return nil
	end

	table.sort(attachments, function(a, b)
		return p.CFrame:PointToObjectSpace(a.WorldPosition).X < p.CFrame:PointToObjectSpace(b.WorldPosition).X
	end)
	return attachments
end

local function getShoulderAttachment(instance, p: string)
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if not (upperTorso and upperTorso:IsA("BasePart")) then
		upperTorso = nil
	end

	if not upperTorso then
		upperTorso = instance:FindFirstChild("Torso")

		if not (upperTorso and upperTorso:IsA("BasePart")) then
			upperTorso = nil
		end
	end

	if not upperTorso then
		return nil
	end

	local attachment = upperTorso:FindFirstChild((`{p}ShoulderRigAttachment`)) or upperTorso:FindFirstChild((`{p}ShoulderAttachment`))

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	return nil
end

local function getArmReach(instance, p: string, p2, p3)
	local part = instance:FindFirstChild((`{p}LowerArm`))

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	local v4

	if part then
		v4 = p2.Size.Y / 2 + part.Size.Y + p3.Size.Y / 2
	else
		v4 = p2.Size.Y
	end

	return (math.max(v4, v.MIN_ARM_REACH))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clampReach(vector2: Vector3, vector3: Vector3, p: number)
	local v4 = vector3 - vector2
	local magnitude = v4.Magnitude

	if magnitude < 0.001 then
		return vector2 + createVector(0, 1, 0) * (p * v.MIN_REACH_FRACTION)
	end

	local v5 = math.clamp(magnitude, p * v.MIN_REACH_FRACTION, p * v.MAX_REACH_FRACTION)
	return vector2 + v4 / magnitude * v5
end

local function solveElbowPole(cframe: CFrame, vector2: Vector3, vector3: Vector3, p: number)
	local v4 = vector3 - vector2
	local unit

	if v4.Magnitude > 0.001 then
		unit = v4.Unit
	else
		unit = cframe.UpVector
	end

	local unit2 = (cframe.RightVector * (v.ELBOW_BIAS_OUTWARD * p) - cframe.UpVector * v.ELBOW_BIAS_DOWN + cframe.LookVector * v.ELBOW_BIAS_FORWARD).Unit
	local v5 = unit2 - unit * unit2:Dot(unit)

	if v5.Magnitude < 0.01 then
		v5 = unit:Cross(cframe.LookVector)
	end

	if v5.Magnitude < 0.01 then
		v5 = unit:Cross(cframe.RightVector)
	end

	return vector2 + v4 * 0.5 + v5.Unit * v.ELBOW_POLE_DISTANCE
end

local function bindArmIK(maid, instance, parent, parent2, parent3, p: string, p2, callback)
	local part = instance:FindFirstChild((`{p}UpperArm`))

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if not part then
		part = instance:FindFirstChild((`{p} Arm`))

		if not (part and part:IsA("BasePart")) then
			part = nil
		end
	end

	local part2 = instance:FindFirstChild((`{p}Hand`))

	if not (part2 and part2:IsA("BasePart")) then
		part2 = nil
	end

	if not part2 then
		part2 = instance:FindFirstChild((`{p} Arm`))

		if not (part2 and part2:IsA("BasePart")) then
			part2 = nil
		end
	end

	if not (part and part2) then
		return nil
	end

	local shoulderAttachment = getShoulderAttachment(instance, p)
	local part3 = instance:FindFirstChild((`{p}LowerArm`))

	if not (part3 and part3:IsA("BasePart")) then
		part3 = nil
	end

	local v4

	if part3 then
		v4 = part.Size.Y / 2 + part3.Size.Y + part2.Size.Y / 2
	else
		v4 = part.Size.Y
	end

	local v5 = math.max(v4, v.MIN_ARM_REACH)
	local v6 = p == "Right" and 1 or -1
	local v7 = createVector(0, 1, 0) * v.HAND_TARGET_Y_OFFSET
	local formatted = `Zipline{p}HandTarget`
	local v8 = p2.WorldCFrame + v7
	local attachment = Instance.new("Attachment")
	attachment.Name = formatted
	attachment.CFrame = parent3.CFrame:ToObjectSpace(v8)
	attachment.Parent = parent3
	maid:GiveTask(attachment)
	local formatted2 = `Zipline{p}ElbowPole`
	local cframe = CFrame.new(part.Position)
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = formatted2
	attachment2.CFrame = parent2.CFrame:ToObjectSpace(cframe)
	attachment2.Parent = parent2
	maid:GiveTask(attachment2)
	local formatted3 = `Zipline{p}HandIK`
	local HAND_PRIORITY = v.HAND_PRIORITY
	local HAND_SMOOTH_TIME = v.HAND_SMOOTH_TIME
	local iKControl = Instance.new("IKControl")
	iKControl.Name = formatted3
	iKControl.Type = Enum.IKControlType.Position
	iKControl.ChainRoot = part
	iKControl.EndEffector = part2
	iKControl.Target = attachment
	iKControl.Pole = attachment2
	iKControl.Priority = HAND_PRIORITY
	iKControl.SmoothTime = HAND_SMOOTH_TIME
	iKControl.Weight = 1
	iKControl.Parent = parent
	maid:GiveTask(iKControl)
	return function()
		local v9 = callback()
		local v10

		if shoulderAttachment then
			v10 = shoulderAttachment.WorldPosition
		else
			v10 = part.Position
		end

		local v11 = v9 * parent2.CFrame:PointToObjectSpace(v10)
		local worldPosition = clampReach(v11, p2.WorldPosition + v7, v5) -- equivalent call inferred; original call site unknown
		attachment.WorldPosition = worldPosition
		attachment2.WorldPosition = solveElbowPole(v9, v11, worldPosition, v6)
	end
end

local function bindHandIK(maid, instance, humanoid, humanoidRootPart, ride, getRootCFrame)
	local handPoints = getHandPoints(ride, humanoidRootPart)

	if not handPoints then
		return nil
	end

	local v4 = bindArmIK(maid, instance, humanoid, humanoidRootPart, ride, "Left", handPoints[1], getRootCFrame)
	local v5 = bindArmIK(maid, instance, humanoid, humanoidRootPart, ride, "Right", handPoints[2], getRootCFrame)

	if v4 and v5 then
		return function(p)
			v4(p)
			v5(p)
		end
	end

	return nil
end

local function bindLegIK(maid, instance, humanoid, humanoidRootPart, ride)
	local leftUpperLeg = instance:FindFirstChild("LeftUpperLeg")

	if not (leftUpperLeg and leftUpperLeg:IsA("BasePart")) then
		leftUpperLeg = nil
	end

	if not leftUpperLeg then
		leftUpperLeg = instance:FindFirstChild("Left Leg")

		if not (leftUpperLeg and leftUpperLeg:IsA("BasePart")) then
			leftUpperLeg = nil
		end
	end

	local rightUpperLeg = instance:FindFirstChild("RightUpperLeg")

	if not (rightUpperLeg and rightUpperLeg:IsA("BasePart")) then
		rightUpperLeg = nil
	end

	if not rightUpperLeg then
		rightUpperLeg = instance:FindFirstChild("Right Leg")

		if not (rightUpperLeg and rightUpperLeg:IsA("BasePart")) then
			rightUpperLeg = nil
		end
	end

	local leftFoot = instance:FindFirstChild("LeftFoot")

	if not (leftFoot and leftFoot:IsA("BasePart")) then
		leftFoot = nil
	end

	if not leftFoot then
		leftFoot = instance:FindFirstChild("Left Leg")

		if not (leftFoot and leftFoot:IsA("BasePart")) then
			leftFoot = nil
		end
	end

	local rightFoot = instance:FindFirstChild("RightFoot")

	if not (rightFoot and rightFoot:IsA("BasePart")) then
		rightFoot = nil
	end

	if not rightFoot then
		rightFoot = instance:FindFirstChild("Right Leg")

		if not (rightFoot and rightFoot:IsA("BasePart")) then
			rightFoot = nil
		end
	end

	if not (leftUpperLeg and rightUpperLeg and leftFoot and rightFoot) then
		return nil
	end

	local pointToObjectSpace = humanoidRootPart.CFrame:PointToObjectSpace(leftFoot.Position)
	local pointToObjectSpace2 = humanoidRootPart.CFrame:PointToObjectSpace(rightFoot.Position)
	local cFrame = leftFoot.CFrame
	local attachment = Instance.new("Attachment")
	attachment.Name = "ZiplineLeftFootTarget"
	attachment.CFrame = humanoidRootPart.CFrame:ToObjectSpace(cFrame)
	attachment.Parent = humanoidRootPart
	maid:GiveTask(attachment)
	local cFrame2 = rightFoot.CFrame
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "ZiplineRightFootTarget"
	attachment2.CFrame = humanoidRootPart.CFrame:ToObjectSpace(cFrame2)
	attachment2.Parent = humanoidRootPart
	maid:GiveTask(attachment2)
	local v4 = humanoidRootPart.CFrame * CFrame.new(pointToObjectSpace.X, -1.5, -1)
	local attachment3 = Instance.new("Attachment")
	attachment3.Name = "ZiplineLeftKneePole"
	attachment3.CFrame = humanoidRootPart.CFrame:ToObjectSpace(v4)
	attachment3.Parent = humanoidRootPart
	maid:GiveTask(attachment3)
	local v5 = humanoidRootPart.CFrame * CFrame.new(pointToObjectSpace2.X, -1.5, -1)
	local attachment4 = Instance.new("Attachment")
	attachment4.Name = "ZiplineRightKneePole"
	attachment4.CFrame = humanoidRootPart.CFrame:ToObjectSpace(v5)
	attachment4.Parent = humanoidRootPart
	maid:GiveTask(attachment4)
	local fixedStepper = createFixedStepper() -- equivalent call inferred; original call site unknown
	local position = ride.Position
	local v6 = 0
	local v7 = 0
	createPositionIK(
		maid,
		humanoid,
		"ZiplineLeftLegIK",
		leftUpperLeg,
		leftFoot,
		attachment,
		attachment3,
		v.LEG_PRIORITY,
		v.LEG_SMOOTH_TIME,
		v.LEG_IK_WEIGHT
	) -- equivalent call inferred; original call site unknown
	createPositionIK(
		maid,
		humanoid,
		"ZiplineRightLegIK",
		rightUpperLeg,
		rightFoot,
		attachment2,
		attachment4,
		v.LEG_PRIORITY,
		v.LEG_SMOOTH_TIME,
		v.LEG_IK_WEIGHT
	) -- equivalent call inferred; original call site unknown
	return function(p)
		local v8 = math.min(
			(ride.Position - position).Magnitude / math.max(p, v.SPRING_TIME_STEP) * v.LEG_DRAG_PER_SPEED,
			v.MAX_LEG_DRAG
		)
		position = ride.Position
		fixedStepper(p, function(p2)
			local v9 = v6
			local v10 = v7
			local LEG_DRAG_STIFFNESS = v.LEG_DRAG_STIFFNESS
			local LEG_DRAG_DAMPING = v.LEG_DRAG_DAMPING
			local MAX_LEG_DRAG = v.MAX_LEG_DRAG
			local v12 = (v10 + (v8 - v9) * LEG_DRAG_STIFFNESS * p2) * math.exp(-LEG_DRAG_DAMPING * p2)
			local v13 = math.clamp(v9 + v12 * p2, 0, MAX_LEG_DRAG)
			local v14 = MAX_LEG_DRAG <= v13 and v12 > 0 and 0 or v13 <= 0 and v12 < 0 and 0 or v12
			v6 = v13
			v7 = v14
		end)
		local v9 = createVector(0, 0, 1) * (v.BASE_LEG_TRAIL + v6)
		attachment.Position = pointToObjectSpace + v9
		attachment2.Position = pointToObjectSpace2 + v9
	end
end

local function createPose(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if not humanoidRootPart then
		return nil
	end

	local ride, v4 = getRide(humanoidRootPart)

	if not (ride and v4) then
		return nil
	end

	local function getRootCFrame()
		return (getRideRootCFrame(ride, v4, humanoidRootPart))
	end

	local maid = Maid.new()
	local v5 = bindTrolleyMotion(maid, instance, v4, ride)
	local v6 = bindHandIK(maid, instance, humanoid, humanoidRootPart, ride, getRootCFrame)
	local v7 = bindLegIK(maid, instance, humanoid, humanoidRootPart, ride)

	if v5 and v6 and v7 then
		maid:GiveTask(RunService.PreAnimation:Connect(function(dt)
			local ride2, v8 = getRide(humanoidRootPart)

			if not humanoidRootPart.Parent or ride2 ~= ride or not v8 or v8 ~= v4 then
				maid:Destroy()
				return
			end

			v5(dt)
			v6(dt)
			v7(dt)
		end))
		return maid
	end

	maid:Destroy()
	return nil
end

function v2:Start()
	if self._maid then
		self._maid:Destroy()
	end

	local maid = Maid.new()
	self._maid = maid
	maid:GiveTask(task.spawn(function()
		while self._maid == maid and self.Instance:HasTag(v.TAG) do
			local pose = createPose(self.Instance)

			if pose then
				maid:GiveTask(pose)
				break
			else
				RunService.Heartbeat:Wait()
			end
		end
	end))
end

function v2:Stop()
	if self._maid then
		self._maid:Destroy()
	end

	self._maid = nil
end

return v2