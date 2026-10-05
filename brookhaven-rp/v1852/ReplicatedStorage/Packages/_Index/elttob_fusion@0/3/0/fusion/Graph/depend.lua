local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local evaluate = require(parent.Graph.evaluate)
local nameOf = require(parent.Utility.nameOf)

local function depend(p, p2)
	evaluate(p2, false)

	if table.isfrozen(p.dependencySet) or table.isfrozen(p2.dependentSet) then
		External.logError("cannotDepend", nil, nameOf(p, "Dependent"), nameOf(p2, "dependency"))
	end

	p2.dependentSet[p] = true
	p.dependencySet[p2] = true
end

return depend