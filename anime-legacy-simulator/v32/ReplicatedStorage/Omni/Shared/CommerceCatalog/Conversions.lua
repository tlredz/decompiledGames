local Gacha = require(script.Parent.Parent.Gacha)
local Progression = require(script.Parent.Parent.Progression)
local Breathings = require(script.Parent.Parent.Breathings)
local Traits = require(script.Parent.Parent.Traits)
local PlayerLevel = require(script.Parent.Parent.PlayerLevel)
local Conversions = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsAmount(value)
	return typeof(value) == "number" and value > 0 and value % 1 == 0 and value <= 9007199254740991
end

local function RegisterProducts(sourceType: string, sourceName: string, p3)
	local price = p3.Price

	if typeof(price) ~= "table" or typeof(p3.Products) ~= "table" then
		return
	end

	for k, product in p3.Products do
		local v

		if typeof(k) == "number" and k > 0 and k % 1 == 0 then
			v = k <= 9007199254740991
		else
			v = false
		end

		if not (v and typeof(product) == "table") then
			continue
		end

		local type = product.Type or price.Type
		local name = product.Name or price.Name
		local amount = not IsAmount(product.Amount) and 0 or product.Amount
		local gems = not IsAmount(product.Price) and 0 or product.Price
		local v6 = sourceType .. ":" .. sourceName .. ":" .. k
		Conversions[v6] = {
			Type = type,
			Currency = name,
			Amount = amount,
			Gems = gems,
			Order = k,
			SourceType = sourceType,
			SourceName = sourceName,
			Enabled = product.Enabled == true and amount > 0 and gems > 0 and type == price.Type and name == price.Name
		}
	end
end

for k, v in Gacha.List do
	RegisterProducts("Gacha", k, v)
end

for k, v in Progression.List do
	RegisterProducts("Progression", k, v)
end

RegisterProducts("Breathings", "Breathings", Breathings)
RegisterProducts("Traits", "Traits", Traits)
RegisterProducts("PlayerLevel", "PlayerLevel", PlayerLevel)
return Conversions