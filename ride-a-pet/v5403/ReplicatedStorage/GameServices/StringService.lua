local StringService = {
	Suffixes = {
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
		"UDc",
		"DDc",
		"TDc",
		"QaDc",
		"QiDc",
		"SxDc",
		"SpDc",
		"OcDc",
		"NoDc",
		"Vg",
		"UVg",
		"DVg",
		"TVg",
		"QaVg",
		"QiVg",
		"SxVg",
		"SpVg",
		"OcVg",
		"NoVg",
		"Tg",
		"UTg",
		"DTg"
	},
	Decimals = 1
}

function StringService.Abbreviate(p, p2, p3)
	local v = tonumber(p) or 0
	local v2 = v < 0 and "-" or ""
	local v3 = math.abs(v)
	local v4 = p2 or StringService.Decimals

	if v3 < 1000 then
		if not p3 then
			return v2 .. tostring((math.floor(v3 + 0.5)))
		end

		local v5 = string.format("%." .. v4 .. "f", v3)

		if v4 > 0 then
			v5 = v5:gsub("0+$", ""):gsub("%.$", "")
		end

		return v2 .. v5
	else
		local suffixes = StringService.Suffixes
		local v5 = math.clamp(math.floor(math.log10(v3) / 3), 1, #suffixes)
		local v6 = string.format("%." .. v4 .. "f", v3 / 1000 ^ v5)

		if tonumber(v6) >= 1000 and v5 < #suffixes then
			v5 += 1
			v6 = string.format("%." .. v4 .. "f", v3 / 1000 ^ v5)
		end

		if v4 > 0 then
			v6 = v6:gsub("0+$", ""):gsub("%.$", "")
		end

		return v2 .. v6 .. suffixes[v5]
	end
end

function StringService.FormatOdds(p)
	return "1 in " .. StringService.Abbreviate(p)
end

function StringService.AddComma(p)
	local v = tonumber(p) or 0
	local v2 = v < 0 and "-" or ""
	local v3 = tostring((math.floor((math.abs(v)))))

	repeat
		local v4
		v3, v4 = v3:gsub("^(%d+)(%d%d%d)", "%1,%2")
	until v4 == 0

	return v2 .. v3
end

StringService.ShortenFrom = 1000000

function StringService.FormatCurrency(p)
	local v = tonumber(p) or 0
	local v2 = v < 0 and "-" or ""
	local v3 = math.abs(v)

	if v3 < StringService.ShortenFrom then
		return v2 .. "$" .. StringService.AddComma(v3)
	end

	return v2 .. "$" .. StringService.Abbreviate(v3)
end

return StringService