function doTask(connection)
	local success, result = pcall(function()
		if type(connection) == "function" then
			connection()
		elseif typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeof(connection) == "Instance" then
			connection:Destroy()
		elseif typeof(connection) == "thread" then
			pcall(task.cancel, connection)
		elseif typeof(connection) == "table" then
			if connection.Destroy then
				connection.Destroy(connection)
			elseif connection.destroy then
				connection.destroy(connection)
			end
		end
	end)

	if not success then
		warn(debug.traceback(result), 2)
	end
end

local v = {
	ClassName = "Maid"
}

function v.new()
	return (setmetatable({
		_tasks = {}
	}, v))
end

function v.isMaid(instance)
	return typeof(instance) == "table" and instance.ClassName == "Maid"
end

function v:__index(p2)
	if v[p2] then
		return v[p2]
	end

	return self._tasks[p2]
end

function v:__newindex(p2, p3)
	if v[p2] ~= nil then
		error(("'%s' is reserved"):format((tostring(p2))), 2)
	end

	if p2 == "_hack" then
		rawset(self, "_hack", p3)
	end

	local _tasks = self._tasks
	local _task = _tasks[p2]

	if _task == p3 then
		return
	end

	_tasks[p2] = p3

	if _task then
		doTask(_task)
	end
end

function v:GiveTask(p2)
	if not p2 or type(p2) == "table" and not (p2.Destroy or p2.destroy) then
		return p2
	end

	local v2 = #self._tasks + 1
	self[v2] = p2
	return p2, v2
end

function v:GivePromise(object)
	if not object:IsPending() then
		return object
	end

	local resolved = object.resolved(object)
	local _, v2 = self:GiveTask(resolved)
	resolved:Finally(function()
		self[v2] = nil
	end)
	return resolved
end

function v:DoCleaning()
	local _tasks = self._tasks

	for k, _task in pairs(_tasks) do
		if typeof(_task) == "RBXScriptConnection" then
			_tasks[k] = nil
			_task:Disconnect()
		elseif typeof(_task) == "thread" then
			_tasks[k] = nil
			pcall(task.cancel, _task)
		end
	end

	local v2, v3 = next(_tasks)

	while v3 ~= nil do
		_tasks[v2] = nil
		doTask(v3)
		v2, v3 = next(_tasks)
	end
end

v.Destroy = v.DoCleaning
return {
	new = v.new,
	isMaid = v.isMaid
}