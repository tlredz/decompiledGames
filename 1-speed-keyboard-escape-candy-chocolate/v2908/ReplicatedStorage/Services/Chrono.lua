local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Chrono = {}
Chrono.__index = Chrono

function Chrono.new()
	return (setmetatable({
		_running = false,
		_startTime = 0,
		_elapsed = 0,
		_bestTime = nil,
		_history = {},
		_heartbeatConn = nil,
		Started = Signal.new(),
		Stopped = Signal.new(),
		NewBestTime = Signal.new()
	}, Chrono))
end

function Chrono:_stopHeartbeat()
	if self._heartbeatConn then
		self._heartbeatConn:Disconnect()
		self._heartbeatConn = nil
	end
end

function Chrono:Start()
	if self._running then
		return
	end

	self._running = true
	self._startTime = os.clock()
	self._elapsed = 0
	self._heartbeatConn = RunService.Heartbeat:Connect(function()
		self._elapsed = os.clock() - self._startTime
	end)
	self.Started:Fire(DateTime.now())
end

function Chrono:Stop()
	if not self._running then
		return {
			elapsed = self._elapsed,
			isPersonalBest = false,
			timestamp = os.time(),
			dateTime = DateTime.now()
		}
	end

	self._running = false
	self:_stopHeartbeat()
	self._elapsed = os.clock() - self._startTime
	local isPersonalBest = self._bestTime == nil or self._elapsed < self._bestTime

	if isPersonalBest then
		self._bestTime = self._elapsed
		self.NewBestTime:Fire(self._elapsed)
	end

	local now = DateTime.now()
	local v2 = {
		elapsed = self._elapsed,
		isPersonalBest = isPersonalBest,
		timestamp = os.time(),
		dateTime = now
	}
	table.insert(self._history, v2)
	self.Stopped:Fire(v2, now)
	return v2
end

function Chrono:Reset()
	self._running = false
	self:_stopHeartbeat()
	self._elapsed = 0
	self._startTime = 0
end

function Chrono:Destroy()
	self:_stopHeartbeat()
	self.Started:Destroy()
	self.Stopped:Destroy()
	self.NewBestTime:Destroy()
end

function Chrono:GetElapsed()
	return self._running and os.clock() - self._startTime or self._elapsed
end

function Chrono:GetBestTime()
	return self._bestTime
end

function Chrono:SetBestTime(bestTime: number)
	if self._bestTime == nil or bestTime < self._bestTime then
		self._bestTime = bestTime
	end
end

function Chrono:IsRunning()
	return self._running
end

function Chrono:GetSnapshot()
	return {
		running = self._running,
		elapsed = self:GetElapsed(),
		bestTime = self._bestTime,
		historyCount = #self._history
	}
end

function Chrono:GetHistory()
	return self._history
end

return Chrono