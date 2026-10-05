local Circle = {}
Circle.__index = Circle

function Circle.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Circle)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Circle:Draw(cframe: CFrame, p2: number, p3: number, p4: number, flag: boolean?)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local v = nil
	local v2 = 0
	local v3 = nil

	for i = 0, p4, math.floor(p4 / p3) do
		local v4 = math.sin((math.rad(i))) * p2
		local v5 = math.cos((math.rad(i))) * p2
		local v6 = cframe.Position + (cframe.UpVector * v5 + cframe.RightVector * v4)

		if v == nil then
			v3 = v6
			v2 = i
			v = v3
			v3 = v
		else
			ceive.Ray:Draw(v, v6)
			v2 = i
			v = v6
		end
	end

	if v2 ~= p4 then
		local v4 = math.sin((math.rad(p4))) * p2
		local v5 = math.cos((math.rad(p4))) * p2
		local v6 = cframe.Position + (cframe.UpVector * v5 + cframe.RightVector * v4)
		ceive.Ray:Draw(v, v6)
	end

	if flag ~= false then
		ceive.Ray:Draw(v, v3)
	end

	return v
end

function Circle.Create(p, cframe: CFrame, radius: number, subdivisions: number, angle: number, connectToStart: boolean?)
	local v = {
		Transform = cframe,
		Radius = radius,
		Subdivisions = subdivisions,
		Angle = angle,
		ConnectToStart = connectToStart,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Circle:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius, data.Subdivisions, data.Angle, data.ConnectToStart)
end

return Circle