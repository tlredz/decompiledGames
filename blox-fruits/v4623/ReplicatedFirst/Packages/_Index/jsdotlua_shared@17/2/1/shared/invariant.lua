local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local error2 = luaupolyfill.Error

local function invariant(p, formatString, ...)
	if not p then
		error(error2(string.format(formatString, ...)))
	end
end

return invariant