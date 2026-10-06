return {
	Place = function(p, p2, p3, p4, p5, items)
		local v = p - p3 - 16
		local v2 = { v }
		local v3 = nil
		local v4 = nil

		for _, item in items do
			table.insert(v2, item.x - p3 - 12)
		end

		local v5 = { p5, 12, p2 - p4 - 12 }

		for _, item in items do
			table.insert(v5, item.y - p4 - 12)
			table.insert(v5, item.y + item.h + 12)
		end

		for _, v6 in v2 do
			for _, v7 in v5 do
				if not (v6 >= 12 and v6 + p3 <= p - 12 and v7 >= 12 and v7 + p4 <= p2 - 12) then
					continue
				end

				local flag = true

				for _, item in items do
					if not (v6 < item.x + item.w + 12 and v6 + p3 > item.x - 12 and v7 < item.y + item.h + 12 and v7 + p4 > item.y - 12) then
						continue
					end

					flag = false
					break
				end

				if not flag then
					continue
				end

				local v9 = math.abs(v6 - v) * 2 + math.abs(v7 - p5)

				if not (not v3 or v9 < v3) then
					continue
				end

				v3 = v9
				v4 = {
					x = v6,
					y = v7
				}
			end
		end

		return v4
	end
}