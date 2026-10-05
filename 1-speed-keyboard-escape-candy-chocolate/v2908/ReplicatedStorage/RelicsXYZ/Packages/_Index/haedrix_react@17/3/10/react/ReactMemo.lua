local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local Shared = require(parent.Shared)
local console = Shared.console
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local object = LuauPolyfill.Object
local inspect = LuauPolyfill.util.inspect
local reactSymbols = Shared.ReactSymbols
local REACT_MEMO_TYPE = reactSymbols.REACT_MEMO_TYPE
local REACT_ELEMENT_TYPE = reactSymbols.REACT_ELEMENT_TYPE
local isValidElementType = Shared.isValidElementType
local getComponentName = Shared.getComponentName
return {
	memo = function(state, callback)
		if ReactGlobals.__DEV__ and not isValidElementType(state) then
			local v = ""

			if state == nil or typeof(state) == "table" and #object.keys(state) == 0 then
				v ..= " You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports."
			end

			local typeName

			if state == nil then
				typeName = "nil"
			elseif array.isArray(state) then
				typeName = "array"
			elseif state == nil or typeof(state) ~= "table" or state["$$typeof"] ~= REACT_ELEMENT_TYPE then
				typeName = typeof(state)

				if state ~= nil then
					v = "\n" .. inspect(state)
				end
			else
				typeName = string.format("<%s />", getComponentName(state.type) or "UNKNOWN")
				v = " Did you accidentally export a JSX literal or Element instead of a component?"
			end

			console.error("memo: The first argument must be a component. Instead received: `%s`.%s", typeName, v)
		end

		local v = {
			["$$typeof"] = REACT_MEMO_TYPE,
			type = state,
			compare = callback or nil
		}

		if ReactGlobals.__DEV__ then
			local displayName = nil
			setmetatable(v, {
				__index = function(p, p2)
					if p2 == "displayName" then
						return displayName
					end

					return (rawget(p, p2))
				end,
				__newindex = function(p, p2, p3)
					if p2 == "displayName" then
						displayName = p3

						if typeof(state) == "table" and state.displayName == nil then
							state.displayName = displayName
						end
					else
						rawset(p, p2, p3)
					end
				end
			})
		end

		return v
	end
}