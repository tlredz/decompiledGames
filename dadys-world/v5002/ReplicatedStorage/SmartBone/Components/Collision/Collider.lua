local createVector = vector.create
local HttpService = game:GetService("HttpService")
local dependencies = script.Parent.Parent.Parent:WaitForChild("Dependencies")
local colliders = script.Parent:WaitForChild("Colliders")
local Box = require(colliders:WaitForChild("Box"))
local Capsule = require(colliders:WaitForChild("Capsule"))
local Cylinder = require(colliders:WaitForChild("Cylinder"))
local Sphere = require(colliders:WaitForChild("Sphere"))
local Utilities = require(script.Parent.Parent.Parent:WaitForChild("Dependencies"):WaitForChild("Utilities"))
local SB_VERBOSE_LOG = Utilities.SB_VERBOSE_LOG
local Gizmo = require(dependencies:WaitForChild("Debug"):WaitForChild("Gizmo"))
local Collider = {}
Collider.__index = Collider

function Collider.new()
	return (setmetatable({
		Type = "Box",
		Scale = createVector(0, 0, 0),
		Offset = createVector(0, 0, 0),
		Rotation = createVector(0, 0, 0),
		Radius = 0,
		PreviousScale = createVector(0, 0, 0),
		PreviousOffset = createVector(0, 0, 0),
		PreviousRotation = createVector(0, 0, 0),
		PreviousObjectPosition = createVector(0, 0, 0),
		PreviousObjectRotation = createVector(0, 0, 0),
		m_Object = nil,
		InNarrowphase = false,
		Transform = CFrame.identity,
		Size = createVector(0, 0, 0),
		GUID = HttpService:GenerateGUID(false)
	}, Collider))
end

function Collider:SetObject(m_Object)
	self.m_Object = m_Object
	self:UpdateTransform()
end

function Collider:UpdateTransform()
	local m_Object = self.m_Object
	local cFrame = m_Object.CFrame
	local size = m_Object.Size
	local scale = self.Scale
	local offset = self.Offset
	local rotation = self.Rotation
	local v = size * offset
	local size2 = size * scale
	local cframe = CFrame.Angles(rotation.X * 0.017453, rotation.Y * 0.017453, rotation.Z * 0.017453)
	self.Transform = cFrame * CFrame.new(v) * cframe
	self.Size = size2
	self.Radius = math.sqrt((math.max(size2.X, size2.Y, size2.Z) * 0.5) ^ 2 * 2)
end

function Collider:GetClosestPoint(p, p2)
	if self.m_Object == nil then
		return
	end

	self.InNarrowphase = false

	if (p - self.Transform.Position).Magnitude - p2 > self.Radius then
		return
	end

	self.InNarrowphase = true
	local type = self.Type
	local v, v2, v3

	if type == "Box" then
		v, v2, v3 = Box(self.Transform, self.Size, p, p2)
	end

	if type == "Capsule" then
		v, v2, v3 = Capsule(self.Transform, self.Size, p, p2)
	end

	if type == "Sphere" then
		v, v2, v3 = Sphere(self.Transform, self.Size, p, p2)
	end

	if type == "Cylinder" then
		v, v2, v3 = Cylinder(self.Transform, self.Size, p, p2)
	end

	return v, v2, v3
end

function Collider:Step()
	self:UpdateTransform()
end

function Collider.DrawDebug(data, p, p2, p3, p4, p5)
	local color = Color3.new(0.509803, 0.933333, 0.42745)
	local color2 = Color3.new(0.90196, 0.784313, 0.513725)
	local color3 = Color3.new(1, 0, 1)
	local color4 = Color3.new(0, 1, 1)
	local color5 = Color3.new(1, 0.3, 0.3)
	local type = data.Type
	local transform = data.Transform
	local size = data.Size

	if not p.m_Awake and p4 then
		color = color3
	end

	if data.InNarrowphase == false and p5 then
		color2 = color4
	end

	if p3 then
		Gizmo.SetStyle(color5, 0, false)
		Gizmo.Sphere:Draw(transform, data.Radius, 25, 360)
	end

	if type == "Box" then
		Gizmo.SetStyle(color, 0, false)
		Gizmo.Box:Draw(transform, size)

		if p2 then
			Gizmo.SetStyle(color2, 0.75, false)
			Gizmo.VolumeBox:Draw(transform, size)
			Gizmo.PushProperty("Transparency", 0)
		end
	elseif type == "Capsule" then
		local v = (size.Y < size.Z and size.Y or size.Z) * 0.5
		local X = size.X
		local v2 = transform * CFrame.Angles(1.5707963267948966, -1.5707963267948966, 0)
		Gizmo.SetStyle(color, 0, false)
		Gizmo.Capsule:Draw(v2, v, X, 15)

		if p2 then
			local v3 = v2.Position + v2.UpVector * (X * 0.5)
			local v4 = v2.Position - v2.UpVector * (X * 0.5)
			Gizmo.SetStyle(color2, 0.75, false)
			Gizmo.VolumeCylinder:Draw(transform, v, X)
			Gizmo.VolumeSphere:Draw(CFrame.new(v3), v)
			Gizmo.VolumeSphere:Draw(CFrame.new(v4), v)
			Gizmo.PushProperty("Transparency", 0)
		end
	elseif type == "Sphere" then
		local v = math.min(size.X, size.Y, size.Z) * 0.5
		Gizmo.SetStyle(color, 0, false)
		Gizmo.Sphere:Draw(transform, v, 15, 360)

		if p2 then
			Gizmo.SetStyle(color2, 0.75, false)
			Gizmo.VolumeSphere:Draw(transform, v)
			Gizmo.PushProperty("Transparency", 0)
		end
	else
		if type ~= "Cylinder" then
			return
		end

		local v = (size.Y < size.Z and size.Y or size.Z) * 0.5
		Gizmo.SetStyle(color, 0, false)
		Gizmo.Cylinder:Draw(transform * CFrame.Angles(0, 0, 1.5707963267948966), v, size.X, 15)

		if p2 then
			Gizmo.SetStyle(color2, 0.75, false)
			Gizmo.VolumeCylinder:Draw(transform * CFrame.Angles(0, -1.5707963267948966, 0), v, size.X, 0, 360)
			Gizmo.PushProperty("Transparency", 0)
		end
	end
end

function Collider.Destroy(p)
	SB_VERBOSE_LOG((`Collider destroying, object: {p.m_Object}`))
	setmetatable(p, nil)
end

return Collider