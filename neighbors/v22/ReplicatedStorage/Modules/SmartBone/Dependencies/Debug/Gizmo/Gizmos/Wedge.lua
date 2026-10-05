local Wedge = {}
Wedge.__index = Wedge

function Wedge.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Wedge)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Wedge:Draw(cframe: CFrame, vector: Vector3, flag: boolean)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local position = cframe.Position
	local upVector = cframe.UpVector
	local rightVector = cframe.RightVector
	local lookVector = cframe.LookVector
	local v = vector * 0.5
	local v2 = upVector * v.Y
	local v3 = rightVector * v.X
	local v4 = lookVector * v.Z
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local v8 = nil

	local function CalculateYFace(p2, p3, p4)
		local v9 = position + (p2 - p3 + p4)
		local v10 = position + (p2 + p3 + p4)
		local v11 = position + (p2 - p3 - p4)
		local v12 = position + (p2 + p3 - p4)
		v5 = v9
		v6 = v10
		ceive.Ray:Draw(v9, v10)
		ceive.Ray:Draw(v9, v11)
		ceive.Ray:Draw(v10, v12)

		if flag ~= false then
			ceive.Ray:Draw(v10, v11)
		end

		ceive.Ray:Draw(v11, v12)
	end

	local function CalculateZFace(p2, p3, p4)
		local v9 = position + (p2 - p3 + p4)
		local v10 = position + (p2 + p3 + p4)
		local v11 = position + (-p2 - p3 + p4)
		local v12 = position + (-p2 + p3 + p4)
		v7 = v9
		v8 = v10
		ceive.Ray:Draw(v9, v10)
		ceive.Ray:Draw(v9, v11)
		ceive.Ray:Draw(v10, v12)

		if flag ~= false then
			ceive.Ray:Draw(v10, v11)
		end

		ceive.Ray:Draw(v11, v12)
	end

	CalculateYFace(-v2, v3, v4)
	CalculateZFace(v2, v3, -v4)
	ceive.Ray:Draw(v5, v7)
	ceive.Ray:Draw(v6, v8)

	if flag ~= false then
		ceive.Ray:Draw(v6, v7)
	end
end

function Wedge.Create(p, cframe: CFrame, vector: Vector3, drawTriangles: boolean)
	local v = {
		Transform = cframe,
		Size = vector,
		DrawTriangles = drawTriangles,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Wedge:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Size, data.DrawTriangles)
end

return Wedge