local v = {
	Common = {
		Base = 72.444,
		Factor = 1.38038,
		DeconstructAmount = 1
	},
	Uncommon = {
		Base = 79.434,
		Factor = 1.38479,
		DeconstructAmount = 2
	},
	Rare = {
		Base = 86.387,
		Factor = 1.3891,
		DeconstructAmount = 3
	},
	Epic = {
		Base = 93.345,
		Factor = 1.39269,
		DeconstructAmount = 5
	},
	Legendary = {
		Base = 100.27,
		Factor = 1.39623,
		DeconstructAmount = 8
	},
	Mythical = {
		Base = 107.154,
		Factor = 1.39985,
		DeconstructAmount = 15
	},
	Secret = {
		Base = 124.702,
		Factor = 1.40335,
		DeconstructAmount = 40
	},
	Exclusive = {
		Base = 124.702,
		Factor = 1.40335,
		DeconstructAmount = 40
	}
}
require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local Traits = require(script.Parent.Traits)
local CommerceEffects = require(script.Parent.CommerceEffects)
local v2 = {
	MaxLevel = 35,
	Exclusives = {},
	List = {}
}

function v2.Register(mapName: string, items)
	for k, item in items do
		if v2.List[k] then
			warn((`Repeated Fighter: {k}!`))
		else
			if not item.Name then
				item.Name = k
			end

			if not item.MapName then
				item.MapName = mapName
			end

			item.CombatSound = item.CombatSound or "Punch"
			local ultimateSpeed = item.UltimateSpeed
			item.UltimateSpeed = (typeof(ultimateSpeed) ~= "number" or ultimateSpeed ~= ultimateSpeed or ultimateSpeed <= 0 or ultimateSpeed == 1e999) and 1 or ultimateSpeed
			local ultimate = {}

			for k2, multiplier in item.Ultimate do
				table.insert(ultimate, {
					Time = k2,
					Multiplier = multiplier
				})
			end

			table.sort(ultimate, function(a, b)
				return a.Time < b.Time
			end)
			item.Ultimate = ultimate
			local v4 = v[item.Rarity]

			if v4 then
				item.BaseExp = v4.Base
				item.ExpFactor = v4.Factor
				item.DeconstructAmount = item.DeconstructAmount or v4.DeconstructAmount
			end

			if typeof(item.Damage) == "string" then
				item.Damage = module:Unformat(item.Damage)
			end

			v2.List[k] = item
		end
	end
end

function v2.GetStrongestBase(p)
	local list = p and p.Fighters and p.Fighters.List

	if not list then
		return nil
	end

	local v3 = 0
	local v4 = nil

	for _, v5 in list do
		local v6 = v2.List[v5.Name]

		if not v6 then
			continue
		end

		if v6.CopyStrongest or v6.Percentage or v6.Damage <= 0 or v6.SPA <= 0 then
			continue
		end

		local v7 = v6.Damage / v6.SPA

		if not (v3 < v7 or v7 == v3 and v4 and v6.Name < v4.Name) then
			continue
		end

		v4 = v6
		v3 = v7
	end

	return v4
end

function v2.GetBaseInformation(p, p2)
	local v3 = v2.List[p.Name]

	if v3 and v3.CopyStrongest then
		return v2.GetStrongestBase(p2) or v3
	end

	return v3
end

function v2.GetDisplayName(p: string, localPlayer)
	local v3 = v2.List[p] or v2.Exclusives[p]

	if not (v3 and v3.PlayerAvatar) then
		return p
	end

	if not localPlayer then
		local Players = game:GetService("Players")
		localPlayer = Players.LocalPlayer
	end

	if typeof(localPlayer) == "number" then
		local Players = game:GetService("Players")
		local playerByUserId = Players:GetPlayerByUserId(localPlayer)

		if playerByUserId then
			return playerByUserId.DisplayName
		end

		local module2 = require("@game/ReplicatedStorage/Omni/Utils/Players")
		return module2.GetPlayerInfo(localPlayer).NickName
	elseif localPlayer then
		return localPlayer.DisplayName
	else
		return p
	end
end

function v2.GetRuntimeID(p: number, p2: string)
	return (`{p}:{p2}`)
end

function v2.GetFighterSPA(p, p2, p3)
	local v3 = p3 or v2.GetBaseInformation(p, p2)

	if v3 then
		return v3.SPA / math.max(0.01, Traits.ApplyAttribute(p, "Attack Speed", 1))
	end

	return 1
end

function v2.GetFighterDamage(p, p2, p3)
	local v3 = p3 or v2.GetBaseInformation(p, p2)

	if not v3 then
		return 1
	end

	if v3.CopyStrongest then
		return 0
	end

	local damage = v3.Damage

	if p.Shiny then
		damage *= 1.5
	end

	local v4 = damage * 1.195 ^ (v2.GetFighterEffectiveLevel(p, p2) - 1)
	return (math.max(0, (math.floor((Traits.ApplyAttribute(p, "Damage", v4))))))
end

function v2.GetFighterUltHits(p, p2, p3)
	local v3 = p3 or v2.GetBaseInformation(p, p2)

	if v3 then
		return (math.max(1, (math.floor((Traits.ApplyAttribute(p, "Ultimate Hits", v3.UltHits))))))
	end

	return 1
end

