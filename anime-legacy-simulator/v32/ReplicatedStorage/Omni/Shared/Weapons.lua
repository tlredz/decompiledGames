local levelSettings = {
	MaxLevel = 25,
	BaseExp = 25,
	ExpFactor = 1.148,
	DamageFactor = 1.05
}
local criticalSettings = {
	Chance = 5,
	Damage = 1
}
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Shared/Breathings")
local Ultimate = require(script.Ultimate)
local PlayerStats = nil
local v3 = {
	List = {},
	Exclusives = {},
	Ultimate = Ultimate,
	LevelSettings = levelSettings,
	CriticalSettings = criticalSettings
}

local function CompilePerksArray(items)
	local v4 = 1
	local total = 0

	for _, item in items do
		if not (typeof(item) == "table" and typeof(item.Amount) == "number") then
			continue
		end

		if item.Type == "Add" then
			total += item.Amount
		else
			v4 *= item.Amount
		end
	end

	return total, v4
end

local function GetBreathingModifiers(p, p2: string, p3: string)
	local result = {}

	for _, v4 in module.GetEntries(p.Breathings) do
		local v5 = module.List[v4.Name]

		if not v5 then
			continue
		end

		local rarity = v5.Rarities[v4.Rarity]

		if not rarity then
			continue
		end

		local v6 = rarity[p2]
		local v7 = v6 and v6[p3]

		if v7 then
			table.insert(result, v7)
		end
	end

	return result
end

local function GetPlayerDamage(p)
	if not PlayerStats then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		PlayerStats = require(ReplicatedStorage.Omni.Utils.PlayerStats)
	end

	return PlayerStats.PlayerDamage(p)
end

function v3.NormalizeData(p)
	for _, v4 in p.Weapons.List do
		if v4.Name == "Freiren's Staff" then
			v4.Name = "Freiren Staff"
		end

		module.NormalizeState(v4.Breathings)
	end

	local weapon = p.Index and p.Index.Weapon

	if weapon and weapon["Freiren's Staff"] then
		weapon["Freiren Staff"] = (weapon["Freiren Staff"] or 0) + weapon["Freiren's Staff"]
		weapon["Freiren's Staff"] = nil
	end
end

function v3.IsConfigured(p: string)
	local v4 = v3.List[p]
	return v4 ~= nil and v4.Configured ~= false and #v4.Hits > 0
end

function v3.CanAutoManage(p: string)
	return not not v3.List[p] and p ~= "Melee" and v3.Exclusives[p] == nil
end

function v3.GetWeaponBreathingsPerks(p, p2: string)
	return (GetBreathingModifiers(p, "Perks", p2))
end

function v3.GetWeaponBreathingsAttributes(p, p2: string)
	return (GetBreathingModifiers(p, "Attributes", p2))
end

function v3.GetMaxLevel(p)
	local v4, v5 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p, "Max Level"))
	return (math.max(1, (math.floor((levelSettings.MaxLevel + v4) * v5))))
end

function v3.GetEffectiveLevel(p)
	return (math.clamp(math.floor(p.Level or 1), 1, v3.GetMaxLevel(p)))
end

function v3.GetExpGain(p)
	local v4, v5 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p, "Exp Gain"))
	return (math.max(0, (v4 + 1) * v5))
end

function v3.GetCriticalChance(p)
	local v4, v5 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p, "Critical Chance"))
	return (math.clamp((criticalSettings.Chance + v4 * 100) * v5, 0, 100))
end

function v3.GetCriticalDamage(p)
	local v4, v5 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p, "Critical Damage"))
	return (math.max(0, (criticalSettings.Damage + v4) * v5))
end

function v3.GetNeededExpForLevel(p: number)
	local v4 = math.max(0, p - 2)
	return (math.max(1, (math.floor(levelSettings.BaseExp * levelSettings.ExpFactor ^ v4))))
end

function v3.GetLevelDamageMultiplier(p)
	local effectiveLevel = v3.GetEffectiveLevel(p)
	return 1 + (levelSettings.DamageFactor - 1) * (effectiveLevel - 1)
end

function v3.SystemSolver(p: string, p2)
	local equipped = p2.Weapons.Equipped

	if not equipped then
		return {}
	end

	local v4 = p2.Weapons.List[equipped]

	if v4 then
		return v3.GetWeaponBreathingsPerks(v4, p)
	end

	return {}
end

function v3.Register(name: string, state, mapName: string?)
	if v3.List[name] then
		warn((`Repeated Weapon: {name}!`))
		return
	end

	if not state.Hits then
		warn((`No Hits for Weapon: {name}!`))
		return
	end

	if not state.Name then
		state.Name = name
	end

	if not state.Rarity then
		state.Rarity = "Common"
	end

	if not state.Icon then
		state.Icon = ""
	end

	if not state.MapName and typeof(mapName) == "string" then
		state.MapName = mapName
	end

	state.CombatSound = state.CombatSound or "Punch"
	v3.List[name] = state
end

