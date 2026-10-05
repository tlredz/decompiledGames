local random = Random.new()
local RandomModeler = {}

function RandomModeler.NormalizeWeights(items)
	local total = 0

	for _, item in items do
		total += item
	end

	if total <= 0 then
		return {}
	end

	local result = {}

	for k, item in items do
		result[k] = item / total
	end

	return result
end

function RandomModeler.WeightedChoose(items, value: number?)
	local total = 0

	for _, item in items do
		total += item
	end

	if total <= 0 then
		return nil
	end

	local v = value or 1

	if v <= 1 then
		local v2 = random:NextNumber() * total
		local total2 = 0
		local v3 = nil

		for k, item in items do
			total2 += item

			if v2 <= total2 then
				return k
			else
				v3 = k
			end
		end

		return v3
	else
		local result = {}

		for i = 1, v do
			local v2 = random:NextNumber() * total
			local total2 = 0
			local v3 = nil

			for k, item in items do
				total2 += item

				if v2 <= total2 then
					result[#result + 1] = k
					v3 = k
					break
				else
					v3 = k
				end
			end

			if #result < i then
				result[#result + 1] = v3
			end
		end

		return result
	end
end

function RandomModeler.EqualRoll(value, value2: number?)
	if type(value) == "string" then
		local v = value2 or 1

		if v < 1 and v < random:NextNumber() then
			return nil
		end

		return value
	else
		local result = {}

		for k, v in value do
			if random:NextNumber() < (value2 or v) then
				result[#result + 1] = k
			end
		end

		return result
	end
end

return RandomModeler