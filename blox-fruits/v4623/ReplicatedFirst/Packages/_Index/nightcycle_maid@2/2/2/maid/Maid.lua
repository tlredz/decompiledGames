local MaidTaskUtils = require(script.Parent:WaitForChild("MaidTaskUtils"))
local Maid = {
	ClassName = "Maid"
}

function Maid.new()
	return (setmetatable({
		IsAlive = true,
		_tasks = {}
	}, Maid))
end

function Maid:__index(p2)
	if p2 == "IsAlive" then
		return (rawget(self, "IsAlive"))
	end

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
	if not rawget(self, "IsAlive") then
		error("Maid is dead and cannot accept new tasks", 2)
	end

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

function Maid:Destroy()
	if not rawget(self, "IsAlive") then
		error("Maid is already dead", 2)
	end

	rawset(self, "IsAlive", false)
	self:DoCleaning()
end

return Maid