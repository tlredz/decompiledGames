local WeightedFuseData = require(script.Parent.Parent.GameData.WeightedFuseData)
local v = {
	MODEL_VERSION = WeightedFuseData.MODEL_VERSION,
	TICKET_COUNT = 10000
}
local v2 = {}
local v3 = {}
local v4 = {}

for _, v5 in ipairs(WeightedFuseData.PETS) do
	local id = v5.id
	local name = string.lower(v5.name)
	v2[id] = v5
	v3[name] = v5
end

for i, v5 in ipairs(WeightedFuseData.RARITIES) do
	v4[v5] = i - 1
end

local function finite(value)
	return type(value) == "number" and value == value and value > -1e999 and value < 1e999
end

local function copy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function exactFour(items)
	if type(items) ~= "table" then
		return false
	end

	local count = 0

	for k in pairs(items) do
		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or k > 4 then
			return false
		end

		count += 1
	end

	return count == 4
end

function v.GetPet(value)
	if type(value) == "string" then
		return v2[value] or v3[string.lower(value)]
	end

	return nil
end

local function resolveConfig(p)
	local v5 = p == nil and {} or p

	if type(v5) ~= "table" then
		error("Configuration must be a table", 3)
	end

	local result = {}

	for _, v6 in ipairs({ "inputWeights", "outputWeights", "rarityWeights" }) do
		local v7 = WeightedFuseData.DEFAULT_CONFIG[v6]
		local v8 = {}

		for k, v9 in pairs(v7) do
			v8[k] = v9
		end

		result[v6] = v8

		if v5[v6] == nil then
			continue
		end

		if type(v5[v6]) ~= "table" then
			error(v6 .. " must be a map", 3)
		end

		for k, v9 in pairs(v5[v6]) do
			result[v6][k] = v9
		end
	end

	result.weakestShare = v5.weakestShare

	if result.weakestShare == nil then
		result.weakestShare = WeightedFuseData.DEFAULT_CONFIG.weakestShare
	end

	result.hydraCap = v5.hydraCap

	if result.hydraCap == nil then
		result.hydraCap = WeightedFuseData.DEFAULT_CONFIG.hydraCap
	end

	result.fuseLuckEnabled = v5.fuseLuckEnabled

	if result.fuseLuckEnabled == nil then
		result.fuseLuckEnabled = WeightedFuseData.DEFAULT_CONFIG.fuseLuckEnabled
	end

	result.fuseLuckBoost = v5.fuseLuckBoost

	if result.fuseLuckBoost == nil then
		result.fuseLuckBoost = WeightedFuseData.DEFAULT_CONFIG.fuseLuckBoost
	end

	local v6 = {}

	if type(result.fuseLuckEnabled) ~= "boolean" then
		error("fuseLuckEnabled must be a boolean", 3)
	end

	local fuseLuckBoost = result.fuseLuckBoost
	local v7

	if type(fuseLuckBoost) == "number" and fuseLuckBoost == fuseLuckBoost and fuseLuckBoost > -1e999 then
		v7 = fuseLuckBoost < 1e999
	else
		v7 = false
	end

	if not v7 or result.fuseLuckBoost < 0.1 or result.fuseLuckBoost > 0.2 then
		error("fuseLuckBoost must be a finite fraction between 0.10 and 0.20", 3)
	end

	local weakestShare = result.weakestShare
	local v8

	if type(weakestShare) == "number" and weakestShare == weakestShare and weakestShare > -1e999 then
		v8 = weakestShare < 1e999
	else
		v8 = false
	end

	if not v8 or result.weakestShare < 0 or result.weakestShare > 1 then
		error("weakestShare must be between 0 and 1", 3)
	end

	local hydraCap = result.hydraCap
	local v9

	if type(hydraCap) == "number" and hydraCap == hydraCap and hydraCap > -1e999 then
		v9 = hydraCap < 1e999
	else
		v9 = false
	end

	if not v9 or result.hydraCap < 0 then
		error("hydraCap must be a finite non-negative fraction", 3)
	end

	if result.hydraCap > WeightedFuseData.HYDRA_HARD_CAP then
		table.insert(v6, "Hydra cap was limited to the non-overridable 5% ceiling")
		result.hydraCap = WeightedFuseData.HYDRA_HARD_CAP
	end

	for k, inputWeight in pairs(result.inputWeights) do
		if not v2[k] then
			error("Unknown input weight: " .. tostring(k), 3)
		end

		local v10

		if type(inputWeight) == "number" and inputWeight == inputWeight and inputWeight > -1e999 then
			v10 = inputWeight < 1e999
		else
			v10 = false
		end

		if not v10 or inputWeight < 0 or inputWeight > 100 then
			error("Input quality for " .. k .. " must be finite and between 0 and 100", 3)
		end
	end

	for k, outputWeight in pairs(result.outputWeights) do
		if not (v2[k] and v2[k].isFuse) then
			error("Unknown fuse output: " .. tostring(k), 3)
		end

		local v10

		if type(outputWeight) == "number" and outputWeight == outputWeight and outputWeight > -1e999 then
			v10 = outputWeight < 1e999
		else
			v10 = false
		end

		if not v10 or outputWeight < 1e-6 or outputWeight > 1000000 then
			error("Output multiplier for " .. k .. " must be between 0.000001 and 1000000", 3)
		end
	end

	for k, rarityWeight in pairs(result.rarityWeights) do
		if v4[k] == nil then
			error("Unknown output rarity: " .. tostring(k), 3)
		end

		local v10

		if type(rarityWeight) == "number" and rarityWeight == rarityWeight and rarityWeight > -1e999 then
			v10 = rarityWeight < 1e999
		else
			v10 = false
		end

		if not v10 or rarityWeight < 1e-6 or rarityWeight > 1000000 then
			error("Rarity multiplier for " .. k .. " must be between 0.000001 and 1000000", 3)
		end
	end

	return result, v6
