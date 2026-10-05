local error2 = require(script.Parent:WaitForChild("error"))
local class = {}
class.__index = class

function class:__tostring()
	if class.isOk(self) then
		if typeof(self._ok) == "table" then
			return (`Ok<{error2.displayAsJson(self._ok)}>`)
		end

		return (`Ok<{self._ok}>`)
	else
		if typeof(self._err) ~= "table" then
			return (`Err<{self._err}>`)
		end

		if error2.isErr(self._err) then
			return (`Err<{self._err:display("Full")}>`)
		end

		return (`Ok<{error2.displayAsJson(self._err)}>`)
	end
end

function class:__eq(p2)
	if class.isOk(self) and class.isOk(p2) then
		return self._ok == p2._ok
	end

	if class.isErr(self) and class.isErr(p2) then
		return self._err == p2._err
	end

	return false
end

function class:isOk()
	return self._state == "O"
end

function class:isErr()
	return self._state == "E"
end

function class:asNullable()
	if class.isOk(self) then
		return self._ok
	end

	return nil
end

function class:inspect(callback)
	if class.isOk(self) then
		callback(self._ok)
	end

	return self
end

function class:inspectErr(callback)
	if class.isErr(self) then
		callback(self._err)
	end

	return self
end

function class:match(callback, callback2)
	if class.isOk(self) then
		return callback(self._ok)
	end

	return callback2(self._err)
end

function class:map(callback)
	if class.isOk(self) then
		local object = setmetatable({
			_state = "O",
			_ok = callback(self._ok),
			_err = nil
		}, class)
		table.freeze(object)
		return object
	else
		local object = setmetatable({
			_state = "E",
			_ok = nil,
			_err = self._err
		}, class)
		table.freeze(object)
		return object
	end
end

function class:mapErr(callback)
	if class.isOk(self) then
		local object = setmetatable({
			_state = "O",
			_ok = self._ok,
			_err = nil
		}, class)
		table.freeze(object)
		return object
	else
		local object = setmetatable({
			_state = "E",
			_ok = nil,
			_err = callback(self._err)
		}, class)
		table.freeze(object)
		return object
	end
end

function class:unwrap()
	if class.isOk(self) then
		return self._ok
	end

	local _err

	if error2.isErr(self._err) then
		_err = self._err:display("Full")
	elseif typeof(self._err) == "table" then
		_err = error2.displayAsJson(self._err)
	else
		_err = self._err
	end

	error((`{_err}`))
end

function class:unwrapErr()
	if class.isErr(self) then
		return self._err
	end

	error("result is not error")
end

function class.unwrapOr(p, p2)
	return class.match(p, function(p3)
		return p3
	end, function(_)
		return p2
	end)
end

function class.unwrapOrElse(p, callback)
	return class.match(p, function(p2)
		return p2
	end, function(_)
		return callback()
	end)
end

function class:expect(message: string)
	if class.isOk(self) then
		return self._ok
	end

	error(message)
end

function class:mapOr(callback, ok)
	if class.isOk(self) then
		local object = setmetatable({
			_state = "O",
			_ok = callback(self._ok),
			_err = nil
		}, class)
		table.freeze(object)
		return object
	else
		local object = setmetatable({
			_state = "O",
			_ok = ok,
			_err = nil
		}, class)
		table.freeze(object)
		return object
	end
end

function class:mapOrElse(callback, callback2)
	if class.isOk(self) then
		local object = setmetatable({
			_state = "O",
			_ok = callback(self._ok),
			_err = nil
		}, class)
		table.freeze(object)
		return object
	else
		local object = setmetatable({
			_state = "O",
			_ok = callback2(),
			_err = nil
		}, class)
		table.freeze(object)
		return object
	end
end

local Result = {}

function Result.ok(ok)
	local self = setmetatable({
		_state = "O",
		_ok = ok,
		_err = nil
	}, class)
	table.freeze(self)
	return self
end

function Result.err(err)
	local self = setmetatable({
		_state = "E",
		_ok = nil,
		_err = err
	}, class)
	table.freeze(self)
	return self
end

function Result.try(callback)
	local ok = nil
	local err = nil
	xpcall(function()
		ok = callback()
	end, function(p)
		err = p
	end)

	if err then
		local self = setmetatable({
			_state = "E",
			_ok = nil,
			_err = err
		}, class)
		table.freeze(self)
		return self
	else
		local self = setmetatable({
			_state = "O",
			_ok = ok,
			_err = nil
		}, class)
		table.freeze(self)
		return self
	end
end

function Result:match(callback, callback2)
	return (self:match(callback, callback2))
end

function Result:map(callback)
	return (self:map(callback))
end

function Result:mapErr(callback)
	return (self:mapErr(callback))
end

function Result.type(callback, callback2)
	return function(object)
		if typeof(object) ~= "table" or getmetatable(object) ~= class then
			return false, "Value is not a result"
		end

		if object:isOk() then
			return callback(object:unwrap())
		end

		return callback2(object:unwrapErr())
	end
end

function Result.from(callback)
	return callback()
end

function Result.catch(flag: boolean, value)
	if flag then
		local self = setmetatable({
			_state = "O",
			_ok = value,
			_err = nil
		}, class)
		table.freeze(self)
		return self
	else
		assert(typeof(value) == "string", (`message must be a string when success = false, got "{typeof(value)}"`))
		local self = setmetatable({
			_state = "E",
			_ok = nil,
			_err = value
		}, class)
		table.freeze(self)
		return self
	end
end

function Result.isResult(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

return Result