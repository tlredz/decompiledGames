local function Chain(...)
	local v = { ... }
	return function(...)
		local v2 = { ... }

		for _, v3 in next, v, nil do
			v2 = { v3(unpack(v2)) }
		end

		return unpack(v2)
	end
end

return Chain