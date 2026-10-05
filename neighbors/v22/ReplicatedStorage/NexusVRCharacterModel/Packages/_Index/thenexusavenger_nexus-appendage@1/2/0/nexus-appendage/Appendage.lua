local createVector = vector.create
local Limb = require(script.Parent:WaitForChild("Limb"))
local JointOffset = require(script.Parent:WaitForChild("JointOffset"))
local Appendage = {
	Presets = {
		LeftArm = {
			"UpperTorso",
			"LeftUpperArm",
			"LeftLowerArm",
			"LeftHand",
			"LeftShoulder",
			"LeftShoulderRigAttachment",
			"LeftElbowRigAttachment",
			"LeftWristRigAttachment",
			"LeftGripAttachment"
		},
		RightArm = {
			"UpperTorso",
			"RightUpperArm",
			"RightLowerArm",
			"RightHand",
			"RightShoulder",
			"RightShoulderRigAttachment",
			"RightElbowRigAttachment",
			"RightWristRigAttachment",
			"RightGripAttachment"
		},
		LeftLeg = {
			"LowerTorso",
			"LeftUpperLeg",
			"LeftLowerLeg",
			"LeftFoot",
			"LeftHip",
			"LeftHipRigAttachment",
			"LeftKneeRigAttachment",
			"LeftAnkleRigAttachment",
			"LeftFootAttachment"
		},
		RightLeg = {
			"LowerTorso",
			"RightUpperLeg",
			"RightLowerLeg",
			"RightFoot",
			"RightHip",
			"RightHipRigAttachment",
			"RightKneeRigAttachment",
			"RightAnkleRigAttachment",
			"RightFootAttachment"
		}
	},
	ConstraintPresets = {
		LeftArm = {
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "UpperTorso",
					Attachment = "LeftShoulderRigAttachment",
					Offset = CFrame.Angles(0, 3.141592653589793, 0)
				},
				Attachment1 = {
					Part = "LeftUpperArm",
					Attachment = "LeftShoulderRigAttachment",
					Offset = CFrame.Angles(0, 3.141592653589793, -1.5707963267948966)
				},
				Properties = {
					Name = "LeftShoulderBallSocket",
					LimitsEnabled = true,
					UpperAngle = 110,
					TwistLimitsEnabled = true,
					TwistLowerAngle = -85,
					TwistUpperAngle = 85
				}
			},
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "LeftUpperArm",
					Attachment = "LeftElbowRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "LeftLowerArm",
					Attachment = "LeftElbowRigAttachment",
					Offset = CFrame.identity
				},
				Properties = {
					Name = "LeftElbowBallSocket",
					LimitsEnabled = true,
					UpperAngle = 20,
					TwistLimitsEnabled = true,
					TwistLowerAngle = 5,
					TwistUpperAngle = 120
				}
			}
		},
		RightArm = {
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "UpperTorso",
					Attachment = "RightShoulderRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "RightUpperArm",
					Attachment = "RightShoulderRigAttachment",
					Offset = CFrame.Angles(0, 0, -1.5707963267948966)
				},
				Properties = {
					Name = "RightShoulderBallSocket",
					LimitsEnabled = true,
					UpperAngle = 110,
					TwistLimitsEnabled = true,
					TwistLowerAngle = -85,
					TwistUpperAngle = 85
				}
			},
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "RightUpperArm",
					Attachment = "RightElbowRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "RightLowerArm",
					Attachment = "RightElbowRigAttachment",
					Offset = CFrame.identity
				},
				Properties = {
					Name = "RightElbowBallSocket",
					LimitsEnabled = true,
					UpperAngle = 20,
					TwistLimitsEnabled = true,
					TwistLowerAngle = 5,
					TwistUpperAngle = 120
				}
			}
		},
		LeftLeg = {
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "LowerTorso",
					Attachment = "LeftHipRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "LeftUpperLeg",
					Attachment = "LeftHipRigAttachment",
					Offset = CFrame.identity
				},
				Properties = {
					Name = "LeftHipBallSocket",
					LimitsEnabled = true,
					UpperAngle = 40,
					TwistLimitsEnabled = true,
					TwistLowerAngle = -5,
					TwistUpperAngle = 80
				}
			},
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "LeftUpperLeg",
					Attachment = "LeftKneeRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "LeftLowerLeg",
					Attachment = "LeftKneeRigAttachment",
					Offset = CFrame.identity
				},
				Properties = {
					Name = "LeftKneeBallSocket",
					LimitsEnabled = true,
					UpperAngle = 5,
					TwistLimitsEnabled = true,
					TwistLowerAngle = -120,
					TwistUpperAngle = 5
				}
			}
		},
		RightLeg = {
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "LowerTorso",
					Attachment = "RightHipRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "RightUpperLeg",
					Attachment = "RightHipRigAttachment",
					Offset = CFrame.identity
				},
				Properties = {
					Name = "RightHipBallSocket",
					LimitsEnabled = true,
					UpperAngle = 40,
					TwistLimitsEnabled = true,
					TwistLowerAngle = -5,
					TwistUpperAngle = 80
				}
			},
			{
				Type = "BallSocketConstraint",
				Attachment0 = {
					Part = "RightUpperLeg",
					Attachment = "RightKneeRigAttachment",
					Offset = CFrame.identity
				},
				Attachment1 = {
					Part = "RightLowerLeg",
					Attachment = "RightKneeRigAttachment",
					Offset = CFrame.identity
				},
				Properties = {
					Name = "RightKneeBallSocket",
					LimitsEnabled = true,
					UpperAngle = 5,
					TwistLimitsEnabled = true,
					TwistLowerAngle = -120,
					TwistUpperAngle = 5
				}
			}
		}
	}
}
Appendage.__index = Appendage
setmetatable(Appendage, Limb)

