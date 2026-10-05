local Maid = {
	ClassName = "Maid"
}

function Maid.new()
	return (setmetatable({
		_tasks = {}
	}, Maid))
end

function Maid.isMaid(instance)
	return type(instance) == "table" and instance.ClassName == "Maid"
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

	if _task == p3 then
		return
	end

	_tasks[p2] = p3

	if _task then
		if type(_task) == "function" then
			_task()
		elseif typeof(_task) == "RBXScriptConnection" then
			_task:Disconnect()
		elseif _task.Destroy then
			_task:Destroy()
		elseif _task.destroy then
			_task:destroy()
		end
	end
end

function Maid:giveTask(p2)
	if not p2 then
		error("Task cannot be false or nil", 2)
	end

	local v = #self._tasks + 1
	self[v] = p2

	if type(p2) == "table" and not (p2.Destroy or p2.destroy) then
		warn([[
[Maid.GiveTask] - Gave table task without .Destroy

]] .. debug.traceback())
	end

	return v
end

function Maid:give(p)
	if type(p) ~= "table" or not p.isAPromise then
		return p, (self:giveTask(p))
	end

	local v, v2 = self:givePromise(p)
	_ = v
	return p, v2
end

function Maid:doCleaning()
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
		elseif connection.destroy then
			connection:destroy()
		end

		v, connection = next(_tasks)
	end
end

Maid.destroy = Maid.doCleaning
Maid.clean = Maid.doCleaning
return Maid