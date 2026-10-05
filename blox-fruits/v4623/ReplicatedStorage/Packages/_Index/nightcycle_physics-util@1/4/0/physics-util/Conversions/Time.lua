local v = {
	toMinute = function(p: number)
		return p / 60
	end,
	toHour = function(p: number)
		return p / 3600
	end,
	toDay = function(p: number)
		return p / 86400
	end
}

function v.toWeek(p: number)
	return v.toDay(p) / 7
end

function v.toYear(p: number)
	return v.toDay(p) / 365.25
end

function v.toDecade(p: number)
	return v.toYear(p) / 10
end

function v.toCentury(p: number)
	return v.toYear(p) / 100
end

function v.toMillenia(p: number)
	return v.toYear(p) / 1000
end

function v.toMicrosecond(p: number)
	return p * 1000000
end

function v.toMillisecond(p: number)
	return v.toMicrosecond(p) / 1000
end

function v.toPicosecond(p: number)
	return v.toMicrosecond(p) * 1000000
end

function v.toNanosecond(p: number)
	return v.toPicosecond(p) / 1000
end

function v.toRoblox(p: number)
	return p
end

local day = {
	toSecond = function(p: number)
		return p * 86400
	end
}

function day.toMinute(p: number)
	return v.toMinute(day.toSecond(p))
end

function day.toHour(p: number)
	return v.toHour(day.toSecond(p))
end

function day.toWeek(p: number)
	return v.toWeek(day.toSecond(p))
end

function day.toYear(p: number)
	return v.toYear(day.toSecond(p))
end

function day.toDecade(p: number)
	return v.toDecade(day.toSecond(p))
end

function day.toCentury(p: number)
	return v.toCentury(day.toSecond(p))
end

function day.toMillenia(p: number)
	return v.toMillenia(day.toSecond(p))
end

function day.toMicrosecond(p: number)
	return v.toMicrosecond(day.toSecond(p))
end

function day.toMillisecond(p: number)
	return v.toMillisecond(day.toSecond(p))
end

function day.toPicosecond(p: number)
	return v.toPicosecond(day.toSecond(p))
end

function day.toNanosecond(p: number)
	return v.toNanosecond(day.toSecond(p))
end

day.toRoblox = day.toSecond
local year = {
	toDay = function(p: number)
		return p * 365.25
	end
}

function year.toSecond(p: number)
	return day.toMinute(year.toDay(p))
end

function year.toMinute(p: number)
	return day.toMinute(year.toDay(p))
end

function year.toHour(p: number)
	return day.toHour(year.toDay(p))
end

function year.toWeek(p: number)
	return day.toWeek(year.toDay(p))
end

function year.toDecade(p: number)
	return day.toDecade(year.toDay(p))
end

function year.toCentury(p: number)
	return day.toCentury(year.toDay(p))
end

function year.toMillenia(p: number)
	return day.toMillenia(year.toDay(p))
end

function year.toMicrosecond(p: number)
	return day.toMicrosecond(year.toDay(p))
end

function year.toMillisecond(p: number)
	return day.toMillisecond(year.toDay(p))
end

function year.toPicosecond(p: number)
	return day.toPicosecond(year.toDay(p))
end

function year.toNanosecond(p: number)
	return day.toNanosecond(year.toDay(p))
end

year.toRoblox = year.toSecond
local microsecond = {
	toSecond = function(p: number)
		return p / 1000000
	end,
	toMillisecond = function(p: number)
		return p / 1000
	end
}

function microsecond.toMinute(p: number)
	return v.toMinute(microsecond.toSecond(p))
end

function microsecond.toHour(p: number)
	return v.toHour(microsecond.toSecond(p))
end

function microsecond.toDay(p: number)
	return v.toDay(microsecond.toSecond(p))
end

function microsecond.toWeek(p: number)
	return v.toWeek(microsecond.toSecond(p))
end

function microsecond.toYear(p: number)
	return v.toYear(microsecond.toSecond(p))
end

