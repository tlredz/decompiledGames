local TaskManager = {}
TaskManager.__index = TaskManager

function TaskManager.new()
	local self = setmetatable({}, TaskManager)
	self.Tasks = {}
	self.NamedTasks = {}
	self.Destroyed = false
	return self
end

function TaskManager:_Clean(connection)
	if not connection then
		return
	end

	local typeName = typeof and typeof(connection) or type(connection)

	if typeName == "RBXScriptConnection" then
		pcall(function()
			connection:Disconnect()
		end)
	elseif typeName == "Instance" then
		if connection.Destroy then
			pcall(function()
				connection:Destroy()
			end)
		end
	elseif type(connection) == "function" then
		pcall(connection)
	elseif type(connection) == "table" then
		if type(connection.Destroy) == "function" then
			pcall(function()
				connection:Destroy()
			end)
		elseif type(connection.Disconnect) == "function" then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end
end

function TaskManager:GiveTask(p)
	if not p then
		return
	end

	if self.Destroyed then
		self:_Clean(p)
		return p
	end

	table.insert(self.Tasks, p)
	return p
end

function TaskManager:GiveNamedTask(p, p2)
	if not (p2 and p) then
		return
	end

	if self.NamedTasks[p] then
		self:_Clean(self.NamedTasks[p])
	end

	if self.Destroyed then
		self:_Clean(p2)
		return p2
	end

	self.NamedTasks[p] = p2
	return p2
end

function TaskManager:DoTask(p)
	for i, task in ipairs(self.Tasks) do
		if task ~= p then
			continue
		end

		table.remove(self.Tasks, i)
		self:_Clean(task)
		return true
	end

	for k, namedTask in pairs(self.NamedTasks) do
		if namedTask ~= p then
			continue
		end

		self.NamedTasks[k] = nil
		self:_Clean(namedTask)
		return true
	end

	return false
end

function TaskManager:Remove(p)
	local namedTask = self.NamedTasks[p]

	if not namedTask then
		return false
	end

	self.NamedTasks[p] = nil
	self:_Clean(namedTask)
	return true
end

function TaskManager:LinkToInstance(instance2)
	if not instance2 or typeof(instance2) ~= "Instance" then
		return
	end

	if instance2.Destroying then
		self:GiveNamedTask("LinkToInstance", (instance2.Destroying:Connect(function()
			self:Destroy()
		end)))
		return instance2
	end

	self:GiveNamedTask("LinkToInstance", (instance2.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			self:Destroy()
		end
	end)))
	return instance2
end

function TaskManager:DoCleaning()
	for i = #self.Tasks, 1, -1 do
		local task = self.Tasks[i]
		self.Tasks[i] = nil
		self:_Clean(task)
	end

	for k, namedTask in pairs(self.NamedTasks) do
		self.NamedTasks[k] = nil
		self:_Clean(namedTask)
	end
end

function TaskManager:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self:DoCleaning()
end

return TaskManager