local MachineSpawnResolver = require(game.ReplicatedStorage.Modules.Gameplay.MachineSpawnResolver)
return function()
	local count = 0
	local count2 = 0

	local function check(p, p2, p3)
		if p2 == p3 then
			count += 1
			return
		end

		count2 += 1
		warn(string.format("  FAIL: %s | expected=%s actual=%s", p, tostring(p3), (tostring(p2))))
	end

	local v = {
		ENABLED = true,
		GLOBAL_DUAL_MULT_PCT = 100,
		GLOBAL_QUAD_MULT_PCT = 100,
		GLOBAL_OCTA_MULT_PCT = 100,
		PLAYER_MULT = {
			DUAL = {
				solo = 0,
				small = 100,
				medium = 150,
				large = 200
			},
			QUAD = {
				solo = 0,
				small = 0,
				medium = 100,
				large = 150
			},
			OCTA = {
				solo = 0,
				small = 0,
				medium = 50,
				large = 100
			}
		},
		SPAWN_ROWS = {
			{
				id = "DUAL45",
				family = "DUAL",
				ENABLED = true,
				BASE_CHANCE_PCT = 5,
				FLOOR_THRESHOLD = 2,
				CHANCE_PER_STEP = 2,
				INTERVAL_FLOORS = 1,
				MAX_CHANCE_PCT = 30
			},
			{
				id = "DUAL90",
				family = "DUAL",
				ENABLED = false,
				BASE_CHANCE_PCT = 0,
				FLOOR_THRESHOLD = 5,
				CHANCE_PER_STEP = 1,
				INTERVAL_FLOORS = 1,
				MAX_CHANCE_PCT = 15
			}
		},
		COMBO_ROWS = {
			{
				id = "DUAL_COMBO",
				family = "DUAL",
				ENABLED = true,
				BASE_CHANCE_PCT = 20,
				FLOOR_THRESHOLD = 2,
				CHANCE_PER_STEP = 5,
				INTERVAL_FLOORS = 2,
				MAX_CHANCE_PCT = 80
			}
		},
		RewardPolicy = {
			Eligibility = "AnyContributor",
			AmountSplit = "Proportional"
		},
		RewardPolicyOverride = {
			DUAL = {}
		}
	}
	local row = MachineSpawnResolver.findRow(v, "DUAL45")
	local row2 = MachineSpawnResolver.findRow(v, "DUAL90")
	local comboRow = MachineSpawnResolver.findComboRow(v, "DUAL")
	local bucketFor = MachineSpawnResolver.bucketFor(1)

	if bucketFor == "solo" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"bucketFor(1) == solo",
			tostring("solo"),
			(tostring(bucketFor))
		))
	end

	local bucketFor2 = MachineSpawnResolver.bucketFor(3)

	if bucketFor2 == "small" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"bucketFor(3) == small",
			tostring("small"),
			(tostring(bucketFor2))
		))
	end

	local bucketFor3 = MachineSpawnResolver.bucketFor(4)

	if bucketFor3 == "medium" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"bucketFor(4) == medium",
			tostring("medium"),
			(tostring(bucketFor3))
		))
	end

	local bucketFor4 = MachineSpawnResolver.bucketFor(8)

	if bucketFor4 == "large" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"bucketFor(8) == large",
			tostring("large"),
			(tostring(bucketFor4))
		))
	end

	local chance = MachineSpawnResolver.resolveChance(v, row, 1, 4)

	if chance == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format("  FAIL: %s | expected=%s actual=%s", "DUAL45 floor 1 = 0", tostring(0), (tostring(chance))))
	end

	local chance2 = MachineSpawnResolver.resolveChance(v, row, 5, 4)

	if chance2 == 16.5 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"DUAL45 floor 5 4p = 16.5",
			tostring(16.5),
			(tostring(chance2))
		))
	end

	local chance3 = MachineSpawnResolver.resolveChance(v, row, 100, 4)

	if chance3 == 30 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"DUAL45 floor 100 cap = 30",
			tostring(30),
			(tostring(chance3))
		))
	end

	local chance4 = MachineSpawnResolver.resolveChance(v, row, 5, 1)

	if chance4 == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"DUAL45 floor 5 solo = 0",
			tostring(0),
			(tostring(chance4))
		))
	end

	local chance5 = MachineSpawnResolver.resolveChance(v, row2, 10, 4)

	if chance5 == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"DUAL90 disabled = 0",
			tostring(0),
			(tostring(chance5))
		))
	end

	v.ENABLED = false
	local chance6 = MachineSpawnResolver.resolveChance(v, row, 10, 4)

	if chance6 == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"cfg disabled DUAL45 = 0",
			tostring(0),
			(tostring(chance6))
		))
	end

	v.ENABLED = true
	local chance7 = MachineSpawnResolver.resolveChance(v, comboRow, 20, 4)

	if chance7 == 80 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"DUAL_COMBO floor 20 4p MAX = 80",
			tostring(80),
			(tostring(chance7))
		))
	end

	local rewardPolicy = MachineSpawnResolver.resolveRewardPolicy(v, "DUAL")
	local eligibility = rewardPolicy.Eligibility

	if eligibility == "AnyContributor" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"policy Eligibility default",
			tostring("AnyContributor"),
			(tostring(eligibility))
		))
	end

	local amountSplit = rewardPolicy.AmountSplit

	if amountSplit == "Proportional" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"policy AmountSplit default",
			tostring("Proportional"),
			(tostring(amountSplit))
		))
	end

	v.RewardPolicyOverride.DUAL.AmountSplit = "Flat"
	local amountSplit2 = MachineSpawnResolver.resolveRewardPolicy(v, "DUAL").AmountSplit

	if amountSplit2 == "Flat" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"policy DUAL override Flat",
			tostring("Flat"),
			(tostring(amountSplit2))
		))
	end

	print(string.format("MachineSpawnResolver_test: %d/%d PASS", count, count + count2))
	return count2 == 0
end