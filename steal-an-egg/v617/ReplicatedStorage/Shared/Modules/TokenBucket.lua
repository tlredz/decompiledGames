local function accrualsFor(data, p)
	local accrual = data.accruals[p]

	if accrual then
		return accrual
	end

	local result = {}

	for _, v in ipairs(data.accrualTemplate) do
		table.insert(result, {
			tokens = v.tokens,
			interval = v.interval,
			credit = 0
		})
	end

	data.accruals[p] = result
	return result
end

local function harvest(data, list, p: number)
	local total = 0

	for _, v in ipairs(list) do
		local v2 = data.maxTokens / (v.tokens / v.interval)
		local credit = math.min(v.credit + p, v2)
		local v4 = math.floor(credit / v.interval)

		if v4 <= 0 then
			v.credit = credit
		else
			total += v4 * v.tokens
			v.credit = math.fmod(credit, v4 * v.interval)
		end
	end

	return total
end

local TokenBucket = {}

function TokenBucket.Build(name: string, data)
	assert(data.MaximumTokens, (`endpoint {name} has no MaximumTokens`))

	if data.InitialTokens then
		assert(data.InitialTokens <= data.MaximumTokens, (`endpoint {name} starts above its own ceiling`))
	end

	local accrualTemplate = {}

	for _, v2 in ipairs(data.Refresh or {}) do
		assert(v2.Tokens > 0, (`a refresh rule on {name} grants no tokens`))
		assert(v2.Interval > 0, (`a refresh rule on {name} has no interval`))
		table.insert(accrualTemplate, {
			tokens = v2.Tokens,
			interval = v2.Interval
		})
	end

	table.freeze(accrualTemplate)
	return {
		name = name,
		maxTokens = data.MaximumTokens,
		initialTokens = data.InitialTokens or data.MaximumTokens,
		causesBan = data.Ban == true,
		accrualTemplate = accrualTemplate,
		tokens = {},
		stamps = {},
		accruals = {}
	}
end

function TokenBucket.Spend(data, p)
	local serverTimeNow = workspace:GetServerTimeNow()

	if not data.stamps[p] then
		data.stamps[p] = serverTimeNow
	end

	if not data.tokens[p] then
		data.tokens[p] = data.initialTokens
	end

	local v = accrualsFor(data, p)
	local token = data.tokens[p]
	local v2 = harvest(data, v, math.max(serverTimeNow - data.stamps[p], 0))
	local selected = token + v2 >= 1
	local v4 = math.min(token + v2, data.maxTokens)

	if selected then
		v4 -= 1
	end

	data.tokens[p] = math.clamp(v4, -1, data.maxTokens)
	data.stamps[p] = serverTimeNow
	return selected
end

function TokenBucket.Forget(data, p)
	data.stamps[p] = nil
	data.tokens[p] = nil
	data.accruals[p] = nil
end

return TokenBucket