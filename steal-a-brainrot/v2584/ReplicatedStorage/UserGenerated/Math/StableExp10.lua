local function StableExp10(value: number, value2: number)
	assert(type(value) == "number")
	assert(type(value2) == "number")

	if value2 == 0 then
		return value
	end

	local v = tonumber((`{string.format("%f", value)}e{value2}`))
	return v or value * 10 ^ value2
end

return StableExp10