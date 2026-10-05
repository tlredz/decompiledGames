local CONFIG = require(script.Parent:WaitForChild("CONFIG"))
local v = {
	en = "en-us",
	de = "de-de",
	es = "es-es",
	fr = "fr-fr",
	it = "it-it",
	ja = "ja-jp",
	pl = "pl-pl",
	["pt-br"] = "pt-br",
	pt = "pt-pt",
	tr = "tr-tr"
}
local v2 = nil

if CONFIG.IS_LUNE_ENV then
	local module = require("@lune/datetime")
	local class = {}
	class.__index = class

	function class:__tostring()
		return (`CompatDateTime<{self:formatIsoDate()}>`)
	end

	function class:formatUniversalTime(p2: string, p3: string)
		return module.fromUnixTimestamp(self.unixTimestampMillis / 1000):formatUniversalTime(p2, p3)
	end

	function class:formatLocalTime(p2: string, p3: string)
		return module.fromUnixTimestamp(self.unixTimestampMillis / 1000):formatLocalTime(p2, p3)
	end

	function class:formatIsoDate()
		return module.fromUnixTimestamp(self.unixTimestampMillis / 1000):toIsoDate()
	end

	function class.toUniveralTime(p)
		return module.fromUnixTimestamp(p.unixTimestampMillis / 1000):toUniversalTime()
	end

	function class.toLocalTime(p)
		return module.fromUnixTimestamp(p.unixTimestampMillis / 1000):toUniversalTime()
	end

	return {
		now = function()
			local now = module.now()
			return (setmetatable({
				unixTimestamp = now.unixTimestamp,
				unixTimestampMillis = now.unixTimestampMillis
			}, class))
		end,
		fromIsoDate = function(p: string)
			local v3 = module.fromIsoDate(p)
			return (setmetatable({
				unixTimestamp = v3.unixTimestamp,
				unixTimestampMillis = v3.unixTimestampMillis
			}, class))
		end,
		fromUnixTimestamp = function(p: number)
			local v3 = module.fromUnixTimestamp((math.round(p)))
			return (setmetatable({
				unixTimestamp = v3.unixTimestamp,
				unixTimestampMillis = v3.unixTimestampMillis
			}, class))
		end,
		fromUnixTimestampMillis = function(p: number)
			local v3 = module.fromUnixTimestamp(math.round(p) / 1000)
			return (setmetatable({
				unixTimestamp = v3.unixTimestamp,
				unixTimestampMillis = v3.unixTimestampMillis
			}, class))
		end,
		fromUniversalTime = function(year: number, month: number, day: number, hour: number, minute: number, second: number, millisecond: number)
			local v3 = module.fromUniversalTime({
				year = year,
				month = month,
				day = day,
				hour = hour,
				minute = minute,
				second = second,
				millisecond = millisecond
			})
			return (setmetatable({
				unixTimestamp = v3.unixTimestamp,
				unixTimestampMillis = v3.unixTimestampMillis
			}, class))
		end,
		fromLocalTime = function(year: number, month: number, day: number, hour: number, minute: number, second: number, millisecond: number)
			local v3 = module.fromLocalTime({
				year = year,
				month = month,
				day = day,
				hour = hour,
				minute = minute,
				second = second,
				millisecond = millisecond
			})
			return (setmetatable({
				unixTimestamp = v3.unixTimestamp,
				unixTimestampMillis = v3.unixTimestampMillis
			}, class))
		end
	}
else
	if not CONFIG.IS_RBX_ENV then
		error("Unsupported environment")
		return v2
	end

	local class = {}
	class.__index = class

	function class:__tostring()
		return (`CompatDateTime<{self:formatIsoDate()}>`)
	end

	function class:formatUniversalTime(p2: string, p3: string)
		return DateTime.fromUnixTimestampMillis(self.unixTimestampMillis):FormatUniversalTime(p2, v[p3])
	end

	function class:formatLocalTime(p2: string, p3: string)
		return DateTime.fromUnixTimestampMillis(self.unixTimestampMillis):FormatLocalTime(p2, v[p3])
	end

	function class:formatIsoDate()
		return DateTime.fromUnixTimestampMillis(self.unixTimestampMillis):ToIsoDate()
	end

	function toTimeMap(data)
		return {
			year = data.Year,
			month = data.Month,
			day = data.Day,
			hour = data.Hour,
			minute = data.Minute,
			second = data.Second,
			millisecond = data.Millisecond
		}
	end

	function class.toUniveralTime(p)
		return toTimeMap((DateTime.fromUnixTimestampMillis(p.unixTimestampMillis):ToUniversalTime()))
	end

	function class.toLocalTime(p)
		return toTimeMap((DateTime.fromUnixTimestampMillis(p.unixTimestampMillis):ToLocalTime()))
	end

	return {
		now = function()
			local now = DateTime.now()
			return (setmetatable({
				unixTimestampMillis = now.UnixTimestampMillis,
				unixTimestamp = now.UnixTimestamp
			}, class))
		end,
		fromIsoDate = function(p: string)
			local dateTime = DateTime.fromIsoDate(p)
			return (setmetatable({
				unixTimestampMillis = dateTime.UnixTimestampMillis,
				unixTimestamp = dateTime.UnixTimestamp
			}, class))
		end,
		fromUnixTimestamp = function(p: number)
			local dateTime = DateTime.fromUnixTimestamp((math.round(p)))
			return (setmetatable({
				unixTimestampMillis = dateTime.UnixTimestampMillis,
				unixTimestamp = dateTime.UnixTimestamp
			}, class))
		end,
		fromUnixTimestampMillis = function(p: number)
			local dateTime = DateTime.fromUnixTimestampMillis((math.round(p)))
			return (setmetatable({
				unixTimestampMillis = dateTime.UnixTimestampMillis,
				unixTimestamp = dateTime.UnixTimestamp
			}, class))
		end,
		fromUniversalTime = function(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
			local dateTime = DateTime.fromUniversalTime(p, p2, p3, p4, p5, p6, p7)
			return (setmetatable({
				unixTimestampMillis = dateTime.UnixTimestampMillis,
				unixTimestamp = dateTime.UnixTimestamp
			}, class))
		end,
		fromLocalTime = function(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
			local dateTime = DateTime.fromLocalTime(p, p2, p3, p4, p5, p6, p7)
			return (setmetatable({
				unixTimestampMillis = dateTime.UnixTimestampMillis,
				unixTimestamp = dateTime.UnixTimestamp
			}, class))
		end
	}
end