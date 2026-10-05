return function(callback, ...)
	coroutine.running()
	local v = nil
	local thread = task.spawn(function(...)
		v = { callback(...) }
	end, ...)

	while coroutine.status(thread) ~= "dead" do
		local RunService = game:GetService("RunService")
		RunService.Heartbeat:Wait()
	end

	return v ~= nil, unpack(v)
end