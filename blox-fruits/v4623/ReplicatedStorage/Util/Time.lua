local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local TimeSpan = require(game.ReplicatedStorage.Util.TimeSpan)
local v = {
	UTC = 0,
	EST = -5,
	CST = -6,
	MST = -7,
	PST = -8
}
local v2 = {
	EST = true,
	CST = true,
	MST = true,
	PST = true
}

function roundToMillis(p: number)
	return math.floor(p * 1000) / 1000
end

function getUSDSTHourOffset(p: number, p2: number, p3: number, p4: number)
	if p2 < 3 or p2 > 11 then
		return 0
	end

	if p2 == 3 then
		if p == 2022 then
			if p3 > 13 then
				return 1
			end

			if p3 ~= 13 then
				return 0
			end
		elseif p == 2023 then
			if p3 > 12 then
				return 1
			end

			if p3 ~= 12 then
				return 0
			end
		elseif p == 2024 then
			if p3 > 10 then
				return 1
			end

			if p3 ~= 10 then
				return 0
			end
		elseif p == 2025 then
			if p3 > 9 then
				return 1
			end

			if p3 ~= 9 then
				return 0
			end
		elseif p == 2026 then
			if p3 > 8 then
				return 1
			end

			if p3 ~= 8 then
				return 0
			end
		elseif p == 2027 then
			if p3 > 14 then
				return 1
			end

			if p3 ~= 14 then
				return 0
			end
		elseif p == 2028 then
			if p3 > 12 then
				return 1
			end

			if p3 ~= 12 then
				return 0
			end
		elseif p == 2029 then
			if p3 > 11 then
				return 1
			end

			if p3 ~= 11 then
				return 0
			end
		elseif p == 2030 then
			if p3 > 10 then
				return 1
			end

			if p3 ~= 10 then
				return 0
			end
		elseif p == 2031 then
			if p3 > 9 then
				return 1
			end

			if p3 ~= 9 then
				return 0
			end
		else
			warn((`getUSDSTHourOffset does not support year {p}`))

			if p3 > 11 then
				return 1
			end

			if p3 ~= 11 then
				return 0
			end
		end

		if p4 >= 2 then
			return 1
		end

		return 0
	else
		if p2 ~= 11 then
			return 1
		end

		if p == 2022 then
			if p3 > 6 then
				return 0
			end

			if p3 ~= 6 then
				return 1
			end
		elseif p == 2023 then
			if p3 > 5 then
				return 0
			end

			if p3 ~= 5 then
				return 1
			end
		elseif p == 2024 then
			if p3 > 3 then
				return 0
			end

			if p3 ~= 3 then
				return 1
			end
		elseif p == 2025 then
			if p3 > 2 then
				return 0
			end

			if p3 ~= 2 then
				return 1
			end
		elseif p == 2026 then
			if p3 > 1 then
				return 0
			end

			if p3 ~= 1 then
				return 1
			end
		elseif p == 2027 then
			if p3 > 7 then
				return 0
			end

			if p3 ~= 7 then
				return 1
			end
		elseif p == 2028 then
			if p3 > 5 then
				return 0
			end

			if p3 ~= 5 then
				return 1
			end
		elseif p == 2029 then
			if p3 > 4 then
				return 0
			end

			if p3 ~= 4 then
				return 1
			end
		else
			if p == 2030 then
				if p3 > 3 then
					return 0
				end
			else
				warn((`getUSDSTHourOffset does not support year {p}`))

				if p3 >= 3 then
					return 0
				end
			end

			if p3 ~= 3 then
				return 1
			end
		end

		if p4 >= 2 then
			return 0
		end

		return 1
	end
end

local Time = {}
Time.__index = Time

function Time.__tostring(data)
	return (`Time<{data.Year}-{string.format("%0.2i", data.Month)}-{string.format("%0.2i", data.Day)} {string.format("%0.2i", data.Hour)}:{string.format("%0.2i", data.Minute)}:{string.format("%0.2i", data.Second)} {data.TimeZone.Type}>`)
