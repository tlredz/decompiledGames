local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function set(p, p2: number, p3)
	if p[p2] == p3 then
		return p
	end

	local clone = table.clone(p)
	clone[p2] = p3
	return maybeFreeze(clone)
end

return set