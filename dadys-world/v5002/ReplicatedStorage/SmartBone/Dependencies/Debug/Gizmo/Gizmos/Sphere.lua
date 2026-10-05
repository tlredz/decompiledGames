local Sphere = {}
Sphere.__index = Sphere

function Sphere.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Sphere)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Sphere:Draw(cframe: CFrame, p2: number, p3: number, p4: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	ceive.Circle:Draw(cframe, p2, p3, p4)
	ceive.Circle:Draw(cframe * CFrame.Angles(0, 1.5707963267948966, 0), p2, p3, p4)
	ceive.Circle:Draw(cframe * CFrame.Angles(1.5707963267948966, 0, 0), p2, p3, p4)
end

function Sphere.Create(p, cframe: CFrame, radius: number, subdivisions: number, angle: number)
	local v = {
		Transform = cframe,
		Radius = radius,
		Subdivisions = subdivisions,
		Angle = angle,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Sphere:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius, data.Subdivisions, data.Angle)
end

return Sphere