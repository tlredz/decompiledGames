local v = { "Exploiting" }
local v2 = {
	Autocomplete = function(value)
		local result = {}

		for _, v3 in v do
			if not v3:lower():find(value:lower()) then
				continue
			end

			table.insert(result, v3)
		end

		return result
	end,
	Parse = function(p)
		return p
	end
}
return function(registry)
	registry:RegisterType("reason", v2)
end