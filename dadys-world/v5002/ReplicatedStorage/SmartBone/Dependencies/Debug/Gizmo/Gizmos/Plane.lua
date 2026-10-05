local createVector = vector.create
local Plane = {}
Plane.__index = Plane

function Plane.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Plane)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Plane:Draw(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local v = vector4 * createVector(1, 1, 0)
	local cframe = CFrame.lookAt(vector2, vector2 + vector3)
	local upVector = cframe.UpVector
	local rightVector = cframe.RightVector
	local lookVector = cframe.LookVector
	local v2 = v * 0.5

	local function CalculateZFace(p2, p3, p4)
		local v3 = vector2 + (p2 - p3 + p4)
		local v4 = vector2 + (p2 + p3 + p4)
		local v5 = vector2 + (-p2 - p3 + p4)
		local v6 = vector2 + (-p2 + p3 + p4)
		ceive.Ray:Draw(v3, v4)
		ceive.Ray:Draw(v3, v5)
		ceive.Ray:Draw(v4, v6)
		ceive.Ray:Draw(v4, v5)
		ceive.Ray:Draw(v5, v6)
	end

	CalculateZFace(upVector * v2.Y, rightVector * v2.X, lookVector * v2.Z)
end

function Plane.Create(p, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v = {
		Position = vector2,
		Normal = vector3,
		Size = vector4,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Plane:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Position, data.Normal, data.Size)
end

return Plane