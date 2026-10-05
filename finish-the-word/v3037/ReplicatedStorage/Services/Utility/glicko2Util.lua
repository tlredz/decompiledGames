local import = _G.import("rankedConstants")
local exp = math.exp
local log = math.log
local sqrt = math.sqrt
local abs = math.abs
local GLICKO = import.GLICKO

local function solveSigma(p, p2, p3, p4, TAU, EPS)
	local v2 = log(p2 * p2)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function f(p5)
		local v3 = exp(p5)
		return v3 * (p3 * p3 - p * p - p4 - v3) / (2 * (p * p + p4 + v3) * (p * p + p4 + v3)) - (p5 - v2) / (TAU * TAU)
	end

	local v3 = p3 * p3
	local v4, v5

	if p * p + p4 < v3 then
		v4 = log(p3 * p3 - p * p - p4)
		v5 = v2
	else
		local v6 = 1
		v4 = v2 - v6 * TAU
		v5 = v2

		while true do
			if not (f(v4) > 0) then
				break
			end

			v6 += 1
			v4 = v2 - v6 * TAU

			if v6 > 50 then
				break
			end
		end
	end

	local v6 = f(v5) -- equivalent call inferred; original call site unknown
	local v7 = f(v4) -- equivalent call inferred; original call site unknown

	while true do
		if not (EPS < abs(v4 - v5)) then
			break
		end

		local v9 = v5 + (v5 - v4) * v6 / (v7 - v6)
		local v10 = f(v9) -- equivalent call inferred; original call site unknown

		if v10 * v7 < 0 then
			v6 = v7
			v5 = v4
		else
			v6 /= 2
		end

		v7 = v10
		v4 = v9
	end

	return (exp(v5 / 2))
end

local Glicko2Util = {
	muToRating = function(p)
		return 1500 + p * GLICKO.SCALE
	end,
	ratingToMu = function(p)
		return (p - 1500) / GLICKO.SCALE
	end,
	phiToRD = function(p)
		return p * GLICKO.SCALE
	end,
	rdToPhi = function(p)
		return p / GLICKO.SCALE
	end,
	g = function(p)
		return 1 / sqrt(1 + 3 * p * p / 9.869604401089358)
	end
}

function Glicko2Util.expected(p, p2, p3)
	return 1 / (exp(-Glicko2Util.g(p3) * (p - p2)) + 1)
end

function Glicko2Util.conservativeMu(p, p2)
	return p - GLICKO.CONS_K * p2
end

function Glicko2Util.teamAggregate(list)
	local total = 0
	local total2 = 0
	local count = 0

	for _, v in ipairs(list) do
		local mu = v.Mu
		local phi = v.Phi
		local v2

		if type(mu) == "number" then
			v2 = type(phi) == "number"
		else
			v2 = false
		end

		if not v2 then
			continue
		end

		total += mu
		total2 += phi * phi
		count += 1
	end

	if count == 0 then
		return 0, 0
	end

	return total / count, sqrt(total2) / count
end

function Glicko2Util.update(p, p2, p3, p4, p5, p6)
	local v = Glicko2Util.g(p5)
	local v3 = 1 / (exp(-v * (p - p4)) + 1)
	local v4 = 1 / (v * v * v3 * (1 - v3))
	local v6 = solveSigma(p2, p3, v4 * v * (p6 - v3), v4, GLICKO.TAU, GLICKO.EPS)
	local v8 = sqrt(p2 * p2 + v6 * v6)
	local v10 = 1 / sqrt(1 / (v8 * v8) + 1 / v4)
	return p + v10 * v10 * v * (p6 - v3), v10, v6, v3
end

return Glicko2Util