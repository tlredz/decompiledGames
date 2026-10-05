local MachineEffects = require(game.ReplicatedStorage.Modules.Gameplay.MachineEffects)
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

	local multiplier = MachineEffects.ComputeMultiplier({}, "DecodeSpeed")

	if multiplier == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"no effects -> decode 1",
			tostring(1),
			(tostring(multiplier))
		))
	end

	local multiplier2 = MachineEffects.ComputeMultiplier({}, "SkillCheckChance")

	if multiplier2 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"no effects -> chance 1",
			tostring(1),
			(tostring(multiplier2))
		))
	end

	local multiplier3 = MachineEffects.ComputeMultiplier({
		BrushaBoosted = true
	}, "DecodeSpeed")

	if multiplier3 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"boost -> decode 1 (moved to extractor)",
			tostring(1),
			(tostring(multiplier3))
		))
	end

	local multiplier4 = MachineEffects.ComputeMultiplier({
		BrushaBoosted = true
	}, "SkillCheckChance")

	if multiplier4 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"boost -> chance 1 (moved to extractor)",
			tostring(1),
			(tostring(multiplier4))
		))
	end

	local multiplier5 = MachineEffects.ComputeMultiplier({
		BrushaDebuffed = true
	}, "SkillCheckChance")

	if multiplier5 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"graffiti -> chance mult neutral",
			tostring(1),
			(tostring(multiplier5))
		))
	end

	local multiplier6 = MachineEffects.ComputeMultiplier({
		BrushaDebuffed = true
	}, "DecodeSpeed")

	if multiplier6 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"graffiti does not touch decode",
			tostring(1),
			(tostring(multiplier6))
		))
	end

	local multiplier7 = MachineEffects.ComputeMultiplier({
		BrushaBoosted = true,
		BrushaDebuffed = true
	}, "SkillCheckChance")

	if multiplier7 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"both -> chance mult neutral",
			tostring(1),
			(tostring(multiplier7))
		))
	end

	local multiplier8 = MachineEffects.ComputeMultiplier({
		BrushaBoosted = true
	}, "NoSuchStat")

	if multiplier8 == 1 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"unknown stat -> 1",
			tostring(1),
			(tostring(multiplier8))
		))
	end

	local additive = MachineEffects.ComputeAdditive({}, "SkillCheckChance")

	if additive == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"add: no effects -> 0",
			tostring(0),
			(tostring(additive))
		))
	end

	local additive2 = MachineEffects.ComputeAdditive({
		BrushaDebuffed = true
	}, "SkillCheckChance")

	if additive2 == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"add: graffiti -> 0 (moved to extractor)",
			tostring(0),
			(tostring(additive2))
		))
	end

	local additive3 = MachineEffects.ComputeAdditive({
		BrushaBoosted = true
	}, "SkillCheckChance")

	if additive3 == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format("  FAIL: %s | expected=%s actual=%s", "add: boost -> 0", tostring(0), (tostring(additive3))))
	end

	local additive4 = MachineEffects.ComputeAdditive({
		BrushaBoosted = true,
		BrushaDebuffed = true
	}, "SkillCheckChance")

	if additive4 == 0 then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"add: both -> 0 (moved to extractor)",
			tostring(0),
			(tostring(additive4))
		))
	end

	local function fakeMachine(p)
		return {
			GetAttribute = function(_, p2)
				return p[p2]
			end
		}
	end

	local v = {}
	local activeArt = MachineEffects.GetActiveArt({
		GetAttribute = function(_, p)
			return v[p]
		end
	})

	if activeArt == nil then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"active art none",
			tostring(nil),
			(tostring(activeArt))
		))
	end

	local v2 = {
		BrushaDebuffed = true
	}
	local activeArt2 = MachineEffects.GetActiveArt({
		GetAttribute = function(_, p)
			return v2[p]
		end
	})

	if activeArt2 == "BrushaGraffiti" then
		count += 1
	else
		count2 += 1
		warn(string.format(
			"  FAIL: %s | expected=%s actual=%s",
			"active art graffiti",
			tostring("BrushaGraffiti"),
			(tostring(activeArt2))
		))
	end

	print(string.format("MachineEffects_test: %d/%d PASS", count, count + count2))
	return count2 == 0
end