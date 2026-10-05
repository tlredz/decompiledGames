local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function values(items)
	local v = {}

	for _, item in items do
		table.insert(v, item)
	end

	return maybeFreeze(v)
end

return values