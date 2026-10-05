local Freeze = require(script.Parent.Parent.Parent.Freeze)
local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Types)
local Utils = require(script.Parent.Utils)
local Signals = {}
Signals.__index = Signals

function Signals.new()
	return (setmetatable({
		_containers = {}
	}, Signals))
end

function Signals:_getContainer(p2: string)
	assert(self._containers, "You're trying to use a Replion that has been destroyed!")
	local _container = self._containers[p2]

	if not _container then
		_container = {}
		self._containers[p2] = _container
	end

	return _container
end

function Signals:Connect(p: string, p2, callback)
	return assert(self:Get(p, p2), "Signal does not exist!"):Connect(callback)
end

function Signals:Get(p: string, p2, flag: boolean?)
	local _getContainer = self:_getContainer(p)
	local __signal = nil

	for _, v in Utils.getPathTable(p2) do
		local v2 = _getContainer[v]

		if not v2 then
			v2 = {}
			_getContainer[v] = v2
		end

		__signal = v2.__signal
		_getContainer = v2
	end

	if not __signal and (flag == nil or flag) then
		__signal = Signal.new()
		_getContainer.__signal = __signal
	end

	return __signal
end

function Signals:FireEvent(p: string, p2, ...)
	local v = self:Get(p, p2)

	if v then
		v:Fire(...)
	end
end

function Signals:FireChange(p, p2, p3)
	local pathTable = Utils.getPathTable(p)

	for i = #pathTable, 1, -1 do
		local slice = Freeze.List.slice(pathTable, 1, i)
		local onChange = self:Get("onChange", slice, false)
		local v = Freeze.Dictionary.getIn(p2, slice)
		local v2 = Freeze.Dictionary.getIn(p3, slice)

		if onChange then
			onChange:Fire(v, v2)
		end

		if not (i > 1) then
			continue
		end

		local onDescendantChange = self:Get("onDescendantChange", Freeze.List.slice(pathTable, 1, i - 1), false)

		if onDescendantChange then
			onDescendantChange:Fire(slice, v, v2)
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