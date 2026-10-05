return function(p, p2, p3)
	if p[p2] == nil then
		return p3
	end

	return p[p2]
end