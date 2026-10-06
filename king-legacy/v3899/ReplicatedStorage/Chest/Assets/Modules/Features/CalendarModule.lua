local CalendarModule = {}
local _ = {
	"Sun",
	"Mon",
	"Tue",
	"Wed",
	"Thu",
	"Fri",
	"Sat"
}
local monthIndex = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}

function DaysInMonth(year, p2)
	local v2 = os.time({
		year = year,
		month = p2 + 1,
		day = 0
	})
	return (tonumber(os.date("%d", v2)))
end

function FirstWeekday(year, month)
	local v2 = os.time({
		year = year,
		month = month,
		day = 1
	})
	return tonumber(os.date("%w", v2)) + 1
end

function CalendarModule.BuildYear(year)
	local v2 = {
		Year = year,
		Months = {}
	}

	for i = 1, 12 do
		local v3 = DaysInMonth(year, i)
		local firstWeekday = FirstWeekday(year, i)
		local dates = {}

		for i2 = 1, v3 do
			local v6 = os.time({
				year = year,
				month = i,
				day = i2
			})
			table.insert(dates, {
				Day = i2,
				Weekday = tonumber(os.date("%w", v6)) + 1
			})
		end

		v2.Months[i] = {
			Index = i,
			MonthName = monthIndex[i],
			FirstWeekday = firstWeekday,
			Dates = dates
		}
	end

	return v2
end

function CalendarModule.BuildCurrentYear()
	local v2 = tonumber(os.date("!%Y"))
	return CalendarModule.BuildYear(v2)
end

function CalendarModule.GetCurrentMonth()
	return (tonumber(os.date("!%m")))
end

function CalendarModule.GetCurrentYear()
	return (tonumber(os.date("!%Y")))
end

CalendarModule.MonthIndex = monthIndex
return CalendarModule