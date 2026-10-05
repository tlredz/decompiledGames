local Cylinder = {}
Cylinder.__index = Cylinder

function Cylinder.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Cylinder)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Cylinder:Draw(cframe: CFrame, p2: number, p3: number, p4: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local v = cframe.Position + cframe.UpVector * (p3 * 0.5)
	local v2 = cframe.Position - cframe.UpVector * (p3 * 0.5)
	local cframe2 = CFrame.lookAt(v, v + cframe.UpVector)
	local cframe3 = CFrame.lookAt(v2, v2 - cframe.UpVector)
	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = nil

	for i = 0, 360, math.floor(360 / p4) do
		local v7 = math.sin((math.rad(i))) * p2
		local v8 = math.cos((math.rad(i))) * p2
		local v9 = cframe.LookVector * v8 + cframe.RightVector * v7
		local v10 = cframe2.Position + v9
		local v11 = cframe3.Position + v9
		ceive.Ray:Draw(v10, v11)

		if v3 then
			ceive.Ray:Draw(v3, v10)
			ceive.Ray:Draw(v4, v11)
			v4 = v11
			v3 = v10
		else
			v6 = v11
			v5 = v10
			v4 = v6
			v3 = v5
			v6 = v4
			v5 = v3
			v4 = v6
		end
	end

	ceive.Ray:Draw(v3, v5)
	ceive.Ray:Draw(v4, v6)
end

function Cylinder.Create(p, cframe: CFrame, radius: number, length: number, subdivisions: number)
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

function Cylinder:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius, data.Length, data.Subdivisions)
end

return Cylinder