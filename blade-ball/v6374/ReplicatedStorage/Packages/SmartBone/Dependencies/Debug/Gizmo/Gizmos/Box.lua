local Box = {}
Box.__index = Box

function Box.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Box)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Box:Draw(cframe: CFrame, vector: Vector3, flag: boolean)
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

	local function CalculateYFace(p2, p3, p4)
		local v5 = position + (p2 - p3 + p4)
		local v6 = position + (p2 + p3 + p4)
		local v7 = position + (p2 - p3 - p4)
		local v8 = position + (p2 + p3 - p4)
		ceive.Ray:Draw(v5, v6)
		ceive.Ray:Draw(v5, v7)
		ceive.Ray:Draw(v6, v8)

		if flag ~= false then
			ceive.Ray:Draw(v6, v7)
		end

		ceive.Ray:Draw(v7, v8)
	end

	local function CalculateZFace(p2, p3, p4)
		local v5 = position + (p2 - p3 + p4)
		local v6 = position + (p2 + p3 + p4)
		local v7 = position + (-p2 - p3 + p4)
		local v8 = position + (-p2 + p3 + p4)
		ceive.Ray:Draw(v5, v6)
		ceive.Ray:Draw(v5, v7)
		ceive.Ray:Draw(v6, v8)

		if flag ~= false then
			ceive.Ray:Draw(v6, v7)
		end

		ceive.Ray:Draw(v7, v8)
	end

	local function CalculateXFace(p2, p3, p4)
		local v5 = position + (p2 - p3 - p4)
		local v6 = position + (p2 - p3 + p4)
		local v7 = position + (-p2 - p3 - p4)
		local v8 = position + (-p2 - p3 + p4)
		ceive.Ray:Draw(v5, v6)
		ceive.Ray:Draw(v5, v7)
		ceive.Ray:Draw(v6, v8)

		if flag ~= false then
			ceive.Ray:Draw(v6, v7)
		end

		ceive.Ray:Draw(v7, v8)
	end

	CalculateXFace(v2, v3, v4)
	CalculateXFace(v2, -v3, v4)
	CalculateYFace(v2, v3, v4)
	CalculateYFace(-v2, v3, v4)
	CalculateZFace(v2, v3, v4)
	CalculateZFace(v2, v3, -v4)
end

function Box.Create(p, cframe: CFrame, vector: Vector3, drawTriangles: boolean)
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

function Box:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Size, data.DrawTriangles)
end

return Box