local TimeUtil = {
	components = function(p)
		local v = math.floor(p / 86400)
		local v2 = p % 86400
		local v3 = math.floor(v2 / 3600)
		local v4 = v2 % 3600
		return v, v3, math.floor(v4 / 60), v4 % 60
	end
}
local v = {
	"D",
	"H",
	"M",
	"S"
}

function TimeUtil.formattedStrings(p, options)
	local v2 = options or {}
	local result = {}

	for k, v3 in pairs({ TimeUtil.components(p) }) do
		local v4 = v[k]
		local v5 = v2[k]

		if not v5 or v5(v3) then
			table.insert(result, v3 .. string.format("<font size=\"6\" color=\"rgb(230,230,230)\">%s</font>", v4))
		end
	end

	return result
end

function TimeUtil.formatTimeRemaining(p, p2)
	local components, v2, v3, v4 = TimeUtil.components(p)

	if p2 then
		return string.format("%02d:%02d:%02d:%02d", components, v2, v3, v4)
	end

	local v5 = v2 + components * 24
	return string.format("%02d:%02d:%02d", v5, v3, v4)
end

function TimeUtil.formatHoursMins(p)
	local components, v2, v3, _ = TimeUtil.components(p)
	local v4 = v2 + components * 24
	return string.format("%dhrs & %dmins", v4, v3)
end

function TimeUtil.dayInSeconds()
	return 86400
end

function TimeUtil.weekInSeconds()
	return TimeUtil.dayInSeconds() * 7
end

function TimeUtil.monthInSeconds()
	return TimeUtil.dayInSeconds() * 31
end

function TimeUtil.secondsUntilMidnight()
	return 86400 - os.time() % 86400
end

return TimeUtil