local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._last_fetch = tick()
	self._last_server_time = workspace:GetServerTimeNow()
	self:_Init()
	return self
end

function class:Get()
	if CONSTANTS.IS_SERVER then
		return (os.time())
	end

	return self._last_server_time + (tick() - self._last_fetch)
end

function class:GetRounded()
	if CONSTANTS.IS_SERVER then
		return (os.time())
	end

	return (math.floor(self:Get() + 0.5))
end

function class:WaitUntil(p)
	wait(p - self:Get())
end

function class:_Init() end

return class._new()