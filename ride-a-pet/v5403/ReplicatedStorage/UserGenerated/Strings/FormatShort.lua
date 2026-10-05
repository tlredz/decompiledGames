local v = {
	"k",
	"m",
	"b",
	"t",
	"q",
	"Qt",
	"Sx",
	"Sp",
	"o",
	"n",
	"d",
	"u",
	"Du",
	"Tr"
}

local function FormatAbbreviated(value: number, value2: number?, value3: number?)
	assert(type(value) == "number")
	assert(value2 == nil or type(value2) == "number")
	assert(value3 == nil or type(value3) == "number")

	if value ~= value then
		return "NaN"
	end

	if value == 1e999 then
		return "Infinity"
	elseif value == -1e999 then
		return "-Infinity"
	end

	local v2 = value2 or 3
	local v3 = math.max(math.abs(value), (math.pow(10, -#v * 3)))
	local v4 = 10 ^ (math.min(math.ceil((math.log10(v3))), #v * 3 + v2) - (value3 or 0) - v2)
	local v5 = math.round(v3 / v4) * v4
	local v6 = math.min(math.floor(math.log10((math.max(v5, 1))) / 3), #v)
	local v7 = v5 * math.sign(value) / 10 ^ (v6 * 3)
	local v8 = string.format("%f", v7):gsub("%.?0+$", "")

	if v6 >= 1 then
		return v8 .. v[v6]
	end

	return v8
end

return FormatAbbreviated