function Appendage.new(parent, p, instance, lowerLimb, instance2, childName: string, startAttachment: string, limbJointAttachment: string, limbEndAttachment: string, childName2: string, flag: boolean?, value: number?)
	local object = setmetatable(Limb.new(), Appendage)
	object.RootPart = p
	object.UpperLimb = instance
	object.LowerLimb = lowerLimb
	object.LimbEnd = instance2
	object.StartJointOffset = JointOffset.new(instance:WaitForChild(childName), p, startAttachment)
	object.StartAttachment = startAttachment
	object.LimbJointAttachment = limbJointAttachment
	object.LimbEndAttachment = limbEndAttachment
	object.LimbHoldAttachment = childName2
	object.AllowDisconnection = flag or false
	object.Constraints = {}

	if (childName2 == "LeftFootAttachment" or childName2 == "RightFootAttachment") and not instance2:FindFirstChild(childName2) then
		local attachment = Instance.new("Attachment")
		attachment.Name = childName2
		attachment.CFrame = CFrame.new(0, -instance2.Size.Y / 2, 0)
		attachment.Parent = instance2
		local vector3Value = Instance.new("Vector3Value")
		vector3Value.Name = "OriginalPosition"
		vector3Value.Value = attachment.Position
		vector3Value.Parent = attachment
	end

	if not parent:FindFirstChildOfClass("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = parent
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = `{instance.Name}_{lowerLimb.Name}_Attachment`
	attachment.Parent = p
	object.IKControlAttachment = attachment
	local iKControl = Instance.new("IKControl")
	iKControl.Name = `{instance.Name}_{lowerLimb.Name}_IKControl`
	iKControl.ChainRoot = instance
	iKControl.EndEffector = instance2
	iKControl.Offset = object:GetAttachmentCFrame(instance2, childName2):Inverse()
	iKControl.SmoothTime = value or 0
	iKControl.Target = attachment
	iKControl.Parent = parent
	object.IKControl = iKControl
	object:MoveTo(object:GetAttachmentCFrame(instance, startAttachment):Inverse() * object:GetAttachmentCFrame(
		instance,
		limbJointAttachment
	) * object:GetAttachmentCFrame(lowerLimb, limbJointAttachment):Inverse() * object:GetAttachmentCFrame(
		lowerLimb,
		limbEndAttachment
	) * object:GetAttachmentCFrame(instance2, limbEndAttachment):Inverse() * object:GetAttachmentCFrame(
		instance2,
		childName2
	))
	return object
end

function Appendage.FromPreset(p: string, instance, flag: boolean?, p2: number?)
	local preset = Appendage.Presets[p]
	local v = Appendage.new(
		instance:WaitForChild("Humanoid"),
		instance:WaitForChild(preset[1]),
		instance:WaitForChild(preset[2]),
		instance:WaitForChild(preset[3]),
		instance:WaitForChild(preset[4]),
		preset[5],
		preset[6],
		preset[7],
		preset[8],
		preset[9],
		flag,
		p2
	)
	v:AddConstraints(p, instance)
	return v
end

function Appendage:AddConstraints(p2: string, instance)
	for _, v in Appendage.ConstraintPresets[p2] do
		local child = instance:WaitForChild(v.Attachment0.Part)
		local child2 = instance:WaitForChild(v.Attachment1.Part)

		if child2:FindFirstChildOfClass(v.Type) then
			continue
		end

		local child3 = child:WaitForChild(v.Attachment0.Attachment)

		if v.Attachment0.Offset ~= CFrame.identity then
			local clone = child3:Clone()
			clone.Name = "NexusAppendageConstraintOffset"
			clone.CFrame = v.Attachment0.Offset
			clone.Parent = child3
			table.insert(self.Constraints, clone)
			child3 = clone
		end

		local child4 = child2:WaitForChild(v.Attachment1.Attachment)

		if v.Attachment1.Offset ~= CFrame.identity then
			local clone = child4:Clone()
			clone.Name = "NexusAppendageConstraintOffset"
			clone.CFrame = v.Attachment1.Offset
			clone.Parent = child4
			table.insert(self.Constraints, clone)
			child4 = clone
		end

		local instance2 = Instance.new(v.Type)

		for k, property in v.Properties do
			instance2[k] = property
		end

		instance2.Attachment0 = child3
		instance2.Attachment1 = child4
		instance2.Parent = child2
		table.insert(self.Constraints, instance2)
	end
end

function Appendage.Enable(p)
	p.IKControl.Weight = 1
end

function Appendage.Disable(p)
	p.IKControl.Weight = 0
end

function Appendage.SetTargetAttachment(p, p2)
	p.IKControl.Target = p2 or p.IKControlAttachment
end

function Appendage.SetSmoothTime(p, smoothTime: number)
	p.IKControl.SmoothTime = smoothTime
end

function Appendage:MoveTo(cframe: CFrame, p)
	local attachmentCFrame = self.StartJointOffset.AttachmentCFrame
	self.StartJointOffset:SetProperty(self.IKControlAttachment, "CFrame", attachmentCFrame * cframe, p)

	if not self.AllowDisconnection then
		return
	end

	local v = cframe * self:GetAttachmentCFrame(self.LimbEnd, self.LimbHoldAttachment):Inverse() * self:GetAttachmentCFrame(
		self.LimbEnd,
		self.LimbEndAttachment
	)
	local magnitude = (self:GetAttachmentCFrame(self.UpperLimb, self.StartAttachment):Inverse() * self:GetAttachmentCFrame(
		self.UpperLimb,
		self.LimbJointAttachment
	) * self:GetAttachmentCFrame(self.LowerLimb, self.LimbJointAttachment):Inverse() * self:GetAttachmentCFrame(
		self.LowerLimb,
		self.LimbEndAttachment
	)).Position.Magnitude
	local magnitude2 = v.Position.Magnitude

	if magnitude < magnitude2 then
		self.StartJointOffset:SetOffset(
			CFrame.new(CFrame.new(createVector(0, 0, 0), v.Position).LookVector * (magnitude2 - magnitude)),
			p
		)
	else
		self.StartJointOffset:SetOffset(CFrame.identity, p)
	end
end

function Appendage:MoveToWorld(cframe: CFrame, _)
	self:MoveTo((self.RootPart.CFrame * self.StartJointOffset.AttachmentCFrame):Inverse() * cframe)
end

function Appendage:Destroy()
	self.StartJointOffset:Destroy()
	self.IKControlAttachment:Destroy()
	self.IKControl:Destroy()

	for _, constraint in self.Constraints do
		constraint:Destroy()
	end
end

return Appendage