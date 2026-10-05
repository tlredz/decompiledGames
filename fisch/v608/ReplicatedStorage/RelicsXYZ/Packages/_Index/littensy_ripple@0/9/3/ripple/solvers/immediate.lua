require(script.Parent.Parent.types)
local intermediate = require(script.Parent.Parent.utils.intermediate)

local function immediate(p)
	local v = intermediate.to(p)
	return function(p2, p3)
		local index = intermediate.index(v, p2)

		if not index then
			return false
		end

		p3.value = index
		p3.complete = true
	end
end

return immediate