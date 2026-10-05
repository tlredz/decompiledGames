local frozen = table.freeze({
	"",
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
	"Ocd",
	"Nod",
	"Vg",
	"Uvg",
	"Dvg",
	"Tvg"
})
local NumberUtils = {}

function NumberUtils.ToString(_, p: number, value: number?)
	local v = value or 1
	local v2 = math.floor((math.log(math.max(1, (math.abs(p))), 1000)))
	local v3 = frozen[v2 + 1] or "e+" .. v2
	local v4 = math.floor(p * (10 ^ v / 1000 ^ v2)) / 10 ^ v
	return string.format(`%.{v}f`, v4):gsub("%.?0+$", "") .. v3
end

function NumberUtils.Comma(_, p: number)
	local v = tostring((tonumber(string.format("%.3f", p))))

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

function NumberUtils.CommaRounded(_, p: number, p2: number)
	local v = tostring((tonumber(string.format(`%.{p2}f`, p))))

	while v:match("^(-?%d+)(%d%d%d)") do
		v = v:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	end

	return v
end

return NumberUtils