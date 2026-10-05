local isInteger = require(script.Parent:WaitForChild("isInteger"))
local MAX_SAFE_INTEGER = require(script.Parent:WaitForChild("MAX_SAFE_INTEGER"))
return function(p)
	return isInteger(p) and math.abs(p) <= MAX_SAFE_INTEGER
end