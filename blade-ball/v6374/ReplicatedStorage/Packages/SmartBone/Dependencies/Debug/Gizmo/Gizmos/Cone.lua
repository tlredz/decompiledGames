local Cone = {}
Cone.__index = Cone

function Cone.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Cone)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Cone:Draw(cframe: CFrame, p2: number, p3: number, p4: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local v = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
	local v2 = v.Position + v.UpVector * (p3 * 0.5)
	local v3 = v.Position + -v.UpVector * (p3 * 0.5)
	local cframe2 = CFrame.lookAt(v2, v2 + v.UpVector)
	local cframe3 = CFrame.lookAt(v3, v3 - v.UpVector)
	local v4 = nil
	local v5 = nil

	for i = 0, 360, math.floor(360 / p4) do
		local v6 = math.sin((math.rad(i))) * p2
		local v7 = math.cos((math.rad(i))) * p2
		local v8 = v.LookVector * v7 + v.RightVector * v6
		local v9 = cframe3.Position + v8

		if v4 then
			ceive.Ray:Draw(v9, cframe2.Position)
			ceive.Ray:Draw(v4, v9)
			v4 = v9
		else
			ceive.Ray:Draw(v9, cframe2.Position)
			v5 = v9
			v4 = v5
			v5 = v4
		end
	end

	ceive.Ray:Draw(v4, v5)
end

function Cone.Create(p, cframe: CFrame, radius: number, length: number, subdivisions: number)
	local v = {
		Transform = cframe,
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

function Cone:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius, data.Length, data.Subdivisions)
end

return Cone