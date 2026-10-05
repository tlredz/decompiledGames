local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local applyInstanceProps = require(parent.Instances.applyInstanceProps)

local function Hydrate(list, p)
	if p == nil then
		External.logError("scopeMissing", nil, "instances using Hydrate", "myScope:Hydrate (instance) { ... }")
	end

	return function(p2)
		table.insert(list, p)
		applyInstanceProps(list, p2, p)
		return p
	end
end

return Hydrate