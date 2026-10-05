local createVector = vector.create
local plane2 = {}
local point3 = {}
local constraint = {}

function posFrom(p, p2, p3, p4)
	p.Position = UDim2.new(
		p2.X.Scale - p.Size.X.Scale * p3,
		p2.X.Offset - p.Size.X.Offset * p3,
		p2.Y.Scale - p.Size.Y.Scale * p4,
		p2.Y.Offset - p.Size.Y.Offset * p4
	)
end

function plane2.new(cframe, normal, point, scalar)
	local self = setmetatable({}, {
		__index = plane2
	})
	self.cframe = cframe
	self.normal = normal
	self.point = point
	self.scalar = scalar
	return self
end

function plane2:isAbove(p)
	local v4 = (p - self.cframe.p):Dot(self.normal) - self.scalar
	return v4 > 0, v4
end

function plane2:pointToPlane(p2)
	return p2 - (p2 - self.point):Dot(self.normal) * self.normal
end

local collision = {}

function collision.new(instance)
	local object = setmetatable({}, {
		__index = collision
	})
	object.planes = {}
	object.origin = instance.CFrame
	local vectorToWorldSpace = instance.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	object.planes[1] = plane2.new(
		instance.CFrame,
		vectorToWorldSpace,
		instance.Position + vectorToWorldSpace * instance.Size.y / 2,
		instance.Size.y / 2
	)
	local vectorToWorldSpace2 = instance.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Bottom))
	object.planes[2] = plane2.new(
		instance.CFrame,
		vectorToWorldSpace2,
		instance.Position + vectorToWorldSpace2 * instance.Size.y / 2,
		instance.Size.y / 2
	)
	local vectorToWorldSpace3 = instance.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Right))
	object.planes[3] = plane2.new(
		instance.CFrame,
		vectorToWorldSpace3,
		instance.Position + vectorToWorldSpace3 * instance.Size.x / 2,
		instance.Size.x / 2
	)
	local vectorToWorldSpace4 = instance.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Left))
	object.planes[4] = plane2.new(
		instance.CFrame,
		vectorToWorldSpace4,
		instance.Position + vectorToWorldSpace4 * instance.Size.x / 2,
		instance.Size.x / 2
	)
	local vectorToWorldSpace5 = instance.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Front))
	object.planes[5] = plane2.new(
		instance.CFrame,
		vectorToWorldSpace5,
		instance.Position + vectorToWorldSpace5 * instance.Size.z / 2,
		instance.Size.z / 2
	)
	local vectorToWorldSpace6 = instance.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Back))
	object.planes[6] = plane2.new(
		instance.CFrame,
		vectorToWorldSpace6,
		instance.Position + vectorToWorldSpace6 * instance.Size.z / 2,
		instance.Size.z / 2
	)
	return object
end

function collision:pointIn(p2)
	local result = {}

	for _, plane in ipairs(self.planes) do
		local above, v5 = plane:isAbove(p2)

		if above then
			return false
		else
			table.insert(result, { math.abs(v5), plane })
		end
	end

	return result
end

function collision:pointToPlanes(p)
	local pointIn = self:pointIn(p)

	if not pointIn then
		return
	end

	table.sort(pointIn, function(a, b)
		return a[1] < b[1]
	end)
	return (pointIn[1][2]:pointToPlane(p))
end

function point3.new(p)
	local self = setmetatable({}, {
		__index = point3
	})
	self.position = p
	self.previousPosition = p
	self.velocity = Vector3.new()
	self.acceleration = Vector3.new()
	self.gravity = 196.2
	self.anchored = false
	return self
end

function point3:update(p, p2)
	if self.anchored then
		self.acceleration = Vector3.new()
		self.velocity = Vector3.new()
		self.previousPosition = self.position
	else
		self.acceleration = Vector3.new(0, -self.gravity, 0)
		self.velocity = self.position - self.previousPosition
		self.previousPosition = self.position
		self.position = self.position + self.velocity * p2 + self.acceleration * p ^ 2
	end
end

function constraint.new(point, point2, restDistance, twod)
	local self = setmetatable({}, {
		__index = constraint
	})
	self.point1 = point
	self.point2 = point2
	self.restDistance = restDistance
	self.canBreak = false
	self.breakDistance = 5
	self.twod = twod

	if self.twod then
		self.line2d = Instance.new("Frame")
		self.line2d.BackgroundColor3 = Color3.new()
		self.line2d.BorderSizePixel = 0
	else
		self.line = Instance.new("Part")
		self.line.Size = createVector(0.2, 0.2, 0.2)
		self.line.Anchored = true
		self.line.CanCollide = false
		self.line.BrickColor = BrickColor.new("Really black")
		self.mesh = Instance.new("BlockMesh", self.line)
		self.mesh.Scale = createVector(1, 1, 1)
	end

	return self
end

function constraint:solve()
	if self.point1 and self.point2 then
		local v5 = self.point1.position - self.point2.position
		local magnitude = v5.magnitude
		local v6 = (self.restDistance - magnitude) / magnitude
		local v7 = v5 * 0.5 * v6

		if not self.point1.anchored then
			self.point1.position = self.point1.position + v7
		end

		if not self.point2.anchored then
			self.point2.position = self.point2.position - v7
		end

		if self.canBreak and (self.point1.position - self.point2.position).magnitude > self.restDistance + self.breakDistance then
			self:Destroy()
		end
	end
end

function constraint.draw(data)
	if data.point1 and data.point2 and data.line then
		local magnitude = (data.point1.position - data.point2.position).magnitude
		data.line.CFrame = CFrame.new(data.point1.position, data.point2.position) * CFrame.new(0, 0, -magnitude / 2)
		data.mesh.Scale = Vector3.new(1, 1, magnitude / 0.2)
	end
end

function constraint.draw2d(data)
	if data.point1 and data.point2 and data.line2d then
		local v5 = data.point1.position - data.point2.position
		local v6 = data.point2.position + v5 / 2
		data.line2d.Rotation = math.deg((math.atan2(v5.y, v5.x)))
		data.line2d.Size = UDim2.new(0, v5.magnitude, 0, 2)
		posFrom(data.line2d, UDim2.new(0, v6.x, 0, v6.y), 0.5, 0.5)
	end
end

function constraint:Destroy()
	self.point1 = nil
	self.point2 = nil

	if self.twod then
		self.line2d:Destroy()
		return
	end

	self.mesh:Destroy()
	self.line:Destroy()
end

return {
	plane = plane2,
	point = point3,
	collision = collision,
	constraint = constraint
}