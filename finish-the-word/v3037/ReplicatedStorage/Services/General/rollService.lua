local function roll(list)
	local v = math.random(1, 1000)
	local total = 0

	for _, v2 in ipairs(list) do
		total += v2.Rate

		if not (total < v) then
			return v2.Id
		end
	end

	warn("roll completed without matching anything", total, v)
end

local function buildRollSet(pets)
	local result = {}

	for k, item in pairs(pets) do
		table.insert(result, {
			Rate = item * 1000,
			Id = k
		})
	end

	table.sort(result, function(a, b)
		return a.Rate < b.Rate
	end)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetHardPity(state)
	state.Hard = 0
	state.Soft = 0
	state.SoftGuaranteed = false
end

local function rollSoft(p, p2, p3, p4, p5)
	p.Soft = 0

	if p.SoftGuaranteed then
		p.SoftGuaranteed = false
		return p2
	end

	if math.random(1, p4 + p5) <= p4 then
		return p2
	end

	p.SoftGuaranteed = true
	return p3
end

local function rollOne(rollSet, pity, state)
	state.Soft += 1
	state.Hard += 1
	local id = rollSet[1].Id
	local id2 = rollSet[2].Id

	if pity and state.Hard >= pity.Hard then
		resetHardPity(state) -- equivalent call inferred; original call site unknown
		return id
	elseif pity and state.Soft >= pity.Soft then
		local rate = rollSet[1].Rate
		local rate2 = rollSet[2].Rate
		state.Soft = 0

		if state.SoftGuaranteed then
			state.SoftGuaranteed = false
			return id
		end

		if math.random(1, rate + rate2) <= rate then
			return id
		end

		state.SoftGuaranteed = true
		return id2
	else
		local v = roll(rollSet)

		if v == id then
			resetHardPity(state) -- equivalent call inferred; original call site unknown
		end

		return v
	end
end

return {
	rollEgg = function(p, p2, data)
		local rollSet = buildRollSet(p.Pets)
		local pity = p.Pity
		local v = {
			Soft = not data and 0 or data.Soft or 0,
			Hard = not data and 0 or data.Hard or 0,
			SoftGuaranteed = data and data.SoftGuaranteed or false
		}
		local result = {}

		for _ = 1, p2 do
			local v2 = rollOne(rollSet, pity, v)

			if v2 then
				table.insert(result, v2)
			end
		end

		return result, v
	end
}