local v = {
	__mode = "k"
}

local function isCallable(value)
	if type(value) == "function" then
		return true
	end

	if type(value) == "table" then
		local metatable = getmetatable(value)

		if metatable and type((rawget(metatable, "__call"))) == "function" then
			return true
		end
	end

	return false
end

local function makeEnum(p, list)
	local v2 = {}

	for _, v3 in ipairs(list) do
		v2[v3] = v3
	end

	return (setmetatable(v2, {
		__index = function(_, p2)
			error(string.format("%s is not in %s!", p2, p), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", p), 2)
		end
	}))
end

local error2 = {
	Kind = makeEnum("Promise.Error.Kind", {
		"ExecutionError",
		"AlreadyCancelled",
		"NotResolvedInTime",
		"TimedOut"
	})
}
error2.__index = error2

function error2.new(options, parent)
	local v3 = options or {}
	return (setmetatable({
		error = tostring(v3.error) or "[This error has no error text.]",
		trace = v3.trace,
		context = v3.context,
		kind = v3.kind,
		parent = parent,
		createdTick = os.clock(),
		createdTrace = debug.traceback()
	}, error2))
end

function error2.is(p)
	if type(p) ~= "table" then
		return false
	end

	local metatable = getmetatable(p)

	if type(metatable) == "table" then
		return rawget(p, "error") ~= nil and type((rawget(metatable, "extend"))) == "function"
	end

	return false
end

function error2.isKind(p, p2)
	assert(p2 ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")
	return error2.is(p) and p.kind == p2
end

function error2:extend(options)
	local v3 = options or {}
	v3.kind = v3.kind or self.kind
	return error2.new(v3, self)
end

function error2:getErrorChain()
	local parents = { self }

	while parents[#parents].parent do
		table.insert(parents, parents[#parents].parent)
	end

	return parents
end

function error2:__tostring()
	local values = { string.format("-- Promise.Error(%s) --", self.kind or "?") }

	for _, v3 in ipairs(self:getErrorChain()) do
		table.insert(values, table.concat({ v3.trace or v3.error, v3.context }, "\n"))
	end

	return table.concat(values, "\n")
end

local function pack(...)
	return select("#", ...), { ... }
end

local function packResult(p, ...)
	return p, select("#", ...), { ... }
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeErrorHandler(p)
	assert(p ~= nil, "traceback is nil")
	return function(error3)
		if type(error3) == "table" then
			return error3
		end

		return error2.new({
			error = error3,
			kind = error2.Kind.ExecutionError,
			trace = debug.traceback(tostring(error3), 2),
			context = [[
Promise created at:

]] .. p
		})
	end
end

local function runExecutor(p, p2, ...)
	return packResult(xpcall(p2, makeErrorHandler(p), ...))
end

local function createAdvancer(p, p2, callback, callback2)
	return function(...)
		local v3, v4, v5 = runExecutor(p, p2, ...)

		if v3 then
			callback(unpack(v5, 1, v4))
		else
			callback2(v5[1])
		end
	end
end

local function isEmpty(items)
	return next(items) == nil
end

local Promise = {
	Error = error2,
	Status = makeEnum("Promise.Status", {
		"Started",
		"Resolved",
		"Rejected",
		"Cancelled"
	}),
	_getTime = os.clock,
	_timeEvent = 0,
	_unhandledRejectionCallbacks = 0
}
local RunService = game:GetService("RunService")
Promise._timeEvent = RunService.Heartbeat
Promise._unhandledRejectionCallbacks = {}
Promise.prototype = {}
Promise.__index = Promise.prototype

function Promise._new(source, p2, parent)
	if parent ~= nil and not Promise.is(parent) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end

	local v3 = {
		_thread = nil,
		_source = source,
		_status = Promise.Status.Started,
		_values = nil,
		_valuesLength = -1,
		_unhandledRejection = true,
		_queuedResolve = {},
		_queuedReject = {},
		_queuedFinally = {},
		_cancellationHook = nil,
		_parent = parent,
		_consumers = setmetatable({}, v)
	}

	if parent and parent._status == Promise.Status.Started then
		parent._consumers[v3] = true
	end

	setmetatable(v3, Promise)

	local function resolve(...)
		v3:_resolve(...)
	end

	local function reject(...)
		v3:_reject(...)
	end

	local function onCancel(cancellationHook)
		if cancellationHook then
			if v3._status == Promise.Status.Cancelled then
				cancellationHook()
			else
				v3._cancellationHook = cancellationHook
			end
		end

		return v3._status == Promise.Status.Cancelled
	end

	v3._thread = coroutine.create(function()
		local v4, _, v5 = runExecutor(v3._source, p2, resolve, reject, onCancel)

		if not v4 then
			reject(v5[1])
		end
	end)
	task.spawn(v3._thread)
	return v3
end

function Promise.new(p)
	return Promise._new(debug.traceback(nil, 2), p)
end

function Promise:__tostring()
	return string.format("Promise(%s)", self._status)
end

function Promise.defer(p)
	local traceback = debug.traceback(nil, 2)
	return (Promise._new(traceback, function(p2, callback, p3)
		task.defer(function()
			local v3, _, v4 = runExecutor(traceback, p, p2, callback, p3)

			if not v3 then
				callback(v4[1])
			end
		end)
	end))
end

Promise.async = Promise.defer

function Promise.resolve(...)
	local v3, v4 = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(callback)
		callback(unpack(v4, 1, v3))
	end)
end

function Promise.reject(...)
	local v3, v4 = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(_, callback)
		callback(unpack(v4, 1, v3))
	end)
end

function Promise._try(p, callback, ...)
	local v3, v4 = pack(...)
	return Promise._new(p, function(callback2)
		callback2(callback(unpack(v4, 1, v3)))
	end)
end

function Promise.try(p, ...)
	return Promise._try(debug.traceback(nil, 2), p, ...)
end

function Promise._all(p, list, p2)
	if type(list) ~= "table" then
		error(string.format("Please pass a list of promises to %s", "Promise.all"), 3)
	end

	for k, v3 in pairs(list) do
		if not Promise.is(v3) then
			error(string.format("Non-promise value passed into %s at index %s", "Promise.all", (tostring(k))), 3)
		end
	end

	if #list == 0 or p2 == 0 then
		return Promise.resolve({})
	end

	return Promise._new(p, function(callback, callback2, callback3)
		local v3 = {}
		local v4 = {}
		local count = 0
		local count2 = 0
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancel()
			for _, v5 in ipairs(v4) do
				v5:cancel()
			end
		end

		local function resolveOne(p3, ...)
			if flag then
				return
			end

			count += 1

			if p2 == nil then
				v3[p3] = ...
			else
				v3[count] = ...
			end

			if count >= (p2 or #list) then
				flag = true
				callback(v3)
				cancel() -- equivalent call inferred; original call site unknown
			end
		end

		callback3(cancel)

		for i, v5 in ipairs(list) do
			local v6 = i
			v4[i] = v5:andThen(function(...)
				resolveOne(v6, ...)
			end, function(...)
				count2 += 1

				if p2 == nil or #list - count2 < p2 then
					cancel() -- equivalent call inferred; original call site unknown
					flag = true
					callback2(...)
				end
			end)
		end

		if flag then
			cancel() -- equivalent call inferred; original call site unknown
		end
	end)
end

function Promise.all(p)
	return Promise._all(debug.traceback(nil, 2), p)
end

function Promise.fold(p, callback, p2)
	assert(type(p) == "table", "Bad argument #1 to Promise.fold: must be a table")
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, "Bad argument #2 to Promise.fold: must be a function")
	local resolved = Promise.resolve(p2)
	return Promise.each(p, function(p3, p4)
		resolved = resolved:andThen(function(p5)
			return callback(p5, p3, p4)
		end)
	end):andThen(function()
		return resolved
	end)
end

function Promise.some(p, value)
	assert(type(value) == "number", "Bad argument #2 to Promise.some: must be a number")
	return Promise._all(debug.traceback(nil, 2), p, value)
end

function Promise.any(p)
	return Promise._all(debug.traceback(nil, 2), p, 1):andThen(function(list)
		return list[1]
	end)
end

function Promise.allSettled(list)
	if type(list) ~= "table" then
		error(string.format("Please pass a list of promises to %s", "Promise.allSettled"), 2)
	end

	for k, v3 in pairs(list) do
		if not Promise.is(v3) then
			error(string.format("Non-promise value passed into %s at index %s", "Promise.allSettled", (tostring(k))), 2)
		end
	end

	if #list == 0 then
		return Promise.resolve({})
	end

	return Promise._new(debug.traceback(nil, 2), function(callback, _, callback2)
		local v3 = {}
		local v4 = {}
		local count = 0

		local function resolveOne(p, ...)
			count += 1
			v3[p] = ...

			if count >= #list then
				callback(v3)
			end
		end

		callback2(function()
			for _, v5 in ipairs(v4) do
				v5:cancel()
			end
		end)

		for i, v5 in ipairs(list) do
			local v6 = i
			v4[i] = v5:finally(function(...)
				resolveOne(v6, ...)
			end)
		end
	end)
end

function Promise.race(list)
	assert(type(list) == "table", string.format("Please pass a list of promises to %s", "Promise.race"))

	for k, v3 in pairs(list) do
		assert(
			Promise.is(v3),
			string.format("Non-promise value passed into %s at index %s", "Promise.race", (tostring(k)))
		)
	end

	return Promise._new(debug.traceback(nil, 2), function(callback, callback2, callback3)
		local v3 = {}
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancel()
			for _, v4 in ipairs(v3) do
				v4:cancel()
			end
		end

		local function finalize(callback4)
			return function(...)
				cancel() -- equivalent call inferred; original call site unknown
				flag = true
				return callback4(...)
			end
		end

		if callback3(function(...)
			cancel() -- equivalent call inferred; original call site unknown
			flag = true
			return callback2(...)
		end) then
			return
		end

		for i, v4 in ipairs(list) do
			v3[i] = v4:andThen(function(...)
				cancel() -- equivalent call inferred; original call site unknown
				flag = true
				return callback(...)
			end, function(...)
				cancel() -- equivalent call inferred; original call site unknown
				flag = true
				return callback2(...)
			end)
		end

		if flag then
			cancel() -- equivalent call inferred; original call site unknown
		end
	end)
end

function Promise.each(list, callback)
	assert(type(list) == "table", string.format("Please pass a list of promises to %s", "Promise.each"))
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise.each"))
	return Promise._new(debug.traceback(nil, 2), function(callback2, callback3, callback4)
		local v4 = {}
		local values = {}
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancel()
			for _, v5 in ipairs(values) do
				v5:cancel()
			end
		end

		callback4(function()
			flag = true
			cancel() -- equivalent call inferred; original call site unknown
		end)
		local v5 = {}

		for i, v6 in ipairs(list) do
			if Promise.is(v6) then
				if v6:getStatus() == Promise.Status.Cancelled then
					cancel() -- equivalent call inferred; original call site unknown
					return callback3(error2.new({
						error = "Promise is cancelled",
						kind = error2.Kind.AlreadyCancelled,
						context = string.format([[
The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.

That Promise was created at:

%s]], i, v6._source)
					}))
				elseif v6:getStatus() == Promise.Status.Rejected then
					cancel() -- equivalent call inferred; original call site unknown
					return callback3(select(2, v6:await()))
				else
					local v7 = v6:andThen(function(...)
						return ...
					end)
					table.insert(values, v7)
					v5[i] = v7
				end
			else
				v5[i] = v6
			end
		end

		for i, v6 in ipairs(v5) do
			if Promise.is(v6) then
				local v7
				v7, v6 = v6:await()

				if not v7 then
					cancel() -- equivalent call inferred; original call site unknown
					return callback3(v6)
				end
			end

			if flag then
				return
			end

			local resolved = Promise.resolve(callback(v6, i))
			table.insert(values, resolved)
			local v7, v8 = resolved:await()

			if v7 then
				v4[i] = v8
			else
				cancel() -- equivalent call inferred; original call site unknown
				return callback3(v8)
			end
		end

		callback2(v4)
	end)
end

function Promise.is(p)
	if type(p) ~= "table" then
		return false
	end

	local metatable = getmetatable(p)

	if metatable == Promise then
		return true
	end

	if metatable == nil then
		local andThen = p.andThen

		if type(andThen) == "function" then
			return true
		end

		if type(andThen) == "table" then
			local metatable2 = getmetatable(andThen)

			if metatable2 and type((rawget(metatable2, "__call"))) == "function" then
				return true
			end
		end

		return false
	else
		if type(metatable) ~= "table" or type((rawget(metatable, "__index"))) ~= "table" then
			return false
		end

		local v3 = rawget(rawget(metatable, "__index"), "andThen")
		local v4

		if type(v3) == "function" then
			v4 = true
		elseif type(v3) == "table" then
			local metatable2 = getmetatable(v3)
			v4 = metatable2 and type((rawget(metatable2, "__call"))) == "function" and true or false
		else
			v4 = false
		end

		if v4 then
			return true
		end

		return false
	end
end

function Promise.promisify(p)
	return function(...)
		return Promise._try(debug.traceback(nil, 2), p, ...)
	end
end

function Promise.delay(duration)
	assert(type(duration) == "number", "Bad argument #1 to Promise.delay, must be a number.")
	local _getTime = Promise._getTime()
	return Promise._new(debug.traceback(nil, 2), function(callback)
		task.delay(duration, function()
			callback(Promise._getTime() - _getTime)
		end)
	end)
end

function Promise.prototype.timeout(p, p2, p3)
	local traceback = debug.traceback(nil, 2)
	return Promise.race({ Promise.delay(p2):andThen(function()
			return Promise.reject(p3 == nil and error2.new({
				kind = error2.Kind.TimedOut,
				error = "Timed out",
				context = string.format([[
Timeout of %d seconds exceeded.
:timeout() called at:

%s]], p2, traceback)
			}) or p3)
		end), p })
end

function Promise.prototype:getStatus()
	return self._status
end

function Promise.prototype:_andThen(p, p2, p3)
	self._unhandledRejection = false

	if self._status ~= Promise.Status.Cancelled then
		return Promise._new(p, function(callback, fn, callback2)
			local fn2

			if p2 then
				local v3 = p
				local v4 = p2

				fn2 = function(...)
					local v5, v6, v7 = runExecutor(v3, v4, ...)

					if v5 then
						callback(unpack(v7, 1, v6))
					else
						fn(v7[1])
					end
				end
			else
				fn2 = callback
			end

			if p3 then
				local v3 = p
				local v4 = p3

				fn = function(...)
					local v5, v6, v7 = runExecutor(v3, v4, ...)

					if v5 then
						callback(unpack(v7, 1, v6))
					else
						fn(v7[1])
					end
				end
			end

			if self._status == Promise.Status.Started then
				table.insert(self._queuedResolve, fn2)
				table.insert(self._queuedReject, fn)
				callback2(function()
					if self._status == Promise.Status.Started then
						table.remove(self._queuedResolve, table.find(self._queuedResolve, fn2))
						table.remove(self._queuedReject, table.find(self._queuedReject, fn))
					end
				end)
			elseif self._status == Promise.Status.Resolved then
				fn2(unpack(self._values, 1, self._valuesLength))
			elseif self._status == Promise.Status.Rejected then
				fn(unpack(self._values, 1, self._valuesLength))
			end
		end, self)
	end

	local v3 = Promise.new(function() end)
	v3:cancel()
	return v3
end

function Promise.prototype:andThen(value, value2)
	local v3

	if value == nil or type(value) == "function" then
		v3 = true
	elseif type(value) == "table" then
		local metatable = getmetatable(value)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise:andThen"))
	local v4

	if value2 == nil or type(value2) == "function" then
		v4 = true
	elseif type(value2) == "table" then
		local metatable = getmetatable(value2)
		v4 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v4 = false
	end

	assert(v4, string.format("Please pass a handler function to %s!", "Promise:andThen"))
	return self:_andThen(debug.traceback(nil, 2), value, value2)
end

function Promise.prototype:catch(value)
	local v3

	if value == nil or type(value) == "function" then
		v3 = true
	elseif type(value) == "table" then
		local metatable = getmetatable(value)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise:catch"))
	return self:_andThen(debug.traceback(nil, 2), nil, value)
end

function Promise.prototype:tap(callback)
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise:tap"))
	return self:_andThen(debug.traceback(nil, 2), function(...)
		local v4 = callback(...)

		if not Promise.is(v4) then
			return ...
		end

		local v5, v6 = pack(...)
		return v4:andThen(function()
			return unpack(v6, 1, v5)
		end)
	end)
end

function Promise.prototype:andThenCall(callback, ...)
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise:andThenCall"))
	local v4, v5 = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return callback(unpack(v5, 1, v4))
	end)
end

function Promise.prototype:andThenReturn(...)
	local v3, v4 = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return unpack(v4, 1, v3)
	end)
end

function Promise.prototype:cancel()
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Cancelled

	if self._cancellationHook then
		self._cancellationHook()
	end

	coroutine.close(self._thread)

	if self._parent then
		self._parent:_consumerCancelled(self)
	end

	for k in pairs(self._consumers) do
		k:cancel()
	end

	self:_finalize()
end

function Promise.prototype:_consumerCancelled(p)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._consumers[p] = nil

	if next(self._consumers) == nil then
		self:cancel()
	end
end

function Promise.prototype:_finally(p, p2)
	self._unhandledRejection = false
	return (Promise._new(p, function(callback, callback2, callback3)
		local v3 = nil
		callback3(function()
			self:_consumerCancelled(self)

			if v3 then
				v3:cancel()
			end
		end)
		local fn = p2 and function(...)
			local v4, _, v5 = runExecutor(p, p2, ...)
			local v6 = v5[1]

			if not v4 then
				return callback2(v6)
			end

			if not Promise.is(v6) then
				callback(self)
				return
			end

			v3 = v6
			v6:finally(function(p3)
				if p3 ~= Promise.Status.Rejected then
					callback(self)
				end
			end):catch(function(...)
				callback2(...)
			end)
		end or callback

		if self._status == Promise.Status.Started then
			table.insert(self._queuedFinally, fn)
		else
			fn(self._status)
		end
	end))
end

function Promise.prototype:finally(value)
	local v3

	if value == nil or type(value) == "function" then
		v3 = true
	elseif type(value) == "table" then
		local metatable = getmetatable(value)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise:finally"))
	return self:_finally(debug.traceback(nil, 2), value)
end

function Promise.prototype:finallyCall(callback, ...)
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, string.format("Please pass a handler function to %s!", "Promise:finallyCall"))
	local v4, v5 = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(v5, 1, v4))
	end)
