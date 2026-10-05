local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function filter(items, callback)
	local v = {}

	for k, item in items do
		if callback(item, k) == true then
			v[k] = item
		end
	end

	return maybeFreeze(v)
end

return filter