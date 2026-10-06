require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local module2 = require("@game/ReplicatedStorage/Omni/Utils/Table")
local module3 = require("@game/ReplicatedStorage/Omni/Shared/Perks")
local Upgrade = {
	List = {}
}

function Upgrade.Register(name: string, state)
	if typeof(name) ~= "string" or typeof(state) ~= "table" then
		return
	end

	if Upgrade.List[name] then
		warn((`Repeated Upgrade Module: {name}!`))
		return
	end

	local products = state.Products or {}

	for k, product in products do
		product.ProductIdentifier = name .. " Upgrade Product - " .. k
	end

	state.Products = products
	state.Name = name

	for _, upgrade in state.Upgrades do
		if upgrade.Icon then
			continue
		end

		local indexFromDictionary = module2:IndexFromDictionary(upgrade.Perks, 1)

		if indexFromDictionary then
			upgrade.Icon = module3[indexFromDictionary] and module3[indexFromDictionary].Icon or ""
		end
	end

	Upgrade.List[name] = state
end

function Upgrade.GetCurrentLevel(p: string, p2: string, p3)
	local v = p3.Upgrade and p3.Upgrade[p]
	return v and v[p2] or 0
end

function Upgrade.GetPriceAmount(p, p2)
	if p2.Type == "Item" then
		local list = p.Items and p.Items.List
		return list and list[p2.Name] or 0
	end

	if p2.Type ~= "Currency" then
		return 0
	end

	if p2.Name == "Gems" then
		return (not (p.Items and p.Items.List) and 0 or p.Items.List["Free Gems"] or 0) + (p.Items and p.Items.List and p.Items.List["Paid Gems"] or 0)
	end

	return p[p2.Name] or 0
end

function Upgrade.IsCompleted(p: string, p2)
	local v = Upgrade.List[p]

	if not v then
		return false
	end

	local v2 = p2.Upgrade[p]

	if not v2 then
		return false
	end

	for k, upgrade in v.Upgrades do
		if (v2[k] or 0) < upgrade.MaxLevel then
			return false
		end
	end

	return true
end

function Upgrade.GetLevelInformation(p: string, p2: string, value: number)
	local v = Upgrade.List[p]

	if not v then
		return
	end

	local upgrade = v.Upgrades[p2]

	if not upgrade or (typeof(value) ~= "number" or not (value >= 0 and value < 1e999)) then
		return
	end

	if value % 1 ~= 0 or upgrade.MaxLevel < value then
		return
	end

	if not upgrade.FinalInformation then
		upgrade.FinalInformation = {}
	end

	local v2 = upgrade.FinalInformation[value]

	if v2 then
		return v2
	end

	if upgrade.Manual then
		return
	end

	local v3 = math.max(0, value - 1)
	local v4 = {}
	local amount = nil

	if upgrade.Price.Increasing.Type == "Add" then
		amount = module:Round(upgrade.Price.Amount + upgrade.Price.Increasing.Amount * v3)
	elseif upgrade.Price.Increasing.Type == "Multi" then
		amount = module:Round(upgrade.Price.Amount * upgrade.Price.Increasing.Amount ^ v3)
	end

	if typeof(amount) ~= "number" or not (amount >= 0 and amount < 1e999) then
		return
	end

	v4.Price = {
		Type = upgrade.Price.Type,
		Name = upgrade.Price.Name,
		Amount = amount
	}
	v4.Perks = {}

	for k, perk in upgrade.Perks do
		local amount2 = nil

		if perk.Increasing.Type == "Add" then
			amount2 = module:Round(perk.Amount + perk.Increasing.Amount * value, 4)
		elseif perk.Increasing.Type == "Multi" then
			amount2 = module:Round(perk.Amount * perk.Increasing.Amount ^ value, 4)
		end

		v4.Perks[k] = {
			Type = perk.Type,
			Amount = amount2
		}
	end

	upgrade.FinalInformation[value] = v4
	return v4
end

function Upgrade.GetLevelMultiplierFromInformation(p, p2: string)
	local perks = {}
	local perk = p.Perks[p2]

	if perk then
		table.insert(perks, perk)
	end

	return perks
end

function Upgrade.GetAllLevelMultipliersFromInformation(p)
	local result = {}

	for k, perk in p.Perks do
		if not result[k] then
			result[k] = {}
		end

		table.insert(result[k], perk)
	end

	return result
end

function Upgrade.GetUpgradeMultiplier(p: string, p2: string, p3: number, _)
	local perks = {}
	local v = Upgrade.List[p2]

	if not v then
		return perks
	end

	for k, _ in v.Upgrades do
		local levelInformation = Upgrade.GetLevelInformation(p2, k, p3)

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

function Upgrade.GetAllUpgradeMultipliers(p: string, p2: number, _)
	local result = {}
	local v = Upgrade.List[p]

	if not v then
		return result
	end

	for k, _ in v.Upgrades do
		local levelInformation = Upgrade.GetLevelInformation(p, k, p2)

		if not levelInformation then
			continue
		end

		for k2, perk in levelInformation.Perks do
			if not result[k2] then
				result[k2] = {}
			end

			table.insert(result[k2], perk)
		end
	end

	return result
end

function Upgrade.SystemSolver(p: string, p2)
	local result = {}

	for k, v in p2.Upgrade do
		for k2, v2 in v do
			local levelInformation = Upgrade.GetLevelInformation(k, k2, v2)

			if not levelInformation then
				continue
			end

			local levelMultiplier = Upgrade.GetLevelMultiplierFromInformation(levelInformation, p)

			if not levelMultiplier then
				continue
			end

			for _, v3 in levelMultiplier do
				table.insert(result, v3)
			end
		end
	end

	return result
end

return Upgrade