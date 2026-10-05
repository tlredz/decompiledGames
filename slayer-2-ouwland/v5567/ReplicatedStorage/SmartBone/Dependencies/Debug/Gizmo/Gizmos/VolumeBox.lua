local terrain = workspace.Terrain
local VolumeBox = {}
VolumeBox.__index = VolumeBox

function VolumeBox.Init(ceive, propertys, request, release, retain, register)
	local self = setmetatable({}, VolumeBox)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	self.Register = register
	return self
end

function VolumeBox:Draw(cFrame: CFrame, size: Vector3)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local request = self.Request("BoxHandleAdornment")
	request.Color3 = self.Propertys.Color3
	request.Transparency = self.Propertys.Transparency
	request.CFrame = cFrame
	request.Size = size
	request.AlwaysOnTop = self.Propertys.AlwaysOnTop
	request.ZIndex = 1
	request.Adornee = terrain
	request.Parent = terrain
	ceive.ActiveInstances += 1
	self.Register(request)
	self.Ceive.ScheduleCleaning()
end

function VolumeBox.Create(p, cframe: CFrame, vector: Vector3)
	local v = {
		Transform = cframe,
		Size = vector,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function VolumeBox:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Size)
end

return VolumeBox