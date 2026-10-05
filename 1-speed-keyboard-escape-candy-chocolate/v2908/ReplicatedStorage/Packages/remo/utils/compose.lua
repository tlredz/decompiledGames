require(script.Parent.Parent.types)

local function compose(list)
	local count = #list

	if count == 0 then
		return function(p)
			return p
		end
	elseif count == 1 then
		return list[1]
	end

	return function(p, ...)
		for i = count, 1, -1 do
			p = list[i](p, ...)
		end

		return p
	end
end

return compose