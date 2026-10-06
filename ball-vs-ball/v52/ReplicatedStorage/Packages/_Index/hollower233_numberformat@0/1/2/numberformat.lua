local floor = math.floor
local log = math.log

local function trim(value: string, value2: string?)
	local v = value2 or "%s*"
	return value:match("^" .. v .. "(.-)" .. v .. "$") or value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function capitalize(value: string)
	return value:sub(1, 1):upper() .. value:sub(2)
end

local values = {}

local function createCaseInsensitiveRegex(items)
	local v = values[items]

	if v then
		return v
	end

	local v2 = {}

	for _, item in items do
		table.insert(v2, (item:gsub("%a", function(value: string)
			return string.format("(%s%s)", value:upper(), value:lower())
		end)))
	end

	local joined = table.concat(v2, "|")
	values[items] = joined
	return joined
end

local Numberformat = {
	commaFormat = function(p, p2: number?, value: string?, value2: string?)
		local v = value or ","
		local v2 = value2 or "."
		local v3 = tostring(p)

		if p2 ~= nil then
			local v4 = tonumber(p)

			if v4 ~= nil and v4 < p2 then
				return v3
			end
		end

		local match, v4 = v3:match("([^%" .. v2 .. "]+)%" .. v2 .. "?(.*)")
		local reversed = (match or v3):reverse():gsub("(%d%d%d)", "%1" .. v):reverse()

		if reversed:sub(1, 1) == v then
			reversed = reversed:sub(2)
		end

		if v4 ~= nil and v4 ~= "" then
			reversed ..= v2 .. v4
		end

		return reversed
	end
}
local defaultSuffixes = {
	"K",
	"M",
	"B",
	"T",
	"Qd",
	"Qt",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"Udc",
	"Ddc",
	"Tdc",
	"Qdc",
	"Qnd",
	"Sxd",
	"Spd",
	"Ocd",
	"Nvd",
	"Vg",
	"Uvg",
	"Dvg",
	"Tvg",
	"Qvg",
	"Qnv",
	"Sxv",
	"Spv",
	"Ocv",
	"Nvv",
	"Tg",
	"Utg",
	"G"
}
createCaseInsensitiveRegex(defaultSuffixes)
Numberformat.defaultSuffixes = defaultSuffixes

function Numberformat.abbreviate(p: number, value: number?, p2)
	if p < (value or 1000) then
		return Numberformat.commaFormat(p)
	end

	local v4 = floor((log(p, 1000))) - 1
	local v5 = 10 ^ ((v4 + 1) * 3)
	return string.format("%.3f", p / v5):gsub("%.?0+$", "") .. (v4 < 0 and "" or (p2 or defaultSuffixes)[v4 + 1])
end

function Numberformat.parseAbbreviated(value: string, p)
	local v2 = p or defaultSuffixes
	local caseInsensitiveRegex = createCaseInsensitiveRegex(v2)
	local v3 = value:gsub(",", "")
	local match, v4 = (v3:match("^%s*(.-)%s*$") or v3):match("^([0-9,.]+)([(" .. caseInsensitiveRegex .. ")]?)$")

	if match == nil then
		error("[NumberFormat]: Invalid suffixed number format")
	end

	local v5 = tonumber(match)

	if v5 == nil then
		error("[NumberFormat]: Invalid suffixed number format")
	end

	if v4 == nil or v4 == "" then
		return v5
	end

	local index = table.find(v2, capitalize(v4:lower()))

	if index ~= nil then
		return v5 * 10 ^ (index * 3)
	end

	return v5
end

local v2 = {
	s = 1,
	second = 1,
	seconds = 1,
	m = 60,
	minute = 60,
	minutes = 60,
	h = 3600,
	hour = 3600,
	hours = 3600,
	d = 86400,
	day = 86400,
	days = 86400,
	w = 604800,
	week = 604800,
	weeks = 604800
}

function Numberformat.toSeconds(value: string)
	local v3 = tonumber(value)

	if v3 ~= nil then
		return v3
	end

	local total = 0

	for k, v4 in value:gsub(" ", ""):gmatch("(%d+)(%a)") do
		local v5 = v2[v4]

		if v5 ~= nil then
			total += tonumber(k) * v5
		end
	end

	return total
end

function Numberformat.toRemainingTime(p: number, value: string?, value2: string?, value3: string?, value4: string?)
	local v3 = value or "%ds"
	local v4 = value2 or "%dm"
	local v5 = value3 or "%dh"
	local v6 = value4 or "%dd"
	local v8 = floor(p / 86400)
	local v9 = p % 86400
	local v11 = floor(v9 / 3600)
	local v12 = v9 % 3600
	local v14 = floor(v12 / 60)
	local v15 = v12 % 60
	local v16 = ""

	if v8 > 0 then
		v16 ..= string.format(v6 .. " ", v8)
	end

	if v11 > 0 then
		v16 ..= string.format(v5 .. " ", v11)
	end

	if v14 > 0 then
		v16 ..= string.format(v4 .. " ", v14)
	end

	if v15 > 0 then
		v16 ..= string.format(v3 .. " ", v15)
	end

	return v16:match("^%s*(.-)%s*$") or v16
end

function Numberformat.toLongRemainingTime(p: number)
	local v4 = floor(p / 3600)
	local v6 = floor(p % 3600 / 60)
	local v7 = p % 60
	return string.format("%02d:%02d:%02d", v4, v6, v7)
end

return Numberformat