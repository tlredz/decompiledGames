local function UTF8Sub(value: string, p: number, value2: number?)
	local v = value2 or -1
	local v2 = utf8.offset(value, p)

	if not v2 then
		if p > 0 then
			return ""
		else
			v2 = 1
		end
	end

	local v3

	if v == -1 then
		v3 = #value
	else
		local v4 = utf8.offset(value, v + 1)

		if v4 then
			v3 = v4 - 1
		else
			v3 = v < 0 and 0 or #value
		end
	end

	return (string.sub(value, v2, v3))
end

return UTF8Sub