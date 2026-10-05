local Maid = {
	ClassName = "Maid"
}

function Maid.new()
	return (setmetatable({
		_tasks = {}
	}, Maid))
end

function Maid:__index(p2)
	if Maid[p2] then
		return Maid[p2]
	end

	return self._tasks[p2]
end

function Maid:__newindex(p2, p3)
	if Maid[p2] ~= nil then
		error(("'%s' is reserved"):format((tostring(p2))), 2)
	end

	local _tasks = self._tasks
	local _task = _tasks[p2]
	_tasks[p2] = p3

	if _task then
		if type(_task) == "function" then
			_task()
		elseif typeof(_task) == "RBXScriptConnection" then
			_task:Disconnect()
		elseif typeof(_task) == "table" then
			if _task.Destroy and typeof(_task.Destroy) == "function" then
				_task:Destroy()
			end

			if _task.Disconnect and typeof(_task.Disconnect) == "function" then
				_task:Disconnect()
			end
		elseif typeof(_task) == "Instance" then
			_task:Destroy()
		elseif typeof(_task) == "thread" then
			task.cancel(_task)
		end
	end
end

function Maid:GiveTask(p2)
	assert(p2, "Task cannot be false or nil")
	local v = #self._tasks + 1
	self[v] = p2
	return v
end

function Maid:GiveTasks(items)
	for _, item in pairs(items) do
		self:GiveTask(item)
	end
end

function Maid:GivePromise(object)
	if not object:IsPending() then
		return object
	end

	local resolved = object.resolved(object)
	local v = self:GiveTask(resolved)
	resolved:Finally(function()
		self[v] = nil
	end)
	return resolved
end

function Maid:DoCleaning()
	self:Destroy()
end

function Maid:Destroy()
	local _tasks = self._tasks

	for k, _task in pairs(_tasks) do
		if typeof(_task) ~= "RBXScriptConnection" then
			continue
		end

		_tasks[k] = nil
		_task:Disconnect()
	end

	while next(_tasks) do
		local v, connection = next(_tasks)
		_tasks[v] = nil

		if type(connection) == "function" then
			connection()
		elseif typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeof(connection) == "table" then
			if connection.Destroy and typeof(connection.Destroy) == "function" then
				connection:Destroy()
			end

			if connection.Disconnect and typeof(connection.Disconnect) == "function" then
				connection:Disconnect()
			end
		elseif typeof(connection) == "Instance" then
			connection:Destroy()
		elseif typeof(connection) == "thread" then
			pcall(task.cancel, connection)
		end

		local _, _ = next(_tasks)
	end
end

return Maid