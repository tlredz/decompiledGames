local ValidUtil = {
	assert = function(p, callback)
		if not p then
			error(callback())
		end
	end
}

function ValidUtil.assertFields(p, ...)
	for _, v in pairs({ ... }) do
		local v2 = v
		ValidUtil.assert(p[v], function()
			return string.format("%s missing field: %s", p.DataId, v2)
		end)
	end
end

function ValidUtil.getFieldFunc()
	return function() end
end

function ValidUtil.isInArray(list, p)
	for _, v in ipairs(list) do
		if v == p then
			return true
		end
	end

	return false
end

function ValidUtil.isValidEmail(value)
	return type(value) == "string" and value:match("^[%w%.%%%+%-]+@[%w%.%-]+%.%a%a+$") ~= nil
end

function ValidUtil.isValidUsername(value)
	return type(value) == "string" and value:match("^[%w_]{3,20}$") ~= nil
end

function ValidUtil.isNumber(value)
	return type(value) == "number"
end

function ValidUtil.isString(value)
	return type(value) == "string"
end

function ValidUtil.isBoolean(p)
	return type(p) == "boolean"
end

function ValidUtil.isTable(p)
	return type(p) == "table"
end

function ValidUtil.isFunction(callback)
	return type(callback) == "function"
end

function ValidUtil.isPositiveNumber(value)
	return type(value) == "number" and value > 0
end

function ValidUtil.isNonNegativeNumber(value)
	return type(value) == "number" and value >= 0
end

function ValidUtil.isInteger(value)
	return type(value) == "number" and math.floor(value) == value
end

function ValidUtil.isPositiveInteger(value)
	return type(value) == "number" and math.floor(value) == value and value > 0
end

function ValidUtil.isNonNegativeInteger(value)
	return type(value) == "number" and math.floor(value) == value and value >= 0
end

function ValidUtil.isInRange(value, p, p2)
	return type(value) == "number" and p <= value and value <= p2
end

function ValidUtil.isValidId(value)
	return type(value) == "string" and value:match("^[%w_%-]+$") ~= nil
end

return ValidUtil