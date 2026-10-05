local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(items)
	local bindableEvent = Instance.new("BindableEvent")
	local self = setmetatable({
		Containers = {},
		Tools = {},
		Events = {},
		ToolsChangedEvent = bindableEvent,
		ToolsChanged = bindableEvent.Event
	}, Inventory)

	if items then
		for _, item in items do
			self:AddContainer(item)
		end
	end

	return self
end

function Inventory:AddTool(backpackItem)
	if not backpackItem:IsA("BackpackItem") then
		return
	end

	for _, tool in self.Tools do
		if backpackItem == tool then
			return
		end
	end

	table.insert(self.Tools, backpackItem)
	self.ToolsChangedEvent:Fire()
end

function Inventory:RemoveTool(backpackItem)
	if not backpackItem:IsA("BackpackItem") then
		return
	end

	for _, container in self.Containers do
		if backpackItem.Parent == container then
			return
		end
	end

	local v = nil

	for k, tool in self.Tools do
		if backpackItem ~= tool then
			continue
		end

		v = k
		break
	end

	if not v then
		return
	end

	table.remove(self.Tools, v)
	self.ToolsChangedEvent:Fire()
end

function Inventory:AddContainer(instance)
	table.insert(self.Containers, instance)

	for _, child in instance:GetChildren() do
		self:AddTool(child)
	end

	table.insert(self.Events, instance.ChildAdded:Connect(function(child)
		self:AddTool(child)
	end))
	table.insert(self.Events, instance.ChildRemoved:Connect(function(child)
		self:RemoveTool(child)
	end))
end

function Inventory:Destroy()
	for _, event in self.Events do
		event:Disconnect()
	end

	self.Events = {}
	self.Tools = {}
	self.Containers = {}
	self.ToolsChangedEvent:Destroy()
end

return Inventory