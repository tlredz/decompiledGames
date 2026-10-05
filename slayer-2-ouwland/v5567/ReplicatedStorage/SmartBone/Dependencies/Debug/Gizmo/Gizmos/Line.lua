local Line = {}
Line.__index = Line

function Line.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Line)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Line:Draw(cframe: CFrame, p2: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local v = cframe.Position + cframe.LookVector * (-p2 * 0.5)
	local v2 = cframe.Position + cframe.LookVector * (p2 * 0.5)
	ceive.Ray:Draw(v, v2)
end

function Line.Create(p, cframe: CFrame, length: number)
	local v = {
		Transform = cframe,
		Length = length,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Line:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Length)
end

return Line