function v3.GetHitTiming(p: number, p2)
	local v4 = v3.List[p2.Name]
	local v5 = v4 and v4.Hits[p]
	local cooldown, delay

	if v5 then
		cooldown = v5.Cooldown or 0
		delay = v5.Delay or 0
	else
		cooldown = 1
		delay = 0
	end

	local v6, v7 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p2, "Attack Speed"))
	local v8 = (v6 + 1) * v7
	return cooldown / v8, delay / v8, v8
end

function v3.GetSolvedHit(p: number, p2, p3, p4: number?)
	local v4 = v3.List[p2.Name]
	local v5 = v4 and v4.Hits[p]
	local v6 = not v5 and 1 or v5.Damage or 1
	local v7, v8 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p2, "Damage"))
	local hitTiming, delay, animationSpeed = v3.GetHitTiming(p, p2)
	local v12 = (v6 + v7) * v8 * v3.GetLevelDamageMultiplier(p2)

	if not p4 then
		if not PlayerStats then
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			PlayerStats = require(ReplicatedStorage.Omni.Utils.PlayerStats)
		end

		p4 = PlayerStats.PlayerDamage(p3)
	end

	return {
		Damage = v12 * p4,
		Cooldown = hitTiming,
		Delay = delay,
		AnimationSpeed = animationSpeed
	}
end

function v3.GetAverageDamage(p, p2, p3: number?)
	local v4 = v3.List[p.Name]

	if not v4 or #v4.Hits <= 0 then
		return 0
	end

	if not p3 then
		if not PlayerStats then
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			PlayerStats = require(ReplicatedStorage.Omni.Utils.PlayerStats)
		end

		p3 = PlayerStats.PlayerDamage(p2)
	end

	local total = 0

	for i = 1, #v4.Hits do
		total += v3.GetSolvedHit(i, p, p2, p3).Damage
	end

	return total / #v4.Hits
end

function v3.GetUltimateDamage(p: number, p2, p3, p4: number?)
	local v4, v5 = CompilePerksArray(v3.GetWeaponBreathingsAttributes(p2, "Damage"))
	local v6 = (p + v4) * v5 * v3.GetLevelDamageMultiplier(p2)

	if p4 then
		return v6 * p4
	end

	if not PlayerStats then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		PlayerStats = require(ReplicatedStorage.Omni.Utils.PlayerStats)
	end

	p4 = PlayerStats.PlayerDamage(p3)
	return v6 * p4
end

function v3.GetUltimateTotalDamage(p, p2, p3: number?)
	local v4 = v3.List[p.Name]
	local ultimate = v4 and v4.Ultimate

	if not (ultimate and Ultimate.Validate(ultimate)) then
		return 0
	end

	if not p3 then
		if not PlayerStats then
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			PlayerStats = require(ReplicatedStorage.Omni.Utils.PlayerStats)
		end

		p3 = PlayerStats.PlayerDamage(p2)
	end

	local v5 = 0
	local v6 = nil
	local v7 = nil
	local total = 0

	for _, phas in ultimate.Phases do
		local damage = phas.Damage
		local v8 = v5 + phas.Duration
		local v9

		if damage then
			v9 = v5 + (damage.Immediate and 0 or damage.Interval) or nil
		end

		if damage and not damage.Immediate and v7 and damage.Interval == v7.Interval then
			v6 = v6 or v9
		else
			v6 = v9
		end

		if damage then
			local ultimateDamage = v3.GetUltimateDamage(damage.Amount, p, p2, p3)

			while v6 < v8 do
				total += ultimateDamage
				v6 += damage.Interval
			end
		end

		v7 = damage
		v5 = v8
	end

	return total
end

function v3.GetDPS(p, p2, p3: number?)
	local v4 = v3.List[p.Name]

	if not v4 or #v4.Hits <= 1 then
		return 0
	end

	if not p3 then
		if not PlayerStats then
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			PlayerStats = require(ReplicatedStorage.Omni.Utils.PlayerStats)
		end

		p3 = PlayerStats.PlayerDamage(p2)
	end

	local total = 0
	local total2 = 0

	for i = 1, #v4.Hits do
		local solvedHit = v3.GetSolvedHit(i, p, p2, p3)
		total += solvedHit.Damage

		if i > 1 then
			total2 += solvedHit.Cooldown
		end
	end

	if total2 <= 0 then
		return 0
	end

	local v5 = total / total2
	local ultimate = v4.Ultimate

	if not (ultimate and Ultimate.Validate(ultimate)) then
		return v5
	end

	local cooldown = ultimate.Cooldown

	for _, phas in ultimate.Phases do
		if phas.AllowAttacks then
			cooldown += phas.Duration
		end
	end

	local v6 = Ultimate.GetDuration(ultimate) + ultimate.Cooldown

	if v6 <= 0 then
		return v5
	end

	return (v3.GetUltimateTotalDamage(p, p2, p3) + v5 * cooldown) / v6
end

function v3.GetAverageSPA(p, _)
	local v4 = v3.List[p.Name]

	if not v4 or #v4.Hits <= 0 then
		return 0
	end

	local total = 0

	for i = 1, #v4.Hits do
		total += v3.GetHitTiming(i, p)
	end

	return total / #v4.Hits
end

return table.freeze(v3)