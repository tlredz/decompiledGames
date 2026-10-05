local terrain = workspace.Terrain
local VolumeCone = {}
VolumeCone.__index = VolumeCone

function VolumeCone.Init(ceive, propertys, request, release, retain, register)
	local self = setmetatable({}, VolumeCone)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	self.Register = register
	return self
end

function VolumeCone:Draw(cFrame: CFrame, radius: number, height: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local request = self.Request("ConeHandleAdornment")
	request.Color3 = self.Propertys.Color3
	request.Transparency = self.Propertys.Transparency
	request.CFrame = cFrame
	request.AlwaysOnTop = self.Propertys.AlwaysOnTop
	request.ZIndex = 1
	request.Height = height
	request.Radius = radius
	request.Adornee = terrain
	request.Parent = terrain
	ceive.ActiveInstances += 1
	self.Register(request)
	self.Ceive.ScheduleCleaning()
end

function VolumeCone.Create(p, cframe: CFrame, radius: number, length: number)
	local v = {
		Transform = cframe,
		Radius = radius,
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

function VolumeCone:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius, data.Length)
end

return VolumeCone