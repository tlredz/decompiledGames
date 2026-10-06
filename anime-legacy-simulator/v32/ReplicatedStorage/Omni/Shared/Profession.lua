require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local module2 = require("@game/ReplicatedStorage/Omni/Utils/Table")
local module3 = require("@game/ReplicatedStorage/Omni/Shared/Perks")
local Profession = {
	List = {}
}

function Profession.Register(name: string, p)
	if typeof(name) ~= "string" or typeof(p) ~= "table" then
		return
	end

	if Profession.List[name] then
		warn((`Repeated Profession Module: {name}!`))
		return
	end

	p.Name = name

	for _, upgrade in p.Upgrades do
		if upgrade.Icon then
			continue
		end

		local indexFromDictionary = module2:IndexFromDictionary(upgrade.Perks, 1)

		if indexFromDictionary then
			upgrade.Icon = module3[indexFromDictionary] and module3[indexFromDictionary].Icon or ""
		end
	end

	Profession.List[name] = p
end

function Profession.GetCurrentLevel(p: string, p2: string, p3)
	local v = p3.Profession[p]
	local v2 = v and v[p2]
	return v2 and v2.Level or 0
end

function Profession.GetCurrentProgress(p: string, p2: string, p3)
	local v = p3.Profession[p]
	local v2 = v and v[p2]
	return v2 and v2.Progress or 0
end

function Profession.IsCompleted(p: string, p2)
	local v = Profession.List[p]

	if not v then
		return false
	end

	for k, upgrade in v.Upgrades do
		if Profession.GetCurrentLevel(p, k, p2) < upgrade.MaxLevel then
			return false
		end
	end

	return true
end

function Profession.GetLevelInformation(p: string, p2: string, p3: number)
	local v = Profession.List[p]

	if not v then
		return
	end

	local upgrade = v.Upgrades[p2]

	if not upgrade then
		return
	end

	if not upgrade.FinalInformation then
		upgrade.FinalInformation = {}
	end

	local v2 = upgrade.FinalInformation[p3]

	if v2 then
		return v2
	end

	if upgrade.MaxLevel < p3 then
		return
	end

	local v3 = math.max(0, p3 - 1)
	local amount = nil

	if upgrade.Requirement.Increasing.Type == "Add" then
		amount = module:Round(upgrade.Requirement.Amount + upgrade.Requirement.Increasing.Amount * v3)
	elseif upgrade.Requirement.Increasing.Type == "Multi" then
		amount = module:Round(upgrade.Requirement.Amount * upgrade.Requirement.Increasing.Amount ^ v3)
	end

	local v4 = {
		Requirement = {
			Type = upgrade.Requirement.Type,
			Name = upgrade.Requirement.Name,
			Amount = amount
		},
		Perks = {}
	}

	for k, perk in upgrade.Perks do
		local amount2 = nil

		if perk.Increasing.Type == "Add" then
			amount2 = module:Round(perk.Amount + perk.Increasing.Amount * p3)
		elseif perk.Increasing.Type == "Multi" then
			amount2 = module:Round(perk.Amount * perk.Increasing.Amount ^ p3)
		end

		v4.Perks[k] = {
			Type = perk.Type,
			Amount = amount2
		}
	end

	upgrade.FinalInformation[p3] = v4
	return v4
end

function Profession.CanUpgrade(p: string, p2: string, p3)
	local currentLevel = Profession.GetCurrentLevel(p, p2, p3)
	local levelInformation = Profession.GetLevelInformation(p, p2, currentLevel + 1)

	if levelInformation then
		return Profession.GetCurrentProgress(p, p2, p3) >= levelInformation.Requirement.Amount
	end

	return false
end

function Profession.SystemSolver(p: string, p2)
	local perks = {}

	for k, v in p2.Profession do
		for k2, v2 in v do
			local levelInformation = Profession.GetLevelInformation(k, k2, v2.Level)

			if not levelInformation then
				continue
			end

			local perk = levelInformation.Perks[p]

			if perk then
				table.insert(perks, perk)
			end
		end
	end

	return perks
end

return Profession