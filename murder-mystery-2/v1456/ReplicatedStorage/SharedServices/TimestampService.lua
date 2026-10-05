local TimestampService = {}

function TimestampService.GetCurrentDayPST(_)
	local now = DateTime.now()
	now:ToUniversalTime()
	local v = now.UnixTimestamp + -28800
	local universalTime = DateTime.fromUnixTimestamp(v):ToUniversalTime()
	return DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day, 0, 0, 0, 0).UnixTimestamp - -28800
end

function TimestampService.GetCurrentPeriodStartPST(_, p: number, value: number?)
	local v = DateTime.now().UnixTimestamp + -28800
	local v2 = (value or 0) + -28800
	local v3 = v2 - v2 % 86400
	local v4 = v - v3
	return v3 + (v4 - v4 % p) - -28800
end

function TimestampService.GetCurrentDayUTC(_)
	local universalTime = DateTime.now():ToUniversalTime()
	return DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day, 0, 0, 0, 0).UnixTimestamp
end

function TimestampService.FormatTimeLeftInSeconds(_, p: number)
	local v = math.floor(p / 3600)
	local v2 = math.floor(p % 3600 / 60)
	local v3 = p % 60

	if v > 0 then
		return string.format("%dh, %dm", v, v2)
	end

	if v2 > 0 then
		return string.format("%dm", v2)
	end

	return string.format("%ds", v3)
end

function TimestampService.GetTimeLeftText(_, p: number)
	local v = math.floor(p / 86400)
	local v2 = math.floor(p % 86400 / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = math.floor(p % 60)

	if v > 0 then
		return (string.format("%dd, %dh, %dm", v, v2, v3))
	end

	if v2 > 0 then
		return (string.format("%dh, %dm", v2, v3))
	end

	if v3 > 0 then
		if v3 <= 5 then
			return (string.format("%dm, %ds", v3, v4))
		end

		return (string.format("%dm", v3))
	else
		return (string.format("%ds", v4))
	end
end

function TimestampService.GetLeaderboardTimeText(_, p)
	local v = math.floor(p / 86400)
	local v2 = math.floor(p % 86400 / 3600)
	local v3 = v .. "d, " .. v2 .. "h"

	if v < 1 then
		local v4 = v2 .. "h"
		v3 = v2 == 1 and "Less than 2 hours" or v4
	end

	local v4 = p <= 3600 and "Less than 1 hour!" or v3
	return p <= 0 and "ENDED!" or v4
end

return TimestampService