local Map = require(script.Parent:WaitForChild("Map"))
local instanceof = require(script.Parent.Parent.Parent:WaitForChild("instance-of"))
local reduce = require(script.Parent.Parent:WaitForChild("Array"):WaitForChild("reduce"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))

local function coerceToTable(object)
	if instanceof(object, Map) then
		return reduce(object:entries(), function(p, list)
			p[list[1]] = list[2]
			return p
		end, {})
	end

	return object
end

return coerceToTable