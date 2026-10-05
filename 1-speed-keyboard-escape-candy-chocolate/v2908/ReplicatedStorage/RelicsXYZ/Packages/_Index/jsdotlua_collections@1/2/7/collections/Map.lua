require(script.Parent.Parent:WaitForChild("es7-types"))
return {
	Map = require(script:WaitForChild("Map")),
	coerceToMap = require(script:WaitForChild("coerceToMap")),
	coerceToTable = require(script:WaitForChild("coerceToTable"))
}