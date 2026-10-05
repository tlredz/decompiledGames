local RandomUtils = {}

function RandomUtils.RandomOnArray(_, list, value: number?, object)
	local v = 1 + (value or 0) / 3
	local v2 = {}
	local total = 0

	for i = 1, #list do
		local v3 = list[i] ^ (1 / v)
		table.insert(v2, v3)
		total += v3
	end

	local v3 = object and object:NextNumber(0, total) or Random.new():NextNumber(0, 1) * total
	local total2 = 0

	for i = 1, #v2 do
		total2 += v2[i]

		if v3 <= total2 then
			return i
		end
	end

	return nil
end

function RandomUtils.RandomOnDict(_, items, value: number?, object)
	local v = 1 + (value or 0) / 3
	local v2 = {}
	local total = 0

	for k, item in items do
		local v3 = item ^ (1 / v)
		v2[k] = v3
		total += v3
	end

	local v3 = object and object:NextNumber(0, total) or Random.new():NextNumber(0, 1) * total
	local total2 = 0

	for k, v4 in v2 do
		total2 += v4

		if v3 <= total2 then
			return k
		end
	end

	return nil
end

function RandomUtils.RandomOnArrayWithChance(_, list, value: number?, object)
	local v = 1 + (value or 0) / 3
	local v2 = {}
	local total = 0

	for i = 1, #list do
		local v3 = list[i].Chance ^ (1 / v)
		table.insert(v2, v3)
		total += v3
	end

	local v3 = object and object:NextNumber(0, total) or Random.new():NextNumber(0, 1) * total
	local total2 = 0

	for i = 1, #v2 do
		total2 += v2[i]

		if v3 <= total2 then
			return list[i]
		end
	end

	return nil
end

function RandomUtils.RandomOnArrayWithWeight(_, list, value: number?, object)
	local v = 1 + (value or 0) / 3
	local v2 = {}
	local total = 0

	for i = 1, #list do
		local v3 = list[i].weight ^ (1 / v)
		table.insert(v2, v3)
		total += v3
	end

	local v3 = object and object:NextNumber(0, total) or Random.new():NextNumber(0, 1) * total
	local total2 = 0

	for i = 1, #v2 do
		total2 += v2[i]

		if v3 <= total2 then
			return list[i], i
		end
	end

	return nil
end

function RandomUtils.GetPercentage(_, list, value: number?)
	local v = 1 + (value or 0) / 3
	local v2 = {}
	local total = 0

	for i = 1, #list do
		local v3 = list[i] ^ (1 / v)
		table.insert(v2, v3)
		total += v3
	end

	local result = {}

	for i = 1, #v2 do
		table.insert(result, v2[i] / total * 100)
	end

	return result
end

return RandomUtils