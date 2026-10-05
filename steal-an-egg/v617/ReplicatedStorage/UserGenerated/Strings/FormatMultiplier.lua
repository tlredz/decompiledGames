local function FormatMultiplier(value: number, value2: number?)
	assert(type(value) == "number")
	local v

	if value2 == nil then
		v = true
	elseif type(value2) == "number" and value2 >= 0 then
		v = math.floor(value2) == value2
	else
		v = false
	end

	assert(v)

	if value ~= value then
		return "NaN"
	end

	if value == 1e999 then
		return "Infinity"
	elseif value == -1e999 then
		return "-Infinity"
	end

	local v2 = value2 or 2

	if v2 > 0 then
		return string.format(`%0.{v2}f`, value):gsub("(%d)%.?0+$", "%1")
	end

	return (tostring((math.round(value))))
end

return FormatMultiplier