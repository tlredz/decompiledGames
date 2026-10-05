local v = {
	IS_VERBOSE = false
}
return (setmetatable({}, {
	__index = function(_, p: string)
		local v2 = "__OSIRIS__" .. p
		local v3 = _G[v2]
		local v4 = rawget(v, p)

		if v4 == nil then
			error((`Attempt to access undefined key "{p}" in ENV`))
		end

		if typeof(v3) == "string" then
			if typeof(v4) == "boolean" then
				return v3 == "true" or v3 ~= "false" and v4
			elseif typeof(v4) == "number" then
				local v5 = tonumber(v3)

				if v5 == nil then
					return v4
				end

				return v5
			end
		end

		if v3 == nil then
			return v4
		end

		return v3
	end,
	__newindex = function(_, p, p2)
		local v2 = "__OSIRIS__" .. p
		assert(rawget(v, p) ~= nil, (`Attempt to set undefined key "{p}" in ENV`))
		_G[v2] = p2
	end
}))