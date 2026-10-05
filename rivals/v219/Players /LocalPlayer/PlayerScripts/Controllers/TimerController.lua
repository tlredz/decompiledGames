local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.TimerUpdated = Signal.new()
	self._finish_times = {}
	self._step_callbacks = {}
	self:_Init()
	return self
end

function class:GetTimeRemaining(p2)
	if self._finish_times[p2] then
		return (math.max(0, (math.ceil(self._finish_times[p2] - tick()))))
	end

	return -1
end

function class:GetTimeRemainingFormatted(p)
	local timeRemaining = self:GetTimeRemaining(p)

	if timeRemaining == -1 then
		return "• • •"
	end

	return (Utility:TimeFormat2(timeRemaining))
end

function class:SetTimeRemaining(p2, p3)
	self._finish_times[p2] = tick() + p3
	self.TimerUpdated:Fire(p2)
end

function class:OnStep(p, p2, p3)
	self._step_callbacks[p] = p2 and p3 and { p2, p3 } or nil
	self:_Step(p)
end

function class:_Step(p)
	local _step_callback = self._step_callbacks[p]

	if not _step_callback then
		return
	end

	local success, result = pcall(
		_step_callback[2],
		self:GetTimeRemaining(_step_callback[1]),
		self:GetTimeRemainingFormatted(_step_callback[1])
	)

	if not success then
		warn("ON STEP CALLBACK ERRORED:", result)
	end
end

function class:_StepLoop()
	while true do
		for k in pairs(self._step_callbacks) do
			self:_Step(k)
		end

		wait(1)
	end
end

function class:_FetchTimers()
	self:SetTimeRemaining("TaskRefresh", ReplicatedStorage.Remotes.Misc.RequestTaskRefreshTimeRemaining:InvokeServer())
	self:SetTimeRemaining(
		"AdventCalendar",
		ReplicatedStorage.Remotes.Misc.RequestAdventCalendarTimeRemaining:InvokeServer()
	)
end

function class:_Init()
	ReplicatedStorage.Remotes.Misc.UpdateTaskRefreshTimeRemaining.OnClientEvent:Connect(function(p)
		self:SetTimeRemaining("TaskRefresh", p)
	end)
	ReplicatedStorage.Remotes.Misc.UpdateAdventCalendarTimeRemaining.OnClientEvent:Connect(function(p)
		self:SetTimeRemaining("AdventCalendar", p)
	end)
	task.spawn(self._StepLoop, self)
	task.spawn(self._FetchTimers, self)
end

return class._new()