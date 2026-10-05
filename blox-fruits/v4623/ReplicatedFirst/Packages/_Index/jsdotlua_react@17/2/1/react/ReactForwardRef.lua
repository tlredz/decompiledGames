local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared2.ReactSymbols
require(script.Parent.Parent:WaitForChild("shared"))
local REACT_FORWARD_REF_TYPE = reactSymbols.REACT_FORWARD_REF_TYPE
local REACT_MEMO_TYPE = reactSymbols.REACT_MEMO_TYPE
return {
	forwardRef = function(render)
		if _G.__DEV__ then
			if typeof(render) == "table" and render["$$typeof"] == REACT_MEMO_TYPE then
				console.error("forwardRef requires a render function but received a `memo` component. Instead of forwardRef(memo(...)), use memo(forwardRef(...)).")
			elseif typeof(render) == "function" then
				local v, _ = debug.info(render, "a")

				if v ~= 0 and v ~= 2 then
					console.error(
						"forwardRef render functions accept exactly two parameters: props and ref. %s",
						v == 1 and "Did you forget to use the ref parameter?" or "Any additional parameter will be undefined."
					)
				end
			else
				console.error("forwardRef requires a render function but was given %s.", (typeof(render)))
			end
		end

		local v = {
			["$$typeof"] = REACT_FORWARD_REF_TYPE,
			render = render
		}

		if _G.__DEV__ then
			local v2 = nil
			setmetatable(v, {
				__index = function(p, p2)
					if p2 == "displayName" then
						return v2
					end

					return (rawget(p, p2))
				end,
				__newindex = function(p, p2, p3)
					if p2 == "displayName" then
						v2 = p3
					else
						rawset(p, p2, p3)
					end
				end
			})
		end

		return v
	end
}