end

local function interpolate(p)
	local ANCHORS = WeightedFuseData.ANCHORS
	local v5 = math.max(ANCHORS[1].score, (math.min(ANCHORS[#ANCHORS].score, p)))
	local v6 = ANCHORS[1]
	local v7 = ANCHORS[#ANCHORS]

	for _, v9 in ipairs(ANCHORS) do
		if v9.score <= v5 then
			v6 = v9
		end

		if not (v5 <= v9.score) then
			continue
		end

		v7 = v9
		break
	end

	local fraction = v7.score == v6.score and 0 or (v5 - v6.score) / (v7.score - v6.score)
	local v10 = {}
	local orderedIds = {}
	local result = {}

	for _, v11 in ipairs({ v6, v7 }) do
		for _, orderedId in ipairs(v11.orderedIds) do
			if v10[orderedId] then
				continue
			end

			v10[orderedId] = true
			table.insert(orderedIds, orderedId)
		end
	end

	for _, v11 in ipairs(orderedIds) do
		local v12 = (1 - fraction) * (v6.weights[v11] or 0) + fraction * (v7.weights[v11] or 0)

		if v12 > 0 then
			result[v11] = v12
		end
	end

	return orderedIds, result, {
		lowerScore = v6.score,
		upperScore = v7.score,
		fraction = fraction
	}
end

local function applyFuseLuck(outcomes, data)
	local probabilitiesByPetId = {}
	local total = 0

	for _, v5 in ipairs(outcomes) do
		probabilitiesByPetId[v5.petId] = v5.probability
		total += v5.quality * v5.probability
	end

	local hydraCapLimited = false

	if data.fuseLuckEnabled then
		local total2 = 0

		for _, v6 in ipairs(outcomes) do
			local probability = v6.probability
			local v7 = math.min(probability, (math.max(0, 0.5 - total2)))
			v6.probability = probability + data.fuseLuckBoost * (v7 * 2 - probability)
			total2 += probability
		end

		for i, v6 in ipairs(outcomes) do
			if not (v6.petId == "hydra" and v6.probability > data.hydraCap) then
				continue
			end

			local v7 = v6.probability - data.hydraCap
			v6.probability = data.hydraCap
			outcomes[i + 1].probability = outcomes[i + 1].probability + v7
			hydraCapLimited = true
		end

		local v6 = nil

		for _, v7 in ipairs(outcomes) do
			if v7.petId ~= "hydra" and (not v6 or v7.probability > v6.probability) then
				v6 = v7
			end
		end

		local total3 = 0

		for _, v7 in ipairs(outcomes) do
			if v7 ~= v6 then
				total3 += v7.probability
			end
		end

		v6.probability = 1 - total3
	end

	return {
		enabled = data.fuseLuckEnabled,
		active = data.fuseLuckEnabled,
		boost = data.fuseLuckBoost,
		method = "median-tail-tilt",
		hydraCapLimited = hydraCapLimited,
		baselineProbabilities = probabilitiesByPetId,
		baselineExpectedQuality = total
	}
end

local function pruneLowEnd(outcomes, list, stage)
	while #outcomes > 0 and outcomes[#outcomes].probability < 0.019999999999999966 do
		if #outcomes <= 3 then
			error(
				"Low-end pruning would leave fewer than 3 outcomes: " .. outcomes[#outcomes].petId .. " is below 2%; adjust output or rarity multipliers",
				3
			)
		end

		local v5 = table.remove(outcomes)
		local v6 = outcomes[#outcomes]
		v6.probability += v5.probability
		table.insert(list, {
			petId = v5.petId,
			name = v5.name,
			quality = v5.quality,
			probability = v5.probability,
			percent = v5.probability * 100,
			stage = stage,
			recipientPetId = v6.petId,
			reason = "weakest-below-2-percent"
		})
	end
end

local function finalizeFuseLuck(outcomes, state, petIds)
	local probabilitiesByPetId = {}
	local total = 0

	for _, v5 in ipairs(outcomes) do
		probabilitiesByPetId[v5.petId] = v5.probability
		total += v5.quality * v5.probability
	end

	local probabilityDeltas = {}
	local relativeChanges = {}
	local fundingLimited = false

	for i, v8 in ipairs(petIds) do
		local baselineProbability = state.baselineProbabilities[v8]
		probabilityDeltas[v8] = (probabilitiesByPetId[v8] or 0) - baselineProbability
		relativeChanges[v8] = probabilityDeltas[v8] / baselineProbability

		if not (state.enabled and i < #petIds and v8 ~= "hydra" and (probabilitiesByPetId[v8] or 0) + 1e-12 < baselineProbability * (1 + state.boost)) then
			continue
		end

		fundingLimited = true
	end

	state.probabilityDeltas = probabilityDeltas
	state.relativeChanges = relativeChanges
	state.fundingLimited = fundingLimited
	state.expectedQualityGain = total - state.baselineExpectedQuality
end

local function baseOddsForScore(p, data)
	local v5, v6, interval = interpolate(p)
	local total = 0
	local v8 = {}
	local v9 = nil

	for _, petId in ipairs(v5) do
		local anchorWeight = v6[petId]

		if not anchorWeight then
			continue
		end

		local v12 = v2[petId]
		local drawWeight = anchorWeight * data.outputWeights[petId] * data.rarityWeights[v12.rarity]
		local v14 = {
			petId = petId,
			name = v12.name,
			rarity = v12.rarity,
			quality = v12.quality,
			inputQuality = data.inputWeights[petId],
			income = v12.income,
			anchorWeight = anchorWeight,
			outputMultiplier = data.outputWeights[petId],
			rarityMultiplier = data.rarityWeights[v12.rarity],
			drawWeight = drawWeight
		}
		total += drawWeight
		table.insert(v8, v14)

		if petId == "hydra" then
			v9 = v14
		end
	end

	for _, v10 in ipairs(v8) do
		v10.probability = v10.drawWeight / total
	end

	local capApplied

	if v9 and v9.probability > data.hydraCap then
		local total2 = 0
		capApplied = true

		for _, v11 in ipairs(v8) do
			if v11.petId ~= "hydra" then
				total2 += v11.drawWeight
			end
		end

		for _, v11 in ipairs(v8) do
			if v11.petId == "hydra" then
				v11.probability = data.hydraCap
			else
				v11.probability = (1 - data.hydraCap) * v11.drawWeight / total2
			end
		end
	else
		capApplied = false
	end

	local outcomes = {}

	for _, v12 in ipairs(v8) do
		if v12.probability > 0 then
			table.insert(outcomes, v12)
		end
	end

	table.sort(outcomes, function(a, b)
		return a.quality > b.quality
	end)
	return {
		outcomes = outcomes,
		capApplied = capApplied,
		interval = interval
	}
end

local function unquantizedOddsForScore(p, p2, p3)
	local v5 = baseOddsForScore(p, p2)
	local outcomes = v5.outcomes
	local capApplied = v5.capApplied
	local interval = v5.interval
	local removedOutcomes = {}

	if not p3 then
		pruneLowEnd(outcomes, removedOutcomes, "baseline")
	end

	local petIds = {}

	for i, outcome in ipairs(outcomes) do
		petIds[i] = outcome.petId
	end

	local fuseLuck = applyFuseLuck(outcomes, p2)

	if not p3 then
		pruneLowEnd(outcomes, removedOutcomes, "event")
	end

	finalizeFuseLuck(outcomes, fuseLuck, petIds)
	local capApplied2 = capApplied or fuseLuck.hydraCapLimited

	for _, outcome in ipairs(outcomes) do
		outcome.percent = outcome.probability * 100
		outcome.effectiveWeight = outcome.percent
	end

	if p3 or not removedOutcomes then
		removedOutcomes = nil
	end

	return {
		outcomes = outcomes,
		capApplied = capApplied2,
		fuseLuck = fuseLuck,
		interval = interval,
		removedOutcomes = removedOutcomes,
		lowEndPruning = not p3 and ({
			threshold = 0.02,
			redistribution = "next-stronger",
			minimumOutcomes = 3
		} or nil) or nil
	}
end

local function quantizeOutcomes(outcomes, HYDRA_HARD_CAP)
	if type(outcomes) ~= "table" or #outcomes == 0 then
		error("Ticket quantization needs a non-empty outcome pool", 3)
	end

	if HYDRA_HARD_CAP == nil then
		HYDRA_HARD_CAP = WeightedFuseData.HYDRA_HARD_CAP
	end

	local v5

	if type(HYDRA_HARD_CAP) == "number" and HYDRA_HARD_CAP == HYDRA_HARD_CAP and HYDRA_HARD_CAP > -1e999 then
		v5 = HYDRA_HARD_CAP < 1e999
	else
		v5 = false
	end

	if not v5 or HYDRA_HARD_CAP < 0 then
		error("Hydra cap must be finite and non-negative", 3)
	end

	local function round(p, p2)
		return (math.floor(p + 0.5 + 1.7763568394002505e-15 * p2))
	end

	local v6 = math.min(WeightedFuseData.HYDRA_HARD_CAP, HYDRA_HARD_CAP)
	local hydraTicketCap = math.floor(v6 * 10000 + 1.7763568394002505e-11)

	while v6 < hydraTicketCap / 10000 do
		hydraTicketCap -= 1
	end

	local total = 0
	local total2 = 0
	local total3 = 0
	local v8 = 0
	local outcomes2 = {}
	local maxAbsoluteErrorPercent = 0
	local petIds = {}
	local removedOutcomes = {}
	local petIds2 = {}

	for i, v12 in ipairs(outcomes) do
		local probability = v12.probability
		local v13

		if type(probability) == "number" and probability == probability and probability > -1e999 then
			v13 = probability < 1e999
		else
			v13 = false
		end

		if not v13 or v12.probability < 0 then
			error("Outcome probabilities must be finite and non-negative", 3)
		end

		if i > 1 and outcomes[i - 1].quality <= v12.quality then
			error("Outcome pool must be ordered by strictly descending quality", 3)
		end

		if v12.petId == "hydra" and i ~= 1 then
			error("Hydra must be the strongest outcome", 3)
		end

		total += v12.probability
		local isBalancingOutcome = i == #outcomes
		local ticketCount

		if v12.petId == "hydra" then
			ticketCount = math.min(hydraTicketCap, (math.floor(v12.probability * 10000 + 0.5 + 1.7763568394002505e-11)))
		elseif isBalancingOutcome then
			ticketCount = 10000 - total2
		else
			total3 += v12.probability
			local v16 = math.max(v8, (math.min(1000, (math.floor(total3 * 1000 + 0.5 + 1.7763568394002505e-12)))))
			ticketCount = (v16 - v8) * 10
			v8 = v16
		end

		if ticketCount < 0 then
			error("Ticket quantization exhausted the common funding outcome", 3)
		end

		local probability2 = ticketCount / 10000
		local v17 = ticketCount / 100
		local v18

		if v12.petId == "hydra" then
			v18 = true
		elseif isBalancingOutcome then
			if outcomes2[1] == nil then
				v18 = false
			else
				v18 = outcomes2[1].petId == "hydra"
			end
		else
			v18 = isBalancingOutcome
		end

		local v19 = {}

		for k, v20 in pairs(v12) do
			v19[k] = v20
		end

		v19.probability = probability2
		v19.percent = v17
		v19.effectiveWeight = v17
		local ticketStart = total2 + 1
		local ticketEnd = total2 + ticketCount
		v19.ticketCount = ticketCount
		v19.ticketStart = ticketStart
		v19.ticketEnd = ticketEnd
		v19.ticketStep = v18 and 1 or 10
		v19.chanceDecimals = v18 and 2 or 1
		v19.isBalancingOutcome = isBalancingOutcome
		maxAbsoluteErrorPercent = math.max(maxAbsoluteErrorPercent, math.abs(probability2 - v12.probability) * 100)

		if ticketCount ~= (v12.petId == "hydra" and math.floor(v12.probability * 10000 + 0.5 + 1.7763568394002505e-11) or math.floor(v12.probability * 1000 + 0.5 + 1.7763568394002505e-12) * 10) then
			table.insert(petIds2, v12.petId)
		end

		if ticketCount > 0 then
			table.insert(outcomes2, v19)
		else
			table.insert(petIds, v12.petId)
			table.insert(removedOutcomes, {
				petId = v12.petId,
				name = v12.name,
				quality = v12.quality,
				probability = v12.probability,
				percent = v12.probability * 100,
				ticketCount = 0,
				stage = "quantization",
				reason = "zero-tickets"
			})
		end

		total2 += ticketCount
	end

	if math.abs(total - 1) > 1e-10 or total2 ~= 10000 then
		error("Outcome probabilities must sum to one", 3)
	end

	return {
		outcomes = outcomes2,
		quantization = {
			enabled = true,
			totalTickets = 10000,
			incrementPercent = 0.1,
			hydraIncrementPercent = 0.01,
			balancingIncrementPercent = outcomes2[1] and outcomes2[1].petId == "hydra" and 0.01 or 0.1,
			ordinaryTicketStep = 10,
			balancingPetId = outcomes[#outcomes].petId,
			method = "mixed-precision-cumulative-rounding",
			rounding = "half-up",
			roundingEpsilon = 1.7763568394002505e-11,
			hydraTicketCap = hydraTicketCap,
			removedPetIds = petIds,
			removedOutcomes = removedOutcomes,
			roundingAdjustedPetIds = petIds2,
			maxAbsoluteErrorPercent = maxAbsoluteErrorPercent
		}
	}
end

v.QuantizeOutcomes = quantizeOutcomes

local function applyMinimumEventBoost(state, outcomes, p, outcomes2, fuseLuckEnabled)
	local result = {
		enabled = fuseLuckEnabled,
		minimumIncrementPercent = 0.1,
		minimumTicketGain = 10,
		eligibility = "positive-raw-event-delta-nonbalancing-nonhydra",
		eligiblePetIds = {},
		adjustedPetIds = {},
		addedTickets = {},
		fundingPetId = outcomes[#outcomes].petId,
		totalFundingTickets = 0
	}

	if not fuseLuckEnabled then
		return result
	end

	local probabilitiesByPetId = {}
	local ticketCountsByPetId = {}
	local v5 = {}

	for _, v6 in ipairs(outcomes2) do
		probabilitiesByPetId[v6.petId] = v6.probability
	end

	for _, outcome in ipairs(p.outcomes) do
		ticketCountsByPetId[outcome.petId] = outcome.ticketCount
	end

	for _, outcome in ipairs(state.outcomes) do
		v5[outcome.petId] = outcome
	end

	local v6 = v5[result.fundingPetId]

	for _, v7 in ipairs(outcomes) do
		if not (v7.petId ~= "hydra" and v7.petId ~= result.fundingPetId and v7.probability > (probabilitiesByPetId[v7.petId] or 0) + 1e-12) then
			continue
		end

		table.insert(result.eligiblePetIds, v7.petId)
		local v8 = (ticketCountsByPetId[v7.petId] or 0) + 10
		local v9 = v5[v7.petId]
		local v10 = math.max(0, v8 - (not v9 and 0 or v9.ticketCount or 0))

		if not (v10 > 0) then
			continue
		end

		if not v6 or v6.ticketCount <= v10 then
			error("Minimum event bonus exhausts the common funding outcome; adjust output or rarity multipliers", 3)
		end

		if not v9 then
			v9 = {}

			for k, v11 in pairs(v7) do
				v9[k] = v11
			end

			v9.ticketCount = 0
			v9.ticketStep = 10
			v9.chanceDecimals = 1
			v9.isBalancingOutcome = false
			v5[v7.petId] = v9
		end

		local ticketCount = v9.ticketCount + v10
		local ticketCount2 = v6.ticketCount - v10
		v9.ticketCount = ticketCount
		v6.ticketCount = ticketCount2
		table.insert(result.adjustedPetIds, v7.petId)
		result.addedTickets[v7.petId] = v10
		result.totalFundingTickets += v10
	end

	state.outcomes = {}

	for _, v7 in pairs(v5) do
		table.insert(state.outcomes, v7)
	end

	table.sort(state.outcomes, function(a, b)
		return a.quality > b.quality
	end)
	local total = 0

	for _, outcome in ipairs(state.outcomes) do
		outcome.probability = outcome.ticketCount / 10000
		outcome.percent = outcome.ticketCount / 100
		outcome.effectiveWeight = outcome.percent
		outcome.ticketStart = total + 1
		total += outcome.ticketCount
		outcome.ticketEnd = total
	end

	local removedOutcomes = {}
	local petIds = {}

	for _, removedOutcome in ipairs(state.quantization.removedOutcomes) do
		if v5[removedOutcome.petId] then
			continue
		end

		table.insert(removedOutcomes, removedOutcome)
		table.insert(petIds, removedOutcome.petId)
	end

	local quantization = state.quantization
	local quantization2 = state.quantization
	quantization.removedOutcomes = removedOutcomes
	quantization2.removedPetIds = petIds
	local maxAbsoluteErrorPercent = 0

	for _, v8 in ipairs(outcomes) do
		maxAbsoluteErrorPercent = math.max(
			maxAbsoluteErrorPercent,
			math.abs((not v5[v8.petId] and 0 or v5[v8.petId].probability or 0) - v8.probability) * 100
		)
	end

	state.quantization.maxAbsoluteErrorPercent = maxAbsoluteErrorPercent
	return result
end

local function oddsForScore(p, config, p2)
	local v5 = unquantizedOddsForScore(p, config, p2)

	if p2 then
		return v5
	end

	local v6 = quantizeOutcomes(v5.outcomes, config.hydraCap)
	local v7

	if config.fuseLuckEnabled then
		local v8 = {}

		for k, v9 in pairs(config) do
			v8[k] = v9
		end

		v8.fuseLuckEnabled = false
		v7 = unquantizedOddsForScore(p, v8)
	else
		v7 = v5
	end

	local v8

	if config.fuseLuckEnabled then
		v8 = quantizeOutcomes(v7.outcomes, config.hydraCap) or v6
	else
		v8 = v6
	end

	local minimumEventBoost = applyMinimumEventBoost(v6, v5.outcomes, v8, v7.outcomes, config.fuseLuckEnabled)
	local outcomes = v6.outcomes

	if #outcomes < 3 then
		error("Ticket quantization would leave fewer than 3 outcomes; adjust output or rarity multipliers", 3)
	end

	if outcomes[#outcomes].ticketCount < 200 then
		error(
			"Boost/rounding would violate the 2% low-end rule for " .. outcomes[#outcomes].petId .. "; adjust custom tuning",
			3
		)
	end

	local fuseLuck = v5.fuseLuck
	local fuseLuck2 = {}

	for k, v11 in pairs(fuseLuck) do
		fuseLuck2[k] = v11
	end

	fuseLuck2.baselineProbabilities = {}
	fuseLuck2.baselineExpectedQuality = 0
	fuseLuck2.baselineTicketCounts = {}
	local petIds = {}

	for i, outcome in ipairs(v8.outcomes) do
		petIds[i] = outcome.petId
		fuseLuck2.baselineProbabilities[outcome.petId] = outcome.probability
		fuseLuck2.baselineTicketCounts[outcome.petId] = outcome.ticketCount
		fuseLuck2.baselineExpectedQuality += outcome.quality * outcome.probability
	end

	finalizeFuseLuck(outcomes, fuseLuck2, petIds)
	fuseLuck2.finalProbabilities = {}
	fuseLuck2.finalTicketCounts = {}
	fuseLuck2.newlyPositivePetIds = {}

	for _, outcome in ipairs(outcomes) do
		fuseLuck2.finalProbabilities[outcome.petId] = outcome.probability
		fuseLuck2.finalTicketCounts[outcome.petId] = outcome.ticketCount

		if fuseLuck2.baselineProbabilities[outcome.petId] then
			continue
		end

		table.insert(fuseLuck2.newlyPositivePetIds, outcome.petId)
		fuseLuck2.probabilityDeltas[outcome.petId] = outcome.probability
		fuseLuck2.relativeChanges[outcome.petId] = nil
	end

	fuseLuck2.quantizationApplied = true
	fuseLuck2.minimumEventBoost = minimumEventBoost
	local quantization = v6.quantization
	v5.outcomes = outcomes
	v5.quantization = quantization
	v5.fuseLuck = fuseLuck2
	return v5
end

local function calculateFuse(list, p, p2)
	if not exactFour(list) then
		error("A fuse needs exactly four input pets", 2)
	end

	local config, warnings = resolveConfig(p)
	local inputs = {}
	local ids = {}
	local total = 0
	local minimumQuality = 1e999
	local v8 = 1e999
	local v9 = -1e999
	local total2 = 0

	for i = 1, 4 do
		local pet = v.GetPet(list[i])

		if not (pet and pet.inputAllowed) then
			error("Pet is not an allowed fuse input: " .. tostring(list[i]), 2)
		end

		local v10 = {}

		for k, v11 in pairs(pet) do
			v10[k] = v11
		end

		v10.quality = config.inputWeights[pet.id]
		local id = pet.id
		inputs[i] = v10
		ids[i] = id
		total += v10.quality
		minimumQuality = math.min(minimumQuality, v10.quality)
		local v11 = v4[pet.rarity]
		v8 = math.min(v8, v11)
		v9 = math.max(v9, v11)
		total2 += pet.income
	end

	local averageQuality = total / 4
	local score = (1 - config.weakestShare) * averageQuality + config.weakestShare * minimumQuality
	local v12 = oddsForScore(score, config, p2)
	local result = {
		version = p2 and "weighted-fuse-v7" or WeightedFuseData.MODEL_VERSION,
		inputIds = ids,
		inputs = inputs,
		score = score,
		totalQuality = total,
		averageQuality = averageQuality,
		minimumQuality = minimumQuality,
		weakestPenalty = averageQuality - score,
		outcomes = v12.outcomes,
		interval = v12.interval,
		hydraProbability = 0,
		hydraCap = config.hydraCap,
		capApplied = v12.capApplied,
		fuseLuck = v12.fuseLuck,
		removedOutcomes = v12.removedOutcomes,
		lowEndPruning = v12.lowEndPruning,
		quantization = v12.quantization,
		expectedIncome = 0,
		inputIncome = total2,
		expectedQuality = 0,
		failureProbability = 0,
		upgradeBeyondBestInputRarity = 0,
		downgradeBelowWeakestInputRarity = 0,
		warnings = warnings
	}

	for _, outcome in ipairs(v12.outcomes) do
		if outcome.petId == "hydra" then
			result.hydraProbability = outcome.probability
		end

		result.expectedIncome += outcome.income * outcome.probability
		result.expectedQuality += outcome.quality * outcome.probability

		if outcome.isFailure then
			result.failureProbability = outcome.probability
		else
			if v9 < v4[outcome.rarity] then
				result.upgradeBeyondBestInputRarity += outcome.probability
			end

			if v4[outcome.rarity] < v8 then
				result.downgradeBelowWeakestInputRarity += outcome.probability
			end
		end
	end

	return result
end

function v.CalculateFuse(p, p2)
	return (calculateFuse(p, p2, false))
end

function v.CalculateLegacyPreview(p)
	return (calculateFuse(p, {
		fuseLuckEnabled = false,
		fuseLuckBoost = 0.15
	}, true))
end

function v.CalculateAtScore(score, p)
	local v5

	if type(score) == "number" and score == score and score > -1e999 then
		v5 = score < 1e999
	else
		v5 = false
	end

	if not v5 then
		error("Score must be finite", 2)
	end

	local config, warnings = resolveConfig(p)
	local v7 = oddsForScore(score, config)
	v7.score = score
	v7.warnings = warnings
	return v7
end

local random = nil

local function nextNumber(callback)
	local v5

	if type(callback) == "function" then
		v5 = callback()
	else
		if callback == nil then
			if not random then
				random = Random.new()
			end

			callback = random
		end

		v5 = callback:NextNumber()
	end

	local v6

	if type(v5) == "number" and v5 == v5 and v5 > -1e999 then
		v6 = v5 < 1e999
	else
		v6 = false
	end

	if not v6 or v5 < 0 or v5 >= 1 then
		error("RNG must return a finite value in [0,1)", 3)
	end

	return v5
end

local function nextTicket(callback, totalTickets)
	if type(callback) == "function" then
		return math.floor(nextNumber(callback) * totalTickets) + 1
	end

	if callback == nil then
		if not random then
			random = Random.new()
		end

		callback = random
	end

	local integer = callback:NextInteger(1, totalTickets)
	local v5

	if type(integer) == "number" and integer == integer and integer > -1e999 then
		v5 = integer < 1e999
	else
		v5 = false
	end

	if not v5 or integer % 1 ~= 0 or integer < 1 or totalTickets < integer then
		error("RNG must return a valid integer ticket within the preview range", 3)
	end

	return integer
end

function v.RollFromPreview(preview, p2)
	if type(preview) ~= "table" or type(preview.outcomes) ~= "table" or #preview.outcomes == 0 then
		error("A computed nonempty fuse preview is required", 2)
	end

	if type(preview.quantization) == "table" and preview.quantization.enabled == true then
		local totalTickets = preview.quantization.totalTickets
		local v5

		if type(totalTickets) == "number" and totalTickets == totalTickets and totalTickets > -1e999 then
			v5 = totalTickets < 1e999
		else
			v5 = false
		end

		if v5 then
			if totalTickets % 1 == 0 and totalTickets >= 1 then
				v5 = totalTickets <= 2147483647
			else
				v5 = false
			end
		end

		assert(v5, "Invalid species ticket total")
		local v6 = nextTicket(p2, totalTickets)
		local total = 0

		for _, outcome in ipairs(preview.outcomes) do
			total += outcome.ticketCount

			if v6 <= total then
				return {
					petId = outcome.petId,
					name = outcome.name,
					probability = outcome.probability,
					preview = preview
				}
			end
		end

		error("Invalid species ticket distribution", 2)
	end

	local v5 = nextNumber(p2)
	local outcome = preview.outcomes[#preview.outcomes]
	local total = 0

	for _, outcome2 in ipairs(preview.outcomes) do
		total += outcome2.probability

		if not (v5 < total) then
			continue
		end

		outcome = outcome2
		break
	end

	return {
		petId = outcome.petId,
		name = outcome.name,
		probability = outcome.probability,
		preview = preview
	}
end

function v.RollFuse(p, p2, p3)
	return v.RollFromPreview(v.CalculateFuse(p, p2), p3)
end

local function tail(p, p2)
	local total = 0

	for _, outcome in ipairs(p.outcomes) do
		if p2 <= outcome.quality then
			total += outcome.probability
		end
	end

	return total
end

function v.ValidateConfig(p)
	local success, result, warnings = pcall(resolveConfig, p)

	if not success then
		return {
			valid = false,
			monotonic = false,
			errors = { (tostring(result)) },
			warnings = {}
		}
	end

	local v6 = {}
	local v7 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addScore(p2)
		if not v7[p2] then
			table.insert(v6, p2)
			v7[p2] = true
		end
	end

	for _, v8 in ipairs(WeightedFuseData.ANCHORS) do
		addScore(v8.score) -- equivalent call inferred; original call site unknown
	end

	local v8

	if result.weakestShare == WeightedFuseData.DEFAULT_CONFIG.weakestShare then
		v8 = result.hydraCap == WeightedFuseData.DEFAULT_CONFIG.hydraCap
	else
		v8 = false
	end

	for _, v9 in ipairs({ "inputWeights", "outputWeights", "rarityWeights" }) do
		for k, v10 in pairs(WeightedFuseData.DEFAULT_CONFIG[v9]) do
			if result[v9][k] ~= v10 then
				v8 = false
			end
		end
	end

	local v9 = {}

	if v8 then
		local v10 = {
			[0] = true
		}

		for _ = 1, 4 do
			local v11 = {}

			for k in pairs(v10) do
				for _, v12 in ipairs(WeightedFuseData.PETS) do
					v11[k + v12.quality] = true
				end
			end

			v10 = v11
		end

		for k in pairs(v10) do
			addScore(k / 4) -- equivalent call inferred; original call site unknown
			v9[k / 4] = true
		end
	end

	local monotonicityScope = v8 and "all-authored-default-recipe-scores" or "sampled-custom-scores-only"

	if result.fuseLuckEnabled and not v8 then
		table.insert(
			warnings,
			"Minimum 0.1-point event bonuses can cause 0.1-point quality-tail steps for fractional custom scores; continuous-score monotonicity is not guaranteed"
		)
	end

	local function capDifference(p2)
		local total = 0
		local v11 = 0

		for _, orderedId in ipairs(p2.orderedIds) do
			local v12 = p2.weights[orderedId] * result.outputWeights[orderedId] * result.rarityWeights[v2[orderedId].rarity]
			total += v12

			if orderedId == "hydra" then
				v11 = v12
			end
		end

		return v11 - result.hydraCap * total
	end

	for i = 1, #WeightedFuseData.ANCHORS - 1 do
		local v11 = WeightedFuseData.ANCHORS[i]
		local v12 = WeightedFuseData.ANCHORS[i + 1]
		local v13 = capDifference(v11)
		local v14 = capDifference(v12)

		if not (v13 * v14 < 0) then
			continue
		end

		addScore(v11.score + (v12.score - v11.score) * (-v13 / (v14 - v13))) -- equivalent call inferred; original call site unknown
	end

	table.sort(v6)
	local v11 = {}

	for i, v12 in ipairs(v6) do
		v11[i] = v12
	end

	local v12 = { 0.019999999999999966 }

	if result.fuseLuckEnabled then
		table.insert(v12, v12[1] / (1 - result.fuseLuckBoost))
	end

	local function lowerTail(p2, quality)
		local total = 0

		for _, outcome in ipairs(baseOddsForScore(p2, result).outcomes) do
			if outcome.quality <= quality then
				total += outcome.probability
			end
		end

		return total
	end

	for i = 2, #v11 do
		local v13 = v11[i - 1]
		local v14 = v11[i]
		addScore((v13 + v14) / 2) -- equivalent call inferred; original call site unknown

		for _, v16 in ipairs(WeightedFuseData.FUSE_PETS) do
			for _, v17 in ipairs(v12) do
				local v18 = lowerTail(v13, v16.quality) - v17

				if not (v18 * (lowerTail(v14, v16.quality) - v17) < 0) then
					continue
				end

				local v19 = v14
				local v20 = v13

				for _ = 1, 64 do
					local midpoint = (v20 + v19) / 2

					if midpoint == v20 or midpoint == v19 then
						break
					end

					local v22 = lowerTail(midpoint, v16.quality) - v17

					if v18 < 0 == (v22 < 0) then
						v18 = v22
						v20 = midpoint
					else
						v19 = midpoint
					end
				end

				addScore(v20) -- equivalent call inferred; original call site unknown
				addScore(v19) -- equivalent call inferred; original call site unknown
				addScore((v20 + v19) / 2) -- equivalent call inferred; original call site unknown
			end
		end
	end

	for i = 1, #v6 do
		local v13 = v6[i]
		local v14 = math.max(1, (math.abs(v13))) * 2.220446049250313e-16 * 16

		if v13 - v14 >= WeightedFuseData.ANCHORS[1].score then
			addScore(v13 - v14) -- equivalent call inferred; original call site unknown
		end

		if not (v13 + v14 <= WeightedFuseData.ANCHORS[#WeightedFuseData.ANCHORS].score) then
			continue
		end

		addScore(v13 + v14) -- equivalent call inferred; original call site unknown
	end

	table.sort(v6)
	local v13 = {}
	local invalidContinuousSamples = {}
	local violations = {}

	for i, v16 in ipairs(v6) do
		local success2, result2 = pcall(oddsForScore, v16, result)

		if success2 then
			v13[i] = result2
		else
			local error2 = tostring(result2):match("^[^:]+:%d+:%s*(.*)$") or tostring(result2)

			if v8 and not v9[v16] then
				table.insert(invalidContinuousSamples, {
					score = v16,
					error = error2
				})
				v13[i] = false
			else
				return {
					valid = false,
					monotonic = false,
					errors = { "Score " .. tostring(v16) .. ": " .. error2 },
					warnings = warnings,
					invalidScore = v16,
					effectiveConfig = result,
					monotonicityScope = monotonicityScope,
					continuousMonotonicityGuaranteed = false
				}
			end
		end
	end

	local v16 = nil
	local sampledContinuousViolations = {}

	for i, toScore in ipairs(v6) do
		local v19 = v13[i]

		if not v19 then
			continue
		end

		if v16 then
			for _, v20 in ipairs(WeightedFuseData.FUSE_PETS) do
				local quality = v20.quality
				local total = 0

				for _, outcome in ipairs(v19.outcomes) do
					if quality <= outcome.quality then
						total += outcome.probability
					end
				end

				local v21 = total + 1e-12
				local v22 = v13[v16]
				local quality2 = v20.quality
				local total2 = 0

				for _, outcome in ipairs(v22.outcomes) do
					if quality2 <= outcome.quality then
						total2 += outcome.probability
					end
				end

				if v21 < total2 then
					table.insert(sampledContinuousViolations, {
						fromScore = v6[v16],
						toScore = toScore,
						thresholdPetId = v20.id
					})
				end
			end
		end

		v16 = i
	end

	if v8 then
		local v18 = nil

		for i, toScore in ipairs(v6) do
			if not v9[toScore] then
				continue
			end

			if v18 then
				for _, v20 in ipairs(WeightedFuseData.FUSE_PETS) do
					local v21 = v13[i]
					local quality = v20.quality
					local total = 0

					for _, outcome in ipairs(v21.outcomes) do
						if quality <= outcome.quality then
							total += outcome.probability
						end
					end

					local v22 = total + 1e-12
					local v23 = v13[v18]
					local quality2 = v20.quality
					local total2 = 0

					for _, outcome in ipairs(v23.outcomes) do
						if quality2 <= outcome.quality then
							total2 += outcome.probability
						end
					end

					if v22 < total2 then
						table.insert(violations, {
							fromScore = v6[v18],
							toScore = toScore,
							thresholdPetId = v20.id
						})
					end
				end
			end

			v18 = i
		end
	else
		for _, v18 in ipairs(sampledContinuousViolations) do
			table.insert(violations, v18)
		end
	end

	if #violations > 0 then
		table.insert(
			warnings,
			"Custom draw/rarity multipliers break monotonic progression at some score bands; restore defaults or retune before shipping"
		)
	end

	local flag = false

	for i = 2, #WeightedFuseData.PETS do
		if not (result.inputWeights[WeightedFuseData.PETS[i].id] < result.inputWeights[WeightedFuseData.PETS[i - 1].id]) then
			continue
		end

		flag = true
		break
	end

	if flag then
		table.insert(warnings, "Custom input qualities reverse one or more authored strength ranks")
	end

	if result.weakestShare > 0.1 then
		table.insert(
			warnings,
			"A weakest-input share above 10% can suppress individual upgrades and cause a last-input jump; the responsive default is the straight mean"
		)
	end

	return {
		valid = true,
		monotonic = #violations == 0,
		inputRanksPreserved = not flag,
		errors = {},
		warnings = warnings,
		violations = violations,
		validationScoreCount = #v6,
		effectiveConfig = result,
		monotonicityScope = monotonicityScope,
		continuousMonotonicityGuaranteed = false,
		sampledContinuousViolations = sampledContinuousViolations,
		invalidContinuousSamples = invalidContinuousSamples
	}
end

return table.freeze(v)