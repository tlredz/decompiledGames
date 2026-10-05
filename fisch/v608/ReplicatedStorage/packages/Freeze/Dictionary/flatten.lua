local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)
local flattenImpl

flattenImpl = function(items, p: number?)
	local result = {}

	for k, item in items do
		if type(item) == "table" and (not p or p > 0) then
			local v = flattenImpl(item, p and p - 1)

			for k2, v2 in pairs(result) do
				v[k2] = v2
			end

			result = v
		else
			result[k] = item
		end
	end

	return result
end

local function flatten(p, p2: number?)
	return maybeFreeze((flattenImpl(p, p2)))
end

return flatten