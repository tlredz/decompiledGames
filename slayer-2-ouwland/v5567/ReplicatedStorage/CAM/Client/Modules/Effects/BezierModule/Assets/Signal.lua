local Signal = {}
Signal.__index = Signal

function Signal.Create(_)
	return (setmetatable({}, Signal))
end

function Signal:Connect(p)
	self[1] = p
end

function Signal.Fire(list, ...)
	if not list[1] then
		return
	end

	local thread = coroutine.create(list[1])
	coroutine.resume(thread, ...)
end

function Signal:Delete()
	self[1] = nil
end

return Signal