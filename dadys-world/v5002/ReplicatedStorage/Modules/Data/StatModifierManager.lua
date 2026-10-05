local StatModifierManager = {}
StatModifierManager.__index = StatModifierManager
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local count = 0
local _ = {
	DEBUG_LOGGING = false,
	UPDATE_ATTRIBUTES = true,
	AUTO_CLEANUP_ON_DEATH = true,
	CLEANUP_DELAY = 0.5,
	FLOAT_PRECISION = 6
}

-- equivalent calls inferred from this helper; original call sites unknown
local function roundToDecimal(p)
	return math.round(p * 1000000) / 1000000
end

-- equivalent calls inferred from this helper; original call sites unknown
local function generateId(p)
	count += 1
	return string.format("%s_%d_%d", p, count, math.floor(tick() * 1000) % 10000)
end

local function debugLog(...) end

local function disableAntiCheat(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return false
	end

	v2[character] = (v2[character] or 0) + 1
	local bindables = ServerStorage:FindFirstChild("Bindables")
	local removeCharacterAntiExploitModule = bindables and bindables:FindFirstChild("RemoveCharacterAntiExploitModule")

	if not removeCharacterAntiExploitModule then
		return v2[character] > 0
	end

	removeCharacterAntiExploitModule:Fire(playerFromCharacter, true)
	debugLog("Anti-cheat disabled for", character.Name)
	return true
end

local function enableAntiCheat(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return
	end

	v2[character] = math.max(0, (v2[character] or 0) - 1)

	if v2[character] == 0 then
		local bindables = ServerStorage:FindFirstChild("Bindables")
		local removeCharacterAntiExploitModule = bindables and bindables:FindFirstChild("RemoveCharacterAntiExploitModule")

		if removeCharacterAntiExploitModule then
			removeCharacterAntiExploitModule:Fire(playerFromCharacter, false)
			debugLog("Anti-cheat re-enabled for", character.Name)
		end

		v2[character] = nil
	end
end

local function updateModifierAttribute(instance, childName)
	if not (instance and instance.Parent) then
		return
	end

	local v7 = v[instance] and v[instance][childName]

	if v7 and next(v7) ~= nil then
		local v8 = 1
		local v9 = {}

		for _, v10 in pairs(v7) do
			v8 *= v10.multiplier
			table.insert(v9, string.format("%s(x%.3f)", v10.source, v10.multiplier))
		end

		instance:SetAttribute("StatMod_" .. childName, roundToDecimal(v8))
		instance:SetAttribute("StatMod_" .. childName .. "_Sources", table.concat(v9, ", "))
	else
		instance:SetAttribute("StatMod_" .. childName, nil)
		instance:SetAttribute("StatMod_" .. childName .. "_Sources", nil)
	end
end

local function initializeCharacterTracking(instance)
	if v[instance] then
		return
	end

	v[instance] = {}
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			task.defer(function()
				StatModifierManager.ClearAllModifiers(instance, "CharacterRemoved")
				v2[instance] = nil
				v5[instance] = nil
				v6[instance] = nil
				ancestryChangedConnection:Disconnect()
			end)
		end
	end)
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.Died:Once(function()
			task.delay(0.5, function()
				StatModifierManager.ClearAllModifiers(instance, "HumanoidDied")
			end)
		end)
	end
end

local function getStatValue(instance, childName)
	local stats = instance:FindFirstChild("Stats")

	if not stats then
		return nil
	end

	local child = stats:FindFirstChild(childName)
	return child or nil
end

local function fn(instance, childName)
	if not (instance and childName) then
		return
	end

	local success, result = pcall(function()
		if not instance.Parent then
			return
		end

		if not v5[instance] then
			v5[instance] = {}
		end

		if v5[instance][childName] == nil then
			local v7 = v6[instance]

			if v7 and v7[childName] ~= nil then
				v5[instance][childName] = v7[childName]
				debugLog("Using registered base for", instance.Name, childName, "=", v7[childName])
			else
				local v8 = childName
				local stats = instance:FindFirstChild("Stats")
				local child

				if stats then
					child = stats:FindFirstChild(v8) or nil
				end

				if child then
					v5[instance][childName] = child.Value
					warn(
						"[StatModifierManager] No registered base for",
						instance.Name,
						childName,
						"- captured from stat.Value:",
						child.Value
					)
				end
			end
		end
	end)

	if not success then
		warn("[StatModifierManager] captureBaseValue failed:", result)
	end
end

local function fn2(instance, childName)
	local v7 = v6[instance]
	local v8

	if v7 and v7[childName] ~= nil then
		v8 = v7[childName]
	else
		local v9 = v5[instance]

		if not v9 or v9[childName] == nil then
			return
		end

		v8 = v9[childName]
	end

	local stats = instance:FindFirstChild("Stats")
	local child

	if stats then
		child = stats:FindFirstChild(childName) or nil
	end

	if not child then
		return
	end

	local total = 0
	local v9 = v4[instance] and v4[instance][childName]

	if v9 then
		for _, v10 in pairs(v9) do
			total += v10.amount
		end
	end

	local v10 = 1
	local v11 = v[instance] and v[instance][childName]

	if v11 then
		for _, v12 in pairs(v11) do
			v10 *= v12.multiplier
		end
	end

	child.Value = roundToDecimal((v8 + total) * v10)
	debugLog(string.format(
		"Recalculate %s for %s: base=%.2f + add=%.2f * mult=%.4f = %.2f",
		childName,
		instance.Name,
		v8,
		total,
		v10,
		child.Value
	))
end

local function fn3(p, p2)
	if not v5[p] then
		return
	end

	local v7 = v[p] and v[p][p2] and next(v[p][p2])
	local v8 = v4[p] and v4[p][p2] and next(v4[p][p2])

	if not (v7 or v8) then
		v5[p][p2] = nil

		if next(v5[p]) == nil then
			v5[p] = nil
		end
	end
end

local function handleOverrideMode(instance, childName, category, priority)
	local v7 = v[instance] and v[instance][childName]

	if not v7 then
		return
	end

	local v8 = {}

	for k, v9 in pairs(v7) do
		if v9.mode == "override" and v9.category == category and (v9.priority or 0) <= priority then
			table.insert(v8, k)
		end
	end

	for _, v9 in ipairs(v8) do
		StatModifierManager.RemoveModifier(instance, childName, v9)
	end
end

function StatModifierManager.ApplyModifier(instance, childName, multiplier, source, options)
	local v7 = options or {}

	if not instance then
		warn("[StatModifierManager] ApplyModifier: No character provided")
		return nil
	end

	if not childName or childName == "" then
		warn("[StatModifierManager] ApplyModifier: No statName provided")
		return nil
	end

	if not multiplier or multiplier <= 0 then
		warn("[StatModifierManager] ApplyModifier: Invalid multiplier:", multiplier)
		return nil
	end

	if not source or source == "" then
		warn("[StatModifierManager] ApplyModifier: No source provided")
		return nil
	end

	if v7.unique then
		StatModifierManager.RemoveModifiersBySource(instance, source, true, childName)
	end

	local stats = instance:FindFirstChild("Stats")
	local child

	if stats then
		child = stats:FindFirstChild(childName) or nil
	end

	if not child then
		warn("[StatModifierManager] ApplyModifier: Stat not found:", childName)
		return nil
	end

	local mode = v7.mode or "blend"
	local category = v7.category or "default"
	local antiCheat = v7.antiCheat or false
	local priority = v7.priority or 0
	local duration = v7.duration
	initializeCharacterTracking(instance)

	if not v[instance][childName] then
		v[instance][childName] = {}
	end

	local antiCheatActive

	if antiCheat then
		antiCheatActive = disableAntiCheat(instance)
	else
		antiCheatActive = false
	end

	if mode == "override" then
		handleOverrideMode(instance, childName, category, priority)
	end

	local id = generateId(source) -- equivalent call inferred; original call site unknown
	fn(instance, childName)
	v[instance][childName][id] = {
		multiplier = multiplier,
		source = source,
		appliedAt = tick(),
		mode = mode,
		category = category,
		priority = priority,
		antiCheatActive = antiCheatActive
	}
	local value = child.Value
	fn2(instance, childName)
	updateModifierAttribute(instance, childName)
	debugLog(string.format(
		"Applied %s to %s: %.3f -> %.3f (x%.3f from %s, mode=%s, duration=%s)",
		childName,
		instance.Name,
		value,
		child.Value,
		multiplier,
		source,
		mode,
		not duration and "permanent" or duration .. "s" or "permanent"
	))

	if duration and duration > 0 then
		v3[id] = task.delay(duration, function()
			v3[id] = nil

			if instance and instance.Parent then
				StatModifierManager.RemoveModifier(instance, childName, id)
			end
		end)
	end

	return id
end

function StatModifierManager.RemoveModifier(instance, childName, p)
	if not (instance and v[instance]) then
		return false
	end

	local v7 = v[instance][childName]

	if not v7 then
		warn("[StatModifierManager] RemoveModifier: Stat not tracked:", childName)
		return false
	end

	local v8 = v7[p]

	if not v8 then
		warn("[StatModifierManager] RemoveModifier: Modifier not found:", p)
		return false
	end

	local stats = instance:FindFirstChild("Stats")
	local child

	if stats then
		child = stats:FindFirstChild(childName) or nil
	end

	v7[p] = nil

	if child then
		local value = child.Value
		fn2(instance, childName)
		debugLog(string.format(
			"Removed %s from %s: %.3f -> %.3f (/%.3f from %s)",
			childName,
			instance.Name,
			value,
			child.Value,
			v8.multiplier,
			v8.source
		))
	end

	if v8.antiCheatActive then
		enableAntiCheat(instance)
	end

	if v3[p] then
		task.cancel(v3[p])
		v3[p] = nil
	end

	updateModifierAttribute(instance, childName)

	if next(v7) == nil then
		v[instance][childName] = nil
	end

	fn3(instance, childName)
	return true
end

function StatModifierManager.RemoveModifiersBySource(p, list, p2, p3)
	if not (p and v[p]) then
		return 0
	end

	local v7 = p2 ~= false
	local v8 = {}
	local count2 = 0

	for k, v9 in pairs(v[p]) do
		if not (not p3 or k == p3) then
			continue
		end

		for k2, v10 in pairs(v9) do
			local v11

			if v7 then
				v11 = v10.source == list
			else
				v11 = v10.source == list or string.sub(v10.source, 1, #list + 1) == list .. "_"
			end

			if v11 then
				table.insert(v8, {
					statName = k,
					modifierId = k2
				})
			end
		end
	end

	for _, v9 in ipairs(v8) do
		if StatModifierManager.RemoveModifier(p, v9.statName, v9.modifierId) then
			count2 += 1
		end
	end

	return count2
end

function StatModifierManager.ClearAllModifiers(p, value)
	if not v[p] then
		return
	end

	local count2 = 0
	local v7 = {}
	local v8 = value or "Manual"

	for k, v9 in pairs(v[p]) do
		for k2, v10 in pairs(v9) do
			count2 += 1

			if v3[k2] then
				task.cancel(v3[k2])
				v3[k2] = nil
			end

			if v10.antiCheatActive then
				enableAntiCheat(p)
			end
		end

		table.insert(v7, k)
	end

	v[p] = nil

	for _, v9 in ipairs(v7) do
		if not (v5[p] and v5[p][v9] ~= nil) then
			continue
		end

		fn2(p, v9)
		fn3(p, v9)
	end

	if StatModifierManager.ClearAllAdditiveModifiers then
		StatModifierManager.ClearAllAdditiveModifiers(p, v8)
	end
end

function StatModifierManager.RegisterCharacter(p, items)
	if not p then
		warn("[StatModifierManager] RegisterCharacter: No character provided")
		return
	end

	if not items or type(items) ~= "table" then
		warn("[StatModifierManager] RegisterCharacter: Invalid baseValues")
		return
	end

	v6[p] = {}

	for k, item in pairs(items) do
		v6[p][k] = item
	end

	initializeCharacterTracking(p)
	debugLog("Registered base values for", p.Name)
end

function StatModifierManager.HasModifier(p, p2)
	if not v[p] then
		return false
	end

	for _, v7 in pairs(v[p]) do
		if v7[p2] then
			return true
		end
	end

	return false
end

function StatModifierManager.HasModifiersFromSource(p, list)
	if not v[p] then
		return false
	end

	for _, v7 in pairs(v[p]) do
		for _, v8 in pairs(v7) do
			if v8.source == list or string.sub(v8.source, 1, #list) == list then
				return true
			end
		end
	end

	return false
end

function StatModifierManager.GetActiveModifiers(instance)
	if RunService:IsServer() then
		if not v[instance] then
			return {}
		end

		local result = {}

		for k, v7 in pairs(v[instance]) do
			result[k] = {}

			for k2, v8 in pairs(v7) do
				result[k][k2] = {
					multiplier = v8.multiplier,
					source = v8.source,
					appliedAt = v8.appliedAt
				}
			end
		end

		return result
	else
		if not instance then
			return {}
		end

		local result = {}

		for _, v7 in ipairs({
			"SpeedModifier",
			"RunSpeedModifier",
			"StaminaModifier",
			"StaminaRegenModifier",
			"BoundarySize",
			"BoundarySizeModifier",
			"DecodeSpeedModifier",
			"StealthModifier"
		}) do
			local attribute = instance:GetAttribute("StatMod_" .. v7)
			local attribute2 = instance:GetAttribute("StatMod_" .. v7 .. "_Sources")

			if not (attribute and attribute2 and attribute2 ~= "") then
				continue
			end

			result[v7] = {}

			for k in string.gmatch(attribute2, "[^,]+") do
				local v8 = string.gsub(k, "^%s+", "")
				local source, v10 = string.match(v8, "(.+)%(x([%d%.]+)%)")

				if not (source and v10) then
					continue
				end

				local v11 = source .. "_attr"
				result[v7][v11] = {
					multiplier = tonumber(v10) or 1,
					source = source,
					appliedAt = tick()
				}
			end
		end

		return result
	end
end

function StatModifierManager.GetTotalMultiplier(p, p2)
	if not (v[p] and v[p][p2]) then
		return 1
	end

	local v7 = 1

	for _, v8 in pairs(v[p][p2]) do
		v7 *= v8.multiplier
	end

	return roundToDecimal(v7)
end

function StatModifierManager.DebugPrint(_) end

function StatModifierManager.ApplySpeedModifiers(p, p2, p3, p4)
	return {
		speedModifierId = StatModifierManager.ApplyModifier(p, "SpeedModifier", p2, p3, p4),
		runSpeedModifierId = StatModifierManager.ApplyModifier(p, "RunSpeedModifier", p2, p3, p4)
	}
end

function StatModifierManager.RemoveSpeedModifiers(p, p2)
	if not p2 then
		return
	end

	if p2.speedModifierId then
		StatModifierManager.RemoveModifier(p, "SpeedModifier", p2.speedModifierId)
	end

	if p2.runSpeedModifierId then
		StatModifierManager.RemoveModifier(p, "RunSpeedModifier", p2.runSpeedModifierId)
	end
end

function StatModifierManager.ApplyAllStatModifiers(instance, currentStaminaMultiplier, p, p2, p3)
	local v7 = {
		speedModifierId = StatModifierManager.ApplyModifier(instance, "SpeedModifier", currentStaminaMultiplier, p, p3),
		runSpeedModifierId = StatModifierManager.ApplyModifier(
			instance,
			"RunSpeedModifier",
			currentStaminaMultiplier,
			p,
			p3
		),
		staminaModifierId = StatModifierManager.ApplyModifier(
			instance,
			"StaminaModifier",
			currentStaminaMultiplier,
			p,
			p3
		),
		boundaryModifierId = StatModifierManager.ApplyModifier(
			instance,
			"BoundarySize",
			currentStaminaMultiplier,
			p,
			p3
		),
		decodeModifierId = StatModifierManager.ApplyModifier(
			instance,
			"DecodeSpeedModifier",
			currentStaminaMultiplier,
			p,
			p3
		),
		stealthModifierId = StatModifierManager.ApplyModifier(
			instance,
			"StealthModifier",
			currentStaminaMultiplier,
			p,
			p3
		)
	}

	if not p2 then
		return v7
	end

	local stats = instance:FindFirstChild("Stats")
	local currentStamina = stats and stats:FindFirstChild("CurrentStamina")

	if currentStamina then
		currentStamina.Value *= currentStaminaMultiplier
		v7.currentStaminaBoosted = true
		v7.currentStaminaMultiplier = currentStaminaMultiplier
	end

	return v7
end

function StatModifierManager.RemoveAllStatModifiers(instance, data)
	if not data then
		return
	end

	if data.speedModifierId then
		StatModifierManager.RemoveModifier(instance, "SpeedModifier", data.speedModifierId)
	end

	if data.runSpeedModifierId then
		StatModifierManager.RemoveModifier(instance, "RunSpeedModifier", data.runSpeedModifierId)
	end

	if data.staminaModifierId then
		StatModifierManager.RemoveModifier(instance, "StaminaModifier", data.staminaModifierId)
	end

	if data.boundaryModifierId then
		StatModifierManager.RemoveModifier(instance, "BoundarySize", data.boundaryModifierId)
	end

	if data.decodeModifierId then
		StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", data.decodeModifierId)
	end

	if data.stealthModifierId then
		StatModifierManager.RemoveModifier(instance, "StealthModifier", data.stealthModifierId)
	end

	if data.currentStaminaBoosted and data.currentStaminaMultiplier then
		local stats = instance:FindFirstChild("Stats")
		local currentStamina = stats and stats:FindFirstChild("CurrentStamina")

		if currentStamina then
			currentStamina.Value /= data.currentStaminaMultiplier
		end
	end
end

function StatModifierManager.ApplyStaminaRegenModifier(p, p2, p3, p4)
	return StatModifierManager.ApplyModifier(p, "StaminaRegenModifier", p2, p3, p4)
end

function StatModifierManager.RemoveStaminaRegenModifier(p, p2)
	return StatModifierManager.RemoveModifier(p, "StaminaRegenModifier", p2)
end

local v7 = {
	"WalkSpeed",
	"RunSpeed",
	"Stealth",
	"BoundarySize",
	"SkillCheckChance",
	"DecodeSpeed"
}

local function updateAdditiveModifierAttribute(instance, childName)
	if not (instance and instance.Parent) then
		return
	end

	local v8 = v4[instance] and v4[instance][childName]

	if v8 and next(v8) ~= nil then
		local total = 0
		local v9 = {}

		for _, v10 in pairs(v8) do
			total += v10.amount
			local v11 = v10.amount >= 0 and "+" or ""
			table.insert(v9, string.format("%s(%s%g)", v10.source, v11, v10.amount))
		end

		instance:SetAttribute("StatAdd_" .. childName, total)
		instance:SetAttribute("StatAdd_" .. childName .. "_Sources", table.concat(v9, ", "))
	else
		instance:SetAttribute("StatAdd_" .. childName, nil)
		instance:SetAttribute("StatAdd_" .. childName .. "_Sources", nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBaseStatValue(instance, childName)
	local stats = instance:FindFirstChild("Stats")

	if stats then
		return stats:FindFirstChild(childName)
	end

	return nil
end

function StatModifierManager.ApplyAdditiveModifier(instance, childName, amount, source, options)
	local v8 = options or {}

	if not instance then
		warn("[StatModifierManager] ApplyAdditiveModifier: No character provided")
		return nil
	end

	if not childName or childName == "" then
		warn("[StatModifierManager] ApplyAdditiveModifier: No statName provided")
		return nil
	end

	if not amount or amount == 0 then
		warn("[StatModifierManager] ApplyAdditiveModifier: Invalid amount:", amount)
		return nil
	end

	if not source or source == "" then
		warn("[StatModifierManager] ApplyAdditiveModifier: No source provided")
		return nil
	end

	if v8.unique then
		StatModifierManager.RemoveAdditiveModifiersBySource(instance, source, childName)
	end

	local baseStatValue = getBaseStatValue(instance, childName) -- equivalent call inferred; original call site unknown

	if not baseStatValue then
		warn("[StatModifierManager] ApplyAdditiveModifier: Stat not found:", childName)
		return nil
	end

	initializeCharacterTracking(instance)

	if not v4[instance] then
		v4[instance] = {}
	end

	if not v4[instance][childName] then
		v4[instance][childName] = {}
	end

	local antiCheatActive

	if v8.antiCheat then
		antiCheatActive = disableAntiCheat(instance)
	else
		antiCheatActive = false
	end

	local id = generateId(source .. "_add") -- equivalent call inferred; original call site unknown
	fn(instance, childName)
	v4[instance][childName][id] = {
		amount = amount,
		source = source,
		appliedAt = tick(),
		antiCheatActive = antiCheatActive
	}
	local value = baseStatValue.Value
	fn2(instance, childName)
	updateAdditiveModifierAttribute(instance, childName)
	debugLog(string.format(
		"Applied ADDITIVE %s to %s: %.2f -> %.2f (%+g from %s)",
		childName,
		instance.Name,
		value,
		baseStatValue.Value,
		amount,
		source
	))
	local duration = v8.duration

	if duration and duration > 0 then
		v3[id] = task.delay(duration, function()
			v3[id] = nil

			if instance and instance.Parent then
				StatModifierManager.RemoveAdditiveModifier(instance, childName, id)
			end
		end)
	end

	return id
end

function StatModifierManager.RemoveAdditiveModifier(instance, childName, p)
	if not (instance and v4[instance]) then
		warn("[StatModifierManager] RemoveAdditiveModifier: Character not tracked")
		return false
	end

	local v8 = v4[instance][childName]

	if not v8 then
		warn("[StatModifierManager] RemoveAdditiveModifier: Stat not tracked:", childName)
		return false
	end

	local v9 = v8[p]

	if not v9 then
		warn("[StatModifierManager] RemoveAdditiveModifier: Modifier not found:", p)
		return false
	end

	local baseStatValue = getBaseStatValue(instance, childName) -- equivalent call inferred; original call site unknown
	v8[p] = nil

	if baseStatValue then
		local value = baseStatValue.Value
		fn2(instance, childName)
		debugLog(string.format(
			"Removed ADDITIVE %s from %s: %.1f -> %.1f (-%g from %s)",
			childName,
			instance.Name,
			value,
			baseStatValue.Value,
			v9.amount,
			v9.source
		))
	end

	if v9.antiCheatActive then
		enableAntiCheat(instance)
	end

	if v3[p] then
		task.cancel(v3[p])
		v3[p] = nil
	end

	updateAdditiveModifierAttribute(instance, childName)

	if next(v8) == nil then
		v4[instance][childName] = nil
	end

	fn3(instance, childName)
	return true
end

function StatModifierManager.RemoveAdditiveModifiersBySource(p, p2, p3)
	if not (p and v4[p]) then
		return 0
	end

	local v8 = {}
	local count2 = 0

	for k, v9 in pairs(v4[p]) do
		if not (not p3 or k == p3) then
			continue
		end

		for k2, v10 in pairs(v9) do
			if v10.source == p2 then
				table.insert(v8, {
					statName = k,
					modifierId = k2
				})
			end
		end
	end

	for _, v9 in ipairs(v8) do
		if StatModifierManager.RemoveAdditiveModifier(p, v9.statName, v9.modifierId) then
			count2 += 1
		end
	end

	return count2
end

function StatModifierManager.GetActiveAdditiveModifiers(instance)
	if RunService:IsServer() then
		if not v4[instance] then
			return {}
		end

		local result = {}

		for k, v8 in pairs(v4[instance]) do
			result[k] = {}

			for k2, v9 in pairs(v8) do
				result[k][k2] = {
					amount = v9.amount,
					source = v9.source,
					appliedAt = v9.appliedAt
				}
			end
		end

		return result
	else
		if not instance then
			return {}
		end

		local result = {}

		for _, v8 in ipairs(v7) do
			local attribute = instance:GetAttribute("StatAdd_" .. v8)
			local attribute2 = instance:GetAttribute("StatAdd_" .. v8 .. "_Sources")

			if not (attribute and attribute2 and attribute2 ~= "") then
				continue
			end

			result[v8] = {}

			for k in string.gmatch(attribute2, "[^,]+") do
				local v9 = string.gsub(k, "^%s+", "")
				local source, v11, v12 = string.match(v9, "(.+)%(([%+%-])([%d%.]+)%)")

				if not (source and v12) then
					continue
				end

				local amount = tonumber(v12) or 0

				if v11 == "-" then
					amount = -amount
				end

				local v14 = source .. "_add_attr"
				result[v8][v14] = {
					amount = amount,
					source = source,
					appliedAt = tick()
				}
			end
		end

		return result
	end
end

function StatModifierManager.ClearAllAdditiveModifiers(p, value)
	if not v4[p] then
		return
	end

	local count2 = 0
	local v8 = {}
	local v9 = value or "Manual"

	for k, v10 in pairs(v4[p]) do
		for k2, v11 in pairs(v10) do
			count2 += 1

			if v3[k2] then
				task.cancel(v3[k2])
				v3[k2] = nil
			end

			if v11.antiCheatActive then
				enableAntiCheat(p)
			end
		end

		table.insert(v8, k)
	end

	v4[p] = nil

	for _, v10 in ipairs(v8) do
		if not (v5[p] and v5[p][v10] ~= nil) then
			continue
		end

		fn2(p, v10)
		fn3(p, v10)
	end

	if count2 > 0 then
		debugLog(string.format("Cleared %d additive modifiers for %s (reason: %s)", count2, p.Name, v9))
	end
end

function StatModifierManager.ApplyAdditiveSpeedBoost(p, p2, p3, p4)
	return {
		walkSpeedModId = StatModifierManager.ApplyAdditiveModifier(p, "WalkSpeed", p2, p3, p4),
		runSpeedModId = StatModifierManager.ApplyAdditiveModifier(p, "RunSpeed", p2, p3, p4)
	}
end

function StatModifierManager.RemoveAdditiveSpeedBoost(p, p2)
	if not p2 then
		return
	end

	if p2.walkSpeedModId then
		StatModifierManager.RemoveAdditiveModifier(p, "WalkSpeed", p2.walkSpeedModId)
	end

	if p2.runSpeedModId then
		StatModifierManager.RemoveAdditiveModifier(p, "RunSpeed", p2.runSpeedModId)
	end
end

function StatModifierManager.ApplyAdditiveStealthModifier(p, p2, p3, p4)
	return StatModifierManager.ApplyAdditiveModifier(p, "Stealth", p2, p3, p4)
end

function StatModifierManager.RemoveAdditiveStealthModifier(p, p2)
	return StatModifierManager.RemoveAdditiveModifier(p, "Stealth", p2)
end

function StatModifierManager.ApplyAdditiveBoundarySize(p, p2, p3, p4)
	return StatModifierManager.ApplyAdditiveModifier(p, "BoundarySize", p2, p3, p4)
end

function StatModifierManager.RemoveAdditiveBoundarySize(p, p2)
	return StatModifierManager.RemoveAdditiveModifier(p, "BoundarySize", p2)
end

function StatModifierManager.ApplyAdditiveSkillCheckChance(p, p2, p3, p4)
	return StatModifierManager.ApplyAdditiveModifier(p, "SkillCheckChance", p2, p3, p4)
end

function StatModifierManager.RemoveAdditiveSkillCheckChance(p, p2)
	return StatModifierManager.RemoveAdditiveModifier(p, "SkillCheckChance", p2)
end

function StatModifierManager.ApplyAdditiveDecodeSpeed(p, p2, p3, p4)
	return StatModifierManager.ApplyAdditiveModifier(p, "DecodeSpeed", p2, p3, p4)
end

function StatModifierManager.RemoveAdditiveDecodeSpeed(p, p2)
	return StatModifierManager.RemoveAdditiveModifier(p, "DecodeSpeed", p2)
end

local function reconcileCharacter(instance)
	local v8 = v6[instance]

	if not (v8 and instance.Parent) then
		return 0
	end

	local stats = instance:FindFirstChild("Stats")

	if not stats then
		return 0
	end

	local count2 = 0

	for childName, v9 in pairs(v8) do
		local child = stats:FindFirstChild(childName)

		if not child then
			continue
		end

		local total = 0
		local v10 = v4[instance] and v4[instance][childName]

		if v10 then
			for _, v11 in pairs(v10) do
				total += v11.amount
			end
		end

		local v11 = 1
		local v12 = v[instance] and v[instance][childName]

		if v12 then
			for _, v13 in pairs(v12) do
				v11 *= v13.multiplier
			end
		end

		local v13 = roundToDecimal((v9 + total) * v11) -- equivalent call inferred; original call site unknown

		if not (math.abs(v13 - child.Value) > 0.001) then
			continue
		end

		warn(string.format(
			"[StatModifierManager] DRIFT DETECTED %s.%s: actual=%.6f expected=%.6f (base=%.4f +%.4f x%.6f). Correcting.",
			instance.Name,
			childName,
			child.Value,
			v13,
			v9,
			total,
			v11
		))
		child.Value = v13
		count2 += 1
	end

	return count2
end

function StatModifierManager.ForceReconcile(p)
	if not p then
		return 0
	end

	local success, result = pcall(reconcileCharacter, p)

	if success then
		return result
	end

	warn("[StatModifierManager] ForceReconcile failed:", result)
	return 0
end

function StatModifierManager.ReconcileAll()
	local total = 0

	for k in pairs(v6) do
		local success, result = pcall(reconcileCharacter, k)

		if success then
			total += result
		else
			warn("[StatModifierManager] ReconcileAll failed for", k.Name, ":", result)
		end
	end

	return total
end

if RunService:IsServer() then
	task.spawn(function()
		while true do
			task.wait(5)
			local success, result = pcall(function()
				for k in pairs(v6) do
					pcall(reconcileCharacter, k)
				end
			end)

			if not success then
				warn("[StatModifierManager] Validation loop error:", result)
			end
		end
	end)
end

return StatModifierManager