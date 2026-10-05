local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared2.ReactSymbols
local REACT_PROVIDER_TYPE = reactSymbols.REACT_PROVIDER_TYPE
local REACT_CONTEXT_TYPE = reactSymbols.REACT_CONTEXT_TYPE
return {
	createContext = function(currentValue, calculateChangedBits)
		local v = {
			["$$typeof"] = REACT_CONTEXT_TYPE,
			_calculateChangedBits = calculateChangedBits,
			_currentValue = currentValue,
			_currentValue2 = currentValue,
			_threadCount = 0,
			Provider = nil,
			Consumer = nil,
			displayName = nil,
			_currentRenderer = nil,
			_currentRenderer2 = nil
		}
		v.Provider = {
			["$$typeof"] = REACT_PROVIDER_TYPE,
			_context = v
		}
		local v2 = false

		if _G.__DEV__ then
			local consumer = {
				["$$typeof"] = REACT_CONTEXT_TYPE,
				_context = v,
				_calculateChangedBits = v._calculateChangedBits
			}
			setmetatable(consumer, {
				__index = function(_, p2)
					if p2 == "_currentValue" then
						return v._currentValue
					elseif p2 == "_currentValue2" then
						return v._currentValue2
					elseif p2 == "_threadCount" then
						return v._threadCount
					elseif p2 == "displayName" then
						return v.displayName
					end

					return nil
				end,
				__newindex = function(_, p2, p3)
					if p2 == "_currentValue" then
						v._currentValue = p3
					elseif p2 == "_currentValue2" then
						v._currentValue2 = p3
					elseif p2 == "_threadCount" then
						v._threadCount = p3
					elseif p2 == "displayName" and not v2 then
						console.warn("Setting `displayName` on Context.Consumer has no effect. " .. "You should set it directly on the context with Context.displayName = " .. p3 .. ".")
						v2 = true
					end
				end
			})
			v.Consumer = consumer
		else
			v.Consumer = v
		end

		if _G.__DEV__ then
			v._currentRenderer = nil
			v._currentRenderer2 = nil
		end

		return v
	end
}