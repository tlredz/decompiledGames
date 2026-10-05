local zoneTypes = script.ZoneTypes
return table.freeze({
	fromBoxes = require(zoneTypes.BoxesZone),
	fromParts = require(zoneTypes.PartsZone),
	SimpleZone = require(script.SimpleZone),
	Vertices = require(script.Vertices)
})