local Set = require(script.Parent.Parent:WaitForChild("Set"))
local Map = require(script.Parent.Parent:WaitForChild("Map"):WaitForChild("Map"))
local isArray = require(script.Parent:WaitForChild("isArray"))
local instanceof = require(script.Parent.Parent.Parent:WaitForChild("instance-of"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
local fromString = require(script:WaitForChild("fromString"))
local fromSet = require(script:WaitForChild("fromSet"))
local fromMap = require(script:WaitForChild("fromMap"))
local fromArray = require(script:WaitForChild("fromArray"))
return function(p, callback, p2)
	if p == nil then
		error("cannot create array from a nil value")
	end

	local typeName = typeof(p)

	if typeName == "table" and isArray(p) then
		return (fromArray(p, callback, p2))
	end

	if instanceof(p, Set) then
		return (fromSet(p, callback, p2))
	end

	if instanceof(p, Map) then
		return (fromMap(p, callback, p2))
	end

	if typeName == "string" then
		return (fromString(p, callback, p2))
	end

	return {}
end