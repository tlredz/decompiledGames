local v = {
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
}
local NumberUtils = {}

function NumberUtils.ToString(_, p: number, value: number?)
	local v2 = value or 1
	local v3 = math.floor((math.log(math.max(1, (math.abs(p))), 1000)))
	local v4 = v[v3 + 1] or "e+" .. v3
	local v5 = math.floor(p * (10 ^ v2 / 1000 ^ v3)) / 10 ^ v2
	return ("%." .. v2 .. "f"):format(v5):gsub("%.?0+$", "") .. v4
end

function NumberUtils.Comma(_, p: number)
	local v2 = tostring(p)

	while v2:match("^(-?%d+)(%d%d%d)") do
		v2 = v2:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	end

	return v2
end

return NumberUtils