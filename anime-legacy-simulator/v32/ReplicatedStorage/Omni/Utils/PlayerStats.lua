local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Table = require(ReplicatedStorage.Omni.Utils.Table)
require("@game/ReplicatedStorage/Omni/DataTemplate")
local Multipliers = require(ReplicatedStorage.Omni.Utils.Multipliers)
local Info = require(ReplicatedStorage.Omni.Utils.Info)
local Shared = require(ReplicatedStorage.Omni.Shared)
local fighters = workspace.Server.Fighters
RunService:IsStudio()
RunService:IsServer()
RunService:IsClient()
local v = {
	GetCurrentMapInfo = function(p)
		return Shared.Gamemodes.List[p.Gamemode] or Shared.Maps.List[p.Maps.Current] or {}
	end,
	OwnsMap = function(value: string, p)
		if type(value) ~= "string" then
			return false
		end

		local v2 = Shared.Maps.List[value]

		if not v2 then
			return false
		end

		if p.Maps.List[value] or v2.Free == true then
			return true
		end

		return false
	end,
	GetDropMap = function(data)
		if typeof(data) ~= "table" then
			return
		end

		if typeof(data.MapName) == "string" then
			return data.MapName
		end

		local v2 = Info:Get(data.Type, data.Name)

		if typeof(v2) == "table" and typeof(v2.MapName) == "string" then
			return v2.MapName
		end

		if data.Type == "SacredArtefact" or data.Type == "SacredArtefacts" then
			return Shared.SacredArtefacts.Map
		end
	end
}

function v.CanObtainDrop(p, p2)
	if typeof(p) ~= "table" then
		return false
	end

	if p.CancelMapLimitation == true then
		return true
	end

	local dropMap = v.GetDropMap(p)

	if dropMap then
		return v.OwnsMap(dropMap, p2)
	end

	return true
end

function v.GetFighterTargets(p, p2)
	local result = {}

	for k in p.Fighters.Equipped do
		local child = fighters:FindFirstChild(Shared.Fighters.GetRuntimeID(p2.UserId, k))

		if not child then
			continue
		end

		local target = child:FindFirstChild("Target")

		if target then
			result[k] = target.Value
		end
	end

	return result
end

function v.GetAvailableFightersForTarget(p: string, p2, p3)
	local fighterTargets = v.GetFighterTargets(p2, p3)
	local v2 = {}

	for k, fighterTarget in fighterTargets do
		local isAttacking = fighterTarget ~= ""

		if fighterTarget ~= p then
			table.insert(v2, {
				ID = k,
				IsAttacking = isAttacking
			})
		end
	end

	table.sort(v2, function(a, b)
		return (a.IsAttacking and 0 or 1) > (b.IsAttacking and 0 or 1)
	end)
	local IDs = {}

	for k, v3 in v2 do
		IDs[k] = v3.ID
	end

	return IDs
end

function v.GetCurrentMultiName(p, p2: string)
	local currentMapInfo = v.GetCurrentMapInfo(p)

	if currentMapInfo.CustomMultipliers then
		return currentMapInfo.CustomMultipliers[p2] or p2
	end

	return p2
end

