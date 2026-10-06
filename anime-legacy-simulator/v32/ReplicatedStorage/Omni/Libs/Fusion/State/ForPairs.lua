local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local For = require(parent.State.For)
local Value = require(parent.State.Value)
local Computed = require(parent.State.Computed)
require(parent.State.For.ForTypes)
local parseError = require(parent.Logging.parseError)
local doCleanup = require(parent.Memory.doCleanup)
local v = {
	__index = {
		roamKeys = false,
		roamValues = false,
		invalidateInputKey = function(p)
			p._inputKeyState:set(p.inputKey)
		end,
		invalidateInputValue = function(p)
			p._inputValueState:set(p.inputValue)
		end,
		useOutputPair = function(p, callback)
			local v2 = callback(p._outputPairState)
			return v2.key, v2.value
		end
	}
}

local function SubObject(maybeScope, inputKey, inputValue, processor)
	local v2 = {
		maybeScope = maybeScope,
		inputKey = inputKey,
		inputValue = inputValue,
		_inputKeyState = Value(maybeScope, inputKey),
		_inputValueState = Value(maybeScope, inputValue),
		_processor = processor
	}
	v2._outputPairState = Computed(maybeScope, function(callback2, list)
		local v3 = callback2(v2._inputKeyState)
		local v4 = callback2(v2._inputValueState)
		local v5, v6, v7 = xpcall(v2._processor, parseError, callback2, list, v3, v4)

		if v5 then
			return {
				key = v6,
				value = v7
			}
		end

		v6.context = `while processing key {tostring(v4)} and value {tostring(v4)}`
		External.logErrorNonFatal("callbackError", v6)
		doCleanup(list)
		table.clear(list)
		return {
			key = nil,
			value = nil
		}
	end)
	return (setmetatable(v2, v))
end

local function ForPairs(p, callback, callback2, p2)
	if typeof(callback) == "function" then
		External.logError(
			"scopeMissing",
			nil,
			"ForPairs",
			"myScope:ForPairs(inputTable, function(scope, use, key, value) ... end)"
		)
	elseif p2 ~= nil then
		External.logWarn("destructorRedundant", "ForPairs")
	end

	return For(p, callback, function(maybeScope, inputKey, inputValue)
		return (SubObject(maybeScope, inputKey, inputValue, callback2))
	end)
end

return ForPairs