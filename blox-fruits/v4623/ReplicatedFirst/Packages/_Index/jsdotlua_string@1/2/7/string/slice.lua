local function slice(value: string, p, p2)
	local v, v2 = utf8.len(value)
	assert(v ~= nil, ("string `%s` has an invalid byte at position %s"):format(value, (tostring(v2))))
	local v3 = tonumber(p)
	assert(typeof(v3) == "number", "startIndexStr should be a number")
	local v4 = v3 + v < 0 and 1 or v3

	if v < v4 then
		return ""
	end

	local v5 = v + 1

	if p2 ~= nil then
		v5 = tonumber(p2) or (0 / 0)
	end

	assert(typeof(v5) == "number", "lastIndexStr should convert to number")

	if v < v5 then
		v5 = v + 1
	end

	return (string.sub(value, utf8.offset(value, v4), utf8.offset(value, v5) - 1))
end

return slice