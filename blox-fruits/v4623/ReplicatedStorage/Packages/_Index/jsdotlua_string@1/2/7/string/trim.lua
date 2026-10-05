local trimStart = require(script.Parent:WaitForChild("trimStart"))
local trimEnd = require(script.Parent:WaitForChild("trimEnd"))
return function(p: string)
	return trimStart(trimEnd(p))
end