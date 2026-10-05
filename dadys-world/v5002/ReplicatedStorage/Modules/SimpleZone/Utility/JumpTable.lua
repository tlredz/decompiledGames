return function(p)
	return function(p2, ...)
		local v = p[p2] or p._

		if v then
			return v(...)
		end
	end
end