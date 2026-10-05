local StatManager = {}
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local v = {
	SpeedModifier = 1,
	RunSpeedModifier = 1,
	StaminaRegenModifier = 1,
	MaxStamina = nil
}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}

local function fn(...)
	print("[StatManager]", ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModifierKey(instance, p, p2)
	return (typeof(instance) == "Instance" and instance.UserId or tostring(instance)) .. "-" .. p .. "-" .. p2
end

local function ensurePlayerTables(player)
	if not v4[player] then
		v4[player] = {}
	end

	if not v3[player] then
		v3[player] = {}
	end
end

local function resolvePlayer(value)
	if typeof(value) == "number" then
		local Players = game:GetService("Players")
		return Players:GetPlayerByUserId(value)
	end

	if typeof(value) ~= "string" then
		return value
	end

	local v7 = tonumber(value)

	if v7 then
		local Players = game:GetService("Players")
		return Players:GetPlayerByUserId(v7)
	end

	local Players = game:GetService("Players")
	return Players:FindFirstChild(value)
end

function StatManager.GetBaseValue(p, childName)
	local player = resolvePlayer(p)

	if not player then
		return v[childName] or 1
	end

	if v3[player] and v3[player][childName] ~= nil then
		return v3[player][childName]
	end

	local character = player.Character

	if not character then
		return v[childName] or 1
	end

	local stats = character:FindFirstChild("Stats")

	if not stats then
		return v[childName] or 1
	end

	local child = stats:FindFirstChild(childName)

	if not child then
		return v[childName] or 1
	end

	ensurePlayerTables(player)
	v3[player][childName] = child.Value
	return child.Value
end

function StatManager.UpdateBaseValue(p, p2, p3)
	local player = resolvePlayer(p)

	if not player then
		return
	end

	ensurePlayerTables(player)
	v3[player][p2] = p3
	StatManager.RecalculateStat(player, p2)
end

function StatManager.AddModifier(p, sourceId, statType, modifierType, p5, duration, p6)
	local player = resolvePlayer(p)

	if not player then
		fn("Failed to add modifier - invalid player")
		return nil
	end

	local modifierKey = getModifierKey(player, sourceId, statType) -- equivalent call inferred; original call site unknown

	if v6[modifierKey] then
		task.cancel(v6[modifierKey])
		v6[modifierKey] = nil
	end

	local now = os.time()
	local expiryTime

	if duration then
		expiryTime = now + duration or nil
	end

	local v9 = {
		player = player,
		sourceId = sourceId,
		statType = statType,
		modifierType = modifierType,
		value = p5,
		expiryTime = expiryTime,
		createdAt = now,
		zoneBound = p6 or false
	}
	v2[modifierKey] = v9
	ensurePlayerTables(player)

	if not v4[player][statType] then
		v4[player][statType] = {}
	end

	v4[player][statType][modifierKey] = v9

	if not v5[sourceId] then
		v5[sourceId] = {}
	end

	v5[sourceId][modifierKey] = v9

	if duration then
		v6[modifierKey] = task.delay(duration, function()
			fn("Auto-removing expired modifier", modifierKey)
			StatManager.RemoveModifier(player, sourceId, statType)
		end)
	end

	StatManager.RecalculateStat(player, statType)
	fn("Added modifier", modifierKey, "value:", p5, "duration:", duration or "permanent")
	return modifierKey
end

function StatManager.RemoveModifier(p, p2, p3)
	local player = resolvePlayer(p)

	if not player then
		fn("Failed to remove modifier - invalid player")
		return false
	end

	local modifierKey = getModifierKey(player, p2, p3) -- equivalent call inferred; original call site unknown

	if v6[modifierKey] then
		task.cancel(v6[modifierKey])
		v6[modifierKey] = nil
	end

	if not v2[modifierKey] then
		fn("Modifier not found", modifierKey)
		return false
	end

	local _ = v2[modifierKey]

	if v4[player] and v4[player][p3] then
		v4[player][p3][modifierKey] = nil

		if next(v4[player][p3]) == nil then
			v4[player][p3] = nil
		end

		if next(v4[player]) == nil then
			v4[player] = nil
		end
	end

	if v5[p2] then
		v5[p2][modifierKey] = nil

		if next(v5[p2]) == nil then
			v5[p2] = nil
		end
	end

	v2[modifierKey] = nil
	StatManager.RecalculateStat(player, p3)
	fn("Removed modifier", modifierKey)
	return true
end

function StatManager.RemoveAllModifiersFromSource(p, p2)
	if p then
		p = resolvePlayer(p)

		if not p then
			fn("Failed to remove modifiers - invalid player")
			return 0
		end
	end

	if not v5[p2] then
		fn("No modifiers found for source", p2)
		return 0
	end

	local v7 = {}
	local v8 = {}
	local count = 0

	for k, v9 in pairs(v5[p2]) do
		v7[k] = v9
	end

	for k, v9 in pairs(v7) do
		if not (not p or v9.player == p) then
			continue
		end

		v8[v9.player] = v8[v9.player] or {}
		v8[v9.player][v9.statType] = true

		if v6[k] then
			task.cancel(v6[k])
			v6[k] = nil
		end

		if v4[v9.player] and v4[v9.player][v9.statType] then
			v4[v9.player][v9.statType][k] = nil

			if next(v4[v9.player][v9.statType]) == nil then
				v4[v9.player][v9.statType] = nil
			end

			if next(v4[v9.player]) == nil then
				v4[v9.player] = nil
			end
		end

		v5[p2][k] = nil
		v2[k] = nil
		count += 1
	end

	if next(v5[p2]) == nil then
		v5[p2] = nil
	end

	for k, v9 in pairs(v8) do
		for k2, _ in pairs(v9) do
			StatManager.RecalculateStat(k, k2)
		end
	end

	fn("Removed", count, "modifiers from source", p2)
	return count
end

function StatManager.RemoveAllZoneModifiers(p)
	local player = resolvePlayer(p)

	if not player then
		fn("Failed to remove zone modifiers - invalid player")
		return 0
	end

	if not v4[player] then
		return 0
	end

	local v7 = {}
	local v8 = {}
	local count = 0

	for k, v9 in pairs(v4[player]) do
		for k2, v10 in pairs(v9) do
			if not v10.zoneBound then
				continue
			end

			table.insert(v7, k2)
			v8[k] = true
		end
	end

	for _, v9 in ipairs(v7) do
		local v10 = v2[v9]

		if v6[v9] then
			task.cancel(v6[v9])
			v6[v9] = nil
		end

		if v5[v10.sourceId] then
			v5[v10.sourceId][v9] = nil

			if next(v5[v10.sourceId]) == nil then
				v5[v10.sourceId] = nil
			end
		end

		if v4[player][v10.statType] then
			v4[player][v10.statType][v9] = nil

			if next(v4[player][v10.statType]) == nil then
				v4[player][v10.statType] = nil
			end
		end

		v2[v9] = nil
		count += 1
	end

	if next(v4[player]) == nil then
		v4[player] = nil
	end

	for k, _ in pairs(v8) do
		StatManager.RecalculateStat(player, k)
	end

	fn("Removed", count, "zone-bound modifiers for player", player.Name)
	return count
end

function StatManager.RecalculateStat(p, childName)
	local player = resolvePlayer(p)

	if not player then
		fn("Failed to recalculate stat - invalid player")
		return
	end

	local character = player.Character

	if not character then
		fn("Failed to recalculate stat - no character for player", player.Name)
		return
	end

	local stats = character:FindFirstChild("Stats")

	if not stats then
		fn("Failed to recalculate stat - no Stats folder for player", player.Name)
		return
	end

	local child = stats:FindFirstChild(childName)

	if not child then
		fn("Failed to recalculate stat - no", childName, "value for player", player.Name)
		return
	end

	local value = StatManager.GetBaseValue(player, childName)

	if v4[player] and v4[player][childName] then
		for _, v7 in pairs(v4[player][childName]) do
			if v7.modifierType ~= "add" then
				continue
			end

			value += v7.value
			fn("Applied add modifier", v7.value, "to", childName, "for player", player.Name)
		end

		for _, v7 in pairs(v4[player][childName]) do
			if v7.modifierType ~= "multiply" then
				continue
			end

			value *= v7.value
			fn("Applied multiply modifier", v7.value, "to", childName, "for player", player.Name)
		end

		local v7 = {}

		for _, v8 in pairs(v4[player][childName]) do
			if v8.modifierType == "set" then
				table.insert(v7, v8)
			end
		end

		table.sort(v7, function(a, b)
			return a.createdAt > b.createdAt
		end)

		if #v7 > 0 then
			value = v7[1].value
			fn("Applied set modifier", value, "to", childName, "for player", player.Name)
		end

		if childName == "SpeedModifier" or childName == "RunSpeedModifier" then
			value = math.max(value, 0.1)
		end

		child.Value = value
		fn("Final", childName, "value set to", value, "for player", player.Name)
	else
		child.Value = value
		fn("Set", childName, "to base value", value, "for player", player.Name)
	end
end

function StatManager.CleanupExpiredModifiers()
	local now = os.time()
	local v7 = {}
	local v8 = {}

	for k, v9 in pairs(v2) do
		if not (v9.expiryTime and v9.expiryTime <= now) then
			continue
		end

		table.insert(v7, k)
		v8[v9.player] = v8[v9.player] or {}
		v8[v9.player][v9.statType] = true
	end

	for _, v9 in ipairs(v7) do
		local v10 = v2[v9]

		if v4[v10.player] and v4[v10.player][v10.statType] then
			v4[v10.player][v10.statType][v9] = nil

			if next(v4[v10.player][v10.statType]) == nil then
				v4[v10.player][v10.statType] = nil
			end

			if next(v4[v10.player]) == nil then
				v4[v10.player] = nil
			end
		end

		if v5[v10.sourceId] then
			v5[v10.sourceId][v9] = nil

			if next(v5[v10.sourceId]) == nil then
				v5[v10.sourceId] = nil
			end
		end

		if v6[v9] then
			task.cancel(v6[v9])
			v6[v9] = nil
		end

		v2[v9] = nil
		fn("Cleaned up expired modifier", v9)
	end

	for k, v9 in pairs(v8) do
		for k2, _ in pairs(v9) do
			StatManager.RecalculateStat(k, k2)
		end
	end

	return #v7
end

function StatManager.GetActiveModifiers(p)
	local player = resolvePlayer(p)

	if not (player and v4[player]) then
		return {}
	end

	local result = {}

	for k, v7 in pairs(v4[player]) do
		result[k] = {}

		for _, v8 in pairs(v7) do
			local v9 = result[k]
			local v10 = {
				sourceId = v8.sourceId,
				modifierType = v8.modifierType,
				value = v8.value,
				expiryTime = v8.expiryTime,
				remainingTime = 0,
				zoneBound = 0
			}
			local remainingTime

			if v8.expiryTime then
				remainingTime = v8.expiryTime - os.time() or nil
			end

			v10.remainingTime = remainingTime
			v10.zoneBound = v8.zoneBound
			table.insert(v9, v10)
		end
	end

	return result
end

function StatManager.CleanupPlayerModifiers(p)
	local player = resolvePlayer(p)

	if not (player and v4[player]) then
		return
	end

	local v7 = {}

	for _, v8 in pairs(v4[player]) do
		for k, _ in pairs(v8) do
			table.insert(v7, k)
		end
	end

	for _, v8 in ipairs(v7) do
		local v9 = v2[v8]

		if v5[v9.sourceId] then
			v5[v9.sourceId][v8] = nil

			if next(v5[v9.sourceId]) == nil then
				v5[v9.sourceId] = nil
			end
		end

		if v6[v8] then
			task.cancel(v6[v8])
			v6[v8] = nil
		end

		v2[v8] = nil
	end

	v4[player] = nil
	v3[player] = nil
	fn("Cleaned up", #v7, "modifiers for player", player.Name)
end

task.spawn(function()
	while true do
		task.wait(0.5)
		StatManager.CleanupExpiredModifiers()
	end
end)
local Players = game:GetService("Players")
Players.PlayerRemoving:Connect(function(player)
	StatManager.CleanupPlayerModifiers(player)
end)
fn("StatManager loaded")
return StatManager