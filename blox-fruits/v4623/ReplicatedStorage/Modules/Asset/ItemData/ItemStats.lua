local ItemStats = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local module = require(moduleScript)

	for k, v in pairs(module) do
		ItemStats[k] = v
		module[k] = nil
	end
end

for _, v in pairs(ItemStats) do
	local v2 = {}

	for i = 0, 5 do
		if not (i ~= 0 or v[i]) then
			continue
		end

		local v3 = v[i]

		if not v3 then
			break
		end

		local v4 = v3[2]

		for k, v5 in pairs(v4) do
			if typeof(v5) == "table" then
				v2[k] = v2[k] or {}

				for k2, v6 in pairs(v5) do
					if v6 == 0 then
						v2[k][k2] = nil
					else
						v2[k][k2] = v6
					end
				end

				if next(v2[k]) == nil then
					v2[k] = nil
				end
			elseif v5 == 0 then
				v2[k] = nil
			else
				v2[k] = v5
			end
		end

		local v5 = {}

		for k, v6 in pairs(v2) do
			if typeof(v6) == "table" then
				v5[k] = {}

				for k2, v7 in pairs(v6) do
					v5[k][k2] = v7
				end
			else
				v5[k] = v6
			end
		end

		v[i][2] = v5

		if not (#v3[1] > 0 and v3[1][1]) then
			continue
		end

		local total = 1
		local v6 = {}

		while total < #v3[1] do
			local v7 = v3[1][total]
			local v8 = v3[1][total + 1]

			if not v8 then
				break
			end

			v6[v7] = v8
			total += 2
		end

		v[i][1] = v6
	end
end

return ItemStats