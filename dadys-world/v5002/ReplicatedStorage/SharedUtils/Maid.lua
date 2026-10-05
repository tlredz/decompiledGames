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
		elseif _task.Destroy then
			_task:Destroy()
		end
	end
end

function Maid:GiveTask(p2)
	assert(p2, "Task cannot be false or nil")
	local v = #self._tasks + 1
	self[v] = p2

	if type(p2) == "table" and not p2.Destroy then
		warn([[
[Maid.GiveTask] - Gave table task without .Destroy

]] .. debug.traceback())
	end

	return v
end

function Maid:DoCleaning()
	local _tasks = self._tasks

	for k, _task in pairs(_tasks) do
		if typeof(_task) ~= "RBXScriptConnection" then
			continue
		end

		_tasks[k] = nil
		_task:Disconnect()
	end

	local v, connection = next(_tasks)

	while connection ~= nil do
		_tasks[v] = nil

		if type(connection) == "function" then
			connection()
		elseif typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif connection.Destroy then
			connection:Destroy()
		end

		v, connection = next(_tasks)
	end
end

Maid.Destroy = Maid.DoCleaning
return Maid