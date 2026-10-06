local random = Random.new()
local v = {
	GetChances = function(items, value: number, flag: boolean?)
		if not (type(items) == "table" and type(value) == "number") then
			return
		end

		local total = 0
		local v2 = {}
		local total2 = 0
		local result = {}

		for k, item in items do
			if not (type(item) == "table" and type(item.Name) == "string" and type(item.Chance) == "number") then
				continue
			end

			total += item.Chance
			table.insert(v2, {
				Name = item.Name,
				Chance = item.Chance,
				RealIndex = k
			})
		end

		for _, v3 in v2 do
			local v4 = 1 - v3.Chance / total
			local weight = v3.Chance * (value + 1) ^ (v4 * 0.4)
			v3.Weight = weight
			total2 += weight
		end

		table.sort(v2, function(a, b)
			return a.Weight < b.Weight
		end)

		for k, v3 in v2 do
			local chance = v3.Weight / total2 * 100

			if flag then
				result[v3.Name] = {
					Name = v3.Name,
					Chance = chance,
					Index = k,
					RealIndex = v3.RealIndex
				}
			else
				table.insert(result, {
					Name = v3.Name,
					Chance = chance,
					Index = k,
					RealIndex = v3.RealIndex
				})
			end
		end

		return result
	end
}

function v.Roll(p, p2: number)
	local chances = v.GetChances(p, p2)

	if not chances then
		return
	end

	local v2 = random:NextNumber() * 100
	local total = 0

	for _, chance in chances do
		total += chance.Chance

		if v2 <= total then
			return chance.Name, chance.RealIndex
		end
	end

	return nil, nil
end

function v.Run(value: number)
	if type(value) ~= "number" then
		return
	end

	if value < 0 or value > 100 then
		return
	else
		return random:NextNumber() * 100 <= value
	end
end

return table.freeze(v)