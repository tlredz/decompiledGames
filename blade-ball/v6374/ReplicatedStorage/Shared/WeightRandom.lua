local function getWeights(p, p2: number?, value: number?)
	local clone = table.clone(p)
	local total = 0

	for _, v in clone do
		total += v
	end

	local universalLuck = tonumber(workspace:GetAttribute("UniversalLuck"))

	if universalLuck then
		if p2 then
			p2 += universalLuck
		else
			p2 = universalLuck
		end
	end

	if p2 and p2 > 0 then
		local v = value or 0.1

		for k, v2 in clone do
			if v2 / total <= v then
				clone[k] += v2 * p2
			end
		end
	end

	local count = 0
	local total2 = 0
	local options = {}
	local relativeWeights = {}

	for k, v3 in clone do
		count += 1
		total2 += v3
		options[count] = k
		relativeWeights[count] = v3
	end

	for i = 1, count do
		relativeWeights[i] /= total2
	end

	return table.freeze({
		relativeWeights = relativeWeights,
		options = options,
		n = count
	})
end

local function random(p: number?)
	if p then
		return (Random.new(p):NextNumber())
	end

	return (math.random())
end

local function weightedProbability(p, p2: number?, p3: number?, _: number?)
	local weights, v = getWeights(p, p2, p3)
	return function(p4: number?)
		if not p4 then
			local v2 = v

			if v2 then
				p4 = Random.new(v2):NextNumber()
			else
				p4 = math.random()
			end
		end

		for i = 1, weights.n do
			p4 -= weights.relativeWeights[i]

			if p4 < 0 then
				return weights.options[i]
			end
		end

		return weights.options[weights.n]
	end
end

return table.freeze({
	getWeights = getWeights,
	getPicker = weightedProbability,
	getPickerFromWeights = function(data, p: number?)
		return function(p2: number?)
			if not p2 then
				local v = p

				if v then
					p2 = Random.new(v):NextNumber()
				else
					p2 = math.random()
				end
			end

			for i = 1, data.n do
				p2 -= data.relativeWeights[i]

				if p2 < 0 then
					return data.options[i]
				end
			end

			return data.options[data.n]
		end
	end,
	applyDistributedWeights = function(p)
		local clone = table.clone(p)
		local clone2 = table.clone(clone.relativeWeights)
		clone.relativeWeights = clone2
		local total = 0

		for k, v in clone2 do
			local v2 = math.floor(v * 10000) / 10000
			clone2[k] = v2
			total += v2
		end

		local v = 1 - total

		if not (v > 0) then
			return table.freeze(clone)
		end

		local v2 = nil
		local v3 = nil

		for k, v4 in clone2 do
			if not (not v2 or v2 < v4) then
				continue
			end

			v3 = k
			v2 = v4
		end

		if v3 then
			clone2[v3] += v
		end

		return table.freeze(clone)
	end
})