local result = require(script.Parent:WaitForChild("result"))
require(script.Parent:WaitForChild("option"))
local luneutil = require(script.Parent:WaitForChild("lune-util"))
local JsonUtil = require(script:WaitForChild("JsonUtil"))

function intersect(callback, callback2)
	return function(p, p2)
		local v = { callback(p, p2), callback2(p, p2) }
		local result2 = {}

		for _, v2 in ipairs(v) do
			for k, v3 in pairs(v2) do
				result2[k] = v3
			end
		end

		return result2
	end
end

local class = {}
class.__index = class

function newSerde(ser, callback2)
	return (table.freeze((setmetatable({
		_ser = ser,
		_deser = callback2
	}, class))))
end

function intersectSerde(p, p2)
	return (table.freeze((setmetatable({
		_ser = intersect(p._ser, p2._ser),
		_deser = intersect(p._deser, p2._deser)
	}, class))))
end

function class:toString(p2)
	return result.try(function()
		return luneutil.Net.jsonEncode(self._ser(p2, JsonUtil.ser))
	end)
end

function class:encode(p2)
	return result.try(function()
		return (self._ser(p2, JsonUtil.ser))
	end):match(function(p3)
		return result.ok(p3)
	end, function(p3: string)
		return result.err(p3)
	end)
end

function class:decode(p2)
	return result.try(function()
		return self._deser(p2, JsonUtil.deser)
	end)
end

function class:fromString(p2: string)
	return result.try(function()
		return self._deser(luneutil.Net.jsonDecode(p2), JsonUtil.deser)
	end)
end

return {
	new = newSerde,
	intersect = intersectSerde
}