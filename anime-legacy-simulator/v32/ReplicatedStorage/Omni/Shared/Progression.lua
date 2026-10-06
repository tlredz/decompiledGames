require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local module2 = require("@game/ReplicatedStorage/Omni/Utils/Validator")
local Progression = {
	List = {}
}

local function IsCounter(p)
	local v = module2:ValidateNumber(p)

	if v then
		if p >= 0 and p <= 9007199254740991 then
			return p % 1 == 0
		else
			return false
		end
	end

	return v
end

local function IsName(value)
	return typeof(value) == "string" and string.find(value, "%S") ~= nil
end

local function CalculateAmount(data, p: number)
	if typeof(data) ~= "table" or not module2:ValidateNumber(data.Amount) or (not module2:ValidateNumber(data.Reason) or data.Reason <= 0) then
		return nil
	end

	local increasing = data.Increasing

	if typeof(increasing) ~= "table" or not module2:ValidateNumber(increasing.Amount) then
		return nil
	end

	local v = math.floor(p / data.Reason)
	local v2

	if increasing.Type == "Add" then
		v2 = data.Amount + increasing.Amount * v
	elseif increasing.Type == "Multi" then
		v2 = data.Amount * increasing.Amount ^ v
	else
		return nil
	end

	if not module2:ValidateNumber(v2) then
		return nil
	end

	local rounded = module:Round(v2)

	if module2:ValidateNumber(rounded) then
		return rounded
	end

	return nil
end

local function CalculateBoundedAmount(p, p2: number)
	if typeof(p) ~= "table" or not (module2:ValidateNumber(p.Minimum) and module2:ValidateNumber(p.Maximum)) or p.Minimum > p.Maximum then
		return nil
	end

	local calculateAmount = CalculateAmount(p, p2)

	if calculateAmount == nil then
		return nil
	end

	return (math.clamp(calculateAmount, p.Minimum, p.Maximum))
end

local function CopyLevelInformation(data)
	if typeof(data) ~= "table" or not module2:ValidateNumber(data.Chance) or (data.Chance < 0 or data.Chance > 100) then
		return nil
	end

	local price = data.Price

	if typeof(price) ~= "table" then
		return nil
	end

	local name = price.Name
	local v

	if typeof(name) == "string" then
		v = string.find(name, "%S") ~= nil
	else
		v = false
	end

	if not v then
		return nil
	end

	if price.Type ~= "Item" and price.Type ~= "Items" and price.Type ~= "Currency" and price.Type ~= "Currencies" then
		return nil
	end

	local amount = price.Amount
	local v2 = module2:ValidateNumber(amount)

	if v2 then
		if amount >= 0 and amount <= 9007199254740991 then
			v2 = amount % 1 == 0
		else
			v2 = false
		end
	end

	if not v2 or price.Amount == 0 or typeof(data.Perks) ~= "table" then
		return nil
	end

	local perks = {}

	for k, perk in data.Perks do
		local v4

		if typeof(k) == "string" then
			v4 = string.find(k, "%S") ~= nil
		else
			v4 = false
		end

		if not v4 or typeof(perk) ~= "table" or perk.Type ~= "Add" and perk.Type ~= "Multi" or not module2:ValidateNumber(perk.Amount) then
			return nil
		end

		perks[k] = {
			Type = perk.Type,
			Amount = perk.Amount
		}
	end

	return {
		Chance = data.Chance,
		Price = {
			Type = price.Type,
			Name = price.Name,
			Amount = price.Amount
		},
		Perks = perks
	}
end

local function CalculateLevelInformation(data, p: number)
	if data.Manual == true then
		if typeof(data.FinalInformation) == "table" then
			return (CopyLevelInformation(data.FinalInformation[p]))
		end

		return nil
	else
		local v = math.max(0, p - 1)
		local chance = CalculateBoundedAmount(data.Chance, v)
		local amount = CalculateBoundedAmount(data.Price, v)

		if chance == nil or amount == nil or (data.Chance.Minimum < 0 or data.Chance.Maximum > 100) then
			return nil
		end

		if data.Price.Minimum <= 0 or data.Price.Maximum > 9007199254740991 or typeof(data.Perks) ~= "table" then
			return nil
		end

		local perks = {}

		for k, perk in data.Perks do
			local amount2 = CalculateAmount(perk, p)

			if amount2 == nil then
				return nil
			else
				perks[k] = {
					Type = perk.Type,
					Amount = amount2
				}
			end
		end

		return (CopyLevelInformation({
			Chance = chance,
			Price = {
				Type = data.Price.Type,
				Name = data.Price.Name,
				Amount = amount
			},
			Perks = perks
		}))
	end
end

