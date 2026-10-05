local Arrow = {}
Arrow.__index = Arrow

function Arrow.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Arrow)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Arrow:Draw(vector: Vector3, vector2: Vector3, p2: number, p3: number, p4: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	ceive.Ray:Draw(vector, vector2)
	local cframe = CFrame.lookAt(vector2 + (vector - vector2).Unit * (p3 * 0.5), vector2)
	ceive.Cone:Draw(cframe, p2, p3, p4)
end

function Arrow.Create(p, vector: Vector3, vector2: Vector3, radius: number, length: number, subdivisions: number)
	local v = {
		Origin = vector,
		End = vector2,
		Radius = radius,
		Length = length,
		Subdivisions = subdivisions,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Arrow:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Origin, data.End, data.Radius, data.Length, data.Subdivisions)
end

return Arrow