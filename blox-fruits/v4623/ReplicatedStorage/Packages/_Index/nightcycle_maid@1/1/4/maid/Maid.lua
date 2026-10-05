local Maid = {
	ClassName = "Maid"
}
local MaidTaskUtils = require(script.Parent.MaidTaskUtils)

function Maid.new()
	return (setmetatable({
		_tasks = {}
	}, Maid))
end

function Maid.bind(instance)
	local maid = Maid.new()
	maid:GiveTask(instance.Destroying:Connect(function()
		maid:Destroy()
	end))
	return maid
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
		MaidTaskUtils.doTask(_task, p2)
	end
end

function Maid:_GiveTask(p2)
	if not p2 then
		error("Task cannot be false or nil", 2)
	end

	local v = #self._tasks + 1
	self[v] = p2

	if type(p2) == "table" and not p2.Destroy then
		warn([[
[Maid.GiveTask] - Gave table task without .Destroy

]] .. debug.traceback())
	end

	return v
end

function Maid:GiveTask(p)
	self:_GiveTask(p)
	return p
end

function Maid:GivePromise(object2)
	if not object2:IsPending() then
		return object2
	end

	local resolved = object2.resolved(object2)
	local _GiveTask = self:_GiveTask(resolved)
	resolved:Finally(function()
		self[_GiveTask] = nil
	end)
	return resolved
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

	local v, v2 = next(_tasks)

	while v2 ~= nil do
		if v ~= nil then
			_tasks[v] = nil
		end

		MaidTaskUtils.doTask(v2, v)
		v, v2 = next(_tasks)
	end

	return nil
end

Maid.Destroy = Maid.DoCleaning
return Maid