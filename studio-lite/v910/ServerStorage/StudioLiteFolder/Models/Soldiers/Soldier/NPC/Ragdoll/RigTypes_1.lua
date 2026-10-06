local createVector = vector.create
local RigTypes = {}
local v = {
	UpperAngle = 60,
	TwistLowerAngle = -60,
	TwistUpperAngle = 60
}
local v2 = {
	UpperAngle = 20,
	TwistLowerAngle = -30,
	TwistUpperAngle = 60
}
local v3 = {
	UpperAngle = 10,
	TwistLowerAngle = -10,
	TwistUpperAngle = 10
}
local v4 = {
	UpperAngle = 30,
	TwistLowerAngle = 0,
	TwistUpperAngle = 120
}
local v5 = {
	UpperAngle = 30,
	TwistLowerAngle = -120,
	TwistUpperAngle = 0
}
local v6 = {
	UpperAngle = 60,
	TwistLowerAngle = -60,
	TwistUpperAngle = 175
}
local v7 = {
	UpperAngle = 40,
	TwistLowerAngle = -5,
	TwistUpperAngle = 150
}
local v8 = {
	UpperAngle = 30,
	TwistLowerAngle = -60,
	TwistUpperAngle = 60
}
local v9 = {
	UpperAngle = 90,
	TwistLowerAngle = -30,
	TwistUpperAngle = 175
}
local limits = {
	UpperAngle = 60,
	TwistLowerAngle = -5,
	TwistUpperAngle = 120
}

