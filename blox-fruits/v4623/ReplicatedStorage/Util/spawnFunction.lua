local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")

if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false then
	return function() end
end

local bindableEvent = Instance.new("BindableEvent", script)
bindableEvent.Event:Connect(function(callback, duration, ...)
	if duration then
		task.delay(duration, callback, ...)
	else
		task.spawn(callback, ...)
	end
end)
return function(p, p2, ...)
	bindableEvent:Fire(p, p2, ...)
end