local v = {
	IS_VERBOSE = false,
	DEBUG_CLIP_RESULTS_AT = 5,
	SEARCH_FILTER_PATH = "",
	PAUSE_DURATION = 0.03333333333333333,
	MAX_RETRIES = 100000,
	MAX_UNCAPPED_PERMUTATIONS = 10000,
	DEFAULT_TABLE_SIZE = 12,
	DEFAULT_STRING_LENGTH = 32,
	DEFAULT_ITERATIONS = 10000
}
return (setmetatable({}, {
	__index = function(_, value)
		assert(typeof(value) == "string", (`Attempt to access non-string key "{value}" in ENV`))
		local v2 = rawget(v, value)
		local v3 = "SIMPLETEST__" .. value
		local v4 = _G[v3]

		if v2 == nil then
			error((`Attempt to access undefined key "{v3}" in ENV`))
		end

		if typeof(v4) == "string" then
			if typeof(v2) == "boolean" then
				return v4 == "true" or v4 ~= "false" and v2
			elseif typeof(v2) == "number" then
				local v5 = tonumber(v4)

				if v5 == nil then
					return v2
				end

				return v5
			end
		end

		if v4 == nil then
			return v2
		end

		return v4
	end,
	__newindex = function(_, value, p)
		assert(typeof(value) == "string", (`Attempt to access non-string key "{value}" in ENV`))
		assert(rawget(v, value) ~= nil, (`Attempt to set undefined key "{value}" in ENV`))
		local v2 = "SIMPLETEST__" .. value
		_G[v2] = p
	end
}))