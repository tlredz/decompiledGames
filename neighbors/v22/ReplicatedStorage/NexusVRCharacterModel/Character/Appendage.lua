local createVector = vector.create
local NexusAppendage = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusAppendage"))
local limb = NexusAppendage.Limb
local Appendage = {}
Appendage.__index = Appendage
setmetatable(Appendage, limb)

function Appendage.new(upperLimb, lowerLimb, limbEnd, startAttachment: string, limbJointAttachment: string, limbEndAttachment: string, limbHoldAttachment: string, flag: boolean?)
	local object = setmetatable(limb.new(), Appendage)
	object.UpperLimb = upperLimb
	object.LowerLimb = lowerLimb
	object.LimbEnd = limbEnd
	object.StartAttachment = startAttachment
	object.LimbJointAttachment = limbJointAttachment
	object.LimbEndAttachment = limbEndAttachment
	object.LimbHoldAttachment = limbHoldAttachment
	object.InvertBendDirection = false
	object.PreventDisconnection = flag or false
	return (setmetatable(object, Appendage))
end

function Appendage:SolveJoint(cframe: CFrame, vector2: Vector3, p2: number, p3: number)
	local pointToObjectSpace = cframe:PointToObjectSpace(vector2)
	local unit = pointToObjectSpace.Unit
	local magnitude = pointToObjectSpace.Magnitude
	local cross = (createVector(0, 0, -1)):Cross(unit)

	if cross == createVector(0, 0, 0) then
		cross = pointToObjectSpace.Z < 0 and createVector(0, 0, 0.001) or createVector(0, 0, -0.001)
	end

	local v = math.acos(-unit.Z)
	local v2 = cframe * CFrame.fromAxisAngle(cross, v)

	if magnitude < math.max(p3, p2) - math.min(p3, p2) then
		if self.PreventDisconnection then
			return v2, -1.5707963267948966, 3.141592653589793
		end

		return
			v2 * CFrame.new(0, 0, math.max(p3, p2) - math.min(p3, p2) - magnitude),
			-1.5707963267948966,
			3.141592653589793
	elseif p2 + p3 < magnitude then
		if self.PreventDisconnection then
			return v2, 1.5707963267948966, 0
		end

		return v2 * CFrame.new(0, 0, p2 + p3 - magnitude), 1.5707963267948966, 0
	else
		local v3 = -math.acos((-(p3 * p3) + p2 * p2 + magnitude * magnitude) / (p2 * 2 * magnitude))
		local v4 = math.acos((p3 * p3 - p2 * p2 + magnitude * magnitude) / (p3 * 2 * magnitude))

		if self.InvertBendDirection then
			v3 = -v3
			v4 = -v4
		end

		return v2, v3 + 1.5707963267948966, v4 - v3
	end
end

function Appendage:RotationTo(cframe: CFrame, cframe2: CFrame)
	local position = (cframe:Inverse() * cframe2).Position
	return CFrame.Angles(math.atan2(position.Z, position.Y), 0, -math.atan2(position.X, position.Y))
end

function Appendage:GetAppendageCFrames(cframe: CFrame, cframe2: CFrame)
	local attachmentCFrame = self:GetAttachmentCFrame(self.LimbEnd, self.LimbHoldAttachment)
	local attachmentCFrame2 = self:GetAttachmentCFrame(self.LimbEnd, self.LimbEndAttachment)
	local attachmentCFrame3 = self:GetAttachmentCFrame(self.UpperLimb, self.StartAttachment)
	local attachmentCFrame4 = self:GetAttachmentCFrame(self.UpperLimb, self.LimbJointAttachment)
	local attachmentCFrame5 = self:GetAttachmentCFrame(self.LowerLimb, self.LimbJointAttachment)
	local attachmentCFrame6 = self:GetAttachmentCFrame(self.LowerLimb, self.LimbEndAttachment)
	local magnitude = (attachmentCFrame3.Position - attachmentCFrame4.Position).Magnitude
	local magnitude2 = (attachmentCFrame5.Position - attachmentCFrame6.Position).Magnitude
	local v = cframe2 * attachmentCFrame:Inverse() * attachmentCFrame2
	local solveJoint, v2, v3 = self:SolveJoint(cframe, v.Position, magnitude, magnitude2)
	local v4 = solveJoint * CFrame.Angles(v2, 0, 0) * CFrame.new(0, -magnitude, 0)
	local v5 = v4 * CFrame.Angles(v3, 0, 0)
	local v6 = v4 * self:RotationTo(attachmentCFrame4, attachmentCFrame3):Inverse() * attachmentCFrame4:Inverse()
	local v7 = v5 * self:RotationTo(attachmentCFrame6, attachmentCFrame5):Inverse() * attachmentCFrame5:Inverse()
	return
		v6,
		v7,
		CFrame.new((v7 * attachmentCFrame6).Position) * (CFrame.new(-v.Position) * v) * attachmentCFrame2:Inverse()
end

return Appendage