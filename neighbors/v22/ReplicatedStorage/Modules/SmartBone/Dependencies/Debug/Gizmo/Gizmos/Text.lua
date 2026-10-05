local createVector = vector.create
local currentCamera = workspace.CurrentCamera
local Text = {}
Text.__index = Text

function Text.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Text)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Text:Draw(vector2: Vector3, p2: string, p3: number?)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	if self.Propertys.AlwaysOnTop then
		local magnitude = (vector2 - currentCamera.CFrame.Position).Magnitude
		local v = ceive.PopProperty("Color3")
		ceive.PushProperty("Color3", Color3.new())
		local v2 = -(createVector(1, 1, 0)).Unit
		ceive.AOTWireframeHandle:AddText(vector2 + v2 * (magnitude * 0.00175), p2, p3)
		ceive.PushProperty("Color3", v)
		ceive.AOTWireframeHandle:AddText(vector2, p2, p3)
	else
		local magnitude = (vector2 - currentCamera.CFrame.Position).Magnitude
		local v = ceive.PopProperty("Color3")
		ceive.PushProperty("Color3", Color3.new())
		local v2 = -(createVector(1, 1, 0)).Unit
		ceive.WireframeHandle:AddText(vector2 + v2 * (magnitude * 0.00175), p2, p3)
		ceive.PushProperty("Color3", v)
		ceive.WireframeHandle:AddText(vector2, p2, p3)
	end

	self.Ceive.ScheduleCleaning()
end

function Text.Create(p, vector2: Vector3, text: string, size: number?)
	local v = {
		Origin = vector2,
		Text = text,
		Size = size,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Text:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Origin, data.Text, data.Size)
end

return Text