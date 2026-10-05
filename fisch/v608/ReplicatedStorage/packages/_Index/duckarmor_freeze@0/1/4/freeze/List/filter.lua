local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function filter(list, callback)
	local v = table.create(#list)

	for k, v2 in list do
		if callback(v2, k) then
			table.insert(v, v2)
		end
	end

	return maybeFreeze(v)
end

return filter