function Progression.Register(name: string, p)
	if typeof(name) ~= "string" or typeof(p) ~= "table" then
		return
	end

	if Progression.List[name] then
		warn((`Repeated Progression Module: {name}!`))
		return
	end

	local products = p.Products or {}

	for k, product in products do
		product.ProductIdentifier = name .. " Progression Product - " .. k
	end

	p.Name = name
	p.Products = products
	Progression.List[name] = p
end

function Progression.IsCompleted(p: string, p2)
	local v = Progression.List[p]

	if v then
		return (p2.Progression.List[p] or 0) >= v.MaxLevel
	end

	return false
end

function Progression.GetLevelInformation(value: string, p: number)
	local v

	if typeof(value) == "string" then
		v = string.find(value, "%S") ~= nil
	else
		v = false
	end

	if not v then
		return nil
	end

	local v2 = module2:ValidateNumber(p)

	if v2 then
		if p >= 0 and p <= 9007199254740991 then
			v2 = p % 1 == 0
		else
			v2 = false
		end
	end

	if not v2 then
		return nil
	end

	local v3 = Progression.List[value]

	if typeof(v3) ~= "table" then
		return nil
	end

	local maxLevel = v3.MaxLevel
	local v4 = module2:ValidateNumber(maxLevel)

	if v4 then
		if maxLevel >= 0 and maxLevel <= 9007199254740991 then
			v4 = maxLevel % 1 == 0
		else
			v4 = false
		end
	end

	if v4 and v3.MaxLevel ~= 0 then
		if v3.Manual ~= nil and typeof(v3.Manual) ~= "boolean" or v3.MaxLevel < p then
			return nil
		end

		return (CalculateLevelInformation(v3, p))
	end

	return nil
end

function Progression.GetPreview(value: string, currentLevel: number)
	local v

	if typeof(value) == "string" then
		v = string.find(value, "%S") ~= nil
	else
		v = false
	end

	if not v then
		return nil, "Invalid Progression name or level."
	end

	local v2 = module2:ValidateNumber(currentLevel)

	if v2 then
		if currentLevel >= 0 and currentLevel <= 9007199254740991 then
			v2 = currentLevel % 1 == 0
		else
			v2 = false
		end
	end

	if not v2 then
		return nil, "Invalid Progression name or level."
	end

	local v3 = Progression.List[value]

	if typeof(v3) ~= "table" then
		return nil, "Invalid Progression configuration."
	end

	local maxLevel = v3.MaxLevel
	local v4 = module2:ValidateNumber(maxLevel)

	if v4 then
		if maxLevel >= 0 and maxLevel <= 9007199254740991 then
			v4 = maxLevel % 1 == 0
		else
			v4 = false
		end
	end

	if not (v4 and v3.MaxLevel ~= 0) then
		return nil, "Invalid Progression configuration."
	end

	local mapName = v3.MapName
	local v5

	if typeof(mapName) == "string" then
		v5 = string.find(mapName, "%S") ~= nil
	else
		v5 = false
	end

	if v5 then
		if v3.MaxLevel < currentLevel then
			return nil, "Progression level exceeds its maximum."
		end

		if currentLevel == v3.MaxLevel then
			return {
				CurrentLevel = currentLevel,
				MaxLevel = v3.MaxLevel,
				Completed = true
			}
		end

		local nextLevel = currentLevel + 1
		local levelInformation = Progression.GetLevelInformation(value, nextLevel)

		if levelInformation then
			return {
				CurrentLevel = currentLevel,
				NextLevel = nextLevel,
				MaxLevel = v3.MaxLevel,
				Completed = false,
				Price = levelInformation.Price,
				SuccessChance = levelInformation.Chance,
				FailureChance = 100 - levelInformation.Chance,
				Perks = levelInformation.Perks
			}
		end

		return nil, "The next Progression level is unavailable or invalid."
	end

	return nil, "Invalid Progression configuration."
end

function Progression.GetProgressionMultiplier(p: string, p2: string, p3: number, _)
	local v = {}
	local levelInformation = Progression.GetLevelInformation(p2, p3)
	local v2 = levelInformation and levelInformation.Perks[p]

	if v2 then
		table.insert(v, v2)
	end

	return v
end

function Progression.GetAllProgressionMultipliers(p: string, p2: number, p3)
	local v = {}
	local result = {}
	local v2 = Progression.List[p]

	if not v2 then
		return result
	end

	for k, _ in v2.Perks do
		v[k] = true
	end

	for k, _ in v do
		result[k] = Progression.GetProgressionMultiplier(k, p, p2, p3)
	end

	return result
end

function Progression.SystemSolver(p: string, p2)
	local result = {}

	for k, v in p2.Progression.List do
		local progressionMultiplier = Progression.GetProgressionMultiplier(p, k, v, p2)

		for _, v2 in progressionMultiplier do
			table.insert(result, v2)
		end
	end

	return result
end

return Progression