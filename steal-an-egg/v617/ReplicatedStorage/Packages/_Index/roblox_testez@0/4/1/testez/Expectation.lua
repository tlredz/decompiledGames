local Expectation = {}
local v = {
	to = true,
	be = true,
	been = true,
	have = true,
	was = true,
	at = true
}
local v2 = {
	never = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function assertLevel(p, value, value2)
	local v3 = value or "Assertion failed!"
	local v4 = value2 or 1

	if not p then
		error(v3, v4 + 1)
	end
end

local function bindSelf(p, callback)
	return function(p2, ...)
		if p2 == p then
			return callback(p, ...)
		end

		return callback(p, p2, ...)
	end
end

local function formatMessage(p, p2, p3)
	if p then
		return p2
	end

	return p3
end

function Expectation.new(p)
	local v3 = {
		value = p,
		successCondition = true,
		condition = false,
		matchers = {},
		_boundMatchers = {}
	}
	setmetatable(v3, Expectation)
	local a = v3.a

	function v3.a(p2, ...)
		if p2 == v3 then
			return a(v3, ...)
		end

		return a(v3, p2, ...)
	end

	v3.an = v3.a
	local ok = v3.ok

	function v3.ok(p2, ...)
		if p2 == v3 then
			return ok(v3, ...)
		end

		return ok(v3, p2, ...)
	end

	local equal = v3.equal

	function v3.equal(p2, ...)
		if p2 == v3 then
			return equal(v3, ...)
		end

		return equal(v3, p2, ...)
	end

	local throw = v3.throw

	function v3.throw(p2, ...)
		if p2 == v3 then
			return throw(v3, ...)
		end

		return throw(v3, p2, ...)
	end

	local near = v3.near

	function v3.near(p2, ...)
		if p2 == v3 then
			return near(v3, ...)
		end

		return near(v3, p2, ...)
	end

	return v3
end

function Expectation.checkMatcherNameCollisions(p)
	return not (v[p] or v2[p] or Expectation[p])
end

function Expectation:extend(options)
	self.matchers = options or {}

	for k, matcher in pairs(self.matchers) do
		local v3 = matcher

		local function fn(p, ...)
			local v4 = v3(self.value, ...)
			assertLevel(v4.pass == self.successCondition, v4.message, 3) -- equivalent call inferred; original call site unknown
			self:_resetModifiers()
			return self
		end

		self._boundMatchers[k] = function(p, ...)
			if p == self then
				return fn(self, ...)
			end

			return fn(self, p, ...)
		end
	end

	return self
end

function Expectation:__index(p)
	if v[p] then
		return self
	end

	if v2[p] then
		local extended = Expectation.new(self.value):extend(self.matchers)
		extended.successCondition = not self.successCondition
		return extended
	elseif self._boundMatchers[p] then
		return self._boundMatchers[p]
	else
		return Expectation[p]
	end
end

function Expectation:_resetModifiers()
	self.successCondition = true
end

function Expectation:a(p)
	local v3 = type(self.value) == p == self.successCondition
	local successCondition = self.successCondition
	local formatted = ("Expected value of type %q, got value %q of type %s"):format(
		p,
		tostring(self.value),
		(type(self.value))
	)
	local formatted2 = ("Expected value not of type %q, got value %q of type %s"):format(
		p,
		tostring(self.value),
		(type(self.value))
	)

	if successCondition then
		formatted2 = formatted
	end

	assertLevel(v3, formatted2, 3) -- equivalent call inferred; original call site unknown
	self:_resetModifiers()
	return self
end

Expectation.an = Expectation.a

function Expectation:ok()
	local v3 = self.value ~= nil == self.successCondition
	local successCondition = self.successCondition
	local formatted = ("Expected value %q to be non-nil"):format((tostring(self.value)))
	local formatted2 = ("Expected value %q to be nil"):format((tostring(self.value)))

	if successCondition then
		formatted2 = formatted
	end

	assertLevel(v3, formatted2, 3) -- equivalent call inferred; original call site unknown
	self:_resetModifiers()
	return self
end

function Expectation:equal(p)
	local v3 = self.value == p == self.successCondition
	local successCondition = self.successCondition
	local formatted = ("Expected value %q (%s), got %q (%s) instead"):format(
		tostring(p),
		type(p),
		tostring(self.value),
		(type(self.value))
	)
	local formatted2 = ("Expected anything but value %q (%s)"):format(tostring(p), (type(p)))

	if successCondition then
		formatted2 = formatted
	end

	assertLevel(v3, formatted2, 3) -- equivalent call inferred; original call site unknown
	self:_resetModifiers()
	return self
end

function Expectation:near(value, value2)
	assert(type(self.value) == "number", "Expectation value must be a number to use 'near'")
	assert(type(value) == "number", "otherValue must be a number")
	assert(type(value2) == "number" or value2 == nil, "limit must be a number or nil")
	local v3 = value2 or 1e-7
	local v4 = math.abs(self.value - value) <= v3 == self.successCondition
	local successCondition = self.successCondition
	local formatted = ("Expected value to be near %f (within %f) but got %f instead"):format(value, v3, self.value)
	local formatted2 = ("Expected value to not be near %f (within %f) but got %f instead"):format(value, v3, self.value)

	if successCondition then
		formatted2 = formatted
	end

	assertLevel(v4, formatted2, 3) -- equivalent call inferred; original call site unknown
	self:_resetModifiers()
	return self
end

function Expectation:throw(p)
	local success, result = pcall(self.value)
	local v3 = success ~= self.successCondition

	if p and not success then
		if self.successCondition then
			v3 = result:find(p, 1, true) ~= nil
		else
			v3 = result:find(p, 1, true) == nil
		end
	end

	local v4

	if p then
		local successCondition = self.successCondition
		v4 = ("Expected function to throw an error containing %q, but it %s"):format(
			p,
			not result and "did not throw." or ("threw: %s"):format(result) or "did not throw."
		)
		local formatted = ("Expected function to never throw an error containing %q, but it threw: %s"):format(
			p,
			(tostring(result))
		)

		if not successCondition then
			v4 = formatted
		end
	else
		local successCondition = self.successCondition
		local formatted = ("Expected function to succeed, but it threw an error: %s"):format((tostring(result)))
		v4 = successCondition and "Expected function to throw an error, but it did not throw." or formatted
	end

	assertLevel(v3, v4, 3) -- equivalent call inferred; original call site unknown
	self:_resetModifiers()
	return self
end

return Expectation