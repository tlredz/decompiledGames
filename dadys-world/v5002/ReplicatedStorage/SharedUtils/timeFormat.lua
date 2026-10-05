local TimeFormat = {
	format = function(value: number?, p: string, p2: number?)
		if type(value) ~= "number" or value <= 0 then
			return ""
		end

		local v = math.floor(value)

		if p2 == nil then
			return DateTime.fromUnixTimestamp(v):FormatLocalTime(p, "en-us")
		end

		return DateTime.fromUnixTimestamp(v + p2 * 3600):FormatUniversalTime(p, "en-us")
	end
}

function TimeFormat.unixToDate(p: number?, p2: number?)
	return TimeFormat.format(p, "M/D/YYYY", p2)
end

function TimeFormat.unixToTime(p: number?, p2: number?)
	return TimeFormat.format(p, "h:mm A", p2)
end

function TimeFormat.unixToDateOrTime(p: number?, p2: number?)
	local formatted = TimeFormat.format(os.time(), "M/D/YYYY", p2)
	local formatted2 = TimeFormat.format(p, "M/D/YYYY", p2)

	if formatted2 == "" or formatted2 ~= formatted then
		return TimeFormat.unixToDate(p, p2)
	end

	return TimeFormat.unixToTime(p, p2)
end

return TimeFormat