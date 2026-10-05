local NexusInstance = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local v = {
	ClassName = "BaseScreenGui"
}
v.__index = v

function v:__new(surfaceGui)
	self.Container = surfaceGui
	local nonReplicatedProperties = {}
	self.NonReplicatedProperties = nonReplicatedProperties
	local metatable = getmetatable(self)
	local __index = metatable.__index

	function metatable.__index(p, p2)
		local v3 = __index(p, p2)

		if v3 == nil and not nonReplicatedProperties[p2] then
			return surfaceGui[p2]
		end

		return v3
	end

	self:OnAnyPropertyChanged(function(p, p2)
		if nonReplicatedProperties[p] then
			return
		end

		surfaceGui[p] = p2
	end)
	self:DisableChangeReplication("RotationOffset")
	self.RotationOffset = CFrame.identity
	self:DisableChangeReplication("Depth")
	self.Depth = 5
	self:DisableChangeReplication("FieldOfView")
	self.FieldOfView = 0.8726646259971648

	if not surfaceGui:IsA("SurfaceGui") then
		self:DisableChangeReplication("CanvasSize")
	end

	self.CanvasSize = Vector2.new(1000, 1000)
	self:DisableChangeReplication("Easing")
	self.Easing = 0
	self:DisableChangeReplication("PointingEnabled")
	self.PointingEnabled = true
end

function v:IsA(p: string)
	warn("BaseScreenGui::IsA is deprecated.")
	return p == "NexusObject" or p == "NexusInstance" or p == "BaseScreenGui"
end

function v:DisableChangeReplication(p2: string)
	self.NonReplicatedProperties[p2] = true
end

function v.GetContainer(p)
	return p.Container
end

function v:Destroy()
	self.Container:Destroy()
end

return (NexusInstance.ToInstance(v))