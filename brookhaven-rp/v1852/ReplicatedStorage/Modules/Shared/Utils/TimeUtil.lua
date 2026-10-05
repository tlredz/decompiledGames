local TimeUtil = {}
local HttpService = game:GetService("HttpService")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local v = {
	"🕛",
	"🕐",
	"🕑",
	"🕒",
	"🕓",
	"🕔",
	"🕕",
	"🕖",
	"🕗",
	"🕘",
	"🕙",
	"🕚"
}
local count = #v
local v2 = {
	Jan = 1,
	Feb = 2,
	Mar = 3,
	Apr = 4,
	May = 5,
	Jun = 6,
	Jul = 7,
	Aug = 8,
	Sep = 9,
	Oct = 10,
	Nov = 11,
	Dec = 12
}
local v3 = false
local now = nil
local now2 = nil
local v4 = nil

function TimeUtil.minutesToSeconds(p: number)
	return p * 60
end

function TimeUtil.secondsToMinutes(p: number)
	return p / 60
end

function TimeUtil.hoursToSeconds(p: number)
	return p * 3600
end

function TimeUtil.secondsToHours(p: number)
	return p / 3600
end

function TimeUtil.daysToSeconds(p: number)
	return p * 86400
end

function TimeUtil.secondsToDays(p: number)
	return p / 86400
end

function TimeUtil.weeksToSeconds(p: number)
	return p * 604800
end

function TimeUtil.secondsToWeeks(p: number)
	return p / 604800
end

function TimeUtil.monthsToSeconds(p: number)
	return p * 2592000
end

function TimeUtil.secondsToMonths(p: number)
	return p / 2592000
end

function TimeUtil.yearsToSeconds(p: number)
	return p * 31536000
end

function TimeUtil.secondsToYears(p: number)
	return p / 31536000
end

local function formatToTimeUnit(p: number)
	return string.format("%02i", p)
end

function TimeUtil.formatSecondsToMSMS(p: number)
	local v5 = math.floor((TimeUtil.secondsToMinutes(p)))
	math.round(p - TimeUtil.minutesToSeconds(v5))
end

function TimeUtil.formatSecondsToSS(p: number)
	return formatToTimeUnit(p)
end

function TimeUtil.formatSecondsToMS(p: number, value: string?, flag: boolean?)
	local v5 = math.floor((TimeUtil.secondsToHours(p)))
	local v6 = p - TimeUtil.hoursToSeconds(v5)
	local v7 = math.floor((TimeUtil.secondsToMinutes(v6)))
	local v8 = math.round(v6 - TimeUtil.minutesToSeconds(v7))
	return ("%s%s%s"):format(
		string.format("%02i", v7) .. (flag and "m" or ""),
		value or ":",
		string.format("%02i", v8) .. (flag and "s" or "")
	)
end

function TimeUtil.formatSecondsToHM(p: number)
	local v5 = math.floor((TimeUtil.secondsToHours(p)))
	local v6 = p - TimeUtil.hoursToSeconds(v5)
	local v7 = math.floor((TimeUtil.secondsToMinutes(v6)))
	return ("%sh:%sm"):format(string.format("%02i", v5), formatToTimeUnit(v7))
end

function TimeUtil.formatSecondsToMSString(p: number)
	local v5 = math.floor((TimeUtil.secondsToMinutes(p)))
	local v6 = math.round(p - TimeUtil.minutesToSeconds(v5))
	return ("%sm:%ss"):format(string.format("%02i", v5), formatToTimeUnit(v6))
end

function TimeUtil.formatSecondsToMSMicro(p: number)
	local v5 = math.floor((TimeUtil.secondsToMinutes(p)))
	local v6 = math.round(p - TimeUtil.minutesToSeconds(v5))
	return ("%s:%s"):format(string.format("%02i", v5), string.format("%.2f", v6))
end

function TimeUtil.formatSecondsToHMS(p: number)
	local v5 = math.floor((TimeUtil.secondsToHours(p)))
	local v6 = p - TimeUtil.hoursToSeconds(v5)
	local v7 = math.floor((TimeUtil.secondsToMinutes(v6)))
	local v8 = math.round(v6 - TimeUtil.minutesToSeconds(v7))
	return ("%sh %sm %ss"):format(string.format("%02i", v5), string.format("%02i", v7), formatToTimeUnit(v8))
end

function TimeUtil.formatSecondsToDHM(p: number)
	local v5 = math.floor((TimeUtil.secondsToDays(p)))
	local v6 = p - TimeUtil.daysToSeconds(v5)
	local v7 = math.floor((TimeUtil.secondsToHours(v6)))
	local v8 = v6 - TimeUtil.hoursToSeconds(v7)
	local v9 = math.floor((TimeUtil.secondsToMinutes(v8)))
	return ("%sd %sh %sm"):format(tostring(v5), string.format("%02i", v7), formatToTimeUnit(v9))
end

function TimeUtil.formatSecondsToDHMS(p: number)
	local v5 = math.floor((TimeUtil.secondsToDays(p)))
	local v6 = p - TimeUtil.daysToSeconds(v5)
	local v7 = math.floor((TimeUtil.secondsToHours(v6)))
	local v8 = v6 - TimeUtil.hoursToSeconds(v7)
	local v9 = math.floor((TimeUtil.secondsToMinutes(v8)))
	local v10 = math.round(v8 - TimeUtil.minutesToSeconds(v9))
	return ("%sd %sh %sm %ss"):format(
		tostring(v5),
		string.format("%02i", v7),
		string.format("%02i", v9),
		formatToTimeUnit(v10)
	)
