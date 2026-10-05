local function simpleHash(value)
	local v = 0

	for i = 1, #value do
		local v2 = string.byte(value, i)
		v = (v * 31 + v2) % 2147483647
	end

	return v
end

local function deterministicRandom(value, value2)
	if type(value) ~= "string" then
		error("First parameter must be a string")
	end

	if type(value2) ~= "number" or value2 < 1 or value2 ~= math.floor(value2) then
		error("Second parameter must be a positive integer")
	end

	local v = 0

	for i = 1, #value do
		local v2 = string.byte(value, i)
		v = (v * 31 + v2) % 2147483647
	end

	return v % value2 + 1
end

return deterministicRandom