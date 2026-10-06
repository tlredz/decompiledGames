require(script.Parent.Maps)
local Gacha = require(script.Parent.Gacha)
local Progression = require(script.Parent.Progression)
local Traits = require(script.Parent.Traits)
local Breathings = require(script.Parent.Breathings)
local PlayerLevel = require(script.Parent.PlayerLevel)
local Items = require(script.Parent.Items)
local Perks = require(script.Parent.Perks)
local Monetization = require(script.Parent.Monetization)
local v = {
	Item = {},
	Currency = {}
}

local function RegisterPrice(price, p: string, value: string?)
	if typeof(price) ~= "table" or typeof(price.Name) ~= "string" then
		return
	end

	local v3 = (price.Type == "Item" or price.Type == "Items") and "Item" or (price.Type == "Currency" or price.Type == "Currencies") and "Currency" or nil

	if not v3 then
		return
	end

	local v4

	if v3 == "Item" then
		v4 = Items.List[price.Name]
	else
		v4 = Perks[price.Name]
	end

	if not v4 then
		return
	end

	local v5 = v[v3][price.Name]

	if not v5 then
		v5 = {
			Type = v3,
			Name = price.Name,
			Uses = {}
		}
		v[v3][price.Name] = v5
	end

	v5.Uses[p] = value or "Random"
end

for k, v3 in Gacha.List do
	RegisterPrice(v3.Price, (`Gacha:{k}`))
end

for k, v3 in Progression.List do
	RegisterPrice(v3.Price, (`Progression:{k}`))
end

RegisterPrice(Traits.Price, "Traits")
RegisterPrice(Breathings.Price, "Breathings")
RegisterPrice(PlayerLevel.Price, "PlayerLevel", "Fixed")

for k, list in v do
	for k2, list2 in list do
		table.freeze(list2.Uses)
		table.freeze(list2)
		local input, v3 = Monetization.RegisterInput(`{k}:{k2}`, {
			Type = k,
			Origin = "Mixed",
			Uses = list2.Uses
		})
		assert(input, v3)
	end

	table.freeze(list)
end

table.freeze(v)
return table.freeze({
	Get = function(p: string, p2: string)
		local v3 = p == "Items" and "Item" or p == "Currencies" and "Currency" or p
		return v[v3] and v[v3][p2]
	end,
	List = function()
		return v
	end
})