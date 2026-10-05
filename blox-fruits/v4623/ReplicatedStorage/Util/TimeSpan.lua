local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local TimeSpan = {}
TimeSpan.__index = TimeSpan

function TimeSpan.__tostring(p)
	return (`TimeSpan<{p.Value}s>`)
end

function TimeSpan.ToSeconds(p)
	return {
		Seconds = math.round(p.Value),
		Remainder = p.Value % 1
	}
end

function TimeSpan.ToMinutes(p)
	local value = p.Value
	local minutes = math.floor(value / 60)
	return {
		Minutes = minutes,
		Seconds = value - minutes * 60,
		Remainder = p.Value % 1
	}
end

function TimeSpan.ToHours(p)
	local value = p.Value
	local hours = math.floor(value / 3600)
	local minutes = math.floor((value - hours * 60 * 60) / 60)
	return {
		Hours = hours,
		Minutes = minutes,
		Seconds = value - hours * 60 * 60 - minutes * 60,
		Remainder = p.Value % 1
	}
end

function TimeSpan.ToDays(p)
	local value = p.Value
	local days = math.floor(value / 86400)
	local hours = math.floor((value - days * 24 * 60 * 60) / 3600)
	local minutes = math.floor((value - days * 24 * 60 * 60 - hours * 60 * 60) / 60)
	return {
		Days = days,
		Hours = hours,
		Minutes = minutes,
		Seconds = value - days * 24 * 60 * 60 - hours * 60 * 60 - minutes * 60,
		Remainder = p.Value % 1
	}
end

function TimeSpan.fromSeconds(p: number)
	local self = setmetatable({
		Value = p
	}, TimeSpan)
	TableUtil.deepFreeze(self)
	return self
end

function TimeSpan.fromMinutes(p: number)
	return TimeSpan.fromSeconds(p * 60)
end

function TimeSpan.fromHours(p: number)
	return TimeSpan.fromSeconds(p * 60 * 60)
end

function TimeSpan.fromDays(p: number)
	return TimeSpan.fromSeconds(p * 24 * 60 * 60)
end

return TimeSpan