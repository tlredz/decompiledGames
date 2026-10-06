local parent = script.Parent.Parent
require(parent.Types)

local function castToGraph(data)
	if typeof(data) == "table" and typeof(data.validity) == "string" and typeof(data.timeliness) == "string" and typeof(data.dependencySet) == "table" and typeof(data.dependentSet) == "table" then
		return data
	end

	return nil
end

return castToGraph