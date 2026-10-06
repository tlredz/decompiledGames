local parent = script.Parent.Parent
require(parent.Types)

local function castToState(p)
	if typeof(p) == "table" and p.type == "State" then
		return p
	end

	return nil
end

return castToState