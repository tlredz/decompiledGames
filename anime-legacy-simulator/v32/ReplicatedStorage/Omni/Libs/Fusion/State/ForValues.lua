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
		roamKeys = true,
		roamValues = false,
		invalidateInputKey = function(_) end,
		invalidateInputValue = function(p)
			p._inputValueState:set(p.inputValue)
		end,
		useOutputPair = function(p, callback)
			return p.inputKey, callback(p._outputValueState)
		end
	}
}

local function SubObject(maybeScope, inputKey, inputValue, processor)
	local v2 = {
		maybeScope = maybeScope,
		inputKey = inputKey,
		inputValue = inputValue,
		_inputValueState = Value(maybeScope, inputValue),
		_processor = processor
	}
	v2._outputValueState = Computed(maybeScope, function(callback2, list)
		local v3 = callback2(v2._inputValueState)
		local v4, v5 = xpcall(v2._processor, parseError, callback2, list, v3)

		if v4 then
			return v5
		end

		v5.context = `while processing value {tostring(v3)}`
		External.logErrorNonFatal("callbackError", v5)
		doCleanup(list)
		table.clear(list)
		return nil
	end)
	return (setmetatable(v2, v))
end

local function ForValues(p, callback, callback2, p2)
	if typeof(callback) == "function" then
		External.logError(
			"scopeMissing",
			nil,
			"ForValues",
			"myScope:ForValues(inputTable, function(scope, use, value) ... end)"
		)
	elseif p2 ~= nil then
		External.logWarn("destructorRedundant", "ForValues")
	end

	return For(p, callback, function(maybeScope, inputKey, inputValue)
		return (SubObject(maybeScope, inputKey, inputValue, callback2))
	end)
end

return ForValues