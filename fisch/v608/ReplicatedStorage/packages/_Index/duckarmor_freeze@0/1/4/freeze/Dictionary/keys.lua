local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function keys(items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	return maybeFreeze(v)
end

return keys