local Gamepasses = require(script.Parent.Gamepasses)
local CommerceCatalog = {
	Enabled = true,
	List = {},
	Conversions = {}
}

local function GetGamepassRewards()
	local v = {}

	for k in Gamepasses do
		table.insert(v, k)
	end

	table.sort(v, function(a, b)
		return (Gamepasses[a].Order or 0) < (Gamepasses[b].Order or 0)
	end)
	local result = {}

	for _, name in v do
		table.insert(result, {
			Type = "Gamepass",
			Name = name,
			Amount = 1
		})
	end

	return result
end

function CommerceCatalog.GetDisplayPrice(p, p2)
	local price = p and p.Price

	if typeof(price) == "number" and price >= 0 and price < 1e999 then
		return price
	end

	local priceInRobux = p2 and p2.PriceInRobux

	if typeof(priceInRobux) == "number" and priceInRobux >= 0 and priceInRobux < 1e999 then
		return priceInRobux
	end

	return nil
end

function CommerceCatalog.GetGemPrice(p, p2)
	if not p or p.Kind ~= "Bundle" and p.Kind ~= "Gamepass" then
		return nil
	end

	local displayPrice = CommerceCatalog.GetDisplayPrice(p, p2)

	if not displayPrice then
		return nil
	end

	local v = displayPrice * 10

	if v <= 0 or v % 1 ~= 0 or v > 9007199254740991 then
		return nil
	end

	return v
end

function CommerceCatalog.IsConfigured(data, flag: boolean?)
	if typeof(data) ~= "table" or typeof(data.Name) ~= "string" then
		return false
	end

	if not flag and (typeof(data.ID) ~= "number" or data.ID <= 0 or data.ID % 1 ~= 0) then
		return false
	end

	for _, v in {
		"Limit",
		"GlobalPurchaseLimit",
		"ExpiresAt",
		"PlayedTimeLimit"
	} do
		local v2 = data[v]

		if v2 ~= nil and (typeof(v2) ~= "number" or v2 <= 0 or v2 % 1 ~= 0 or v2 > 9007199254740991) then
			return false
		end
	end

	for k, v in CommerceCatalog.List do
		if not flag and k ~= data.Name and v.ID == data.ID and v.Kind == "Gamepass" == (data.Kind == "Gamepass") then
			return false
		end
	end

	return true
end

function CommerceCatalog.Get(p: string)
	return CommerceCatalog.List[p]
end

function CommerceCatalog.GetRewards(p: string)
	local v = CommerceCatalog.List[p]

	if not v then
		return {}
	end

	local result = {}

	for _, v2 in v.Rewards or {} do
		table.insert(result, table.clone(v2))
	end

	if v.AllGamepasses then
		for _, v2 in GetGamepassRewards() do
			table.insert(result, v2)
		end
	end

	return result
end

function CommerceCatalog.GetByProductId(value: number)
	if typeof(value) ~= "number" or value <= 0 then
		return nil
	end

	local v = nil

	for _, v2 in CommerceCatalog.List do
		if not (v2.Kind ~= "Gamepass" and v2.ID == value) then
			continue
		end

		if v then
			return nil
		else
			v = v2
		end
	end

	return v
end

function CommerceCatalog.GetSection(p: string)
	local result = {}

	for _, v in CommerceCatalog.List do
		if v.Section == p then
			table.insert(result, v)
		end
	end

	table.sort(result, function(a, b)
		return a.Order < b.Order
	end)
	return result
end

for k, gamepass in Gamepasses do
	local clone = table.clone(gamepass)
	clone.Name = k
	clone.Kind = "Gamepass"
	clone.Section = "Gamepasses"
	clone.Limit = 1
	CommerceCatalog.List[k] = clone
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	for k, v in module do
		v.Name = k

		if moduleScript.Name == "Conversions" then
			CommerceCatalog.Conversions[k] = v
		else
			CommerceCatalog.List[k] = v
		end
	end
end

return CommerceCatalog