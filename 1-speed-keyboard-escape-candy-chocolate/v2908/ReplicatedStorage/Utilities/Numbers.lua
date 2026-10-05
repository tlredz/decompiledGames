local Suffixes = require(script.Suffixes)
local Numbers = {}

function Numbers.formatNumber(p, value)
	local v = tonumber(p) or 0
	local v2 = "%." .. (value or 2) .. "f"

	for _, SUFFIX in ipairs(Suffixes.SUFFIXES) do
		local v3 = SUFFIX[1]
		local v4 = SUFFIX[2]

		if v3 <= v then
			return string.format(v2, v / v3):gsub("%.?0+$", "") .. v4
		end
	end

	return (tostring((math.floor(v))))
end

function Numbers.formatMultiplier(p)
	local v = tonumber(p) or 1

	for _, SUFFIX in ipairs(Suffixes.SUFFIXES) do
		local v2 = SUFFIX[1]
		local v3 = SUFFIX[2]

		if v2 <= v then
			return string.format("%.2f", v / v2):gsub("%.?0+$", "") .. v3
		end
	end

	if v == math.floor(v) then
		return (tostring((math.floor(v))))
	end

	return string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "")
end

function Numbers.formatComma(p)
	return tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

return Numbers