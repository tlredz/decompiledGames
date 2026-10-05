local terrain = workspace.Terrain
local VolumeCylinder = {}
VolumeCylinder.__index = VolumeCylinder

function VolumeCylinder.Init(ceive, propertys, request, release, retain, register)
	local self = setmetatable({}, VolumeCylinder)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	self.Register = register
	return self
end

function VolumeCylinder:Draw(cFrame: CFrame, radius: number, height: number, value: number?, value2: number?)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local request = self.Request("CylinderHandleAdornment")
	request.Color3 = self.Propertys.Color3
	request.Transparency = self.Propertys.Transparency
	request.CFrame = cFrame
	request.Height = height
	request.Radius = radius
	request.InnerRadius = value or 0
	request.Angle = value2 or 360
	request.AlwaysOnTop = self.Propertys.AlwaysOnTop
	request.ZIndex = 1
	request.Adornee = terrain
	request.Parent = terrain
	ceive.ActiveInstances += 1
	self.Register(request)
	self.Ceive.ScheduleCleaning()
end

function VolumeCylinder.Create(p, cframe: CFrame, radius: number, length: number, value: number?, value2: number?)
	local v = {
		Transform = cframe,
		Radius = radius,
		Length = length,
		InnerRadius = value or 0,
		Angle = value2 or 360,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function VolumeCylinder:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius, data.Length, data.InnerRadius, data.Angle)
end

return VolumeCylinder