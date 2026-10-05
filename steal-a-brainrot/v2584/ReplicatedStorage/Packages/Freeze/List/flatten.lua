local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)
local flatten

flatten = function(item, p: number?)
	local v = {}
	local v2 = 1

	for _, item2 in item do
		if type(item2) == "table" and (not p or p > 0) then
			local v3 = flatten(item2, p and p - 1)

			for i = 1, #v3 do
				v[v2] = v3[i]
				v2 += 1
			end
		else
			v[v2] = item2
			v2 += 1
		end
	end

	return maybeFreeze(v)
end

return flatten