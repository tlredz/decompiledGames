local WaitScheduler = {}
WaitScheduler.__index = WaitScheduler

function WaitScheduler.new()
	local self = setmetatable({}, WaitScheduler)
	self._startTime = os.clock()
	self._elapsed = 0
	return self
end

function WaitScheduler:wait(p)
	self._elapsed += p
	local v = self._startTime + self._elapsed - os.clock()

	if v > 0 then
		task.wait(v)
	end
end

return WaitScheduler