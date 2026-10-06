local v = {
	[0] = "A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"+",
	"/"
}
local v2 = {
	[61] = 0,
	[65] = 0
}
local v3 = {}

for i, v4 in ipairs(v) do
	v2[string.byte(v4)] = i
end

for i = 0, 255 do
	v3[i] = string.char(i)
end

local B64 = {}

function B64.encode(value)
	local v4 = string.len(value)
	local v5 = table.create(math.ceil(v4 / 4) * 4)
	local total = 1

	for i = 1, v4, 3 do
		local v6, v7, v8 = string.byte(value, i, i + 2)
		local v9 = bit32.lshift(v6, 16) + bit32.lshift(v7 or 0, 8) + (v8 or 0)
		v5[total] = v[bit32.extract(v9, 18, 6)]
		v5[total + 1] = v[bit32.extract(v9, 12, 6)]
		v5[total + 2] = not v7 and "=" or v[bit32.extract(v9, 6, 6)] or "="
		v5[total + 3] = v8 and v[bit32.band(v9, 63)] or "="
		total += 4
	end

	return table.concat(v5)
end

function B64.decode(value)
	local v4 = string.len(value)
	local v5 = table.create(v4 * 0.75)
	local total = 1

	for i = 1, v4, 4 do
		local v6, v7, v8, v9 = string.byte(value, i, i + 3)
		local v10 = bit32.lshift(v2[v6], 18) + bit32.lshift(v2[v7], 12) + bit32.lshift(v2[v8], 6) + v2[v9]
		v5[total] = v3[bit32.extract(v10, 16, 8)]
		v5[total + 1] = v8 == "=" and "=" or v3[bit32.extract(v10, 8, 8)] or "="
		v5[total + 2] = v9 == "=" and "=" or v3[bit32.band(v10, 255)] or "="
		total += 3
	end

	return table.concat(v5)
end

return B64