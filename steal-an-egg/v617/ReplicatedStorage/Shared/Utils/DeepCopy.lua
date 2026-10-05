local function replicate(p)
	local v = {}
	local v2 = {}

	local function shadow(p2)
		if type(p2) ~= "table" then
			return p2
		end

		local v3 = v[p2]

		if v3 == nil then
			v3 = {}
			v[p2] = v3
			table.insert(v2, p2)
		end

		return v3
	end

	local v3

	if type(p) == "table" then
		v3 = v[p]

		if v3 == nil then
			v3 = {}
			v[p] = v3
			table.insert(v2, p)
		end
	else
		v3 = p
	end

	while #v2 > 0 do
		local v4 = table.remove(v2)
		local v5 = v[v4]

		for k, v6 in v4 do
			local v7

			if type(k) == "table" then
				v7 = v[k]

				if v7 == nil then
					v7 = {}
					v[k] = v7
					table.insert(v2, k)
				end
			else
				v7 = k
			end

			local v8

			if type(v6) == "table" then
				v8 = v[v6]

				if v8 == nil then
					v8 = {}
					v[v6] = v8
					table.insert(v2, v6)
				end
			else
				v8 = v6
			end

			v5[v7] = v8
		end
	end

	return v3
end

return function(p)
	if type(p) == "table" then
		return (replicate(p))
	end

	return p
end