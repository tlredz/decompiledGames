local RunService = game:GetService("RunService")
local Signal = require(script.Parent.Signal)
local Timer = {}
Timer.__index = Timer

function Timer.new(interval: number)
	assert(type(interval) == "number", "argument #1 to Timer.new must be a number; got " .. type(interval))
	assert(interval >= 0, "argument #1 to Timer.new must be greater or equal to 0; got " .. tostring(interval))
	local self = setmetatable({}, Timer)
	self._runHandle = nil
	self.Interval = interval
	self.UpdateSignal = RunService.Heartbeat
	self.TimeFunction = time
	self.AllowDrift = true
	self.Tick = Signal.new()
	return self
end

function Timer.simple(p: number, callback, flag: boolean?, p2, callback2)
	local v = p2 or RunService.Heartbeat
	local v2 = callback2 or time
	local v3 = v2() + p

	if flag then
		task.defer(callback)
	end

	return v:Connect(function()
		local v4 = v2()

		if v3 <= v4 then
			v3 = v4 + p
			task.defer(callback)
		end
	end)
end

function Timer.is(p)
	return type(p) == "table" and getmetatable(p) == Timer
end

function Timer:_startTimer()
	local timeFunction = self.TimeFunction
	local v = timeFunction() + self.Interval
	self._runHandle = self.UpdateSignal:Connect(function()
		local v2 = timeFunction()

		if v <= v2 then
			v = v2 + self.Interval
			self.Tick:Fire()
		end
	end)
end

function Timer:_startTimerNoDrift()
	assert(self.Interval > 0, "interval must be greater than 0 when AllowDrift is set to false")
	local timeFunction = self.TimeFunction
	local v = 1
	local v2 = timeFunction()
	local v3 = v2 + self.Interval
	self._runHandle = self.UpdateSignal:Connect(function()
		local v4 = timeFunction()

		while v3 <= v4 do
			v += 1
			v3 = v2 + self.Interval * v
			self.Tick:Fire()
		end
	end)
end

function Timer:Start()
	if self._runHandle then
		return
	end

	if self.AllowDrift then
		self:_startTimer()
	else
		self:_startTimerNoDrift()
	end
end

function Timer:StartNow()
	if self._runHandle then
		return
	end

	self.Tick:Fire()
	self:Start()
end

function Timer:Stop()
	if not self._runHandle then
		return
	end

	self._runHandle:Disconnect()
	self._runHandle = nil
end

function Timer:IsRunning()
	return self._runHandle ~= nil
end

function Timer:Destroy()
	self.Tick:Destroy()
	self:Stop()
end

return Timer