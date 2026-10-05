local Draw = require(game.ReplicatedStorage.Packages.Draw)

function newPlane(vector: Vector3, vector2: Vector3, vector3: Vector3)
	local unit = (vector2 - vector):Cross(vector3 - vector2).Unit
	local v = {
		Normal = unit,
		Origin = vector,
		Dot = -unit:Dot(vector)
	}
	table.freeze(v)
	return v
end

function getPlaneIntersection(vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local dot = vector2:Dot(vector4)

	if math.abs(dot) > 1e-6 then
		local v = -vector2:Dot(vector3 - vector) / dot

		if v >= 0 and v <= 1 then
			return vector3 + vector4 * v
		end
	end

	return nil
end

function getRectangleIntersection(vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, vector6: Vector3)
	local vector7 = (vector4 - vector3).Unit:Cross((vector5 - vector3).Unit)

	if vector7:Dot(vector2.Unit) > 0 then
		vector7 *= -1
	end

	local planeIntersection = getPlaneIntersection(vector3, vector7, vector, vector2)

	if not planeIntersection then
		return nil
	end

	local dot = (vector4 - vector3):Dot(planeIntersection - vector3)
	local dot2 = (vector3 - vector4):Dot(planeIntersection - vector4)
	local dot3 = (vector5 - vector4):Dot(planeIntersection - vector4)
	local dot4 = (vector4 - vector5):Dot(planeIntersection - vector5)
	local dot5 = (vector6 - vector5):Dot(planeIntersection - vector5)
	local dot6 = (vector5 - vector6):Dot(planeIntersection - vector6)
	local dot7 = (vector3 - vector6):Dot(planeIntersection - vector6)
	local dot8 = (vector6 - vector3):Dot(planeIntersection - vector3)

	if dot >= 0 and dot2 >= 0 and dot3 >= 0 and dot4 >= 0 and dot5 >= 0 and dot6 >= 0 and dot7 >= 0 and dot8 >= 0 then
		return planeIntersection
	end

	return nil
end

function getTriangleIntersection(vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3)
	local vector6 = (vector4 - vector3).Unit:Cross((vector5 - vector3).Unit)

	if vector6:Dot(vector2.Unit) > 0 then
		vector6 *= -1
	end

	local planeIntersection = getPlaneIntersection(vector3, vector6, vector, vector2)

	if not planeIntersection then
		return nil
	end

	local function getTriangleArea(p: number, p2: number, p3: number)
		local midpoint = (p + p2 + p3) / 2
		return (midpoint * (midpoint - p) * (midpoint - p2) * (midpoint - p3)) ^ 0.5
	end

	local magnitude = (vector3 - vector4).Magnitude
	local magnitude2 = (vector4 - vector5).Magnitude
	local magnitude3 = (vector5 - vector3).Magnitude
	local magnitude4 = (planeIntersection - vector3).Magnitude
	local magnitude5 = (planeIntersection - vector4).Magnitude
	local magnitude6 = (planeIntersection - vector5).Magnitude
	local midpoint2 = (magnitude + magnitude4 + magnitude5) / 2
	local v2 = (midpoint2 * (midpoint2 - magnitude) * (midpoint2 - magnitude4) * (midpoint2 - magnitude5)) ^ 0.5
	local midpoint3 = (magnitude2 + magnitude6 + magnitude5) / 2
	local v4 = (midpoint3 * (midpoint3 - magnitude2) * (midpoint3 - magnitude6) * (midpoint3 - magnitude5)) ^ 0.5
	local midpoint4 = (magnitude3 + magnitude6 + magnitude4) / 2
	local v6 = (midpoint4 * (midpoint4 - magnitude3) * (midpoint4 - magnitude6) * (midpoint4 - magnitude4)) ^ 0.5
	local midpoint5 = (magnitude + magnitude2 + magnitude3) / 2
	local v8 = (midpoint5 * (midpoint5 - magnitude) * (midpoint5 - magnitude2) * (midpoint5 - magnitude3)) ^ 0.5

	if math.abs(v8 - (v2 + v4 + v6)) < v8 * 0.001 then
		return planeIntersection
	end

	return nil
end

local DebugFrustum = {}
DebugFrustum.__index = DebugFrustum

function DebugFrustum._GetIfPointIsCloseEnough(p, vector: Vector3)
	return p.CFrame:PointToObjectSpace(vector).Z <= p.FarPlaneDistance
end

function DebugFrustum:GetIfPointRendered(vector: Vector3)
	return self:GetIfSphereRendered(vector, 0)
end

function DebugFrustum:GetIfSphereRendered(vector: Vector3, p2: number)
	for _, plane in pairs(self.Planes) do
		if vector:Dot(plane.Normal) + plane.Dot + p2 <= 0 then
			return false
		end
	end

	return true
end

function DebugFrustum:GetIfRectangleRendered(vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local lerped = vector:Lerp(vector2, 0.5):Lerp(vector3:Lerp(vector4, 0.5), 0.5)

	if not self:GetIfSphereRendered(
		lerped,
		(math.max(
			(lerped - vector).Magnitude,
			(lerped - vector2).Magnitude,
			(lerped - vector3).Magnitude,
			(lerped - vector4).Magnitude
		))
	) then
		return false
	end

	if self:GetIfPointRendered(vector) or self:GetIfPointRendered(vector2) or self:GetIfPointRendered(vector3) or self:GetIfPointRendered(vector4) then
		return true
	end

	for _, ray in ipairs(self.Rays) do
		if getRectangleIntersection(ray.Origin, ray.Direction, vector, vector2, vector3, vector4) then
			return true
		end
	end

	return false
end

function DebugFrustum:GetIfTriangleRendered(vector: Vector3, vector2: Vector3, vector3: Vector3)
	local lerped = vector:Lerp(vector2, 0.5):Lerp(vector3, 0.3333333333333333)

	if not self:GetIfSphereRendered(
		lerped,
		(math.max((lerped - vector).Magnitude, (lerped - vector2).Magnitude, (lerped - vector3).Magnitude))
	) then
		return false
	end

	if self:GetIfPointRendered(vector) or self:GetIfPointRendered(vector2) or self:GetIfPointRendered(vector3) then
		return true
	end

	for _, ray in ipairs(self.Rays) do
		if getTriangleIntersection(ray.Origin, ray.Direction, vector, vector2, vector3) then
			return true
		end
	end

	return false
end

function DebugFrustum.GetIfPlaneRendered(p, vector: Vector3, vector2: Vector3)
	for _, ray in ipairs(p.Rays) do
		if getPlaneIntersection(vector, vector2, ray.Origin, ray.Direction) then
			return true
		end
	end

	return false
end

function DebugFrustum:GetIfBlockRendered(cframe: CFrame, vector: Vector3)
	if not self:GetIfSphereRendered(cframe.Position, vector.Magnitude / 2) then
		return false
	end

	local lookVector = self.CFrame.LookVector

	for _, v in ipairs({
		{ cframe.RightVector * vector.X, -cframe.LookVector * vector.Z, cframe.UpVector * vector.Y },
		{ cframe.UpVector * vector.Y, cframe.RightVector * vector.X, -cframe.LookVector * vector.Z },
		{ -cframe.LookVector * vector.Z, cframe.RightVector * vector.X, cframe.UpVector * vector.Y }
	}) do
		local v4 = v[2]
		local v5 = v[3]

		local function solveFace(vector2: Vector3)
			local v6 = cframe.Position + vector2 / 2
			local v7 = v6 + v4 / 2 + v5 / 2

			if self:GetIfPointRendered(v7) then
				return true
			end

			local v8 = v6 - v4 / 2 + v5 / 2

			if self:GetIfPointRendered(v8) then
				return true
			end

			local v9 = v6 + v4 / 2 - v5 / 2

			if self:GetIfPointRendered(v9) then
				return true
			end

			local v10 = v6 - v4 / 2 - v5 / 2

			if self:GetIfPointRendered(v10) or self:GetIfRectangleRendered(v7, v8, v9, v10) then
				return true
			end

			return false
		end

		if v[1]:Dot(lookVector) < 0 then
			if solveFace(v[1]) then
				return true
			end
		elseif solveFace(-v[1]) then
			return true
		end
	end

	return false
end

function DebugFrustum:GetIfOverlapFrustum(p)
	return self:GetIfSphereRendered(p.Position, p.Size.Magnitude / 2)
end

function DebugFrustum._Draw(p)
	local folder = Instance.new("Folder")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function line(origin: Vector3, direction: Vector3, color: Color3)
		local vector = Draw.vector(origin, direction, color, folder, 1)
		vector.Locked = true
		vector.Archivable = false
	end

	for _, ray in ipairs(p.Rays) do
		line(ray.Origin, ray.Direction, Color3.new(1, 0, 1)) -- equivalent call inferred; original call site unknown
	end

	folder.Name = "Frustum"
	return folder
end

function DebugFrustum.__eq(data, data2)
	if type(data2) ~= "table" then
		return false
	end

	assert(type(data2) == "table")

	if not (data.CFrame == data2.CFrame and data.FieldOfView == data2.FieldOfView and data.ViewportSize == data2.ViewportSize) then
		return false
	end

	return data.NearPlaneZ == data2.NearPlaneZ and data.FarPlaneDistance == data2.FarPlaneDistance
end

function DebugFrustum.new(cFrame: CFrame, p: number, viewportSize: Vector2, nearPlaneZ: number, farPlaneDistance: number)
	local self = setmetatable({}, DebugFrustum)
	self.CFrame = cFrame
	self.FarPlaneDistance = farPlaneDistance
	self.ViewportSize = viewportSize
	self.AspectRatio = self.ViewportSize.X / self.ViewportSize.Y
	self.NearPlaneZ = nearPlaneZ
	self.FieldOfView = math.rad(p)
	self.HalfFieldOfView = self.FieldOfView / 2
	self.HalfHorizontalFieldOfView = self.AspectRatio * self.HalfFieldOfView
	self.HalfFarPlaneHeight = math.tan(self.HalfFieldOfView) * 2 * self.FarPlaneDistance / 2
	self.HalfFarPlaneWidth = self.HalfFarPlaneHeight * self.AspectRatio
	self.HalfNearPlaneHeight = math.tan(self.HalfFieldOfView) * 2 * -self.NearPlaneZ / 2
	self.HalfNearPlaneWidth = self.HalfNearPlaneHeight * self.AspectRatio
	self.FarTopLeft = self.CFrame * Vector3.new(
		-self.HalfFarPlaneWidth,
		self.HalfFarPlaneHeight,
		-self.FarPlaneDistance
	)
	self.FarTopRight = self.CFrame * Vector3.new(
		self.HalfFarPlaneWidth,
		self.HalfFarPlaneHeight,
		-self.FarPlaneDistance
	)
	self.FarBottomRight = self.CFrame * Vector3.new(
		self.HalfFarPlaneWidth,
		-self.HalfFarPlaneHeight,
		-self.FarPlaneDistance
	)
	self.FarBottomLeft = self.CFrame * Vector3.new(
		-self.HalfFarPlaneWidth,
		-self.HalfFarPlaneHeight,
		-self.FarPlaneDistance
	)
	self.NearTopLeft = self.CFrame * Vector3.new(-self.HalfNearPlaneWidth, self.HalfNearPlaneHeight, self.NearPlaneZ)
	self.NearTopRight = self.CFrame * Vector3.new(self.HalfNearPlaneWidth, self.HalfNearPlaneHeight, self.NearPlaneZ)
	self.NearBottomLeft = self.CFrame * Vector3.new(
		-self.HalfNearPlaneWidth,
		-self.HalfNearPlaneHeight,
		self.NearPlaneZ
	)
	self.NearBottomRight = self.CFrame * Vector3.new(
		self.HalfNearPlaneWidth,
		-self.HalfNearPlaneHeight,
		self.NearPlaneZ
	)
	self.Planes = {}
	self.Planes.Near = newPlane(self.NearTopRight, self.NearBottomRight, self.NearTopLeft)
	self.Planes.Far = newPlane(self.FarTopRight, self.FarTopLeft, self.FarBottomRight)
	self.Planes.Top = newPlane(self.NearTopRight, self.NearTopLeft, self.FarTopRight)
	self.Planes.Bottom = newPlane(self.NearBottomRight, self.FarBottomRight, self.NearBottomLeft)
	self.Planes.Left = newPlane(self.NearTopLeft, self.NearBottomLeft, self.FarTopLeft)
	self.Planes.Right = newPlane(self.NearTopRight, self.FarTopRight, self.NearBottomRight)
	self.Rays = {
		Ray.new(self.FarTopLeft, self.FarTopRight - self.FarTopLeft),
		Ray.new(self.FarTopLeft, self.NearTopLeft - self.FarTopLeft),
		Ray.new(self.FarTopRight, self.NearTopRight - self.FarTopRight),
		Ray.new(self.NearTopLeft, self.NearTopRight - self.NearTopLeft),
		Ray.new(self.FarBottomLeft, self.FarBottomRight - self.FarBottomLeft),
		Ray.new(self.FarBottomLeft, self.NearBottomLeft - self.FarBottomLeft),
		Ray.new(self.FarBottomRight, self.NearBottomRight - self.FarBottomRight),
		Ray.new(self.NearBottomLeft, self.NearBottomRight - self.NearBottomLeft),
		Ray.new(self.NearBottomLeft, self.NearTopLeft - self.NearBottomLeft),
		Ray.new(self.FarBottomLeft, self.FarTopLeft - self.FarBottomLeft),
		Ray.new(self.NearBottomRight, self.NearTopRight - self.NearBottomRight),
		Ray.new(self.FarBottomRight, self.FarTopRight - self.FarBottomRight)
	}
	table.freeze(self.Planes)
	table.freeze(self.Rays)
	table.freeze(self)
	return self
end

function DebugFrustum.fromCamera(object, p: number)
	assert(object.FieldOfViewMode == Enum.FieldOfViewMode.Vertical, "camera FieldOfViewMode must be vertical for now")
	return DebugFrustum.new(object:GetRenderCFrame(), object.FieldOfView, object.ViewportSize, object.NearPlaneZ, p)
end

return DebugFrustum