function v2.GetFighterUltMultiplier(p, p2, p3)
	local v3 = p3 or v2.GetBaseInformation(p, p2)

	if not v3 then
		return 1
	end

	if v3.CopyStrongest then
		return 0
	end

	return (math.max(0, Traits.ApplyAttribute(p, "Ultimate Damage", v3.UltMultiplier)))
end

function v2.GetFighterDPS(p, p2)
	local baseInformation = v2.GetBaseInformation(p, p2)

	if not baseInformation then
		return 0
	end

	local fighterSPA = v2.GetFighterSPA(p, p2, baseInformation)
	local fighterDamage = v2.GetFighterDamage(p, p2, baseInformation)
	local fighterUltHits = v2.GetFighterUltHits(p, p2, baseInformation)
	local fighterUltMultiplier = v2.GetFighterUltMultiplier(p, p2, baseInformation)
	local v3 = 0
	local total = 0

	for _, v4 in baseInformation.Ultimate do
		v3 = math.max(v3, v4.Time)
		total += math.max(0, v4.Multiplier)
	end

	local v4 = v3 / (baseInformation.UltimateSpeed or 1)
	local v5 = (fighterUltHits + 1) * fighterSPA + v4

	if v5 <= 0 then
		return 0
	end

	return (fighterDamage * fighterUltHits + fighterDamage * fighterUltMultiplier * total) / v5
end

function v2.GetFighterMaxLevel(p, _)
	return (math.max(1, (math.floor((Traits.ApplyAttribute(p, "Max Level", v2.MaxLevel))))))
end

function v2.GetFighterEffectiveLevel(p, p2)
	return (math.clamp(p.Level or 1, 1, v2.GetFighterMaxLevel(p, p2)))
end

function v2.GetFighterMovementSpeed(p)
	return (math.max(0.01, Traits.ApplyAttribute(p, "Movement Speed", 30)))
end

function v2.GetFighterSize(p)
	return (math.max(0.01, Traits.ApplyAttribute(p, "Fighter Size", 1)))
end

function v2.GetFighterBossDamage(p)
	return (math.max(0, Traits.ApplyAttribute(p, "Boss Damage", 1)))
end

function v2.GetFighterCriticalChance(p)
	return (math.clamp(Traits.ApplyAttribute(p, "Critical Chance", 0), 0, 100))
end

function v2.GetFighterCriticalDamage(p)
	return (math.max(0, Traits.ApplyAttribute(p, "Critical Damage", 1)))
end

function v2.GetFighterExpGain(p, p2)
	local v3, v4

	if p2 then
		v3, v4 = CommerceEffects.GetMultiplier("Fighter Exp", p2)
	else
		v3 = 0
		v4 = 1
	end

	return math.max(0, Traits.ApplyAttribute(p, "Exp Gain", 1)) * (v3 + 1) * v4
end

function v2.GetNeededExpForLevel(p: number, p2, _)
	local v3 = v2.List[p2.Name]

	if not v3 then
		return
	end

	local baseExp = v3.BaseExp or 100
	local expFactor = v3.ExpFactor or 1.1
	local v4 = math.max(0, p - 1)

	if p2.Shiny then
		baseExp *= 1.5
	end

	return (math.floor(baseExp * expFactor ^ v4))
end

function v2.GetFighterMultiplier(p: string, p2, p3)
	local v3 = {}
	local v4 = Traits.Get(p2)

	if v4 and v4.Perks[p] then
		table.insert(v3, v4.Perks[p])
	end

	local v5 = v2.List[p2.Name]

	if not v5 then
		return v3
	end

	local v6 = nil

	if v5.Percentage then
		local perks = {}

		for _, v7 in p3.Fighters.List do
			local v8 = v2.List[v7.Name]

			if not v8 or v8.Percentage then
				continue
			end

			local perk = v8.Perks[p]

			if not perk or perk.Percentage then
				continue
			end

			table.insert(perks, perk)
		end

		table.sort(perks, function(a, b)
			return a.Amount > b.Amount
		end)
		local v7 = perks[1]

		if v7 then
			v6 = {
				Type = v7.Type,
				Amount = v7.Amount
			}
		end
	else
		local perk = v5.Perks[p]

		if perk then
			v6 = {
				Type = perk.Type,
				Amount = perk.Amount
			}
		end
	end

	if v6 then
		table.insert(v3, v6)
	end

	return v3
end

function v2.GetAllFighterMultipliers(p, p2)
	local result = {}
	local v3 = Traits.Get(p)

	if v3 then
		for k in v3.Perks do
			result[k] = v2.GetFighterMultiplier(k, p, p2)
		end
	end

	local v4 = v2.List[p.Name]

	if v4 then
		for k, _ in v4.Perks do
			result[k] = v2.GetFighterMultiplier(k, p, p2)
		end
	end

	return result
end

function v2.SystemSolver(p: string, p2)
	local result = {}

	for k in p2.Fighters.Equipped do
		local v3 = p2.Fighters.List[k]

		if not v3 then
			continue
		end

		local fighterMultiplier = v2.GetFighterMultiplier(p, v3, p2)

		if not next(fighterMultiplier) then
			continue
		end

		for _, v4 in fighterMultiplier do
			table.insert(result, v4)
		end
	end

	return result
end

return table.freeze(v2)