end

function TimeUtil.formatSecondsToDays(p: number)
	local v5 = math.floor((TimeUtil.secondsToDays(p)))

	if v5 == 1 then
		return ("%s day"):format((tostring(1)))
	end

	return ("%s days"):format((tostring(v5)))
end

local function formatRelativeTime(p: number)
	local v5 = p < 0 and -1 or 1
	local v6 = math.abs(p)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function timeToString(p2: number, p3: string)
		local v7 = math.floor(p2) * v5
		return ("%d %s%s"):format(v7, p3, math.abs(v7) == 1 and "" or "s")
	end

	if v6 < 60 then
		return timeToString(math.floor(v6), "second"), 0, 1
	end

	if v6 < 3600 then
		local v7 = math.floor((TimeUtil.secondsToMinutes(v6)))
		return timeToString(v7, "minute"), (v6 - TimeUtil.minutesToSeconds(v7)) * v5, 2
	elseif v6 < 86400 then
		local v7 = math.floor((TimeUtil.secondsToHours(v6)))
		return timeToString(v7, "hour"), (v6 - TimeUtil.hoursToSeconds(v7)) * v5, 3
	elseif v6 < 2592000 then
		local v7 = math.floor((TimeUtil.secondsToDays(v6)))
		return timeToString(v7, "day"), (v6 - TimeUtil.daysToSeconds(v7)) * v5, 4
	elseif v6 < 31536000 then
		local v7 = math.floor((TimeUtil.secondsToMonths(v6)))
		return timeToString(v7, "month"), (v6 - TimeUtil.monthsToSeconds(v7)) * v5, 5
	else
		local v7 = math.floor((TimeUtil.secondsToYears(v6)))
		return timeToString(v7, "year"), (v6 - TimeUtil.yearsToSeconds(v7)) * v5, 6
	end
end

function TimeUtil.formatRelativeTime(p: number, value: number?)
	if p == 0 then
		return formatRelativeTime(p), 0
	end

	local v6 = 1e999
	local v7 = ""

	for i = 1, value or 1 or 1 do
		local v8, v9, v10 = formatRelativeTime(p)

		if v6 <= v10 then
			break
		end

		v7 = ("%s%s%s"):format(v7, i == 1 and "" or ", ", v8)
		v6 = v10
		p = v9
	end

	return v7, p
end

function TimeUtil.getClockEmoji(p: number, flag: boolean?)
	local v5 = math.floor(p) % count + 1

	if flag then
		v5 = count - (v5 - 1)
	end

	return v[v5]
end

local function RFC2616DateStringToUnixTimestamp(date: string)
	local match, v5, year, hour, min, sec = date:match(".*, (.*) (.*) (.*) (.*):(.*):(.*) .*")
	local v10 = {
		day = match,
		month = v2[v5],
		year = year,
		hour = hour,
		min = min,
		sec = sec
	}
	return os.time(v10)
end

function TimeUtil.getGoogleTime()
	if not RunService:IsServer() then
		error("Server only")
	end

	local function init()
		local success, result = pcall(function()
			local now3 = tick()
			now = RFC2616DateStringToUnixTimestamp(HttpService:RequestAsync({
				Url = "http://google.com"
			}).Headers.date)
			now2 = tick()
			v4 = (now2 - now3) / 2
			v3 = true
		end)

		if not success then
			warn(("Error requesting time from google.com (%s)"):format(result))
			now = os.time()
			now2 = tick()
			v4 = 0
		end
	end

	local function time()
		if not v3 then
			init()
		end

		return now + tick() - now2 - v4
	end

	if not v3 then
		init()
	end

	return now + tick() - now2 - v4
end

local now3 = os.time()
local v5 = os.date("!*t", now3)
os.time({
	year = v5.year,
	month = v5.month,
	day = v5.day + 1,
	hour = 0,
	min = 0,
	sec = 0
})

function TimeUtil.GetCurrentDate()
	return os.date("!*t", os.time())
end

function TimeUtil:GetNextDayStartTimestamp()
	self.day += 1
	return TimeUtil.GetCurrentDayStartTimestamp(self)
end

function TimeUtil.GetCurrentDayStartTimestamp(data)
	return os.time({
		year = data.year,
		month = data.month,
		day = data.day,
		hour = 0,
		min = 0,
		sec = 0
	})
end

function TimeUtil.getUnixTimestamp()
	return os.time()
end

function TimeUtil:MakeTimerFromText(max: number, text: string, callback)
	local heartbeatConnection = nil
	local total = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v6 = math.floor((math.clamp(max - total, 0, max)))

		if v6 <= 0 then
			self.Text = text
			heartbeatConnection:Disconnect()
		else
			self.Text = callback(v6)
		end
	end)
	return heartbeatConnection
end

function TimeUtil.serverAuthoritativeDateTimeNow()
	return DateTime.fromUnixTimestamp(Workspace:GetServerTimeNow())
end

return TimeUtil