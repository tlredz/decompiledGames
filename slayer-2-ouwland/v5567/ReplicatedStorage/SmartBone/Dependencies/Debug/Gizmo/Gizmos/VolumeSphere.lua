local terrain = workspace.Terrain
local VolumeSphere = {}
VolumeSphere.__index = VolumeSphere

function VolumeSphere.Init(ceive, propertys, request, release, retain, register)
	local self = setmetatable({}, VolumeSphere)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	self.Register = register
	return self
end

function VolumeSphere:Draw(cFrame: CFrame, radius: number)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local request = self.Request("SphereHandleAdornment")
	request.Color3 = self.Propertys.Color3
	request.Transparency = self.Propertys.Transparency
	request.CFrame = cFrame
	request.Radius = radius
	request.AlwaysOnTop = self.Propertys.AlwaysOnTop
	request.ZIndex = 1
	request.Adornee = terrain
	request.Parent = terrain
	ceive.ActiveInstances += 1
	self.Register(request)
	self.Ceive.ScheduleCleaning()
end

function VolumeSphere.Create(p, cframe: CFrame, radius: number)
	local v = {
		Transform = cframe,
		Radius = radius,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function VolumeSphere:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Radius)
end

return VolumeSphere