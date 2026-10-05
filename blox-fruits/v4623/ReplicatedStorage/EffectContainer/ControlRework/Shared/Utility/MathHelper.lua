local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v = { workspace:WaitForChild("Terrain"), _WorldOrigin, workspace.CurrentCamera }
local MathHelper = {}

function MathHelper.QuadBezier(_, p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return (1 - p) ^ 2 * vector2 + (1 - p) * 2 * p * vector3 + p ^ 2 * vector4
end

function MathHelper.CubicBezier(_, p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3)
	return (1 - p) ^ 3 * vector2 + (1 - p) ^ 2 * 3 * p * vector3 + (1 - p) * 3 * p ^ 2 * vector4 + p ^ 3 * vector5
end

function MathHelper.WaitByAnimationTimePosition(_, p: number, value: number?, value2: number?)
	return task.wait(p / (value2 or 60) / (value or 1))
end

function MathHelper:RayCast(vector2: Vector3, vector3: Vector3, filterDescendantsInstances, p, p2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = p or Enum.RaycastFilterType.Exclude

	if raycastParams.FilterType == Enum.RaycastFilterType.Exclude then
		local filterDescendantsInstances2 = {}

		for _, v3 in pairs(v) do
			table.insert(filterDescendantsInstances2, v3)
		end

		for _, v3 in pairs(filterDescendantsInstances or {}) do
			table.insert(filterDescendantsInstances2, v3)
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances2
	else
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	end

	local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)

	if raycastResult or not p2 then
		return raycastResult
	end

	return {
		Position = typeof(p2) == "Vector3" and p2 or vector3
	}
end

function MathHelper:GroundRayCast(value)
	return self:RayCast(
		typeof(value) == "Vector3" and value or typeof(value) == "CFrame" and value.Position or value:GetPivot().Position,
		Vector3.new(0, -3 * (typeof(value) ~= "Instance" and 1 or value:GetScale() or 1)),
		{ workspace.Map },
		Enum.RaycastFilterType.Include
	)
end

function MathHelper.BodyVelocity(_, parent, vector2: Vector3?, vector3: Vector3?, childName: string?)
	if childName and parent:FindFirstChild(childName) then
		parent[childName]:Destroy()
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = vector2 or createVector(0, 0, 0)
	bodyVelocity.MaxForce = vector3 or createVector(250000, 250000, 250000)
	bodyVelocity.P = (bodyVelocity.MaxForce.X + bodyVelocity.MaxForce.Y + bodyVelocity.MaxForce.Z) / 3
	bodyVelocity.Name = childName or bodyVelocity.Name
	bodyVelocity.Parent = parent
	return bodyVelocity
end

function MathHelper.BodyGyro(_, parent, value: number?, value2: number?, vector2: Vector3?, p: string?)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = vector2 or createVector(250000, 250000, 250000)
	bodyGyro.P = value or 0
	bodyGyro.D = value2 or 0
	bodyGyro.Name = p or bodyGyro.Name
	bodyGyro.CFrame = parent.CFrame
	bodyGyro.Parent = parent
	return bodyGyro
end

function MathHelper:Attachment(parent, childName: string?)
	if childName and parent:FindFirstChild(childName) then
		parent[childName]:Destroy()
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = childName or attachment.Name
	attachment.Parent = parent
	return attachment
end

function MathHelper:LinearVelocity(p, vector2: Vector3?, vector3: Vector3?, p2: string?, p3)
	local attachment = self:Attachment(p, p2)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = p3 or Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = vector2 or createVector(1, 1, 1) * 1e999
	linearVelocity.VectorVelocity = vector3 or createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	return linearVelocity, attachment
end

function MathHelper:AlignPosition(p, vector2: Vector3?, vector3: Vector3?, p2: string?, p3)
	local attachment = self:Attachment(p, p2)
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

function MathHelper:AlignOrientation(p, value: Vector3?, vector2: Vector3?, p2: string?)
	local attachment = self:Attachment(p, p2)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxTorque = value or 1e999
	alignOrientation.CFrame = vector2 or CFrame.new()
	alignOrientation.Parent = attachment
	return alignOrientation, attachment
end

return MathHelper