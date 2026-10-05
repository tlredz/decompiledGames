local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Types)
local Utils = require(script.Parent.Utils)

local function getIn(p, items)
	for _, item in items do
		if not p then
			return nil
		end

		p = p[item]
	end

	return p
end

local Signals = {}
Signals.__index = Signals

function Signals.new()
	return (setmetatable({
		_containers = {}
	}, Signals))
end

function Signals:_getContainer(p2, p3)
	assert(self._containers, "You're trying to use a Replion that has been destroyed!")

	if p3 and not self._containers[p2] then
		self._containers[p2] = {}
	end

	return self._containers[p2]
end

function Signals:Connect(p, p2, p3)
	if not _G.__DEV__ or _G.__IGNORE_INSTANCES_WARNING__ then
		return assert(self:Get(p, p2), "Signal does not exist!"):Connect(p3)
	end

	local flag = false

	for _, v2 in Utils.getPathTable(p2) do
		if typeof(v2) ~= "Instance" then
			continue
		end

		flag = true
		break
	end

	if flag then
		local v2, v3 = debug.info(3, "sl")
		task.spawn(
			error,
			`[Memory Leak Warning] Instance used as a Connection index at {v2}:{v3}. ` .. "Using Instances will cause memory leaks as Replion cannot automatically dispose of such connections. Consider using a string or number as your index to prevent this issue."
		)
	end

	return assert(self:Get(p, p2), "Signal does not exist!"):Connect(p3)
end

function Signals:Get(p, p2, p3)
	local v = p3 == nil or p3
	local _getContainer = self:_getContainer(p, v)

	if not _getContainer then
		return
	end

	for _, v2 in Utils.getPathTable(p2) do
		if not _getContainer[v2] then
			if not v then
				return nil
			end

			_getContainer[v2] = {}
		end

		_getContainer = _getContainer[v2]

		if not _getContainer then
			return nil
		end
	end

	if v and not _getContainer.__signal then
		_getContainer.__signal = Signal.new()
	end

	return _getContainer.__signal
end

function Signals:FireEvent(p, p2, ...)
	local v = self:Get(p, p2, false)

	if v then
		v:Fire(...)
	end
end

function Signals:FireChange(p2, p3, p4)
	if not (self._containers and next(self._containers)) then
		return
	end

	local pathTable = Utils.getPathTable(p2)
	local count = #pathTable
	local v = self._containers.onDescendantChange ~= nil

	for i = count, 1, -1 do
		if i < count then
			pathTable[i + 1] = nil
		end

		local onChange = self._containers.onChange

		for _, v3 in pathTable do
			if onChange then
				onChange = onChange[v3]
			else
				onChange = nil
				break
			end
		end

		local __signal

		if onChange then
			__signal = onChange.__signal
		end

		local __signal2

		if v and i > 1 then
			local v3 = pathTable[i]
			pathTable[i] = nil
			local onDescendantChange = self._containers.onDescendantChange

			for _, v5 in pathTable do
				if onDescendantChange then
					onDescendantChange = onDescendantChange[v5]
				else
					onDescendantChange = nil
					break
				end
			end

			if onDescendantChange then
				__signal2 = onDescendantChange.__signal
			end

			pathTable[i] = v3
		end

		if not (__signal or __signal2) then
			continue
		end

		local v3 = p3

		for _, v5 in pathTable do
			if v3 then
				v3 = v3[v5]
			else
				v3 = nil
				break
			end
		end

		local v5 = p4

		for _, v7 in pathTable do
			if v5 then
				v5 = v5[v7]
			else
				v5 = nil
				break
			end
		end

		if __signal then
			__signal:Fire(v3, v5)
		end

		if __signal2 then
			__signal2:Fire(table.clone(pathTable), v3, v5)
		end
	end
end

function Signals:Destroy()
	assert(self._containers, "This Replion has already been destroyed!")
	local destroySignals

	destroySignals = function(p2)
		if p2.__signal then
			p2.__signal:Destroy()
			p2.__signal = nil
		end

		for _, v in p2 do
			destroySignals(v)
		end
	end

	for _, _container in self._containers do
		if _container.__signal then
			_container.__signal:Destroy()
			_container.__signal = nil
		end

		for _, v in _container do
			destroySignals(v)
		end
	end

	self._containers = nil
end

return Signals