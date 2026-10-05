local Collider = require(script.Parent:WaitForChild("Collider"))
local Utilities = require(script.Parent.Parent.Parent:WaitForChild("Dependencies"):WaitForChild("Utilities"))
local SB_VERBOSE_LOG = Utilities.SB_VERBOSE_LOG
local ColliderObject = {}
ColliderObject.__index = ColliderObject

function ColliderObject.new(p, instance)
	local object = setmetatable({
		m_Object = instance,
		m_Awake = true,
		m_LastSleepCycle = 0,
		Destroyed = false,
		Colliders = {}
	}, ColliderObject)
	object:m_LoadColliderTable(p)
	object.DestroyConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if instance.Parent == nil then
			object.Destroyed = true
		end
	end)
	return object
end

function ColliderObject:m_LoadCollider(data)
	local vector = Vector3.new(data.ScaleX, data.ScaleY, data.ScaleZ)
	local vector2 = Vector3.new(data.OffsetX, data.OffsetY, data.OffsetZ)
	local vector3 = Vector3.new(data.RotationX, data.RotationY, data.RotationZ)
	local v = Collider.new()
	v.Scale = vector
	v.Offset = vector2
	v.Rotation = vector3
	v.Type = data.Type
	v:SetObject(self.m_Object)
	table.insert(self.Colliders, v)
end

function ColliderObject:m_LoadColliderTable(items)
	for _, item in items do
		self:m_LoadCollider(item)
	end
end

function ColliderObject.GetObject(p)
	return p.m_Object
end

function ColliderObject:GetCollisions(p, p2)
	if not (self.m_Object and #self.Colliders ~= 0) then
		return {}
	end

	if os.clock() - self.m_LastSleepCycle >= 0.2 then
		self.m_LastSleepCycle = os.clock()

		if self.m_Object:IsDescendantOf(workspace) then
			self.m_Awake = true
		else
			self.m_Awake = false
		end
	end

	if not self.m_Awake then
		return {}
	end

	local result = {}

	for _, collider in self.Colliders do
		local closestPoint, closestPoint2, normal = collider:GetClosestPoint(p, p2)

		if closestPoint then
			table.insert(result, {
				ClosestPoint = closestPoint2,
				Normal = normal
			})
		end
	end

	return result
end

function ColliderObject:Step()
	for _, collider in self.Colliders do
		collider:Step()
	end
end

function ColliderObject:DrawDebug(p2, p3, p4, p5)
	for _, collider in self.Colliders do
		collider:DrawDebug(self, p2, p3, p4, p5)
		collider.InNarrowphase = false
	end
end

function ColliderObject:Destroy()
	task.synchronize()
	SB_VERBOSE_LOG((`Collider object destroying, object: {self.m_Object}`))
	self.DestroyConnection:Disconnect()

	if #self.Colliders ~= 0 then
		for _, collider in self.Colliders do
			collider:Destroy()
		end
	end

	setmetatable(self, nil)
	task.desynchronize()
end

return ColliderObject