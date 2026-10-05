local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LimbTree = require(script:WaitForChild("LimbTree"))
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local v

if RunService:IsServer() then
	v = Net:RemoteEvent("Ragdoll")
else
	v = nil
end

local Ragdoll = {}

function Ragdoll.RagdollCharacter(folder, vector2: Vector3?)
	local playerFromCharacter = Players:GetPlayerFromCharacter(folder)

	if playerFromCharacter and v then
		v:FireClient(playerFromCharacter, true, vector2)
	end

	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("Cannot Ragdoll: No Humanoid")
		return
	end

	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local head = folder:FindFirstChild("Head")
		local torso = folder:FindFirstChild("Torso")
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
		local rightArm = folder:FindFirstChild("Right Arm")
		local leftArm = folder:FindFirstChild("Left Arm")
		local rightLeg = folder:FindFirstChild("Right Leg")
		local leftLeg = folder:FindFirstChild("Left Leg")

		if torso and not torso:FindFirstChild("NeckJoint") then
			local attachment = Instance.new("Attachment")
			attachment.Parent = head
			attachment.Name = "NeckAttachment"
			attachment.Position = createVector(0, -0.5, 0)
			attachment.Orientation = createVector(0, 0, 0)
			attachment:SetAttribute("Ragdoll", true)
			local attachment2 = Instance.new("Attachment")
			attachment2.Parent = torso
			attachment2.Name = "TorsoNeckAttachment"
			attachment2.Position = createVector(0, 1, 0)
			attachment2.Orientation = createVector(0, 0, 0)
			attachment2:SetAttribute("Ragdoll", true)
			local clone = script.Neck:Clone()
			clone.Parent = torso
			clone.Name = "NeckJoint"
			clone.Attachment0 = attachment
			clone.Attachment1 = attachment2
			clone:SetAttribute("Ragdoll", true)
			local attachment3 = Instance.new("Attachment")
			attachment3.Parent = rightArm
			attachment3.Name = "RightArmAttachment"
			attachment3.Position = createVector(-0.5, 0.5, 0)
			attachment3.Orientation = createVector(0, 0, 0)
			attachment3:SetAttribute("Ragdoll", true)
			local attachment4 = Instance.new("Attachment")
			attachment4.Parent = torso
			attachment4.Name = "TorsoRightArmAttachment"
			attachment4.Position = createVector(1, 0.5, 0)
			attachment4.Orientation = createVector(0, 0, 0)
			attachment4:SetAttribute("Ragdoll", true)
			local clone2 = script.Default:Clone()
			clone2.Parent = torso
			clone2.Name = "RightArmJoint"
			clone2.Attachment0 = attachment4
			clone2.Attachment1 = attachment3
			clone2:SetAttribute("Ragdoll", true)
			local attachment5 = Instance.new("Attachment")
			attachment5.Parent = leftArm
			attachment5.Name = "LeftArmAttachment"
			attachment5.Position = createVector(0.5, 0.5, 0)
			attachment5.Orientation = createVector(0, 0, 0)
			attachment5:SetAttribute("Ragdoll", true)
			local attachment6 = Instance.new("Attachment")
			attachment6.Parent = torso
			attachment6.Name = "TorsoLeftArmAttachment"
			attachment6.Position = createVector(-1, 0.5, 0)
			attachment6.Orientation = createVector(0, 0, 0)
			attachment6:SetAttribute("Ragdoll", true)
			local clone3 = script.Default:Clone()
			clone3.Parent = torso
			clone3.Name = "LeftArmJoint"
			clone3.Attachment0 = attachment6
			clone3.Attachment1 = attachment5
			clone3:SetAttribute("Ragdoll", true)
			local attachment7 = Instance.new("Attachment")
			attachment7.Parent = rightLeg
			attachment7.Name = "RightLegAttachment"
			attachment7.Position = createVector(0, 1, 0)
			attachment7.Orientation = createVector(0, 0, -90)
			attachment7:SetAttribute("Ragdoll", true)
			local attachment8 = Instance.new("Attachment")
			attachment8.Parent = torso
			attachment8.Name = "TorsoRightLegAttachment"
			attachment8.Position = createVector(-0.5, -1, 0)
			attachment8.Orientation = createVector(0, 0, -90)
			attachment8:SetAttribute("Ragdoll", true)
			local clone4 = script.Default:Clone()
			clone4.Parent = torso
			clone4.Name = "RightLegJoint"
			clone4.Attachment0 = attachment7
			clone4.Attachment1 = attachment8
			clone4:SetAttribute("Ragdoll", true)
			local attachment9 = Instance.new("Attachment")
			attachment9.Parent = leftLeg
			attachment9.Name = "LeftLegAttachment"
			attachment9.Position = createVector(0, 1, 0)
			attachment9.Orientation = createVector(0, 0, -90)
			attachment9:SetAttribute("Ragdoll", true)
			local attachment10 = Instance.new("Attachment")
			attachment10.Parent = torso
			attachment10.Name = "TorsoLeftLegAttachment"
			attachment10.Position = createVector(0.5, -1, 0)
			attachment10.Orientation = createVector(0, 0, -90)
			attachment10:SetAttribute("Ragdoll", true)
			local clone5 = script.Default:Clone()
			clone5.Parent = torso
			clone5.Name = "LeftLegJoint"
			clone5.Attachment0 = attachment9
			clone5.Attachment1 = attachment10
			clone3:SetAttribute("Ragdoll", true)
		end

		if humanoidRootPart:GetAttribute("RagdollRootCollide") == nil then
			humanoidRootPart:SetAttribute("RagdollRootCollide", humanoidRootPart.CanCollide)
		end

		humanoidRootPart.CanCollide = false

		for _, part in pairs(folder:GetChildren()) do
			if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LowerTorso" and part.Name ~= "UpperTorso") then
				continue
			end

			local noCollisionConstraint = Instance.new("NoCollisionConstraint")
			noCollisionConstraint.Parent = torso
			noCollisionConstraint.Name = part.Name
			noCollisionConstraint.Part0 = part
			noCollisionConstraint.Part1 = torso
			noCollisionConstraint:SetAttribute("Ragdoll", true)
		end
	else
		local head = folder:FindFirstChild("Head")
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
		local upperTorso = folder:FindFirstChild("UpperTorso")
		local lowerTorso = folder:FindFirstChild("LowerTorso")
		local rightUpperLeg = folder:FindFirstChild("RightUpperLeg")
		local leftUpperLeg = folder:FindFirstChild("LeftUpperLeg")
		local rightLowerLeg = folder:FindFirstChild("RightLowerLeg")
		local leftLowerLeg = folder:FindFirstChild("LeftLowerLeg")
		local rightFoot = folder:FindFirstChild("RightFoot")
		local leftFoot = folder:FindFirstChild("LeftFoot")
		local rightUpperArm = folder:FindFirstChild("RightUpperArm")
		local leftUpperArm = folder:FindFirstChild("LeftUpperArm")
		local rightLowerArm = folder:FindFirstChild("RightLowerArm")
		local leftLowerArm = folder:FindFirstChild("LeftLowerArm")
		local rightHand = folder:FindFirstChild("RightHand")
		local leftHand = folder:FindFirstChild("LeftHand")
		local clone = script.Neck:Clone()
		clone.Parent = lowerTorso
		clone.Name = "NeckJoint"
		clone.Attachment0 = head and head.NeckRigAttachment
		clone.Attachment1 = upperTorso and upperTorso.NeckRigAttachment
		clone:SetAttribute("Ragdoll", true)
		local clone2 = script.Waist:Clone()
		clone2.Parent = lowerTorso
		clone2.Name = "WaistJoint"
		clone2.Attachment0 = lowerTorso and lowerTorso.WaistRigAttachment
		clone2.Attachment1 = upperTorso and upperTorso.WaistRigAttachment
		clone2:SetAttribute("Ragdoll", true)
		local clone3 = script.Hip:Clone()
		clone3.Parent = lowerTorso
		clone3.Name = "RightHipJoint"
		clone3.Attachment0 = lowerTorso and lowerTorso.RightHipRigAttachment
		clone3.Attachment1 = rightUpperLeg and rightUpperLeg.RightHipRigAttachment
		clone3:SetAttribute("Ragdoll", true)
		local clone4 = script.Hip:Clone()
		clone4.Parent = lowerTorso
		clone4.Name = "LeftHipJoint"
		clone4.Attachment0 = lowerTorso and lowerTorso.LeftHipRigAttachment
		clone4.Attachment1 = leftUpperLeg and leftUpperLeg.LeftHipRigAttachment
		clone4:SetAttribute("Ragdoll", true)
		local clone5 = script.Knee:Clone()
		clone5.Parent = lowerTorso
		clone5.Name = "RightKneeJoint"
		clone5.Attachment0 = rightUpperLeg and rightUpperLeg.RightKneeRigAttachment
		clone5.Attachment1 = rightLowerLeg and rightLowerLeg.RightKneeRigAttachment
		clone5:SetAttribute("Ragdoll", true)
		local clone6 = script.Knee:Clone()
		clone6.Parent = lowerTorso
		clone6.Name = "LeftKneeJoint"
		clone6.Attachment0 = leftUpperLeg and leftUpperLeg.LeftKneeRigAttachment
		clone6.Attachment1 = leftLowerLeg and leftLowerLeg.LeftKneeRigAttachment
		clone6:SetAttribute("Ragdoll", true)
		local clone7 = script.Ankle:Clone()
		clone7.Parent = lowerTorso
		clone7.Name = "RightAnkleJoint"
		clone7.Attachment0 = rightLowerLeg and rightLowerLeg.RightAnkleRigAttachment
		clone7.Attachment1 = rightFoot and rightFoot.RightAnkleRigAttachment
		clone7:SetAttribute("Ragdoll", true)
		local clone8 = script.Ankle:Clone()
		clone8.Parent = lowerTorso
		clone8.Name = "LeftAnkleJoint"
		clone8.Attachment0 = leftLowerLeg and leftLowerLeg.LeftAnkleRigAttachment
		clone8.Attachment1 = leftFoot and leftFoot.LeftAnkleRigAttachment
		clone8:SetAttribute("Ragdoll", true)
		local clone9 = script.Shoulder:Clone()
		clone9.Parent = lowerTorso
		clone9.Name = "RightShoulderJoint"
		clone9.Attachment0 = upperTorso and upperTorso.RightShoulderRigAttachment
		clone9.Attachment1 = rightUpperArm and rightUpperArm.RightShoulderRigAttachment
		clone9:SetAttribute("Ragdoll", true)
		local clone10 = script.Shoulder:Clone()
		clone10.Parent = lowerTorso
		clone10.Name = "LeftShoulderJoint"
		clone10.Attachment0 = upperTorso and upperTorso.LeftShoulderRigAttachment
		clone10.Attachment1 = leftUpperArm and leftUpperArm.LeftShoulderRigAttachment
		clone10:SetAttribute("Ragdoll", true)
		local clone11 = script.Elbow:Clone()
		clone11.Parent = lowerTorso
		clone11.Name = "RightElbowJoint"
		clone11.Attachment0 = rightUpperArm and rightUpperArm.RightElbowRigAttachment
		clone11.Attachment1 = rightLowerArm and rightLowerArm.RightElbowRigAttachment
		clone11:SetAttribute("Ragdoll", true)
		local clone12 = script.Elbow:Clone()
		clone12.Parent = lowerTorso
		clone12.Name = "LeftElbowJoint"
		clone12.Attachment0 = leftUpperArm and leftUpperArm.LeftElbowRigAttachment
		clone12.Attachment1 = leftLowerArm and leftLowerArm.LeftElbowRigAttachment
		clone12:SetAttribute("Ragdoll", true)
		local clone13 = script.Wrist:Clone()
		clone13.Parent = lowerTorso
		clone13.Name = "RightWristJoint"
		clone13.Attachment0 = rightLowerArm and rightLowerArm.RightWristRigAttachment
		clone13.Attachment1 = rightHand and rightHand.RightWristRigAttachment
		clone13:SetAttribute("Ragdoll", true)
		local clone14 = script.Wrist:Clone()
		clone14.Parent = lowerTorso
		clone14.Name = "LeftWristJoint"
		clone14.Attachment0 = leftLowerArm and leftLowerArm.LeftWristRigAttachment
		clone14.Attachment1 = leftHand and leftHand.LeftWristRigAttachment
		clone14:SetAttribute("Ragdoll", true)

		if humanoidRootPart:GetAttribute("RagdollRootCollide") == nil then
			humanoidRootPart:SetAttribute("RagdollRootCollide", humanoidRootPart.CanCollide)
		end

		humanoidRootPart.CanCollide = false

		for _, part in pairs(folder:GetChildren()) do
			if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LowerTorso" and part.Name ~= "UpperTorso") then
				continue
			end

			local noCollisionConstraint = Instance.new("NoCollisionConstraint")
			noCollisionConstraint.Parent = lowerTorso
			noCollisionConstraint.Name = part.Name
			noCollisionConstraint.Part0 = part
			noCollisionConstraint.Part1 = LimbTree.GetParent(part.Name, folder)
			noCollisionConstraint:SetAttribute("Ragdoll", true)
			local noCollisionConstraint2 = Instance.new("NoCollisionConstraint")
			noCollisionConstraint2.Parent = lowerTorso
			noCollisionConstraint2.Name = part.Name
			noCollisionConstraint2.Part0 = part
			noCollisionConstraint2.Part1 = lowerTorso
			noCollisionConstraint2:SetAttribute("Ragdoll", true)
			local noCollisionConstraint3 = Instance.new("NoCollisionConstraint")
			noCollisionConstraint3.Parent = lowerTorso
			noCollisionConstraint3.Name = part.Name
			noCollisionConstraint3.Part0 = part
			noCollisionConstraint3.Part1 = upperTorso
			noCollisionConstraint3:SetAttribute("Ragdoll", true)
		end
	end

	humanoid.AutoRotate = false

	for _, motor6D in pairs(folder:GetDescendants()) do
		if not (motor6D:IsA("Motor6D") and motor6D.Name ~= "Root" and motor6D.Name ~= "RootJoint" and motor6D.Name ~= "WeaponConnector") then
			continue
		end

		if motor6D.Parent.Name == "WeaponHitbox" or motor6D.Name == "joint" or motor6D.Name == "RightGrip" or motor6D:FindFirstAncestorOfClass("Tool") then
			continue
		end

		motor6D.Enabled = false
	end
end

function Ragdoll.UnRagdollCharacter(folder)
	local playerFromCharacter = Players:GetPlayerFromCharacter(folder)

	if playerFromCharacter and v then
		v:FireClient(playerFromCharacter, false)
	end

	local humanoid = folder:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local ragdollRootCollide = humanoidRootPart:GetAttribute("RagdollRootCollide")
		humanoidRootPart.CanCollide = ragdollRootCollide == nil or ragdollRootCollide
		humanoidRootPart:SetAttribute("RagdollRootCollide", nil)
	end

	for _, motor6D in pairs(folder:GetDescendants()) do
		if motor6D:GetAttribute("Ragdoll") then
			motor6D:Destroy()
		end

		if motor6D:IsA("Motor6D") then
			motor6D.Enabled = true
		end
	end

	if humanoid then
		humanoid.AutoRotate = true
	end
end

return Ragdoll