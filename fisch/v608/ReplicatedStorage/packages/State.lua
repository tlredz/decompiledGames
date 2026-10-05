local HttpService = game:GetService("HttpService")
local State = {}
State.__index = State

function State.new(p)
	return (setmetatable({
		value = p,
		callbacks = {}
	}, State))
end

function State:set(p)
	self.value = p

	for _, callback in self.callbacks do
		task.spawn(callback, self.value)
	end
end

function State:get()
	return self.value
end

function State:observe(callback, flag: boolean?)
	if flag then
		task.spawn(callback, self.value)
	end

	local GUID = HttpService:GenerateGUID(false)
	self.callbacks[GUID] = callback
	return function()
		self.callbacks[GUID] = nil
	end
end

function State:Set(p)
	self:set(p)
end

function State:Get()
	return self:get()
end

function State:Observe(p, flag: boolean?)
	return self:observe(p, flag)
end

return State