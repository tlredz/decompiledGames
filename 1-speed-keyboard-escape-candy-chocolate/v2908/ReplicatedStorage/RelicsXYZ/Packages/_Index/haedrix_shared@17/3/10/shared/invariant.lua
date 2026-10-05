local parent = script.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error

local function invariant(p, formatString, ...)
	if not p then
		error(error2(string.format(formatString, ...)))
	end
end

return invariant