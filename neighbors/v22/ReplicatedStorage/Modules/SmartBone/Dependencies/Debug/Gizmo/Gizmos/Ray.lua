local Ray = {}
Ray.__index = Ray

function Ray.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Ray)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Ray:Draw(vector: Vector3, vector2: Vector3)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	if self.Propertys.AlwaysOnTop then
		ceive.AOTWireframeHandle:AddLine(vector, vector2)
	else
		ceive.WireframeHandle:AddLine(vector, vector2)
	end

	self.Ceive.ActiveRays += 1
	self.Ceive.ScheduleCleaning()
end

function Ray.Create(p, vector: Vector3, vector2: Vector3)
	local v = {
		Origin = vector,
		End = vector2,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Ray:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Origin, data.End)
end

return Ray