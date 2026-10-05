local function reduce(list, callback, p, flag: boolean)
	local v = #list + 1

	for k, v2 in list do
		if flag then
			v2 = list[v - k]
		end

		p = callback(p, v2, k)
	end

	return p
end

return reduce