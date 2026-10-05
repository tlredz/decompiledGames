local createVector = vector.create
local MathUtil = {
	quadBezier = function(p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3)
		return (1 - p) ^ 2 * vector2 + (1 - p) * 2 * p * vector3 + p ^ 2 * vector4
	end,
	cubicBezier = function(p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3)
		return (1 - p) ^ 3 * vector2 + (1 - p) ^ 2 * 3 * p * vector3 + (1 - p) * 3 * p ^ 2 * vector4 + p ^ 3 * vector5
	end,
	getDirectionByVector3 = function(vector2: Vector3)
		local X = vector2.X
		local Z = vector2.Z

		if math.abs(X) > math.abs(Z) then
			if X < 0 then
				return "Left"
			end

			return "Right"
		elseif Z > 0 then
			return "Back"
		else
			return "Front"
		end
	end,
	rayCast = function(vector2: Vector3, vector3: Vector3, filterDescendantsInstances, p, flag: boolean?)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = p or Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)

		if raycastResult or not flag then
			return raycastResult
		end

		return {
			Position = vector3
		}
	end
}

function MathUtil.checkGround(vector2: Vector3, value: number?)
	local map = workspace:FindFirstChild("Map")
	assert(map, "bad map")
	return MathUtil.rayCast(
		vector2,
		createVector(-0, -1, -0) * (value or 3.25),
		{ map },
		Enum.RaycastFilterType.Include
	)
end

function MathUtil.clearBodyMover(instance, value: string?)
	local firstChildWhichIsA = instance:FindFirstChildWhichIsA(value or "BodyMover")

	if not firstChildWhichIsA then
		return
	end

	firstChildWhichIsA:Destroy()
end

function MathUtil.bodyVelocity(parent, vector2: Vector3?, vector3: Vector3?)
	MathUtil.clearBodyMover(parent, "BodyVelocity")
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = vector2 or createVector(0, 0, 0)
	bodyVelocity.MaxForce = vector3 or createVector(2500000, 2500000, 2500000)
	bodyVelocity.P = 1e999
	bodyVelocity.Parent = parent
	return bodyVelocity
end

function MathUtil.bodyGyro(parent, cframe: CFrame?, vector2: Vector3?, value: number?, value2: number?)
	MathUtil.clearBodyMover(parent, "BodyGyro")
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = vector2 or createVector(250000, 250000, 250000)
	bodyGyro.P = value or 250000
	bodyGyro.D = value2 or 0
	bodyGyro.CFrame = cframe or parent.CFrame
	bodyGyro.Parent = parent
	return bodyGyro
end

function MathUtil.attachment(parent, p: string?)
	local attachment = Instance.new("Attachment")
	attachment.Name = p or attachment.Name
	attachment.Parent = parent
	return attachment
end

function MathUtil.linearVelocity(p, p2: string?, vector2: Vector3?, vector3: Vector3?, p3)
	local attachment = MathUtil.attachment(p, p2)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = p3 or Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = vector2 or createVector(1, 1, 1) * 1e999
	linearVelocity.VectorVelocity = vector3 or createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	return linearVelocity, attachment
end

function MathUtil.alignPosition(p, p2: string?, vector2: Vector3?, vector3: Vector3?, p3)
	local attachment = MathUtil.attachment(p, p2)
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.ForceRelativeTo = p3 or Enum.ActuatorRelativeTo.Attachment0
	alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxAxesForce = vector2 or createVector(1, 1, 1) * 1e999
	alignPosition.Position = vector3 or createVector(0, 0, 0)
	alignPosition.Parent = attachment
	return alignPosition, attachment
end

function MathUtil.alignOrientation(p, p2: string?, value: number?, cframe: CFrame?)
	local attachment = MathUtil.attachment(p, p2)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxTorque = value or 1e999
	alignOrientation.CFrame = cframe or CFrame.new()
	alignOrientation.Parent = attachment
	return alignOrientation, attachment
end

return MathUtil