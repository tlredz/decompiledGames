require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local module2 = require("@game/ReplicatedStorage/Omni/Utils/Table")
local module3 = require("@game/ReplicatedStorage/Omni/Utils/Order")
local module4 = require("@game/ReplicatedStorage/Omni/Shared/Perks")
local SacredArtefacts = {
	MinimumMap = "Sins Kingdom",
	List = {}
}
SacredArtefacts.Map = SacredArtefacts.MinimumMap

function SacredArtefacts.Register(name: string, state)
	if typeof(name) ~= "string" or typeof(state) ~= "table" then
		return
	end

	if SacredArtefacts.List[name] then
		warn((`Repeated Sacred Artefact Module: {name}!`))
		return
	end

	state.Name = name
	local v = not state.Icon and module2:IndexFromDictionary(state.Perks, 1)

	if v then
		state.Icon = module4[v] and module4[v].Icon or ""
	end

	SacredArtefacts.List[name] = state
end

function SacredArtefacts.GetCount(p: string, p2)
	return p2.Index.SacredArtefact and p2.Index.SacredArtefact[p] or 0
end

function SacredArtefacts.IsUnlocked(p: string, p2)
	return SacredArtefacts.GetCount(p, p2) > 0
end

function SacredArtefacts.GetCurrentRarity(p: string, p2)
	local v = SacredArtefacts.List[p]

	if not v then
		return module3.Rarities[1]
	end

	local count = SacredArtefacts.GetCount(p, p2)
	local rarity = module3.Rarities[1]

	for _, rarity2 in module3.Rarities do
		if (v.Needed[rarity2] or 0) <= count then
			rarity = rarity2
		else
			break
		end
	end

	return rarity
end

function SacredArtefacts.GetNextRarity(p: string, p2)
	local rarity = module3:Rarity((SacredArtefacts.GetCurrentRarity(p, p2)))
	return module3.Rarities[rarity + 1]
end

function SacredArtefacts.GetLevelInformation(p: string, p2: string)
	local v = SacredArtefacts.List[p]

	if not v then
		return
	end

	local v2 = module3:Rarity(p2) - 1
	local v3 = {
		Perks = {}
	}

	for k, perk in v.Perks do
		local amount = nil

		if perk.Increasing.Type == "Add" then
			amount = module:Round(perk.Amount + perk.Increasing.Amount * v2)
		elseif perk.Increasing.Type == "Multi" then
			amount = module:Round(perk.Amount * perk.Increasing.Amount ^ v2)
		end

		v3.Perks[k] = {
			Type = perk.Type,
			Amount = amount
		}
	end

	return v3
end

function SacredArtefacts.SystemSolver(p: string, p2)
	local perks = {}

	for k in SacredArtefacts.List do
		if not SacredArtefacts.IsUnlocked(k, p2) then
			continue
		end

		local currentRarity = SacredArtefacts.GetCurrentRarity(k, p2)
		local levelInformation = SacredArtefacts.GetLevelInformation(k, currentRarity)

		if not levelInformation then
			continue
		end

		local perk = levelInformation.Perks[p]

		if perk then
			table.insert(perks, perk)
		end
	end

	return perks
end

return SacredArtefacts