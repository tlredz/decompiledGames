require(game.ReplicatedStorage.Packages.Signal)
require(game.ReplicatedStorage.Util.Time)
local class = {}
class.__index = class

function class:ConnectUpdateLoop(callback, _: number?)
	local v = self:ConnectOnStart(function()
		callback(true)
	end)
	local v2 = self:ConnectOnFinish(function()
		callback(false)
	end)
	task.spawn(function()
		callback(self:GetIfActive())
	end)
	return function()
		v()
		v2()
	end
end

function class:ConnectOnStart(callback)
	local _StartDateTime = self._StartDateTime
	local now = DateTime.now()
	local v

	if _StartDateTime then
		v = (_StartDateTime.UnixTimestampMillis - now.UnixTimestampMillis) / 1000
	end

	if not v or v < 0 then
		return function() end
	end

	local thread = task.delay(v, function()
		callback()
	end)
	return function()
		task.cancel(thread)
	end
end

function class:ConnectOnFinish(callback)
	local _FinishDateTime = self._FinishDateTime
	local now = DateTime.now()
	local v

	if _FinishDateTime then
		v = (_FinishDateTime.UnixTimestampMillis - now.UnixTimestampMillis) / 1000
	end

	if not v or v < 0 then
		return function() end
	end

	local thread = task.delay(v, function()
		callback()
	end)
	return function()
		task.cancel(thread)
	end
end

function class:GetIfActive()
	local now = DateTime.now()
	local _FinishDateTime = self._FinishDateTime
	local _StartDateTime = self._StartDateTime

	if _FinishDateTime and _StartDateTime then
		return now.UnixTimestampMillis <= _FinishDateTime.UnixTimestampMillis and now.UnixTimestampMillis >= _StartDateTime.UnixTimestampMillis
	else
		if _FinishDateTime then
			return now.UnixTimestampMillis <= _FinishDateTime.UnixTimestampMillis
		end

		if _StartDateTime then
			return now.UnixTimestampMillis <= _StartDateTime.UnixTimestampMillis
		end

		return false
	end
end

function new(start, object2)
	local self = setmetatable({
		_IsAlive = true,
		Start = start,
		_StartDateTime = start and start:ToDateTimeUTC(),
		Finish = object2,
		_FinishDateTime = object2 and object2:ToDateTimeUTC()
	}, class)
	table.freeze(self)
	return self
end

local Scheduler = {}

function Scheduler.before(p)
	return new(nil, p)
end

function Scheduler.after(p)
	return new(p, nil)
end

function Scheduler.between(p, p2)
	return new(p, p2)
end

return Scheduler