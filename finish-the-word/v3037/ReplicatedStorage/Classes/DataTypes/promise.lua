local status2 = ({
	new = function(items)
		local v2 = {
			items = {}
		}

		for k, item in pairs(items) do
			v2.items[item] = k
		end

		return (setmetatable(v2, {
			__index = function(p, p2)
				return p.items[p2]
			end,
			__newindex = function() end
		}))
	end,
	match = function(p, p2, ...)
		return p2[p](...)
	end
}).new({
	"Started",
	"Resolved",
	"Rejected",
	"Cancelled"
})
local started = status2.Started
local resolved = status2.Resolved
local rejected = status2.Rejected
local cancelled = status2.Cancelled
local Promise = {
	methods = {}
}
Promise.__index = Promise.methods
Promise.Status = status2

-- equivalent calls inferred from this helper; original call sites unknown
local function createAdvancer(callback, callback2)
	return callback and (function(...)
		callback2(callback(...))
	end or callback2) or callback2
end

local function advanceNow(p, p2, ...)
	return p2[p](...)
end

local function arrayMerge(p, items)
	local clone = table.clone(p)

	for k, item in pairs(items) do
		table.insert(clone, item)
	end

	return clone
end

function Promise.new(callback, parent)
	local object = setmetatable({
		_resolveCallbacks = {},
		_rejectCallbacks = {},
		_finallyCallbacks = {},
		_status = status2.Started,
		_parent = parent
	}, Promise)

	local function resolve(...)
		object:_chain(resolved, ...)
	end

	local function reject(...)
		object:_chain(rejected, ...)
	end

	object.thread = task.spawn(function()
		callback(resolve, reject)
	end)
	return object
end

function Promise.isPromise(p)
	return getmetatable(p) == Promise
end

function Promise.try(callback, ...)
	local v2 = { ... }
	return Promise.new(function(callback2, callback3)
		local success, result = pcall(callback, unpack(v2))

		if success then
			callback2(result)
		else
			callback3(result)
		end
	end)
end

function Promise.promisify(p)
	return function(...)
		return Promise.try(p, ...)
	end
end

function Promise.all(list)
	return Promise.new(function(callback, p)
		local count = #list
		local count2 = 0

		for k, v2 in pairs(list) do
			v2:andThen(function()
				count2 += 1

				if count2 == count then
					callback()
				end
			end)
		end
	end)
end

function Promise.numericFor(p, callback)
	return Promise.new(function(callback2)
		local count = 0
		local iterPromise

		iterPromise = function()
			count += 1

			if p < count then
				callback2()
				return
			end

			local v2 = callback(count)

			if Promise.isPromise(v2) then
				v2:andThen(iterPromise)
			else
				iterPromise()
			end
		end

		count += 1

		if p < count then
			callback2()
		else
			local v2 = callback(count)

			if Promise.isPromise(v2) then
				v2:andThen(iterPromise)
			else
				iterPromise()
			end
		end
	end)
end

function Promise.race(items)
	local v2 = nil

	for k, item in pairs(items) do
		item:andThen(function(p)
			v2 = p
		end)
	end

	return Promise.new(function(callback, p)
		repeat
			task.wait(0)
		until v2

		for k, item in pairs(items) do
			if #item._resolveCallbacks == 0 and #item._rejectCallbacks == 0 then
				item:cancel()
			end
		end

		callback(v2)
	end)
end

Promise.sleep = Promise.promisify(task.wait)
Promise.pass = Promise.promisify(function() end)

function Promise.methods:_chain(status, ...)
	local v2 = select(1, ...)
	local _resolveCallbacks = status == resolved and self._resolveCallbacks or self._rejectCallbacks

	if v2 and Promise.isPromise(v2) then
		local v3 = { ... }
		table.remove(v3, 1)
		v2:andThen(function(...)
			local v6 = ...
			local clone = table.clone({ ... })

			for k, v8 in pairs(v3) do
				table.insert(clone, v8)
			end

			self:_chain(status, v6, unpack(clone))
		end)
	else
		self._status = status
		self._value = { ... }

		for k, _resolveCallback in pairs(_resolveCallbacks) do
			_resolveCallback(...)
		end
	end
end

function Promise.methods:_andThen(p, p2, cancelCallback)
	return Promise.new(function(callback, callback2)
		local _status = self._status
		local v2 = {
			[resolved] = createAdvancer(p, callback),
			[rejected] = createAdvancer(p2, callback2)
		}

		if v2[_status] then
			v2[_status](unpack(self._value))
		elseif _status == started then
			table.insert(self._resolveCallbacks, v2[resolved])
			table.insert(self._rejectCallbacks, v2[rejected])
			self._cancelCallback = cancelCallback
		end
	end, self)
end

function Promise.methods:andThen(p, p2)
	return self:_andThen(p)
end

function Promise.methods:catch(p)
	return self:_andThen(_, p)
end

function Promise.methods:finally(p)
	return self:_andThen(p, p, p)
end

function Promise.methods:await(p2)
	repeat
		task.wait(0)
	until self._status ~= started

	return unpack(self._value)
end

function Promise.methods:cancel()
	self.status = cancelled
	self._resolveCallbacks = {}
	self._rejectCallbacks = {}
	coroutine.close(self.thread)

	if self._parent then
		self._parent:cancel()
	end

	if self._cancelCallback then
		self._cancelCallback()
	end
end

return Promise