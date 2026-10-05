require(game.ReplicatedStorage.Economy.EconomyItem)
local PRODUCTS = require(script.PRODUCTS)
local BOX = require(script.BOX)
local ALL = {}
local v2 = {}

function injectItems(list)
	for _, v3 in ipairs(list) do
		local itemId = v3.ItemId

		if v2[itemId] == true then
			error((`Duplicate storage id: {itemId} for item {v3}`))
		end

		v2[v3.ItemId] = true
		table.insert(ALL, v3)
	end
end

injectItems(PRODUCTS.ALL)
injectItems(BOX)
table.sort(ALL, function(a, b)
	return a.ItemId < b.ItemId
end)
table.freeze(ALL)
local LIBRARY = {
	ALL = ALL,
	BOX = BOX,
	PRODUCT = PRODUCTS
}
table.freeze(LIBRARY)
return LIBRARY