end

function Promise.prototype:finallyReturn(...)
	local v3, v4 = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(v4, 1, v3)
	end)
end

function Promise.prototype:awaitStatus()
	self._unhandledRejection = false

	if self._status == Promise.Status.Started then
		local thread = coroutine.running()
		self:finally(function()
			task.spawn(thread)
		end):catch(function() end)
		coroutine.yield()
	end

	if not (self._status ~= Promise.Status.Resolved and self._status ~= Promise.Status.Rejected) then
		return self._status, unpack(self._values, 1, self._valuesLength)
	end

	return self._status
end

local function awaitHelper(p, ...)
	return p == Promise.Status.Resolved, ...
end

function Promise.prototype:await()
	return awaitHelper(self:awaitStatus())
end

local function expectHelper(p, ...)
	if p ~= Promise.Status.Resolved then
		error(... == nil and "Expected Promise rejected with no value." or ..., 3)
	end

	return ...
end

function Promise.prototype:expect()
	return expectHelper(self:awaitStatus())
end

Promise.prototype.awaitValue = Promise.prototype.expect

function Promise.prototype:_unwrap()
	if self._status == Promise.Status.Started then
		error("Promise has not resolved or rejected.", 2)
	end

	return self._status == Promise.Status.Resolved, unpack(self._values, 1, self._valuesLength)
