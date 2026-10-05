local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local v = require3("@game/ReplicatedStorage/Common/RewardInfo")
local v2 = require3("@game/ReplicatedStorage/Common/Utils")

local function createPicker(list)
	local total = 0
	local v3 = {}

	for k, v4 in list do
		total += v4.chance
		v3[k] = total
	end

	for i = 1, #v3 do
		v3[i] /= total
	end

	return function(p: number)
		local number = Random.new(p):NextNumber()

		for k, v4 in v3 do
			if number < v4 then
				return list[k]
			end
		end

		return list[#list]
	end
end

local function getRandomSeed(value)
	if type(value) == "number" then
		return value
	end

	local total = 0

	for i = 1, string.len(value) do
		total += string.byte((string.sub(value, i, i)))
	end

	return total
end

local function getRewardFor(p, data, p2: number)
	if data.randomPool and #data.randomPool > 0 then
		local v3 = {}

		for _, v4 in ipairs(data.randomPool) do
			if not v2.RewardInfo.playerOwnsItem(p, v4) then
				table.insert(v3, v4)
			end
		end

		if #v3 > 0 then
			return v3[Random.new(p2):NextInteger(1, #v3)]
		end
	elseif not (data.randomPool or v2.RewardInfo.playerOwnsItem(p, data.reward)) then
		return data.reward
	end

	if not data.fallback then
		return data.reward
	end

	local fallback = data.fallback

	while fallback do
		if not v2.RewardInfo.playerOwnsItem(p, fallback.reward) then
			return fallback.reward
		end

		fallback = fallback.fallback
	end

	return data.fallback.reward
end

local function getPremiumReward(data)
	if data.Type == "Coins" then
		return (v.createCoinsReward(math.floor(data.Value + data.Value * 1.2), "Med"))
	end

	if data.Type == "AbilityFreeTrial" then
		data = v.createAbilityFreeTrialReward(data.Value, (math.floor(data.Duration + data.Duration * 1.2)))
	end

	return data
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBaseXP(p: number)
	return (p - 1) * 62 + 140 + math.floor((p - 1) / 10) * 166
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getXPNeeded(p: number)
	if p <= 120 then
		return getBaseXP(p)
	end

	return 9344 + (p - 120) * 94 + math.floor((p - 121) / 30) * 234
end

local Rewards = {}

function Rewards.createInfiniteRewards(data)
	local seed = data.seed
	local v3

	if type(seed) == "number" then
		v3 = seed
	else
		v3 = 0

		for i = 1, string.len(seed) do
			v3 += string.byte((string.sub(seed, i, i)))
		end
	end

	local v4 = {}
	local premiumEmptyChance = data.premiumEmptyChance or 0
	local v5

	if premiumEmptyChance >= 0 then
		v5 = premiumEmptyChance <= 1
	else
		v5 = false
	end

	assert(v5, (`"premiumEmptyChance" needs to be between 0 and 1, got {premiumEmptyChance}`))
	local picker = createPicker(data.pool)
	local picker2 = createPicker(data.premiumPool)

	local function getReward(p: number, p2)
		assert(p > 0, (`"index" needs to be positive, got {p}`))
		local v6 = not p2 and v4[p]

		if v6 then
			return v6
		end

		local fillAfter = data.fillAfter

		if fillAfter and fillAfter < p then
			return nil
		end

		local v7 = data.rewards and data.rewards[p]

		if v7 then
			local v8 = {
				free = v7.free,
				premium = v7.premium,
				xp = 0
			}
			local xPNeeded = getXPNeeded(p) -- equivalent call inferred; original call site unknown
			v8.xp = xPNeeded
			return v8
		else
			local v8 = v3 + p * 42
			local v9 = v3 + p * 84
			local v10 = v9 + 1000003
			local v11 = picker(v8)
			local v12 = picker2(v9)
			local free = p2 and getRewardFor(p2, v11, v8) or v11.reward or v11.randomPool[1]
			local premium

			if not (Random.new(v10):NextNumber() < premiumEmptyChance) then
				premium = getPremiumReward(p2 and getRewardFor(p2, v12, v9) or v12.reward or v12.randomPool[1])
			end

			local xPNeeded = getXPNeeded(p) -- equivalent call inferred; original call site unknown
			local v15 = {
				free = free,
				premium = premium,
				xp = xPNeeded
			}

			if not p2 then
				v4[p] = v15
			end

			return v15
		end
	end

	return {
		getXPNeeded = getXPNeeded,
		getReward = getReward,
		getRewards = function(p: number, p2: number, p3)
			assert(p > 0, (`"from" needs to be positive, got {p}`))
			local rewards = {}

			for i = p, p2 do
				local reward = getReward(i, p3)

				if reward then
					rewards[i] = reward
				end
			end

			return rewards
		end,
		getRewardsFromXP = function(p: number, p2)
			assert(p >= 0, (`"xp" needs to be positive, got {p}`))
			local v6 = 1
			local rewards = {}

			while true do
				local reward = getReward(v6, p2)

				if not reward or p < reward.xp then
					break
				end

				table.insert(rewards, reward)
				v6 += 1
			end

			return rewards
		end,
		getNextReward = function(p: number, p2)
			assert(p >= 0, (`"xp" needs to be positive, got {p}`))
			local v6 = 1

			while true do
				local reward = getReward(v6, p2)

				if not reward then
					break
				end

				if p < reward.xp then
					return reward
				else
					v6 += 1
				end
			end

			return nil
		end,
		getTierFromXP = function(p: number)
			assert(p >= 0, (`"xp" needs to be positive, got {p}`))
			local count = 0

			while true do
				local reward = getReward(count + 1)

				if not reward or p < reward.xp then
					break
				end

				count += 1
			end

			return count
		end,
		fixed = data.rewards
	}
end

function Rewards.createFallbackChain(chance: number, list)
	assert(#list > 0, "rewards list cannot be empty")
	local fallback = nil

	for i = #list, 2, -1 do
		fallback = {
			reward = list[i],
			fallback = fallback
		}
	end

	return {
		reward = list[1],
		chance = chance,
		fallback = fallback
	}
end

function Rewards.createRandomPool(chance: number, randomPool, reward)
	return {
		chance = chance,
		randomPool = randomPool,
		reward = reward,
		fallback = {
			reward = reward,
			fallback = nil
		}
	}
end

return Rewards