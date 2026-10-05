local class = {}
class.__index = class

function class.__tostring(p)
	return (`<Bind {p.Name}>`)
end

function class:Call(...)
	return self._fn(...)
end

function class:SetFunction(fn)
	self._fn = fn
end

function class:Destroy()
	local index = table.find(self._binder.Binds, self)

	if index then
		table.remove(self._binder.Binds, index)
		self._binder:Reorder()
	end

	self._fn = nil
	self._priority = nil
	self._binder = nil
end

local Binder = {
	CANCEL = newproxy(true)
}
Binder.__index = Binder

local function wrap(...)
	return { ... }
end

local function CANCEL()
	return Binder.CANCEL
end

function Binder.Call(p, ...)
	if not next(p.Binds) then
		return ...
	end

	local v = wrap(...)

	for _, bind in p.Binds do
		local v2 = { pcall(bind.Call, bind, table.unpack(v)) }

		if v2[1] then
			if v2[2] == Binder.CANCEL then
				return Binder.CANCEL
			else
				v = { table.unpack(v2, 2) }
			end
		else
			warn((`Bind {bind} failed on call, ignoring it\n{table.unpack(v2, 2)}`))
		end
	end

	return table.unpack(v)
end

function Binder:Reorder()
	table.sort(self.Binds, function(a, b)
		local _priority = a._priority
		local _priority2 = b._priority
		return not not _priority and (not _priority2 or _priority < _priority2)
	end)
end

function Binder:Bind(name: string, fn, priority: number?)
	local object2 = setmetatable({
		Name = name,
		_fn = fn,
		_priority = priority,
		_binder = self
	}, class)
	table.insert(self.Binds, object2)
	self:Reorder()
	return object2
end

function Binder:Destroy()
	local _, v = next(self.Binds)

	while v do
		v:Destroy()
		local v2
		v2, v = next(self.Binds)
	end

	self.Binds = nil
end

function Binder.new()
	return (setmetatable({
		Binds = {}
	}, Binder))
end

return Binder