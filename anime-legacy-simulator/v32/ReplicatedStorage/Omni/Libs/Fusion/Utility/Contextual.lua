local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local parseError = require(parent.Logging.parseError)
local v = {
	type = "Contextual"
}
local frozen = table.freeze({
	__index = v
})
local frozen2 = table.freeze({
	__mode = "k"
})

local function Contextual(defaultValue)
	return (setmetatable({
		_valuesNow = setmetatable({}, frozen2),
		_defaultValue = defaultValue
	}, frozen))
end

function v:now()
	local thread = coroutine.running()
	local v2 = self._valuesNow[thread]

	if typeof(v2) == "table" then
		return v2.value
	end

	return self._defaultValue
end

function v:is(p2)
	return {
		during = function(_, callback, ...)
			local thread = coroutine.running()
			local v2 = self._valuesNow[thread]
			self._valuesNow[thread] = {
				value = p2
			}
			local v3, v4 = xpcall(callback, parseError, ...)
			self._valuesNow[thread] = v2

			if not v3 then
				External.logError("callbackError", v4)
			end

			return v4
		end
	}
end

table.freeze(v)
return Contextual