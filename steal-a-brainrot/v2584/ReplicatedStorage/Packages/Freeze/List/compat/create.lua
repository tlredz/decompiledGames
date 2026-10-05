local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function create(p: number, p2)
	deprecationWarning("List." .. script.Name, "table.create")
	return table.create(p, p2)
end

return create