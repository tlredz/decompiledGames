require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
local indexOf = require(script.Parent:WaitForChild("indexOf"))
return function(p, p2, p3: number?)
	return indexOf(p, p2, p3) ~= -1
end