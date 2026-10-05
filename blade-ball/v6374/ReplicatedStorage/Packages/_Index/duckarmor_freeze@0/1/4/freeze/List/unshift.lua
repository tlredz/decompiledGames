local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function unshift(p, ...)
	local v = select("#", ...)
	local clone = table.clone(p)

	for i = v, 1, -1 do
		table.insert(clone, 1, (select(i, ...)))
	end

	return maybeFreeze(clone)
end

return unshift