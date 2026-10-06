local ModuleScriptMaid = {}

function ModuleScriptMaid.new()
	local v = {
		_tasks = {}
	}
	setmetatable(v, ModuleScriptMaid)
	return v
end

function ModuleScriptMaid:__index(p2)
	return ModuleScriptMaid[p2] or self._tasks[p2]
end

function ModuleScriptMaid:__newindex(p2, p3)
	if ModuleScriptMaid[p2] then
		error(string.format("Cannot use %q as a Maid key", (tostring(p2))))
	end

	local _tasks = self._tasks
	local _task = _tasks[p2]
	_tasks[p2] = p3

	if _task then
		ModuleScriptMaid.cleanupTask(_task)
	end
end

function ModuleScriptMaid:give(p2)
	local _tasks = self._tasks
	_tasks[#_tasks + 1] = p2
end

function ModuleScriptMaid.cleanupTask(connection)
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

function ModuleScriptMaid:clean()
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
		ModuleScriptMaid.cleanupTask(v2)
		v, v2 = next(_tasks)
	end
end

ModuleScriptMaid.destroy = ModuleScriptMaid.clean
ModuleScriptMaid.Destroy = ModuleScriptMaid.clean
return ModuleScriptMaid