end

function Promise.prototype._resolve(object, ...)
	if object._status == Promise.Status.Started then
		if Promise.is((...)) then
			if select("#", ...) > 1 then
				local v3 = string.format([[
When returning a Promise from andThen, extra arguments are discarded! See:

%s]], object._source)
				warn(v3)
			end

			local v3 = ...
			local parent = v3:andThen(function(...)
				object:_resolve(...)
			end, function(...)
				local _value = v3._values[1]

				if v3._error then
					_value = error2.new({
						error = v3._error,
						kind = error2.Kind.ExecutionError,
						context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]"
					})
				end

				if error2.isKind(_value, error2.Kind.ExecutionError) then
					return object:_reject(_value:extend({
						error = "This Promise was chained to a Promise that errored.",
						trace = "",
						context = string.format([[
The Promise at:

%s
...Rejected because it was chained to the following Promise, which encountered an error:
]], object._source)
					}))
				end

				object:_reject(...)
			end)

			if parent._status == Promise.Status.Cancelled then
				object:cancel()
			elseif parent._status == Promise.Status.Started then
				object._parent = parent
				parent._consumers[object] = true
			end
		else
			object._status = Promise.Status.Resolved
			local valuesLength, values = pack(...)
			object._valuesLength = valuesLength
			object._values = values

			for _, callback in ipairs(object._queuedResolve) do
				coroutine.wrap(callback)(...)
			end

			object:_finalize()
		end
	elseif Promise.is((...)) then
		(...):_consumerCancelled(object)
	end
