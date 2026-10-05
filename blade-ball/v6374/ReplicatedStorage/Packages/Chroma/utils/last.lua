local type2 = type

local function last(...)
	local v = select("#", ...)

	if v < 2 then
		return nil
	end

	local v2 = select(v, ...)

	if type2(v2) == "string" then
		return string.lower(v2)
	end

	return nil
end

return last