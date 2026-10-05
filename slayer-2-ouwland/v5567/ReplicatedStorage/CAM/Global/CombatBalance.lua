local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Series = require(ReplicatedStorage.CAM.Global.Series)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local PVPs = {}
local CombatBalance = {}

for _, moduleScript in ReplicatedStorage.Skills:QueryDescendants("ModuleScript#Config") do
	local module = require(moduleScript)
	local PVP = module.PVP

	if PVP == nil then
		continue
	end

	PVPs[moduleScript.Parent.Name] = PVP

	for _, moduleScript2 in moduleScript.Parent:GetChildren() do
		if moduleScript2:IsA("ModuleScript") and moduleScript2 ~= moduleScript then
			PVPs[string.gsub(moduleScript2.Name, "Server$", "")] = PVP
		end
	end
end

local pvPsByName = {}

for _, v in { Series.Passives, Series.OutfitPassives } do
	for _, v2 in v do
		if v2.PvP ~= nil then
			pvPsByName[v2.Name] = v2.PvP
		end
	end
end

function CombatBalance.Block(p: string?)
	if p == nil then
		return nil
	end

	local item = Items[p]
	local v = PVPs[p]

	if v then
		return v
	end

	local v2

	if item ~= nil then
		v2 = item.PvP
	end

	return v2 or pvPsByName[p]
end

function CombatBalance.Knob(p: string?, p2: string)
	local block = CombatBalance.Block(p)
	return block ~= nil and block[p2] or 1
end

local function playerOf(player)
	if player == nil then
		return nil
	end

	if player:IsA("Player") then
		return player
	end

	return Players:GetPlayerFromCharacter(player)
end

function CombatBalance.IsPvP(playerFromCharacter, playerFromCharacter2)
	if playerFromCharacter == nil then
		playerFromCharacter = nil
	elseif not playerFromCharacter:IsA("Player") then
		playerFromCharacter = Players:GetPlayerFromCharacter(playerFromCharacter)
	end

	if playerFromCharacter2 == nil then
		playerFromCharacter2 = nil
	elseif not playerFromCharacter2:IsA("Player") then
		playerFromCharacter2 = Players:GetPlayerFromCharacter(playerFromCharacter2)
	end

	if playerFromCharacter == nil or playerFromCharacter == playerFromCharacter2 then
		return false
	end

	return playerFromCharacter2 ~= nil or CombatMode.PvPHits(playerFromCharacter)
end

function CombatBalance.HitKnob(p, p2: string?, p3: string)
	local knob = CombatBalance.Knob(p2, p3)

	if CombatMode.IsRanked(playerOf(p)) then
		knob *= CombatBalance.Knob(p2, (`Ranked{p3}`))
	end

	return knob
end

function CombatBalance.CastKnob(p, p2: string?, p3: string)
	if not CombatMode.InPvPMode(p) then
		return 1
	end

	local knob = CombatBalance.Knob(p2, p3)

	if CombatMode.IsRanked(p) then
		knob *= CombatBalance.Knob(p2, (`Ranked{p3}`))
	end

	return knob
end

function CombatBalance.IsWeighted(value: string)
	return value == "Additional Damage" or value == "Damage Reduction" or value == "Damage Reduction Factor" or string.find(
		value,
		" Damage Factor",
		1,
		true
	) ~= nil
end

local v = {
	{
		Knob = "Damage",
		Name = "damage",
		Hit = true
	},
	{
		Knob = "Base",
		Name = "base damage",
		Hit = true
	},
	{
		Knob = "AdScale",
		Name = "additional damage scaling",
		Hit = true
	},
	{
		Knob = "Stun",
		Name = "stun",
		Hit = true
	},
	{
		Knob = "StrictStun",
		Name = "strict stun",
		Hit = true
	},
	{
		Knob = "BlockDamage",
		Name = "block damage",
		Hit = true
	},
	{
		Knob = "RankedDamage",
		Name = "damage in ranked",
		Hit = true
	},
	{
		Knob = "RankedBase",
		Name = "base damage in ranked",
		Hit = true
	},
	{
		Knob = "RankedAdScale",
		Name = "additional damage scaling in ranked",
		Hit = true
	},
	{
		Knob = "RankedStun",
		Name = "stun in ranked",
		Hit = true
	},
	{
		Knob = "RankedStrictStun",
		Name = "strict stun in ranked",
		Hit = true
	},
	{
		Knob = "RankedBlockDamage",
		Name = "block damage in ranked",
		Hit = true
	},
	{
		Knob = "Cooldown",
		Name = "cooldown in arenas"
	},
	{
		Knob = "Stamina",
		Name = "stamina cost in arenas"
	},
	{
		Knob = "RankedCooldown",
		Name = "cooldown in ranked"
	},
	{
		Knob = "RankedStamina",
		Name = "stamina cost in ranked"
	},
	{
		Knob = "Stats",
		Name = "damage and defence stats"
	},
	{
		Knob = "Upgrades",
		Name = "refine and set tier bonus"
	}
}

function CombatBalance.Lines(p, p2: string, flag: boolean?)
	local result = {}

	if p == nil then
		return result
	end

	for _, v2 in v do
		local share = p[v2.Knob]

		if share ~= nil and share ~= 1 and (v2.Hit or not flag) then
			table.insert(result, {
				Label = `{p2}{v2.Name}`,
				Share = share
			})
		end
	end

	return result
end

return CombatBalance