end

function Time:ToTimeZone(p2: string)
	return Time._fromValue(self._Value, p2)
end

function Time:After(p2)
	return Time._fromValue(self._Value + p2.Value, self.TimeZone.Type)
end

function Time:Before(p2)
	return Time._fromValue(self._Value - p2.Value, self.TimeZone.Type)
end

function Time:Until(object)
	if object.TimeZone.Type ~= self.TimeZone.Type then
		object = object:ToTimeZone(self.TimeZone.Type)
	end

	local v3 = object._Value - self._Value

	if v3 < 0 then
		return nil
	end

	return TimeSpan.fromSeconds(v3)
end

function Time:Since(object)
	if object.TimeZone.Type ~= self.TimeZone.Type then
		object = object:ToTimeZone(self.TimeZone.Type)
	end

	local v3 = self._Value - object._Value

	if v3 < 0 then
		return nil
	end

	return TimeSpan.fromSeconds(v3)
end

function Time:ToOSTime()
	if self.TimeZone.Type == "UTC" then
		return self._Value
	end

	return self:ToTimeZone("UTC"):ToOSTime()
end

function Time:ToDateTimeUTC()
	if self.TimeZone.Type == "UTC" then
		return DateTime.fromUnixTimestampMillis(self._Value * 1000)
	end

	return self:ToTimeZone("UTC"):ToDateTimeUTC()
end

function Time.now(p: string)
	if p == "UTC" then
		return Time._fromValue(os.time(), "UTC")
	end

	return Time._fromValue(os.time(), "UTC"):ToTimeZone(p)
end

function Time.fromDateTime(p)
	return Time.fromOSTime(p.UnixTimestampMillis / 1000)
end

function Time._fromValue(p: number, p2: string)
	local v3 = roundToMillis(p)
	local uTCOffset = v[p2]

	if uTCOffset == nil then
		error((`Invalid time zone: "{p2}"`))
	end

	local dSTOffset

	if v2[p2] then
		local v6 = os.date("!*t", v3 + uTCOffset * 60 * 60)
		local year = v6.year
		local month = v6.month
		local day = v6.day
		local hour = v6.hour
		dSTOffset = getUSDSTHourOffset(year, month, day, hour)
	else
		dSTOffset = 0
	end

	local remainder = v3 % 1
	local v7 = os.date("!*t", v3 + uTCOffset * 60 * 60 + dSTOffset * 60 * 60)
	local self = setmetatable({
		TimeZone = {
			Type = p2,
			DSTOffset = dSTOffset,
			UTCOffset = uTCOffset
		},
		_Value = v3,
		Year = v7.year,
		Month = v7.month,
		Day = v7.day,
		Hour = v7.hour,
		Minute = v7.min,
		Second = v7.sec,
		Remainder = remainder
	}, Time)
	TableUtil.deepFreeze(self)
	return self
end

function Time.fromOSTime(p: number)
	return Time._fromValue(p, "UTC")
end

function Time.new(value: string?, value2: number?, value3: number?, value4: number?, value5: number?, value6: number?, value7: number?)
	local v3 = value or "UTC"
	local year = value2 or 1970
	local month = value3 or 1
	local day = value4 or 1
	local hour = value5 or 0
	local min = value6 or 0
	local v9 = value7 or 0
	assert(v3 and year and month and day and hour and min and v9, "bad params")
	local v10 = v9 % 1
	local sec = math.floor(v9)
	local v12 = v[v3]

	if v12 == nil then
		error((`Invalid time zone: "{v3}"`))
	end

	local v13 = not v2[v3] and 0 or getUSDSTHourOffset(year, month, day, hour)
	local v14 = os.time({
		year = year,
		month = month,
		day = day,
		hour = hour,
		min = min,
		sec = sec
	}) + v10
	return Time._fromValue(roundToMillis(v14 - v12 * 60 * 60 - v13 * 60 * 60), v3)
end

return Time