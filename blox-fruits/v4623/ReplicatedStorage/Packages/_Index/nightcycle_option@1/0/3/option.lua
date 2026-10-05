local v = {
	isSome = function(self)
		return self._state == "S"
	end,
	isNone = function(self)
		return self._state == "N"
	end,
	inspect = function(self, callback)
		if self:isSome() then
			callback(self._value)
		end

		return self
	end,
	match = function(self, callback, callback2)
		if self:isSome() then
			return callback(self._value)
		end

		assert(self:isNone())
		return callback2()
	end
}

function v:map(callback)
	if self:isSome() then
		local v2 = callback(self._value)
		assert(typeof(v2) ~= "nil", "some() value cannot be nil")
		local object2 = setmetatable({
			_state = "S",
			_value = v2
		}, v)
		table.freeze(object2)
		return object2
	else
		local object2 = setmetatable({
			_state = "N",
			_value = nil
		}, v)
		table.freeze(object2)
		return object2
	end
end

function v:unwrap()
	if self:isSome() then
		return self._value
	end

	error("Option is none")
end

function v:asNullable()
	if self:isSome() then
		return self._value
	end

	return nil
end

function v:unwrapOr(p)
	if self:isSome() then
		return self._value
	end

	return p
end

function v:expect(message: string)
	if self:isSome() then
		return self._value
	end

	error(message)
end

function v:unwrapOrElse(callback)
	if self:isSome() then
		return self._value
	end

	return callback()
end

v.__index = v

function v:__tostring()
	if self:isSome() then
		return "Some<" .. tostring(self._value) .. ">"
	end

	return "None"
end

function v:__eq(object2)
	if self:isSome() and object2:isSome() then
		return self._value == object2._value
	end

	return self:isNone() and object2:isNone()
end

function v:mapOr(callback, p)
	if self:isSome() then
		local v2 = callback(self._value)
		assert(typeof(v2) ~= "nil", "some() value cannot be nil")
		local object2 = setmetatable({
			_state = "S",
			_value = v2
		}, v)
		table.freeze(object2)
		return object2
	else
		assert(typeof(p) ~= "nil", "some() value cannot be nil")
		local object2 = setmetatable({
			_state = "S",
			_value = p
		}, v)
		table.freeze(object2)
		return object2
	end
end

function v:mapOrElse(callback, callback2)
	if self:isSome() then
		local v2 = callback(self._value)
		assert(typeof(v2) ~= "nil", "some() value cannot be nil")
		local object2 = setmetatable({
			_state = "S",
			_value = v2
		}, v)
		table.freeze(object2)
		return object2
	else
		local v2 = callback2()
		assert(typeof(v2) ~= "nil", "some() value cannot be nil")
		local object2 = setmetatable({
			_state = "S",
			_value = v2
		}, v)
		table.freeze(object2)
		return object2
	end
end

function v:unpack()
	return self:asNullable()
end

local Option = {}

function Option.none()
	local self = setmetatable({
		_state = "N",
		_value = nil
	}, v)
	table.freeze(self)
	return self
end

function Option.some(p)
	assert(typeof(p) ~= "nil", "some() value cannot be nil")
	local self = setmetatable({
		_state = "S",
		_value = p
	}, v)
	table.freeze(self)
	return self
end

function Option.match(object, callback, callback2)
	if object:isSome() then
		return callback(object:unwrap())
	end

	return callback2()
end

function Option.map(object, callback)
	if object:isSome() then
		local v2 = callback(object:unwrap())
		assert(typeof(v2) ~= "nil", "some() value cannot be nil")
		local self = setmetatable({
			_state = "S",
			_value = v2
		}, v)
		table.freeze(self)
		return self
	else
		local self = setmetatable({
			_state = "N",
			_value = nil
		}, v)
		table.freeze(self)
		return self
	end
end

function Option.isOption(p)
	return typeof(p) == "table" and getmetatable(p) == v
end

function Option.type(callback)
	return function(object)
		if typeof(object) ~= "table" or getmetatable(object) ~= v then
			return false, "Value is not an option"
		end

		if object:isSome() then
			return callback(object:unwrap())
		end

		return true, nil
	end
end

function Option.try(callback)
	local v2 = callback()

	if typeof(v2) == "nil" then
		local self = setmetatable({
			_state = "N",
			_value = nil
		}, v)
		table.freeze(self)
		return self
	else
		assert(typeof(v2) ~= "nil", "some() value cannot be nil")
		local self = setmetatable({
			_state = "S",
			_value = v2
		}, v)
		table.freeze(self)
		return self
	end
end

function Option.from(p)
	if typeof(p) == "nil" then
		local self = setmetatable({
			_state = "N",
			_value = nil
		}, v)
		table.freeze(self)
		return self
	else
		assert(typeof(p) ~= "nil", "some() value cannot be nil")
		local self = setmetatable({
			_state = "S",
			_value = p
		}, v)
		table.freeze(self)
		return self
	end
end

return Option