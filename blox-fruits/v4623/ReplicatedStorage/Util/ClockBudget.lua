local wait = task.wait
local clock = os.clock
return function(p: number, object)
	local v = p * 0.25
	local now = 0

	if object then
		return function(flag: boolean)
			local v2 = clock() - now
			local v3

			if flag then
				v3 = v
			else
				v3 = p
			end

			if v3 < v2 then
				object:Wait()
				now = clock()
				return true
			end
		end, function()
			now = clock()
			return true
		end
	end

	return function(flag: boolean)
		local v2 = clock() - now
		local v3

		if flag then
			v3 = v
		else
			v3 = p
		end

		if v3 < v2 then
			wait()
			now = clock()
			return true
		end
	end, function()
		now = clock()
		return true
	end
end