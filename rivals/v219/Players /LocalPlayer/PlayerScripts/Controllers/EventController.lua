local ReplicatedStorage = game:GetService("ReplicatedStorage")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._last_update = -1
	self._time_remaining = nil
	self:_Init()
	return self
end

function class:GetTimeRemaining()
	if self._time_remaining then
		return (math.max(0, (math.ceil(self._time_remaining - (tick() - self._last_update)))))
	end
end

function class:_UpdateTimer(time_remaining)
	self._last_update = tick()
	self._time_remaining = time_remaining
end

function class:_Fetch()
	self:_UpdateTimer(ReplicatedStorage.Remotes.Misc.RequestEventTimer:InvokeServer())
end

function class:_Init()
	ReplicatedStorage.Remotes.Misc.UpdateEventTimer.OnClientEvent:Connect(function(p)
		self:_UpdateTimer(p)
	end)
	task.defer(self._Fetch, self)
end

return class._new()