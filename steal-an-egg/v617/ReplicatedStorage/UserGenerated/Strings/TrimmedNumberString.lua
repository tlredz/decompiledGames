local function TrimmedNumberString(value: number)
	assert(type(value) == "number")

	if value ~= value then
		return "NaN"
	end

	if value == 1e999 then
		return "Infinity"
	elseif value == -1e999 then
		return "-Infinity"
	end

	local v = string.format("%f", value)
	local v2, v3 = string.match(v, "^([^%.]*)%.?(.*)$")
	assert(v2)

	if not v3 then
		return v2
	end

	local v4 = string.gsub(v3, "0+$", "")

	if #v4 == 0 then
		return v2
	end

	return (`{v2}.{v4}`)
end

return TrimmedNumberString