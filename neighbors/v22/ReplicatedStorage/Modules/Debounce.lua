local Debounce = {}

function Debounce.trailing(duration: number, callback)
	local thread = nil
	return function(...)
		if thread then
			pcall(task.cancel, thread)
		end

		thread = task.delay(duration, callback, ...)
	end
end

function Debounce.standard(duration: number, callback)
	local v = true
	return function(...)
		if not v then
			return
		end

		v = false
		callback(...)
		task.wait(duration)
		v = true
	end
end

return Debounce