function microsecond.toDecade(p: number)
	return v.toDecade(microsecond.toSecond(p))
end

function microsecond.toCentury(p: number)
	return v.toCentury(microsecond.toSecond(p))
end

function microsecond.toMillenia(p: number)
	return v.toMillenia(microsecond.toSecond(p))
end

function microsecond.toPicosecond(p: number)
	return v.toPicosecond(microsecond.toSecond(p))
end

function microsecond.toNanosecond(p: number)
	return v.toNanosecond(microsecond.toSecond(p))
end

microsecond.toRoblox = microsecond.toSecond
local picosecond = {
	toMicrosecond = function(p: number)
		return p / 1000000
	end,
	toNanosecond = function(p: number)
		return p / 1000
	end
}

function picosecond.toSecond(p: number)
	return microsecond.toSecond(picosecond.toMicrosecond(p))
end

function picosecond.toMillisecond(p: number)
	return microsecond.toMillisecond(picosecond.toMicrosecond(p))
end

function picosecond.toMinute(p: number)
	return microsecond.toMinute(picosecond.toMicrosecond(p))
end

function picosecond.toHour(p: number)
	return microsecond.toHour(picosecond.toMicrosecond(p))
end

function picosecond.toDay(p: number)
	return microsecond.toDay(picosecond.toMicrosecond(p))
end

function picosecond.toWeek(p: number)
	return microsecond.toWeek(picosecond.toMicrosecond(p))
end

function picosecond.toYear(p: number)
	return microsecond.toYear(picosecond.toMicrosecond(p))
end

function picosecond.toDecade(p: number)
	return microsecond.toDecade(picosecond.toMicrosecond(p))
end

function picosecond.toCentury(p: number)
	return microsecond.toCentury(picosecond.toMicrosecond(p))
end

function picosecond.toMillenia(p: number)
	return microsecond.toMillenia(picosecond.toMicrosecond(p))
end

picosecond.toRoblox = picosecond.toSecond
local nanosecond = {
	toPicosecond = function(p: number)
		return p * 1000
	end
}

function nanosecond.toMicrosecond(p: number)
	return picosecond.toMicrosecond(nanosecond.toPicosecond(p))
end

function nanosecond.toSecond(p: number)
	return picosecond.toSecond(nanosecond.toPicosecond(p))
end

function nanosecond.toMillisecond(p: number)
	return picosecond.toMillisecond(nanosecond.toPicosecond(p))
end

function nanosecond.toMinute(p: number)
	return picosecond.toMinute(nanosecond.toPicosecond(p))
end

function nanosecond.toHour(p: number)
	return picosecond.toHour(nanosecond.toPicosecond(p))
end

function nanosecond.toDay(p: number)
	return picosecond.toDay(nanosecond.toPicosecond(p))
end

function nanosecond.toWeek(p: number)
	return picosecond.toWeek(nanosecond.toPicosecond(p))
end

function nanosecond.toYear(p: number)
	return picosecond.toYear(nanosecond.toPicosecond(p))
end

function nanosecond.toDecade(p: number)
	return picosecond.toDecade(nanosecond.toPicosecond(p))
end

function nanosecond.toCentury(p: number)
	return picosecond.toCentury(nanosecond.toPicosecond(p))
end

function nanosecond.toMillenia(p: number)
	return picosecond.toMillenia(nanosecond.toPicosecond(p))
end

nanosecond.toRoblox = nanosecond.toSecond
local millisecond = {
	toMicrosecond = function(p: number)
		return p * 1000
	end
}

function millisecond.toSecond(p: number)
	return microsecond.toMinute(millisecond.toMicrosecond(p))
end

function millisecond.toMinute(p: number)
	return microsecond.toMinute(millisecond.toMicrosecond(p))
end

function millisecond.toHour(p: number)
	return microsecond.toHour(millisecond.toMicrosecond(p))
end

function millisecond.toDay(p: number)
	return microsecond.toDay(millisecond.toMicrosecond(p))
end

