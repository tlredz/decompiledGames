local TimeUtil = {
	getUnitsOfTime = function(p: number)
		local day = math.floor(p / 86400)
		local v2 = p % 86400
		local hour = math.floor(v2 / 3600)
		local v4 = v2 % 3600
		return {
			Day = day,
			Hour = hour,
			Minute = math.floor(v4 / 60),
			Second = v4 % 60
		}
	end
}

function TimeUtil.formatUnits(p: number, items, value: string?)
	local unitsOfTime = TimeUtil.getUnitsOfTime(p)
	local v = {}

	for _, v2 in {
		{
			Seconds = 86400,
			Short = { "d" },
			Long = { "day" },
			Value = unitsOfTime.Day
		},
		{
			Seconds = 3600,
			Short = { "h" },
			Long = { "hour" },
			Value = unitsOfTime.Hour
		},
		{
			Seconds = 60,
			Short = { "m" },
			Long = { "minute" },
			Value = unitsOfTime.Minute
		},
		{
			Seconds = 1,
			Short = { "s" },
			Long = { "second" },
			Value = unitsOfTime.Second
		}
	} do
		local v3 = nil

		for _, item in items do
			if not (table.find(v2.Short, item) or table.find(v2.Long, item)) then
				continue
			end

			v3 = item
			break
		end

		if not v3 then
			continue
		end

		local value2 = v2.Value

		if not (value2 > 0 or #v > 0) then
			continue
		end

		local v5 = table.find(v2.Long, v3) ~= nil
		local v6

		if v5 then
			v6 = v2.Long[1]
		else
			v6 = v2.Short[1]
		end

		if v5 and value2 > 1 then
			v6 = `{v6}s`
		end

		if v5 then
			table.insert(v, (`{value2} {v6}`))
		else
			table.insert(v, (`{value2}{v6}`))
		end

		local _ = v2.Seconds > 1
	end

	return table.concat(v, value or " ")
end

function TimeUtil.format(value, p: string?, value2: string?)
	local v = {}
	local v2 = nil

	if typeof(value) == "number" then
		v2 = TimeUtil.getUnitsOfTime(value)
	elseif typeof(value) == "table" then
		v2 = value
	end

	local day = v2.Day or 0
	local hour = v2.Hour or 0
	local minute = v2.Minute or 0
	local second = v2.Second or 0

	if p == nil or p == "short" then
		if day > 0 then
			table.insert(v, (`{day}d`))
		end

		if hour > 0 then
			table.insert(v, (`{hour}h`))
		end

		if minute > 0 and day == 0 then
			table.insert(v, (`{minute}m`))
		end

		if second > 0 and minute == 0 then
			table.insert(v, (`{second}s`))
		end
	elseif p == "long" then
		if day > 0 then
			table.insert(v, (`{day} day{day > 1 and "s" or ""}`))
		end

		if hour > 0 then
			table.insert(v, (`{hour} hour{hour > 1 and "s" or ""}`))
		end

		if minute > 0 and day == 0 then
			table.insert(v, (`{minute} minute{minute > 1 and "s" or ""}`))
		end

		if second > 0 and minute == 0 then
			table.insert(v, (`{second} second{second > 1 and "s" or ""}`))
		end
	elseif p == "long_days_only" then
		if day > 0 then
			table.insert(v, (`{day} day{day > 1 and "s" or ""}`))
		end
	elseif p == "minimal" then
		if day > 0 then
			return string.format("%d:%02d:%02d:%02d", day, hour, minute, second)
		end

		if hour > 0 then
			return string.format("%02d:%02d:%02d", hour, minute, second)
		end

		if minute > 0 then
			return string.format("%02d:%02d", minute, second)
		end

		return string.format("00:%02d", second)
	end

	if #v > 0 then
		return table.concat(v, value2 or ", ")
	end

	return ""
end

function TimeUtil.ostimefromstamp(value: string, p: string?)
	local match, v, v2, v3, v4, v5 = value:match("(%d+)/(%d+)/(%d+) (%d+):(%d+) ([AMP]+)")
	local month = assert(tonumber(match), "month failed")
	local day = assert(tonumber(v), "day failed")
	local year = assert(tonumber(v2), "year failed")
	local v9 = assert(tonumber(v3), "hour failed")
	local min = assert(tonumber(v4), "minute failed")
	assert(v5)

	if v5 == "AM" then
		v9 %= 12
	elseif v5 == "PM" and v9 < 12 then
		v9 += 12
	end

	local v11 = p and p == "PST" and -8 or p and p == "EST" and -5 or 0
	local v12 = os.time({
		year = year,
		month = month,
		day = day,
		hour = v9 + -v11,
		min = min,
		sec = 0
	})
	return DateTime.fromUnixTimestamp(v12).UnixTimestamp
end

function TimeUtil.diffTime(p: number, p2: number?)
	return os.difftime(p, p2 or workspace:GetServerTimeNow())
end

function TimeUtil.timeUntil(value, p: string?)
	local v = nil

	if typeof(value) == "string" then
		v = TimeUtil.ostimefromstamp(value)
	elseif typeof(value) == "number" then
		v = value
	else
		error((`unknown input type: {typeof(value)}`))
	end

	local diffTime = TimeUtil.diffTime(v)

	if diffTime > 0 then
		return TimeUtil.format(TimeUtil.getUnitsOfTime(diffTime), p)
	end

	return nil
end

return TimeUtil