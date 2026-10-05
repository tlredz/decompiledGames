local v = {
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Od",
	"Nd",
	"V",
	"Uv",
	"Dv",
	"Tv",
	"Qav",
	"Qiv",
	"Sxv",
	"Spv",
	"Ov",
	"Nv",
	"Tt"
}
local v2 = {
	{ 100, "C" },
	{ 90, "XC" },
	{ 50, "L" },
	{ 40, "XL" },
	{ 10, "X" },
	{ 9, "IX" },
	{ 5, "V" },
	{ 4, "IV" },
	{ 1, "I" }
}
local v3 = {
	{ "s", 1 },
	{ "m", 60 },
	{ "h", 3600 },
	{ "d", 86400 },
	{ "w", 604800 },
	{ "mo", 2592000 }
}
local FormatNumber = {
	Percent = function(p, value)
		local v4 = 10 ^ (value or 0)
		return (`{math.floor(p * 100 * v4) / v4}%`)
	end,
	Commas = function(p)
		return tostring(p):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
	end
}
local v4 = {}

function FormatNumber.RomanNumerals(p)
	local v5 = math.floor(p)

	if v4[v5] then
		return v4[v5]
	end

	local v6 = ""

	while v5 > 0 do
		for i = 1, #v2 do
			local v7, v8 = unpack(v2[i])

			if not (v7 <= v5) then
				continue
			end

			v6 ..= v8
			v5 -= v7
			break
		end
	end

	if v5 < 100 then
		v4[v5] = v6
	end

	return v6
end

function FormatNumber.ShortClockString(p, list)
	local v5 = 1
	local v6 = "s"

	for _, v7 in v3 do
		local v8 = v7[2]

		if not (v8 < p and v5 < v8) then
			continue
		end

		v6 = v7[1]
		v5 = v8
	end

	local v7 = ""

	if list and table.find(list, v6) then
		local v8 = math.floor(p % v5 / v5 * 10)

		if v8 > 0 then
			v7 = "." .. v8
		end
	end

	return (`{math.floor(p / v5)}{v7}{v6}`)
end

function FormatNumber.Chance(p)
	if p > 10 or p > 1 then
		return FormatNumber.DecimalPlaces(p, 1) .. "%"
	end

	local match, v5 = FormatNumber.SigFigs(p, 1):match("(.+)e(.+)")

	if match and v5 then
		local v6 = tonumber(v5)
		local v7 = string.format("%.2f", match) * 100
		return (`0.{string.rep("0", (math.abs(v6)))}{string.format(v7)}`):gsub("([0%.]+)$", "") .. "%"
	else
		return FormatNumber.SigFigs(p, 1) .. "%"
	end
end

function FormatNumber.ToClockString(p)
	local v5 = tonumber(p)

	if v5 <= 0 then
		return "00:00:00"
	end

	local v6 = string.format("%02.f", (math.floor(v5 / 3600)))
	local v7 = string.format("%02.f", (math.floor(v5 / 60 - v6 * 60)))
	return v6 .. ":" .. v7 .. ":" .. string.format("%02.f", (math.floor(v5 - v6 * 3600 - v7 * 60)))
end

function FormatNumber.AdaptiveClockString(p: number, flag: boolean?, _: number)
	local v5 = math.max(p, 0)

	if flag and v5 < 60 or not flag and v5 <= 1 then
		return (`{math.floor(v5)}s`)
	end

	local v6 = false
	local v7 = ""
	local v8 = 1

	for i = #v3, 1, -1 do
		local v9 = v3[i]
		local v10 = v9[1]
		local v11 = v9[2]

		if not (v11 <= v5 or v6 or i <= v8) then
			continue
		end

		v6 = true
		local v12 = math.floor(v5 / v11)
		v5 %= v11

		if flag then
			v7 ..= string.format("%02.f", v12) .. ":"
		else
			v7 ..= v12 .. v10 .. " "
		end
	end

	return v7:sub(1, -2)
end

function FormatNumber.Short(p: number, p2)
	if p < 1000 then
		if p2 and p < 10 then
			return (tostring(FormatNumber.DecimalPlaces(p, 1)))
		end

		return (tostring((math.floor(p))))
	else
		local v5 = math.floor(p)
		local v6 = math.floor(math.floor((math.log10(v5))) / 3)
		return tostring(math.floor(v5 / 1000 ^ v6 * 100) / 100) .. v[v6]
	end
end

function FormatNumber.HHMMSS(p)
	local v5 = tonumber(p)

	if v5 <= 0 then
		return "00:00:00"
	end

	local v6 = math.floor(v5 / 3600)
	local v7 = math.floor(v5 / 60 - v6 * 60)
	local v8 = math.floor(v5 - v6 * 3600 - v7 * 60)
	return string.format("%02.f:%02.f:%02.f", v6, v7, v8)
end

function FormatNumber.SigFigs(p: number, p2: number)
	return string.format("%." .. p2 .. "g", p)
end

function FormatNumber.DecimalPlaces(p: number, p2: number)
	local v5 = 10 ^ p2
	return math.floor(p * v5) / v5
end

function FormatNumber.SigDP(p: number, value: number)
	local v6 = p % 1

	if v6 < 1e-6 then
		return (tostring((math.floor(p))))
	end

	return math.floor(p) .. "." .. FormatNumber.SigFigs(v6, value or 2):sub(3)
end

return FormatNumber