function millisecond.toWeek(p: number)
	return microsecond.toWeek(millisecond.toMicrosecond(p))
end

function millisecond.toYear(p: number)
	return microsecond.toYear(millisecond.toMicrosecond(p))
end

function millisecond.toDecade(p: number)
	return microsecond.toDecade(millisecond.toMicrosecond(p))
end

function millisecond.toCentury(p: number)
	return microsecond.toCentury(millisecond.toMicrosecond(p))
end

function millisecond.toMillenia(p: number)
	return microsecond.toMillenia(millisecond.toMicrosecond(p))
end

function millisecond.toPicosecond(p: number)
	return microsecond.toPicosecond(millisecond.toMicrosecond(p))
end

function millisecond.toNanosecond(p: number)
	return microsecond.toNanosecond(millisecond.toMicrosecond(p))
end

millisecond.toRoblox = millisecond.toSecond
local minute = {
	toSecond = function(p: number)
		return p * 60
	end
}

function minute.toDay(p: number)
	return v.toDay(minute.toSecond(p))
end

function minute.toHour(p: number)
	return v.toHour(minute.toSecond(p))
end

function minute.toWeek(p: number)
	return v.toWeek(minute.toSecond(p))
end

function minute.toYear(p: number)
	return v.toYear(minute.toSecond(p))
end

function minute.toDecade(p: number)
	return v.toDecade(minute.toSecond(p))
end

function minute.toCentury(p: number)
	return v.toCentury(minute.toSecond(p))
end

function minute.toMillenia(p: number)
	return v.toMillenia(minute.toSecond(p))
end

function minute.toMicrosecond(p: number)
	return v.toMicrosecond(minute.toSecond(p))
end

function minute.toMillisecond(p: number)
	return v.toMillisecond(minute.toSecond(p))
end

function minute.toPicosecond(p: number)
	return v.toPicosecond(minute.toSecond(p))
end

function minute.toNanosecond(p: number)
	return v.toNanosecond(minute.toSecond(p))
end

minute.toRoblox = minute.toSecond
local hour = {
	toSecond = function(p: number)
		return p * 3600
	end
}

function hour.toDay(p: number)
	return v.toDay(hour.toSecond(p))
end

function hour.toMinute(p: number)
	return v.toMinute(hour.toSecond(p))
end

function hour.toWeek(p: number)
	return v.toWeek(hour.toSecond(p))
end

function hour.toYear(p: number)
	return v.toYear(hour.toSecond(p))
end

function hour.toDecade(p: number)
	return v.toDecade(hour.toSecond(p))
end

function hour.toCentury(p: number)
	return v.toCentury(hour.toSecond(p))
end

function hour.toMillenia(p: number)
	return v.toMillenia(hour.toSecond(p))
end

function hour.toMicrosecond(p: number)
	return v.toMicrosecond(hour.toSecond(p))
end

function hour.toMillisecond(p: number)
	return v.toMillisecond(hour.toSecond(p))
end

function hour.toPicosecond(p: number)
	return v.toPicosecond(hour.toSecond(p))
end

function hour.toNanosecond(p: number)
	return v.toNanosecond(hour.toSecond(p))
end

hour.toRoblox = hour.toSecond
local week = {
	toDay = function(p: number)
		return p * 7
	end
}

function week.toSecond(p: number)
	return day.toMinute(week.toDay(p))
end

function week.toMinute(p: number)
	return day.toMinute(week.toDay(p))
end

function week.toHour(p: number)
	return day.toHour(week.toDay(p))
end

function week.toYear(p: number)
	return day.toYear(week.toDay(p))
end

function week.toDecade(p: number)
	return day.toDecade(week.toDay(p))
end

function week.toCentury(p: number)
	return day.toCentury(week.toDay(p))
end

function week.toMillenia(p: number)
	return day.toMillenia(week.toDay(p))
end

function week.toMicrosecond(p: number)
	return day.toMicrosecond(week.toDay(p))
end

function week.toMillisecond(p: number)
	return day.toMillisecond(week.toDay(p))
