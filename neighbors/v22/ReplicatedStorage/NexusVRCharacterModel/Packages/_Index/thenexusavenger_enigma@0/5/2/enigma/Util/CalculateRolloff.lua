return function(p: number, p2: number, p3: number)
	if p3 <= p then
		return p3
	end

	return p + math.min(p3 - p, p2) / 2
end