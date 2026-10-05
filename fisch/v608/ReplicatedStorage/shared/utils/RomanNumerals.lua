local RomanNumerals = {
	Numerals = {
		{ "M", 1000 },
		{ "CM", 900 },
		{ "D", 500 },
		{ "CD", 400 },
		{ "C", 100 },
		{ "XC", 90 },
		{ "L", 50 },
		{ "XL", 40 },
		{ "X", 10 },
		{ "IX", 9 },
		{ "V", 5 },
		{ "IV", 4 },
		{ "I", 1 }
	}
}

function RomanNumerals.ToRoman(_, p: number)
	local v = ""

	if not p or p <= 0 then
		return nil
	end

	for _, numeral in ipairs(RomanNumerals.Numerals) do
		local v2 = numeral[1]
		local v3 = numeral[2]

		while v3 <= p do
			p -= v3
			v ..= v2
		end
	end

	return v
end

function RomanNumerals.ToDecimal(_, value: string)
	if not value or value == "" then
		return nil
	end

	local total = 1
	local total2 = 0

	while total <= #value do
		local v = false

		for _, numeral in ipairs(RomanNumerals.Numerals) do
			local v3 = numeral[1]
			local v4 = numeral[2]
			local count = #v3

			if string.sub(value, total, total - 1 + count) ~= v3 then
				continue
			end

			total2 += v4
			total += count
			v = true
			break
		end

		if not v then
			return nil
		end
	end

	return total2
end

return RomanNumerals