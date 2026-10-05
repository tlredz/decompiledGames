local ChanceWeightUtil = {}
ChanceWeightUtil.__index = ChanceWeightUtil
local random = Random.new()

function ChanceWeightUtil.Roll(p)
	local number = random:NextNumber(0, p.maxWeight)
	local total = 0

	for k, weight in p.weights do
		total += weight

		if number <= total then
			return k
		end
	end

	if p.maxWeight == 0 then
		return nil
	end

	error("bug")
end

function ChanceWeightUtil.Combine(p, items, p2)
	local v = {}

	for k, item in items do
		v[k] = item
	end

	for k, weight in p.weights do
		if not (p2 and v[k]) then
			v[k] = weight
		end
	end

	return ChanceWeightUtil.new(v)
end

function ChanceWeightUtil.new(weights)
	local v = {
		weights = weights,
		maxWeight = 0
	}

	for _, item in weights do
		assert(typeof(item) == "number")
		v.maxWeight += item
	end

	return (setmetatable(v, ChanceWeightUtil))
end

return ChanceWeightUtil