local function createJointData(attachment, attachment2, limits2)
	assert(attachment)
	assert(attachment2)
	assert(limits2)
	assert(limits2.UpperAngle >= 0)
	assert(limits2.TwistLowerAngle <= limits2.TwistUpperAngle)
	return {
		attachment0 = attachment,
		attachment1 = attachment2,
		limits = limits2
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function find(instance)
	return function(list, list2, limits2)
		local child = instance:FindFirstChild(list[1])
		local child2 = instance:FindFirstChild(list2[1])

		if child and child2 then
			local attachment = child:FindFirstChild(list[2])
			local attachment2 = child2:FindFirstChild(list2[2])

			if attachment and attachment2 and attachment:IsA("Attachment") and attachment2:IsA("Attachment") then
				return (createJointData(attachment, attachment2, limits2))
			end
		end
	end
end

function RigTypes.getNoCollisions(p, p2)
	if p2 == Enum.HumanoidRigType.R6 then
		return RigTypes.getR6NoCollisions(p)
	end

	if p2 == Enum.HumanoidRigType.R15 then
		return RigTypes.getR15NoCollisions(p)
	end

	return {}
end

function RigTypes.getAttachments(p, p2)
	if p2 == Enum.HumanoidRigType.R6 then
		return RigTypes.getR6Attachments(p)
	end

	if p2 == Enum.HumanoidRigType.R15 then
		return RigTypes.getR15Attachments(p)
	end

	return {}
end

function RigTypes.getR6Attachments(instance)
	local attachment = Instance.new("Attachment")
	attachment.Name = "RagdollRightLegAttachment"
	attachment.Position = createVector(0, 1, 0)
	attachment.Parent = instance:FindFirstChild("Right Leg")
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "RagdollLeftLegAttachment"
	attachment2.Position = createVector(0, 1, 0)
	attachment2.Parent = instance:FindFirstChild("Left Leg")
	local attachment3 = Instance.new("Attachment")
	attachment3.Name = "RagdollTorsoLeftAttachment"
	attachment3.Position = createVector(-0.5, -1, 0)
	attachment3.Parent = instance:FindFirstChild("Torso")
	local attachment4 = Instance.new("Attachment")
	attachment4.Name = "RagdollTorsoRightAttachment"
	attachment4.Position = createVector(0.5, -1, 0)
	attachment4.Parent = instance:FindFirstChild("Torso")
	local attachment5 = Instance.new("Attachment")
	attachment5.Name = "RagdollHeadAttachment"
	attachment5.Position = createVector(0, -0.5, 0)
	attachment5.Parent = instance:FindFirstChild("Head")
	local attachment6 = Instance.new("Attachment")
	attachment6.Name = "RagdollLeftArmAttachment"
	attachment6.Position = createVector(0.5, 1, 0)
	attachment6.Parent = instance:FindFirstChild("Left Arm")
	local attachment7 = Instance.new("Attachment")
	attachment7.Name = "RagdollRightArmAttachment"
	attachment7.Position = createVector(-0.5, 1, 0)
	attachment7.Parent = instance:FindFirstChild("Right Arm")
	local v11 = find(instance) -- equivalent call inferred; original call site unknown
	return {
		Head = v11({ "Torso", "NeckAttachment" }, { "Head", "RagdollHeadAttachment" }, v8),
		["Left Arm"] = v11({ "Torso", "LeftCollarAttachment" }, { "Left Arm", "RagdollLeftArmAttachment" }, v9),
		["Right Arm"] = v11({ "Torso", "RightCollarAttachment" }, { "Right Arm", "RagdollRightArmAttachment" }, v9),
		["Left Leg"] = createJointData(attachment3, attachment2, limits),
		["Right Leg"] = createJointData(attachment4, attachment, limits)
	}
end

function RigTypes.getR15Attachments(instance)
	local v11 = find(instance) -- equivalent call inferred; original call site unknown
	return {
		Head = v11({ "UpperTorso", "NeckRigAttachment" }, { "Head", "NeckRigAttachment" }, v),
		LowerTorso = v11({ "UpperTorso", "WaistRigAttachment" }, { "LowerTorso", "RootRigAttachment" }, v2),
		LeftUpperArm = v11(
			{ "UpperTorso", "LeftShoulderRigAttachment" },
			{ "LeftUpperArm", "LeftShoulderRigAttachment" },
			v6
		),
		LeftLowerArm = v11(
			{ "LeftUpperArm", "LeftElbowRigAttachment" },
			{ "LeftLowerArm", "LeftElbowRigAttachment" },
			v4
		),
		LeftHand = v11({ "LeftLowerArm", "LeftWristRigAttachment" }, { "LeftHand", "LeftWristRigAttachment" }, v3),
		RightUpperArm = v11(
			{ "UpperTorso", "RightShoulderRigAttachment" },
			{ "RightUpperArm", "RightShoulderRigAttachment" },
			v6
		),
		RightLowerArm = v11(
			{ "RightUpperArm", "RightElbowRigAttachment" },
			{ "RightLowerArm", "RightElbowRigAttachment" },
			v4
		),
		RightHand = v11({ "RightLowerArm", "RightWristRigAttachment" }, { "RightHand", "RightWristRigAttachment" }, v3),
		LeftUpperLeg = v11({ "LowerTorso", "LeftHipRigAttachment" }, { "LeftUpperLeg", "LeftHipRigAttachment" }, v7),
		LeftLowerLeg = v11({ "LeftUpperLeg", "LeftKneeRigAttachment" }, { "LeftLowerLeg", "LeftKneeRigAttachment" }, v5),
		LeftFoot = v11({ "LeftLowerLeg", "LeftAnkleRigAttachment" }, { "LeftFoot", "LeftAnkleRigAttachment" }, v3),
		RightUpperLeg = v11({ "LowerTorso", "RightHipRigAttachment" }, { "RightUpperLeg", "RightHipRigAttachment" }, v7),
		RightLowerLeg = v11(
			{ "RightUpperLeg", "RightKneeRigAttachment" },
			{ "RightLowerLeg", "RightKneeRigAttachment" },
			v5
		),
		RightFoot = v11({ "RightLowerLeg", "RightAnkleRigAttachment" }, { "RightFoot", "RightAnkleRigAttachment" }, v3)
	}
end

function RigTypes.getR6NoCollisions(instance)
	local v11 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addPair(list)
		local child = instance:FindFirstChild(list[1])
		local child2 = instance:FindFirstChild(list[2])

		if child and child2 then
			table.insert(v11, { child, child2 })
		end
	end

	addPair({ "Head", "Torso" }) -- equivalent call inferred; original call site unknown
	addPair({ "Left Arm", "Torso" }) -- equivalent call inferred; original call site unknown
	addPair({ "Right Arm", "Torso" }) -- equivalent call inferred; original call site unknown
	addPair({ "Left Leg", "Torso" }) -- equivalent call inferred; original call site unknown
	addPair({ "Right Leg", "Torso" }) -- equivalent call inferred; original call site unknown
	addPair({ "Left Leg", "Right Leg" }) -- equivalent call inferred; original call site unknown
	return v11
end

function RigTypes.getR15NoCollisions(instance)
	local v11 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addPair(list)
		local child = instance:FindFirstChild(list[1])
		local child2 = instance:FindFirstChild(list[2])

		if child and child2 then
			table.insert(v11, { child, child2 })
		end
	end

	addPair({ "Head", "UpperTorso" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "LowerTorso" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "LeftUpperArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "LowerTorso", "LeftUpperArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftUpperArm", "LeftLowerArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftLowerArm", "LeftHand" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftUpperArm", "LeftHand" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "RightUpperArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "LowerTorso", "RightUpperArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "RightUpperArm", "RightLowerArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "RightLowerArm", "RightHand" }) -- equivalent call inferred; original call site unknown
	addPair({ "RightUpperArm", "RightHand" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftUpperLeg", "RightUpperLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "RightUpperLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "LowerTorso", "RightUpperLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "RightUpperLeg", "RightLowerLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "RightLowerLeg", "RightFoot" }) -- equivalent call inferred; original call site unknown
	addPair({ "RightUpperLeg", "RightFoot" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "LeftUpperLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "LowerTorso", "LeftUpperLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftUpperLeg", "LeftLowerLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftLowerLeg", "LeftFoot" }) -- equivalent call inferred; original call site unknown
	addPair({ "LeftUpperLeg", "LeftFoot" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "LeftLowerLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "RightLowerLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "LowerTorso", "LeftLowerLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "LowerTorso", "RightLowerLeg" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "LeftLowerArm" }) -- equivalent call inferred; original call site unknown
	addPair({ "UpperTorso", "RightLowerArm" }) -- equivalent call inferred; original call site unknown
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if upperTorso and upperTorso.Size.x <= 1.5 then
		addPair({ "Head", "LeftUpperArm" }) -- equivalent call inferred; original call site unknown
		addPair({ "Head", "RightUpperArm" }) -- equivalent call inferred; original call site unknown
	end

	return v11
end

return RigTypes