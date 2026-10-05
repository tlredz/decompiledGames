local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local doCleanup = require(parent.Memory.doCleanup)
local For = require(parent.State.For)
local Value = require(parent.State.Value)
local Computed = require(parent.State.Computed)
require(parent.State.For.ForTypes)
local parseError = require(parent.Logging.parseError)
local v = {
	__index = {
		roamKeys = false,
		roamValues = true,
		invalidateInputKey = function(p)
			p._inputKeyState:set(p.inputKey)
		end,
		invalidateInputValue = function(_) end,
		useOutputPair = function(p, callback)
			return callback(p._outputKeyState), p.inputValue
		end
	}
}

local function SubObject(maybeScope, inputKey, inputValue, processor)
	local v2 = {
		maybeScope = maybeScope,
		inputKey = inputKey,
		inputValue = inputValue,
		_inputKeyState = Value(maybeScope, inputKey),
		_processor = processor
	}
	v2._outputKeyState = Computed(maybeScope, function(callback2, list)
		local v3 = callback2(v2._inputKeyState)
		local v4, v5 = xpcall(v2._processor, parseError, callback2, list, v3)

		if v4 then
			return v5
		end

		v5.context = `while processing key {tostring(v3)}`
		External.logErrorNonFatal("callbackError", v5)
		doCleanup(list)
		table.clear(list)
		return nil
	end)
	return (setmetatable(v2, v))
end

local function ForKeys(p, callback, callback2, p2)
	if typeof(callback) == "function" then
		External.logError(
			"scopeMissing",
			nil,
			"ForKeys",
			"myScope:ForKeys(inputTable, function(scope, use, key) ... end)"
		)
	elseif p2 ~= nil then
		External.logWarn("destructorRedundant", "ForKeys")
	end

	return For(p, callback, function(maybeScope, inputKey, inputValue)
		return (SubObject(maybeScope, inputKey, inputValue, callback2))
	end)
end

return ForKeys