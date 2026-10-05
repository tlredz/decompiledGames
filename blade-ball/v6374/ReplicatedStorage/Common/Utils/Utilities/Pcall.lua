return table.freeze({
	pcallWithDelayedRetries = function(p: number?, duration: number?, callback, ...)
		if p == nil or p == 0 then
			return pcall(callback, ...)
		end

		local v = false
		local v2 = nil

		for _ = 1, p do
			v2 = { pcall(callback, ...) }
			v = v2[1]

			if v then
				break
			end

			if p > 0 and duration > 0 then
				task.wait(duration)
			end
		end

		return v, table.unpack(v2, 2)
	end
})