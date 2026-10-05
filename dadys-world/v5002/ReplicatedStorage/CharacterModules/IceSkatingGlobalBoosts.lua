local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IceSkatingGlobalBoosts = {
	Counts = {},
	HasBuff = {},
	ModifierIds = {}
}
local v = nil

local function getStatModifierManager()
	if not v then
		local success, result = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("StatModifierManager"))
		end)

		if success then
			v = result
		end
	end

	return v
end

local function debugLog(...) end

local function applyBuffsOnce(p, value)
	debugLog("applyBuffsOnce called for", p.Name)

	if IceSkatingGlobalBoosts.HasBuff[p] then
		debugLog("  WARNING: Already has buff, skipping apply!")
		return false
	end

	if not v then
		local success, result = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("StatModifierManager"))
		end)

		if success then
			v = result
		end
	end

	local v2 = v

	if not v2 then
		warn("[IceSkatingGlobalBoosts] StatModifierManager not found!")
		return false
	end

	local v3 = value or 1.15
	debugLog("  Applying multiplier via StatModifierManager:", v3)
	local v4 = v2.ApplySpeedModifiers(p, v3, "IceSkating", {
		category = "event",
		antiCheat = true
	})

	if not (v4 and v4.speedModifierId) then
		debugLog("  ERROR: StatModifierManager failed to apply modifiers!")
		return false
	end

	IceSkatingGlobalBoosts.HasBuff[p] = true
	IceSkatingGlobalBoosts.ModifierIds[p] = v4
	print("[IceSkatingGlobalBoosts] Applied speed boost to", p.Name, "multiplier:", v3)
	return true
end

local function removeBuffsOnce(instance)
	debugLog("removeBuffsOnce called for", instance.Name)

	if not IceSkatingGlobalBoosts.HasBuff[instance] then
		debugLog("  WARNING: No buff to remove! HasBuff is nil/false")
		return false
	end

	local modifierId = IceSkatingGlobalBoosts.ModifierIds[instance]

	if modifierId then
		if not v then
			local success, result = pcall(function()
				return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("StatModifierManager"))
			end)

			if success then
				v = result
			end
		end

		local v2 = v

		if v2 and instance and instance.Parent then
			v2.RemoveSpeedModifiers(instance, modifierId)
			print("[IceSkatingGlobalBoosts] Removed speed boost from", instance.Name)
		else
			debugLog("  WARNING: StatModifierManager missing or character destroyed")
		end

		IceSkatingGlobalBoosts.HasBuff[instance] = nil
		IceSkatingGlobalBoosts.ModifierIds[instance] = nil
		return true
	else
		debugLog("  WARNING: No modifier IDs stored!")
		IceSkatingGlobalBoosts.HasBuff[instance] = nil
		return false
	end
end

function IceSkatingGlobalBoosts.AddBoost(p, p2)
	if not p then
		return false
	end

	IceSkatingGlobalBoosts.Counts[p] = (IceSkatingGlobalBoosts.Counts[p] or 0) + 1
	return IceSkatingGlobalBoosts.Counts[p] == 1 and applyBuffsOnce(p, p2)
end

function IceSkatingGlobalBoosts.RemoveBoost(p)
	if not p then
		return false
	end

	local count = IceSkatingGlobalBoosts.Counts[p]

	if not count or count <= 0 then
		return false
	end

	IceSkatingGlobalBoosts.Counts[p] = count - 1

	if IceSkatingGlobalBoosts.Counts[p] ~= 0 then
		return false
	end

	IceSkatingGlobalBoosts.Counts[p] = nil
	return (removeBuffsOnce(p))
end

function IceSkatingGlobalBoosts.HasBoost(p)
	return IceSkatingGlobalBoosts.HasBuff[p] == true
end

function IceSkatingGlobalBoosts.GetBoostCount(p)
	return IceSkatingGlobalBoosts.Counts[p] or 0
end

function IceSkatingGlobalBoosts.CleanupCharacter(p)
	if not p then
		return
	end

	removeBuffsOnce(p)
	IceSkatingGlobalBoosts.Counts[p] = nil
	IceSkatingGlobalBoosts.HasBuff[p] = nil
	IceSkatingGlobalBoosts.ModifierIds[p] = nil
end

function IceSkatingGlobalBoosts.CleanupAll()
	print("[IceSkatingGlobalBoosts] Cleaning up all active boosts")
	local v2 = {}

	for k, _ in pairs(IceSkatingGlobalBoosts.HasBuff) do
		table.insert(v2, k)
	end

	for _, v3 in ipairs(v2) do
		IceSkatingGlobalBoosts.CleanupCharacter(v3)
	end

	IceSkatingGlobalBoosts.Counts = {}
	IceSkatingGlobalBoosts.HasBuff = {}
	IceSkatingGlobalBoosts.ModifierIds = {}
	print("[IceSkatingGlobalBoosts] Cleanup complete")
end

function IceSkatingGlobalBoosts.GetStatus()
	local count = 0

	for _ in pairs(IceSkatingGlobalBoosts.HasBuff) do
		count += 1
	end

	local total = 0

	for _, count2 in pairs(IceSkatingGlobalBoosts.Counts) do
		total += count2
	end

	return {
		buffedCharacters = count,
		totalBoostSources = total
	}
end

return IceSkatingGlobalBoosts