end

function Promise.prototype:_reject(...)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Rejected
	local valuesLength, values = pack(...)
	self._valuesLength = valuesLength
	self._values = values
	local _queuedReject = self._queuedReject

	if next(_queuedReject) == nil then
		local v5 = tostring((...))
		coroutine.wrap(function()
			Promise._timeEvent:Wait()

			if not self._unhandledRejection then
				return
			end

			local v6 = string.format([[
Unhandled Promise rejection:

%s

%s]], v5, self._source)

			for _, callback in ipairs(Promise._unhandledRejectionCallbacks) do
				task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
			end

			if Promise.TEST then
				return
			end

			warn(v6)
		end)()
	else
		for _, callback in ipairs(self._queuedReject) do
			coroutine.wrap(callback)(...)
		end
	end

	self:_finalize()
end

function Promise.prototype:_finalize()
	for _, callback in ipairs(self._queuedFinally) do
		coroutine.wrap(callback)(self._status)
	end

	self._queuedFinally = nil
	self._queuedReject = nil
	self._queuedResolve = nil

	if not Promise.TEST then
		self._parent = nil
		self._consumers = nil
	end

	task.defer(coroutine.close, self._thread)
end

function Promise.prototype.now(object, p)
	local traceback = debug.traceback(nil, 2)

	if object._status == Promise.Status.Resolved then
		return object:_andThen(traceback, function(...)
			return ...
		end)
	end

	local reject = Promise.reject

	if p == nil then
		p = error2.new({
			kind = error2.Kind.NotResolvedInTime,
			error = "This Promise was not resolved in time for :now()",
			context = [[
:now() was called at:

]] .. traceback
		}) or nil
	end

	return reject(p)
