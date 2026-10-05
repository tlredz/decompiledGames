return {
	new = function(p)
		local v = {}
		local class = {
			__index = v
		}

		if p then
			for k, v2 in pairs(getmetatable(p).__index) do
				v[k] = v2
			end
		end

		function class.__newindex(_, p2, p3)
			assert(v[p2] == nil, string.format("Cannot reassign %s in context", (tostring(p2))))
			v[p2] = p3
		end

		return (setmetatable({}, class))
	end
}