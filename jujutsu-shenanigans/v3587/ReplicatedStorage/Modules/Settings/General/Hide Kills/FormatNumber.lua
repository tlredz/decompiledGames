local function addCommas(p)
	local v = tostring(p)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

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
	"Dc"
}

local function abbreviate(p)
	local v2 = math.abs(p) * 1
	local v3 = 1

	while v2 >= 1000 and v3 < #v do
		v2 /= 1000
		v3 += 1
	end

	local v4 = string.format("%.2f", v2)
	local v5 = string.gsub(v4, "%.00$", "")
	local v6 = string.gsub(v5, "(%.%d)0$", "%1")

	if p < 0 then
		v6 = "-" .. v6
	end

	return v6 .. v[v3]
end

return {
	Format = function(p)
		return (addCommas(p))
	end
}