end

function Promise.retry(callback, value, ...)
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, "Parameter #1 to Promise.retry must be a function")
	assert(type(value) == "number", "Parameter #2 to Promise.retry must be a number")
	local v4 = { ... }
	local v5 = select("#", ...)
	return Promise.resolve(callback(...)):catch(function(...)
		if value > 0 then
			return Promise.retry(callback, value - 1, unpack(v4, 1, v5))
		end

		return Promise.reject(...)
	end)
end

function Promise.retryWithDelay(callback, value, value2, ...)
	local v3

	if type(callback) == "function" then
		v3 = true
	elseif type(callback) == "table" then
		local metatable = getmetatable(callback)
		v3 = metatable and type((rawget(metatable, "__call"))) == "function" and true or false
	else
		v3 = false
	end

	assert(v3, "Parameter #1 to Promise.retry must be a function")
	assert(type(value) == "number", "Parameter #2 (times) to Promise.retry must be a number")
	assert(type(value2) == "number", "Parameter #3 (seconds) to Promise.retry must be a number")
	local v4 = { ... }
	local v5 = select("#", ...)
	return Promise.resolve(callback(...)):catch(function(...)
		if value > 0 then
			Promise.delay(value2):await()
			return Promise.retryWithDelay(callback, value - 1, value2, unpack(v4, 1, v5))
		else
			return Promise.reject(...)
		end
	end)
end

function Promise.fromEvent(object, p)
	local v3 = p or function()
		return true
	end
	return Promise._new(debug.traceback(nil, 2), function(callback, _, callback2)
		local connection = nil
		local v4 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disconnect()
			connection:Disconnect()
			connection = nil
		end

		connection = object:Connect(function(...)
			local v5 = v3(...)

			if v5 == true then
				callback(...)

				if not connection then
					v4 = true
					return
				end

				disconnect() -- equivalent call inferred; original call site unknown
			elseif type(v5) ~= "boolean" then
				error("Promise.fromEvent predicate should always return a boolean")
			end
		end)

		if v4 and connection then
			return disconnect()
		end

		callback2(disconnect)
	end)
end

function Promise.onUnhandledRejection(p)
	table.insert(Promise._unhandledRejectionCallbacks, p)
	return function()
		local index = table.find(Promise._unhandledRejectionCallbacks, p)

		if index then
			table.remove(Promise._unhandledRejectionCallbacks, index)
		end
	end
end

return Promise