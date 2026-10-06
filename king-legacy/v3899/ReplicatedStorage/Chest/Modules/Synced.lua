local v = {
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
local HttpService = game:GetService("HttpService")

local function RFC2616DateStringToUnixTimestamp(date)
	local match, v2, year, hour, min, sec = date:match(".*, (.*) (.*) (.*) (.*):(.*):(.*) .*")
	local v7 = {
		day = match,
		month = v[v2],
		year = year,
		hour = hour,
		min = min,
		sec = sec
	}
	return os.time(v7)
end

local v2 = false
local now = nil
local now2 = nil
local v3 = nil

local function init()
	if not v2 then
		if not pcall(function()
			local now3 = tick()
			now = RFC2616DateStringToUnixTimestamp(HttpService:RequestAsync({
				Url = "http://google.com"
			}).Headers.date)
			now2 = tick()
			v3 = (now2 - now3) / 2
		end) then
			warn("Cannot get time from google.com. Make sure that http requests are enabled!")
			now = os.time()
			now2 = tick()
			v3 = 0
		end

		v2 = true
	end
end

local Synced = {}

function Synced.inited()
	return v2
end

Synced.init = init

function Synced.time()
	if not v2 then
		init()
	end

	return now + tick() - now2 - v3
end

return Synced