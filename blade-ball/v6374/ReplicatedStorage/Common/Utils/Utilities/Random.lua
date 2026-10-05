local random = Random.new()
local Random_2 = {}

function Random_2.NextValueFromDictionary(_, items)
	local v = {}

	for _, item in pairs(items) do
		v[#v + 1] = item
	end

	table.sort(v, function(a, b)
		return (a.Chance or 1) < (b.Chance or 1)
	end)
	local number = random:NextNumber()

	for _, v2 in pairs(v) do
		if number <= v2.Chance then
			return v2
		end
	end
end

function Random_2.NextValueFromTable(_, list)
	assert(#list > 0, "TABLE IS EMPTY!")
	local v = {}

	for _, v2 in pairs(list) do
		v[#v + 1] = v2
	end

	return v[random:NextInteger(1, #v)]
end

function Random_2:NextNumber(...)
	return random:NextNumber(...)
end

function Random_2:NextInteger(p, p2, ...)
	return random:NextInteger(p2 and p or not p2 and 1 or p2 - 1 or 1, p2 or p and p + 1 or 1, ...)
end

function Random_2.NextRangeNumber(_, p)
	return random:NextNumber() * p - p / 2
end

return Random_2