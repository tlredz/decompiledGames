local MachineSpawnResolver = {}
local v = {
	"solo",
	"small",
	"small",
	"medium",
	"medium",
	"large",
	"large",
	"large"
}

function MachineSpawnResolver.bucketFor(value)
	return v[math.clamp(value or 1, 1, 8)] or "large"
end

function MachineSpawnResolver.resolveChance(p, data, p2, value)
	if not (p.ENABLED and data.ENABLED) or p2 < data.FLOOR_THRESHOLD then
		return 0
	end

	local v2 = math.max(data.INTERVAL_FLOORS or 1, 1)
	local v3 = math.floor((p2 - data.FLOOR_THRESHOLD) / v2)
	local v4 = (data.BASE_CHANCE_PCT or 0) + v3 * (data.CHANCE_PER_STEP or 0) + (data.PER_PLAYER_PCT or 0) * (value or 0)
	local v5 = p.PLAYER_MULT and p.PLAYER_MULT[data.family]
	return (math.clamp(
		v4 * ((v5 and v5[MachineSpawnResolver.bucketFor(value)] or 100) / 100) * ((p["GLOBAL_" .. (data.family or "DUAL") .. "_MULT_PCT"] or 100) / 100),
		0,
		data.MAX_CHANCE_PCT or 100
	))
end

function MachineSpawnResolver.findRow(p, p2)
	for _, v2 in ipairs(p.SPAWN_ROWS or {}) do
		if v2.id == p2 then
			return v2
		end
	end

	return nil
end

function MachineSpawnResolver.findComboRow(p, p2)
	for _, v2 in ipairs(p.COMBO_ROWS or {}) do
		if v2.family == p2 then
			return v2
		end
	end

	return nil
end

function MachineSpawnResolver.resolveRewardPolicy(p, value)
	local rewardPolicy = p.RewardPolicy or {}
	local v2 = p.RewardPolicyOverride and p.RewardPolicyOverride[value or "SINGLE"]
	return {
		Eligibility = v2 and v2.Eligibility or rewardPolicy.Eligibility or "AnyContributor",
		AmountSplit = v2 and v2.AmountSplit or rewardPolicy.AmountSplit or "Proportional"
	}
end

return MachineSpawnResolver