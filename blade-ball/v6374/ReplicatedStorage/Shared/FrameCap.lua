return function(p: number)
	local v = {}
	return function(p2)
		local v2 = (v[p2] or 0) + 1
		v[p2] = v2

		if p <= v2 then
			v[p2] = nil
			task.wait()
		end
	end
end