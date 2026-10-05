local Map = require(script.Parent:WaitForChild("Map"))
local Object = require(script.Parent.Parent:WaitForChild("Object"))
local instanceof = require(script.Parent.Parent.Parent:WaitForChild("instance-of"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))

local function coerceToMap(p)
	return instanceof(p, Map) and p or Map.new(Object.entries(p))
end

return coerceToMap