local function retryPcall(p: number, duration: number?, callback, ...)
	local v = { false }

	for _ = 1, p do
		v = { pcall(callback, ...) }

		if v[1] then
			break
		end

		if duration and duration > 0 then
			task.wait(duration)
		end
	end

	return table.unpack(v)
end

return retryPcall