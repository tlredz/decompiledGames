local import = _G.import("dictUtil")
local IterUtil = {
	new = function(p)
		local count = 0
		return function()
			count += 1
			local v = p[count]

			if v then
				return count, v
			end
		end
	end,
	collect = function(items)
		local result = {}

		for k, item in items do
			result[k] = item
		end

		return result
	end
}

function IterUtil.toDict(p, p2)
	return import.map(IterUtil.collect(p), p2)
end

return IterUtil