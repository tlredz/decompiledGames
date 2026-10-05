local VolumeArrow = {}
VolumeArrow.__index = VolumeArrow

function VolumeArrow.Init(ceive, propertys, request, release, retain, register)
	local self = setmetatable({}, VolumeArrow)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	self.Register = register
	return self
end

function VolumeArrow:Draw(vector: Vector3, vector2: Vector3, p2: number, p3: number, p4: number, flag: boolean?)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local cframe = CFrame.lookAt(vector2 - (vector2 - vector).Unit * (p4 * 0.5), vector2)

	if flag == true then
		local position = cframe.Position
		local magnitude = (position - vector).Magnitude
		local cframe2 = CFrame.lookAt((vector + position) * 0.5, vector2)
		ceive.VolumeCylinder:Draw(cframe2, p2, magnitude)
	else
		ceive.Ray:Draw(vector, vector2)
	end

	ceive.VolumeCone:Draw(cframe, p3, p4)
	self.Ceive.ScheduleCleaning()
end

function VolumeArrow.Create(p, vector: Vector3, vector2: Vector3, cylinderRadius: number, coneRadius: number, length: number, useCylinder: boolean?)
	local v = {
		Origin = vector,
		End = vector2,
		CylinderRadius = cylinderRadius,
		ConeRadius = coneRadius,
		Length = length,
		UseCylinder = useCylinder,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function VolumeArrow:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Origin, data.End, data.Radius, data.Length, data.UseCylinder)
end

return VolumeArrow