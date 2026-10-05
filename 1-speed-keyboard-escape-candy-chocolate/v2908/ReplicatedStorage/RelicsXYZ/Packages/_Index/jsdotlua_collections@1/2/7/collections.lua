local Array = require(script:WaitForChild("Array"))
local Map = require(script:WaitForChild("Map"))
local Object = require(script:WaitForChild("Object"))
local Set = require(script:WaitForChild("Set"))
local WeakMap = require(script:WaitForChild("WeakMap"))
local inspect = require(script:WaitForChild("inspect"))
require(script.Parent:WaitForChild("es7-types"))
return {
	Array = Array,
	Object = Object,
	Map = Map.Map,
	coerceToMap = Map.coerceToMap,
	coerceToTable = Map.coerceToTable,
	Set = Set,
	WeakMap = WeakMap,
	inspect = inspect
}