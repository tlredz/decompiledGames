local None = require(script.Parent.Parent.None)
return function(...)
	local result = {}

	for i = 1, select("#", ...) do
		local v = select(i, ...)

		if v == nil then
			continue
		end

		assert(type(v) == "table", "Expected table")

		for k, v2 in v do
			if v2 == None then
				result[k] = nil
			else
				result[k] = v2
			end
		end
	end

	return result
end