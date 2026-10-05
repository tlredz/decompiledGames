return function(duration: number)
	local v

	if duration >= 0 then
		v = duration == duration
	else
		v = false
	end

	assert(v, "cooldown duration must be a non-negative number")
	local v2 = true
	return function(callback)
		if not v2 then
			return false
		end

		v2 = false
		task.delay(duration, function()
			v2 = true
		end)

		if callback then
			callback()
		end

		return true
	end
end