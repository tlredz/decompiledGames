local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	return {}
end

local RunService2 = game:GetService("RunService")
local bindableEvent

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	bindableEvent = Instance.new("BindableEvent")
	assert(bindableEvent, "bad bindable")
	bindableEvent.Event:Connect(function(callback, ...)
		callback(...)
	end)
else
	bindableEvent = nil
end

return (setmetatable({
	wrap = function(p)
		return function(...)
			assert(bindableEvent, "bad bindable")
			bindableEvent:Fire(p, ...)
		end
	end
}, {
	__call = function(_, ...)
		assert(bindableEvent, "bad bindable")
		bindableEvent:Fire(...)
	end
}))