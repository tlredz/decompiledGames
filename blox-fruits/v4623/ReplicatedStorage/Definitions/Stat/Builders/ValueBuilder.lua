local Result = require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Definitions.Stat.Types)

local function startsWith(value: string, list: string)
	return value:sub(1, #list) == list
end

local function splitAdd(value)
	if type(value) == "number" then
		return Result.ok(value)
	end

	if type(value) ~= "string" then
		return Result.err((`unsupported add type: "{typeof(value)}"`))
	end

	local v = tonumber(value)

	if v then
		return Result.ok(v)
	end

	local v2 = tonumber((string.sub(value, 2)))

	if string.sub(value, 1, 1) == "+" and v2 then
		return Result.ok(v2)
	end

	return Result.err((`unknown number str format "{value}"`))
end

local function splitMultiplier(p)
	local v = typeof(p) == "boolean" and (p and 1 or 0) or p

	if typeof(v) == "number" then
		return Result.ok(v)
	end

	if typeof(v) ~= "string" then
		return Result.err((`expected number or string for multiplier, got: {typeof(v)}`))
	end

	if v:sub(1, 1) ~= "*" then
		return Result.err((`invalid multiplier format: {v}`))
	end

	local v2 = string.sub(v, 2)
	local v3 = tonumber(v2)

	if v3 then
		return Result.ok(v3)
	end

	return Result.err((`invalid multiplier number: {v2}`))
end

local function percentOrX(p: number, p2: string?)
	if p % 1 == 0 and p2 == nil then
		return (`{math.round(p + 1)}x`)
	end

	return (not p2 and "+" or p2 .. "") .. `{math.round(100 * (p - 1))}%`
end

local function cooldown(p)
	local v = splitMultiplier(p)

	if v:isErr() then
		return Result.err(v:unwrapErr())
	end

	local unwrapped = v:unwrap()
	local v2 = unwrapped + 1
	local _ = v2 % 1 == 0
	local text = "-" .. `{math.round(100 * (v2 - 1))}%`
	return Result.ok({
		Modification = "Multiply",
		Value = 1 - unwrapped,
		Text = text
	})
end

local function add1Multiply(p)
	local v = splitMultiplier(p)

	if v:isErr() then
		return Result.err(v:unwrapErr())
	end

	local unwrapped = v:unwrap()
	local v2 = unwrapped + 1
	local text

	if v2 % 1 == 0 then
		text = `{math.round(v2 + 1)}x`
	else
		text = "+" .. `{math.round(100 * (v2 - 1))}%`
	end

	return Result.ok({
		Modification = "Multiply",
		Value = unwrapped + 1,
		Text = text
	})
end

local function rawMultiply(p)
	local v = splitMultiplier(p)

	if v:isErr() then
		return Result.err(v:unwrapErr())
	end

	local unwrapped = v:unwrap()
	local v2 = unwrapped - 1
	local text

	if v2 % 1 == 0 then
		text = `{math.round(v2 + 1)}x`
	else
		text = "+" .. `{math.round(100 * (v2 - 1))}%`
	end

	return Result.ok({
		Modification = "Multiply",
		Value = unwrapped,
		Text = text
	})
end

local function multiply(value)
	local v = splitMultiplier(value)

	if v:isErr() then
		return Result.err(v:unwrapErr())
	end

	local v2 = v:unwrap() + ((typeof(value) == "string" or value > 1) and 0 or 1)
	local text

	if v2 % 1 == 0 then
		text = `{math.round(v2 + 1)}x`
	else
		text = "+" .. `{math.round(100 * (v2 - 1))}%`
	end

	return Result.ok({
		Modification = "Multiply",
		Value = v2,
		Text = text
	})
end

local function add(value)
	local v = splitAdd(value)

	if v:isErr() then
		return Result.err(v:unwrapErr())
	end

	local unwrapped = v:unwrap()

	if typeof(unwrapped) ~= "number" then
		return Result.err((`expected number for Add stat, got: {typeof(unwrapped)}`))
	end

	local formatted = `+{math.round(unwrapped)}`
	return Result.ok({
		Modification = "Add",
		Value = unwrapped,
		Text = formatted
	})
end

local function addOrMultiply(value)
	if type(value) ~= "string" then
		return Result.err((`requires string input for specification of multiplication (*) or addition (+), received "{value}" (type {typeof(value)})`))
	end

	local v = value:sub(1, 1)
	local v2 = value:sub(2)

	if not tonumber(v2) then
		return Result.err((`couldn't parse num "{v2}" from value "{value}"`))
	end

	if v == "+" then
		return add(value)
	elseif v == "*" then
		return multiply(value)
	end

	return Result.err((`unknown symbol "{v}"`))
end

local function addOrMultiplyFavorAdd(value)
	if type(value) == "boolean" then
		return Result.err((`requires string input for specification of multiplication (*) or addition (+), received "{value}" (type {typeof(value)})`))
	end

	if type(value) == "string" then
		return addOrMultiply(value)
	end

	return add(value)
end

local function boolean(p)
	local v

	if typeof(p) == "boolean" then
		v = p
		return Result.ok({
			Modification = "Boolean",
			Value = v and 1 or 0,
			Text = p and "Enabled" or "Disabled"
		})
	end

	if p == 1 or p == "1" or p == "true" then
		v = true
		return Result.ok({
			Modification = "Boolean",
			Value = true and 1 or 0,
			Text = p and "Enabled" or "Disabled"
		})
	end

	if p ~= 0 and p ~= "0" and p ~= "false" then
		return Result.err((`expected boolean for bool stat, got: {typeof(p)}`))
	end

	v = false
	return Result.ok({
		Modification = "Boolean",
		Value = false and 1 or 0,
		Text = p and "Enabled" or "Disabled"
	})
end

local frozen = table.freeze({
	Add = add,
	Add1Multiply = add1Multiply,
	AddOrMultiply = addOrMultiply,
	AddOrMultiplyFavorAdd = addOrMultiplyFavorAdd,
	Boolean = boolean,
	Cooldown = cooldown,
	Multiply = multiply,
	RawMultiply = rawMultiply
})
local ValueBuilder = {
	find = function(p)
		return frozen[p]
	end
}

function ValueBuilder.get(p)
	local v = ValueBuilder.find(p)
	assert(v, (`no value constructor for form "{p}"`))
	return v
end

return ValueBuilder