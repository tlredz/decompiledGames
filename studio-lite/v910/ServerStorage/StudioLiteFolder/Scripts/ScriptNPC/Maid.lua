local Maid = {}

function Maid.new()
	local v = {
		_tasks = {}
	}
	setmetatable(v, Maid)
	return v
end

function Maid:__index(p2)
	return Maid[p2] or self._tasks[p2]
end

function Maid:__newindex(p2, p3)
	if Maid[p2] then
		error(string.format("Cannot use %q as a Maid key", (tostring(p2))))
	end

	local _tasks = self._tasks
	local _task = _tasks[p2]
	_tasks[p2] = p3

	if _task then
		Maid.cleanupTask(_task)
	end
end

function Maid:give(p2)
	local _tasks = self._tasks
	_tasks[#_tasks + 1] = p2
end

function Maid.cleanupTask(connection)
	local typeName = typeof(connection)

	if typeName == "function" then
		connection()
	elseif typeName == "RBXScriptConnection" then
		connection:Disconnect()
	elseif typeName == "Instance" then
		connection:Destroy()
	elseif connection.Destroy then
		connection:Destroy()
	elseif connection.destroy then
		connection:destroy()
	elseif connection.disconnect then
		connection:disconnect()
	else
		error("Unable to cleanup unknown task")
	end
end

function Maid:clean()
	local _tasks = self._tasks

	for k, _task in pairs(_tasks) do
		if typeof(_task) ~= "RBXScriptConnection" then
			continue
		end

		_tasks[k] = nil
		_task:Disconnect()
	end

	local v, v2 = next(_tasks)

	while v2 ~= nil do
		_tasks[v] = nil
		Maid.cleanupTask(v2)
		v, v2 = next(_tasks)
	end
end

Maid.destroy = Maid.clean
Maid.Destroy = Maid.clean
return Maid