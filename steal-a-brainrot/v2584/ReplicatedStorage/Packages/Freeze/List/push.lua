local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function push(p, ...)
	if #{ ... } == 0 then
		return p
	end

	local clone = table.clone(p)

	for _, v in { ... } do
		table.insert(clone, v)
	end

	return maybeFreeze(clone)
end

return push