function v.MaxStarOpens(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Star Open")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (3 + multiplierAmount) * v3
end

function v.StarOpenSpeed(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Star Open Speed")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3
end

function v.GachaRolls(p, p2, p3: string, p4: string?)
	local v2 = Shared.Gacha.List[p3]

	if not v2 then
		return 1
	end

	if v2.Source.Type == "Normal" then
		local v4 = p4 or v.GetCurrentMultiName(p, (`{p3} Roll`))
		local multiplierAmount, v5 = Multipliers.GetMultiplierAmountFromSystem(v4, "All", p, p2)
		local multiplierAmount2, v6 = Multipliers.GetMultiplierAmountFromSystem("Gacha Open", "All", p, p2)
		return (1 + multiplierAmount + multiplierAmount2) * v5 * v6
	else
		return 1
	end
end

function v.GachaCooldown(p, p2, p3: string, p4: string?)
	local v2 = Shared.Gacha.List[p3]

	if not v2 then
		return 5
	end

	local v3 = p4 or v.GetCurrentMultiName(p, (`{p3} Speed`))
	local multiplierAmount, v4 = Multipliers.GetMultiplierAmountFromSystem(v3, "All", p, p2)
	local v5 = v2.Source.Type == "Normal" and 2 or v2.Source.Type == "Talents" and 1 or 1
	local multiplierAmount2, v6 = Multipliers.GetMultiplierAmountFromSystem("Gacha Open Speed", "All", p, p2)
	return v5 / ((1 + multiplierAmount) * v4 * (1 + multiplierAmount2) * v6)
end

function v.BreathingsCooldown(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Breathings Speed")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	local multiplierAmount2, v4 = Multipliers.GetMultiplierAmountFromSystem("Gacha Open Speed", "All", p, p2)
	return 2 / ((1 + multiplierAmount) * v3 * (1 + multiplierAmount2) * v4)
end

function v.TraitsCooldown(p, p2)
	local multiplierAmount, v2 = Multipliers.GetMultiplierAmountFromSystem("Gacha Open Speed", "All", p, p2)
	return Shared.Traits.Cooldown / ((1 + multiplierAmount) * v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReservedTradeSlots(p, p2: string)
	local pending = p.Trade and p.Trade.Pending

	if pending and not pending.Applied then
		return (math.max(Table:Size(pending.Outgoing[p2]), (Table:Size(pending.Incoming[p2]))))
	end

	return 0
end

function v.FightersInventory(p, p2)
	local multiplierAmount, v2 = Multipliers.GetMultiplierAmountFromSystem("Inventory Slots", "All", p, p2)
	local v3 = (100 + multiplierAmount) * v2
	local v4 = Table:Size(p.Fighters.List) + ReservedTradeSlots(p, "Fighters")
	return v3, v4, v3 - v4
end

function v.AccessoriesInventory(p, p2)
	local multiplierAmount, v2 = Multipliers.GetMultiplierAmountFromSystem("Inventory Slots", "All", p, p2)
	local v3 = (100 + multiplierAmount) * v2
	local size = Table:Size(p.Accessories.List)
	return v3, size, v3 - size
end

function v.WeaponsInventory(p, p2)
	local multiplierAmount, v2 = Multipliers.GetMultiplierAmountFromSystem("Inventory Slots", "All", p, p2)
	local v3 = (100 + multiplierAmount) * v2
	local v4 = Table:Size(p.Weapons.List) + ReservedTradeSlots(p, "Weapons")
	return v3, v4, v3 - v4
end

function v.FightersEquipped(p, p2)
	local multiplierAmount, v2 = Multipliers.GetMultiplierAmountFromSystem("Fighter Equip", "All", p, p2)
	local v3 = (3 + multiplierAmount) * v2
	local size = Table:Size(p.Fighters.Equipped)
	return v3, size, v3 - size
end

function v.TotalPower(p, _)
	local total = 0

	for k in p.Fighters.Equipped do
		local v2 = p.Fighters.List[k]

		if not v2 then
			continue
		end

		local baseInformation = Shared.Fighters.GetBaseInformation(v2, p)
		local fighterDamage = Shared.Fighters.GetFighterDamage(v2, p, baseInformation)
		local fighterSPA = Shared.Fighters.GetFighterSPA(v2, p, baseInformation)

		if not (fighterDamage <= 0 or fighterSPA <= 0) then
			total += fighterDamage / fighterSPA
		end
	end

	local v2 = p.Weapons.Equipped and p.Weapons.List[p.Weapons.Equipped]

	if not v2 then
		return total
	end

	local averageDamage = Shared.Weapons.GetAverageDamage(v2, p)
	local averageSPA = Shared.Weapons.GetAverageSPA(v2, p)

	if averageDamage > 0 and averageSPA > 0 then
		total += averageDamage / averageSPA
	end

	return total
end

function v.ShinyChance(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Shiny Chance")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (math.clamp((2.5 + multiplierAmount) * v3, 0, 100))
end

function v.RarityChance(p, p2, p3: string, p4: string?)
	local v2 = p4 or v.GetCurrentMultiName(p, (`{p3} Chance`))
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3
end

function v.MythicalChance(p, p2, p3: string?)
	return v.RarityChance(p, p2, "Mythical", p3)
end

function v.SecretChance(p, p2, p3: string?)
	return v.RarityChance(p, p2, "Secret", p3)
end

function v.GetSources(p, p2, p3: string)
	local currentMultiName = v.GetCurrentMultiName(p, p3)
	local _, _, v2 = Multipliers.GetMultiplierAmountFromSystem(currentMultiName, "All", p, p2)
	local result = {}

	for k, v3 in v2 do
		table.insert(result, {
			Name = k,
			Add = v3.Add,
			Multi = v3.Multi
		})
	end

	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

function v.AutoAttackRange(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Attack Range")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (10 + multiplierAmount) * v3
end

function v.Damage(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Damage")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3
end

function v.PlayerDamage(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Player Damage")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3 * v.Damage(p, p2)
end

function v.FighterDamage(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Fighter Damage")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3
end

function v.Yen(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Yen")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3
end

function v.Luck(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Luck")
	local multiplierAmount, v3, v4 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	local multi = v4.Potions and v4.Potions.Multi or 1
	return multiplierAmount * v3 + multi - 1
end

function v.GachaLuck(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Gacha Luck")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return multiplierAmount * v3
end

function v.Drops(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Drops")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return multiplierAmount, v3
end

function v.PlayerExp(p, p2, p3: string?)
	local v2 = p3 or v.GetCurrentMultiName(p, "Player Exp")
	local multiplierAmount, v3 = Multipliers.GetMultiplierAmountFromSystem(v2, "All", p, p2)
	return (1 + multiplierAmount) * v3
end

return table.freeze(v)