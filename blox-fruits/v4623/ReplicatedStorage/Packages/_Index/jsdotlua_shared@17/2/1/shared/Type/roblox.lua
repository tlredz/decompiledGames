local Symbolroblox = require(script.Parent:WaitForChild("Symbol.roblox"))
local v = newproxy(true)
local v2 = {}

local function addType(p)
	v2[p] = Symbolroblox.named("Roact" .. p)
end

v2.HostChangeEvent = Symbolroblox.named("RoactHostChangeEvent")
v2.HostEvent = Symbolroblox.named("RoactHostEvent")

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

return v