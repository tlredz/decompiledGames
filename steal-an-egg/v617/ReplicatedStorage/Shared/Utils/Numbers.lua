local v = utf8.char(8734)
local v2 = {
	b = 9,
	k = 3,
	m = 6,
	q = 15,
	t = 12
}

local function groupThousands(value: string)
	local count = #value
	local v4 = {}

	while count > 0 do
		local v5 = math.max(count - 2, 1)
		table.insert(v4, 1, (string.sub(value, v5, count)))
		count = v5 - 1
	end

	return table.concat(v4, ",")
end

return table.freeze({
	AddCommas = function(value: number)
		assert(type(value) == "number", "amount must be a number")

		if value ~= value then
			return "NaN"
		end

		local v4 = math.round((math.abs(value)))
		local selected

		if v4 == 1e999 then
			selected = v
		else
			selected = groupThousands(string.format("%.0f", v4))
		end

		if value < 0 and v4 > 0 then
			return "-" .. selected
		end

		return selected
	end,
	Parse = function(value: string)
		assert(type(value) == "string", "text must be a string")
		local v4 = string.gsub(string.lower(value), "[^%w%.%+%-]", "")

		for k, v5 in v2 do
			local v6 = string.match(v4, "^(.+)" .. k .. "$")

			if not v6 then
				continue
			end

			local v7 = tonumber(v6)

			if v7 then
				return v7 * 10 ^ v5
			end

			return nil
		end

		return (tonumber(v4))
	end
})