local keyOf = require(script.Parent.Parent.utils.keyOf)

local function indexOf(p, p2)
	local v = keyOf(p, p2)

	if v == nil then
		return nil
	end

	return v
end

return indexOf