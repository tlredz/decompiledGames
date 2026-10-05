local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardChase = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardChase
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage2.Packages.t)
local GuardChasePolicy = {
	GetWakingDuration = function()
		return guardChase.WAKING_DURATION
	end,
	ResolveHitDistance = function(p: number?)
		t.strict(t.optional(t.number))(p)
		local v = p or guardChase.DEFAULT_HIT_DISTANCE
		assert(v > 0)
		return v
	end,
	ResolveWalkSpeed = function(p: number, p2: number, p3: number)
		t.strict(t.number)(p)
		t.strict(t.number)(p2)
		t.strict(t.number)(p3)
		assert(p > 0)
		assert(p2 > 0)
		assert(p3 >= 0)
		local v = math.max(p2, 0.001)

		if p3 <= v then
			return p
		end

		return (math.min(
			p * (1 + (p3 / v - 1) * guardChase.DISTANCE_MULTIPLIER_STRENGTH),
			p * guardChase.MAX_DISTANCE_MULTIPLIER
		))
	end
}

function GuardChasePolicy.ResolveCatchDuration(p: number, p2: number, p3: number, p4: number, p5: number)
	t.strict(t.number)(p)
	t.strict(t.number)(p2)
	t.strict(t.number)(p3)
	t.strict(t.number)(p4)
	t.strict(t.number)(p5)
	assert(p > 0)
	assert(p2 > 0)
	assert(p3 > 0)
	assert(p4 >= 0)
	assert(p5 >= 0)

	if p4 <= p3 then
		return 0
	end

	if GuardChasePolicy.ResolveWalkSpeed(p, p2, p3) <= p5 then
		return nil
	end

	local v = math.max(p2, 0.001)
	local v2 = v * (1 + (guardChase.MAX_DISTANCE_MULTIPLIER - 1) / guardChase.DISTANCE_MULTIPLIER_STRENGTH)
	local total = 0
	local v3 = math.max(p3, v2)

	if v3 < p4 then
		total += (p4 - v3) / (p * guardChase.MAX_DISTANCE_MULTIPLIER - p5)
	end

	local v4 = math.max(p3, v)
	local v5 = math.min(p4, v2)

	if v4 < v5 then
		local v6 = p * guardChase.DISTANCE_MULTIPLIER_STRENGTH / v
		local v7 = p * (1 - guardChase.DISTANCE_MULTIPLIER_STRENGTH)
		total += math.log((v7 + v6 * v5 - p5) / (v7 + v6 * v4 - p5)) / v6
	end

	local v6 = math.min(p4, v)

	if p3 < v6 then
		total += (v6 - p3) / (p - p5)
	end

	return total
end

return GuardChasePolicy