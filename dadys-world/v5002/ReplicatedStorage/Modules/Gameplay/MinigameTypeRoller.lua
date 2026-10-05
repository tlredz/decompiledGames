local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MinigameTypeRoller = {
	rollForFloor = function(value)
		local v = value or 1
		local v2 = math.random(1, 100)

		if v >= 10 then
			if v2 <= 35 then
				return "Original"
			end

			if v2 <= 70 then
				return "Circle"
			end

			if v2 <= 85 then
				return "MovementTreadmill"
			end

			return "Barnaby"
		elseif v >= 5 then
			if v2 <= 50 then
				return "Original"
			end

			if v2 <= 80 then
				return "Circle"
			end

			if v2 <= 90 then
				return "MovementTreadmill"
			end

			return "Barnaby"
		elseif v >= 2 then
			if v2 <= 70 then
				return "Original"
			end

			return "Circle"
		else
			return "Original"
		end
	end
}

function MinigameTypeRoller.rollForFloorExcludingTreadmill(p)
	local rollForFloor = MinigameTypeRoller.rollForFloor(p)

	if rollForFloor ~= "MovementTreadmill" then
		return rollForFloor
	end

	if math.random(1, 100) <= 70 then
		return "Original"
	end

	return "Circle"
end

function MinigameTypeRoller.rollHeterogeneousPair()
	local ServerStorage = game:GetService("ServerStorage")
	local DOUBLE_COMBO_POOL = require(ServerStorage.Modules.Data.MultiGenConfig).DOUBLE_COMBO_POOL

	if not DOUBLE_COMBO_POOL or #DOUBLE_COMBO_POOL == 0 then
		warn("[MinigameTypeRoller] DOUBLE_COMBO_POOL empty — cannot roll heterogeneous pair")
		return nil, nil
	end

	local v = DOUBLE_COMBO_POOL[math.random(1, #DOUBLE_COMBO_POOL)]

	if math.random() < 0.5 then
		return v[1], v[2]
	end

	return v[2], v[1]
end

function MinigameTypeRoller.rollHeterogeneousForFloor(p, value)
	local rollForFloor = MinigameTypeRoller.rollForFloor(p)

	for _ = 1, value or 8 do
		local rollForFloor2 = MinigameTypeRoller.rollForFloor(p)

		if rollForFloor2 ~= rollForFloor then
			return rollForFloor, rollForFloor2
		end
	end

	return rollForFloor, rollForFloor
end

function MinigameTypeRoller.rollHeterogeneousAllTypes()
	local v = { "Original", "Circle", "MovementTreadmill" }
	local v2 = math.random(1, #v)
	local v3 = v[v2]
	local v4 = {}

	for i, v5 in ipairs(v) do
		if i ~= v2 then
			table.insert(v4, v5)
		end
	end

	return v3, v4[math.random(1, #v4)]
end

function MinigameTypeRoller.rollPerSlotIndependent(p, p2)
	return p2 or MinigameTypeRoller.rollForFloor(p), (MinigameTypeRoller.rollForFloor(p))
end

function MinigameTypeRoller.rollComboRowDriven(value, value2)
	local ServerStorage = game:GetService("ServerStorage")
	local MultiGenConfig = require(ServerStorage.Modules.Data.MultiGenConfig)
	local MachineSpawnResolver = require(ReplicatedStorage.Modules.Gameplay.MachineSpawnResolver)
	local comboRow = MachineSpawnResolver.findComboRow(MultiGenConfig, "DUAL")
	local v = not comboRow and 0 or MachineSpawnResolver.resolveChance(
		MultiGenConfig,
		comboRow,
		value or 1,
		value2 or 1
	) or 0

	if v > 0 and math.random() * 100 <= v then
		return MinigameTypeRoller.rollHeterogeneousForFloor(value)
	end

	local rollForFloor = MinigameTypeRoller.rollForFloor(value)
	return rollForFloor, rollForFloor
end

return MinigameTypeRoller