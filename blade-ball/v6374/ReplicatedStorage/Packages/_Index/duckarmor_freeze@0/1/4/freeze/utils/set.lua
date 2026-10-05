return function(p, p2, p3)
	if p[p2] == p3 then
		return p
	end

	local clone = table.clone(p)
	clone[p2] = p3
	return clone
end