end

function week.toPicosecond(p: number)
	return day.toPicosecond(week.toDay(p))
end

function week.toNanosecond(p: number)
	return day.toNanosecond(week.toDay(p))
end

week.toRoblox = week.toSecond
local millenia = {
	toYear = function(p: number)
		return p * 1000
	end
}

function millenia.toSecond(p: number)
	return year.toSecond(millenia.toYear(p))
end

function millenia.toMinute(p: number)
	return year.toMinute(millenia.toYear(p))
end

function millenia.toHour(p: number)
	return year.toHour(millenia.toYear(p))
end

function millenia.toWeek(p: number)
	return year.toWeek(millenia.toYear(p))
end

function millenia.toDecade(p: number)
	return year.toDecade(millenia.toYear(p))
end

function millenia.toCentury(p: number)
	return year.toCentury(millenia.toYear(p))
end

function millenia.toDay(p: number)
	return year.toDay(millenia.toYear(p))
end

function millenia.toMicrosecond(p: number)
	return year.toMicrosecond(millenia.toYear(p))
end

function millenia.toMillisecond(p: number)
	return year.toMillisecond(millenia.toYear(p))
end

function millenia.toPicosecond(p: number)
	return year.toPicosecond(millenia.toYear(p))
end

function millenia.toNanosecond(p: number)
	return year.toNanosecond(millenia.toYear(p))
end

millenia.toRoblox = millenia.toSecond
local decade = {
	toYear = function(p: number)
		return p * 10
	end
}

function decade.toMillenia(p: number)
	return year.toDecade(decade.toYear(p))
end

function decade.toSecond(p: number)
	return year.toSecond(decade.toYear(p))
end

function decade.toMinute(p: number)
	return year.toMinute(decade.toYear(p))
end

function decade.toHour(p: number)
	return year.toHour(decade.toYear(p))
end

function decade.toWeek(p: number)
	return year.toWeek(decade.toYear(p))
end

function decade.toCentury(p: number)
	return year.toCentury(decade.toYear(p))
end

function decade.toDay(p: number)
	return year.toDay(decade.toYear(p))
end

function decade.toMicrosecond(p: number)
	return year.toMicrosecond(decade.toYear(p))
end

function decade.toMillisecond(p: number)
	return year.toMillisecond(decade.toYear(p))
end

function decade.toPicosecond(p: number)
	return year.toPicosecond(decade.toYear(p))
end

function decade.toNanosecond(p: number)
	return year.toNanosecond(decade.toYear(p))
end

decade.toRoblox = decade.toSecond
local century = {
	toYear = function(p: number)
		return p * 100
	end
}

function century.toMillenia(p: number)
	return year.toMillenia(century.toYear(p))
end

function century.toSecond(p: number)
	return year.toSecond(century.toYear(p))
end

function century.toMinute(p: number)
	return year.toMinute(century.toYear(p))
end

function century.toHour(p: number)
	return year.toHour(century.toYear(p))
end

function century.toWeek(p: number)
	return year.toWeek(century.toYear(p))
end

function century.toDecade(p: number)
	return year.toDecade(century.toYear(p))
end

function century.toDay(p: number)
	return year.toDay(century.toYear(p))
end

function century.toMicrosecond(p: number)
	return year.toMicrosecond(century.toYear(p))
end

function century.toMillisecond(p: number)
	return year.toMillisecond(century.toYear(p))
end

function century.toPicosecond(p: number)
	return year.toPicosecond(century.toYear(p))
end

function century.toNanosecond(p: number)
	return year.toNanosecond(century.toYear(p))
end

century.toRoblox = century.toSecond
return {
	Millenia = millenia,
	Century = century,
	Decade = decade,
	Year = year,
	Week = week,
	Day = day,
	Hour = hour,
	Minute = minute,
	Second = v,
	Millisecond = millisecond,
	Microsecond = microsecond,
	Nanosecond = nanosecond,
	Picosecond = picosecond,
	Roblox = v
}