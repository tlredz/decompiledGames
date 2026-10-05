local RaceFormat = {
	FormatTime = function(p: number)
		local v = math.floor(p / 60)
		local v2 = math.floor(p % 60)
		local v3 = math.floor(p % 1 * 1000)
		return string.format("%02d:%02d.%03d", v, v2, v3)
	end
}

function RaceFormat.FormatDelta(p: number)
	return string.format("%s%s", p >= 0 and "+" or "-", RaceFormat.FormatTime((math.abs(p))))
end

return RaceFormat