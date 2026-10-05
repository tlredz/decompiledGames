return {
	RandomFromWeightedTable = function(_, items)
		local total = 0

		for _, item in pairs(items) do
			total += item
		end

		local v = math.random(1, total)
		local total2 = 0

		for k, item in pairs(items) do
			total2 += item

			if v <= total2 then
				return k, item
			end
		end
	end
}