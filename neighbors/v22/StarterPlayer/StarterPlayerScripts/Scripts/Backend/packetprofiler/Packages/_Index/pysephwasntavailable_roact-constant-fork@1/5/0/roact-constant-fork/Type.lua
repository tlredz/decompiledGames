local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)
local v = newproxy(true)
local v2 = {}

local function addType(p)
	v2[p] = Symbol.named("Roact" .. p)
end

v2.Binding = Symbol.named("RoactBinding")
v2.Element = Symbol.named("RoactElement")
v2.HostChangeEvent = Symbol.named("RoactHostChangeEvent")
v2.HostEvent = Symbol.named("RoactHostEvent")
v2.StatefulComponentClass = Symbol.named("RoactStatefulComponentClass")
v2.StatefulComponentInstance = Symbol.named("RoactStatefulComponentInstance")
v2.VirtualNode = Symbol.named("RoactVirtualNode")
v2.VirtualTree = Symbol.named("RoactVirtualTree")

function v2.of(p)
	if typeof(p) == "table" then
		return p[v]
	end

	return nil
end

getmetatable(v).__index = v2

getmetatable(v).__tostring = function()
	return "RoactType"
end

strict(v2, "Type")
return v