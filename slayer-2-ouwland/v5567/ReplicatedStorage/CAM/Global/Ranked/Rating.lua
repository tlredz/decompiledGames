local Rating = {
	MU = 25,
	SIGMA = 8.333333333333334,
	BETA = 4.166666666666667,
	TAU = 0.08333333333333333
}

function Rating.New()
	return {
		Mu = Rating.MU,
		Sigma = Rating.SIGMA
	}
end

local function updateSide(items, p: number, p2: number, p3: number)
	local result = {}

	for k, item in items do
		local v = item.Sigma * item.Sigma / p
		result[k] = {
			Mu = item.Mu + v * p2,
			Sigma = item.Sigma * math.sqrt((math.max(1 - v * p3, 0.0001)))
		}
	end

	return result
end

function Rating.Update(p, p2, p3: number)
	local v = Rating.TAU * Rating.TAU

	local function withDynamics(items)
		local result = {}

		for k, item in items do
			result[k] = {
				Mu = item.Mu,
				Sigma = math.sqrt(item.Sigma * item.Sigma + v)
			}
		end

		return result
	end

	local v2 = withDynamics(p)
	local v3 = withDynamics(p2)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sums(items)
		local total = 0
		local total2 = 0

		for _, item in items do
			total += item.Mu
			total2 += item.Sigma * item.Sigma
		end

		return total, total2
	end

	local total3, total22 = sums(v2) -- equivalent call inferred; original call site unknown
	local total4, total23 = sums(v3) -- equivalent call inferred; original call site unknown
	local v8 = math.sqrt(total22 + total23 + 2 * Rating.BETA * Rating.BETA)
	local v9 = math.exp(total3 / v8)
	local v10 = v9 / (v9 + math.exp(total4 / v8))
	local v11 = 1 - v10
	local v12 = 1 - p3
	local v13 = total22 / v8 * (p3 - v10)
	local v14 = total23 / v8 * (v12 - v11)
	local v15 = total22 / (v8 * v8) * (math.sqrt(total22) / v8) * v10 * (1 - v10)
	local v16 = total23 / (v8 * v8) * (math.sqrt(total23) / v8) * v11 * (1 - v11)
	return updateSide(v2, total22, v13, v15), updateSide(v3, total23, v14, v16), v10
end

return Rating