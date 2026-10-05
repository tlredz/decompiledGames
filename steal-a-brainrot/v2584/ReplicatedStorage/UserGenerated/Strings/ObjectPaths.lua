return table.freeze({
	QueryObject = function(p, value: string, p2)
		for _, v in ipairs(string.split(value, ".")) do
			if p == nil then
				return false
			end

			if p == p2 then
				return true
			end

			if type(p) ~= "table" then
				return false
			end

			p = p[v]
		end

		if p == nil then
			return false
		end

		if p == p2 then
			return true
		end

		return true, p
	end,
	HasHierarchicalOverlap = function(value: string, value2: string)
		if value == value2 then
			return true
		end

		local v = string.split(value, ".")
		local v2 = string.split(value2, ".")

		for i = 1, math.min(#v, #v2) do
			if v[i] ~= v2[i] then
				return false
			end
		end

		return true
	end
})