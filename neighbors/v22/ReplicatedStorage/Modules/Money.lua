function comma_value(value)
	repeat
		local v
		value, v = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v
	until k == 0

	return value
end

function round(p, p2)
	if p2 then
		return math.floor(p * 10 ^ p2 + 0.5) / 10 ^ p2
	end

	return (math.floor(p + 0.5))
end

function format_num(p, value, value2, value3)
	local v = value or 2
	local v2 = value3 or "-"
	local rounded = math.floor((math.abs((round(p, v)))))
	local rounded2 = round(math.abs(p) - rounded, v)
	local v3 = comma_value(rounded)

	if v > 0 then
		local v4 = string.sub(tostring(rounded2), 3)
		v3 ..= "." .. v4 .. string.rep("0", v - string.len(v4))
	end

	local v4 = (value2 or "") .. v3

	if not (p < 0) then
		return v4
	end

	if v2 == "()" then
		return "(" .. v4 .. ")"
	end

	return v2 .. v4
end

function yen_format(p, p2)
	local v = format_num(p, 0)

	if p2 == nil then
		return "$" .. v
	elseif p2 == true then
		return v
	end

	if p2 ~= "reputation" then
		return v
	end

	if p >= 0 then
		return "+" .. v
	end

	return v
end

return yen_format