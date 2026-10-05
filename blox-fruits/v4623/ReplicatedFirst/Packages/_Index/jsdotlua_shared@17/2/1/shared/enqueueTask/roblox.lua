local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local setTimeout = luaupolyfill.setTimeout
return function(p)
	return setTimeout(p, 0)
end