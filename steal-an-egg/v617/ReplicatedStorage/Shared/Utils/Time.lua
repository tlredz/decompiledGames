local v = {
	{
		seconds = 86400,
		symbol = "d"
	},
	{
		seconds = 3600,
		symbol = "h"
	},
	{
		seconds = 60,
		symbol = "m"
	},
	{
		seconds = 1,
		symbol = "s"
	}
}
local count = #v
local v2 = utf8.char(8734)

-- equivalent calls inferred from this helper; original call sites unknown
local function wholeSeconds(value: number)
	if value == value and value ~= 1e999 then
		return (math.ceil((math.max(value, 0))))
	end

	return nil
end

local function nonFiniteText(p: number)
	if p == p then
		return v2
	end

	return "NaN"
end

local function splitUnits(p: number)
	local result = table.create(#v)

	for k, v4 in v do
		result[k] = p // v4.seconds
		p %= v4.seconds
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function leadingUnit(p: number)
	for i = 1, count - 1 do
		if v[i].seconds <= p then
			return i
		end
	end

	return count
end

return table.freeze({
	Timecode = function(value: number)
		assert(type(value) == "number", "seconds must be a number")
		local v4 = wholeSeconds(value) -- equivalent call inferred; original call site unknown

		if v4 == nil then
			if value == value then
				return v2
			end

			return "NaN"
		else
			local v5 = leadingUnit(v4) -- equivalent call inferred; original call site unknown

			if v5 == count then
				return (`{v4}s`)
			end

			local v6 = table.create(#v)

			for k, v7 in v do
				v6[k] = v4 // v7.seconds
				v4 %= v7.seconds
			end

			local v7 = { (tostring(v6[v5])) }

			for i = v5 + 1, count do
				table.insert(v7, string.format("%02d", v6[i]))
			end

			return table.concat(v7, ":")
		end
	end,
	Elapsed = function(value: number)
		assert(type(value) == "number", "seconds must be a number")
		local v4 = wholeSeconds(value) -- equivalent call inferred; original call site unknown

		if v4 == nil then
			if value == value then
				return v2
			end

			return "NaN"
		else
			local v5 = table.create(#v)
			local v6 = v4

			for k, v7 in v do
				v5[k] = v6 // v7.seconds
				v6 %= v7.seconds
			end

			local v7 = leadingUnit(v4) -- equivalent call inferred; original call site unknown
			local formatted = `{v5[v7]}{v[v7].symbol}`
			local v8 = v7 + 1

			if v8 <= count and v5[v8] > 0 then
				formatted ..= ` {v5[v8]}{v[v8].symbol}`
			end

			return formatted
		end
	end
})