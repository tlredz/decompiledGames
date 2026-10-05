return function(list)
	table.sort(list, function(a, b)
		return b < a
	end)
	local total = 0

	for _, v in list do
		total += v
	end

	local v = total * math.random()

	for k, v2 in list do
		v -= v2

		if v <= 0 then
			return k
		end
	end
end