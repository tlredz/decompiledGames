local Workspace = game:GetService("Workspace")
local TimeService = {
	now = function()
		return Workspace:GetServerTimeNow()
	end,
	getDayKeyAt = function(p: number, p2: number, value: number?)
		return (math.floor((p + p2 - (value or 0) * 3600) / 86400))
	end
}

function TimeService.getDayKey(p: number, p2: number?)
	return TimeService.getDayKeyAt(TimeService.now(), p, p2)
end

function TimeService.getWeekBoundaryDayKeyAt(p: number, p2: number, p3: number?, value: number?)
	local v = value or 1
	local v2

	if v >= 1 and v <= 7 then
		v2 = v % 1 == 0
	else
		v2 = false
	end

	assert(v2, "resetWeekday 必须是周一=1到周日=7的整数")
	local dayKeyAt = TimeService.getDayKeyAt(p, p2, p3)
	return dayKeyAt - ((dayKeyAt + 3) % 7 - (v - 1)) % 7
end

function TimeService.getWeekKeyAt(p: number, p2: number, p3: number?, p4: number?)
	return (math.floor(TimeService.getWeekBoundaryDayKeyAt(p, p2, p3, p4) / 7))
end

function TimeService.getWeekKey(p: number, p2: number?, p3: number?)
	return TimeService.getWeekKeyAt(TimeService.now(), p, p2, p3)
end

function TimeService.configDateToDayKey(value)
	local v = tonumber(value)

	if v then
		return math.floor(v) - 25569
	end

	if typeof(value) == "string" then
		local v2, v3, v4 = string.match(value, "^(%d+)%D(%d+)%D(%d+)")

		if v2 then
			return DateTime.fromUniversalTime(tonumber(v2), tonumber(v3), (tonumber(v4))).UnixTimestamp // 86400
		end
	end

	return nil
end

function TimeService.configDateToDayKey(value)
	local v = tonumber(value)

	if v then
		return math.floor(v) - 25569
	end

	if typeof(value) == "string" then
		local v2, v3, v4 = string.match(value, "^(%d+)%D(%d+)%D(%d+)")

		if v2 then
			return DateTime.fromUniversalTime(tonumber(v2), tonumber(v3), (tonumber(v4))).UnixTimestamp // 86400
		end
	end

	return nil
end

function TimeService.formatCountdown(p: number)
	local v = math.max(0, (math.floor(p)))

	if v > 86400 then
		local v2 = v // 86400
		local v3 = v % 86400 // 3600

		if v3 == 0 then
			return string.format("%dd", v2)
		end

		return string.format("%dd %dh", v2, v3)
	elseif v > 3600 then
		local v2 = v // 3600
		local v3 = v % 3600 // 60

		if v3 == 0 then
			return string.format("%dh", v2)
		end

		return string.format("%dh %dm", v2, v3)
	else
		local v2 = v // 60
		local v3 = v % 60

		if v3 == 0 then
			return string.format("%dm", v2)
		end

		return string.format("%dm %ds", v2, v3)
	end
end

function TimeService.formatClock(p: number)
	local v = math.max(0, (math.floor(p)))
	local v2 = v // 3600
	local v3 = v % 3600 // 60
	local v4 = v % 60

	if v2 > 0 then
		return string.format("%d:%02d:%02d", v2, v3, v4)
	end

	return string.format("%02d:%02d", v3, v4)
end

return TimeService