local Date = {}

function Date.ToHMS(_, p: number)
	local v = math.floor(p / 3600)
	local v2 = math.floor(p % 3600 / 60)
	local v3 = math.floor(p % 60)
	return string.format("%02d:%02d:%02d", v, v2, v3)
end

function Date.ToPhrase(_, p: number)
	local v = math.floor(p / 86400)
	local v2 = math.floor(p % 86400 / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = math.floor(p % 60)

	if v > 0 then
		return string.format("%02d:%02d:%02d:%02d", v, v2, v3, v4)
	end

	if v2 > 0 then
		return string.format("%02d:%02d:%02d", v2, v3, v4)
	end

	if v3 > 0 then
		return string.format("%02d:%02d", v3, v4)
	end

	return string.format("%02d", v4)
end

function Date.FormatDate(_, p: number)
	local v = os.time() - p

	if v < 60 then
		return v .. " seconds ago"
	end

	if v < 3600 then
		return math.floor(v / 60) .. " minutes ago"
	end

	if v < 86400 then
		return math.floor(v / 3600) .. " hours ago"
	end

	return (DateTime.fromUnixTimestamp(p):FormatLocalTime("L", "en-us"))
end

return Date