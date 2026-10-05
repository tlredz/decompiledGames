local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useShopContext = require(game.ReplicatedStorage.React.Hooks.useShopContext)
local moneyPrices = {}
local result = {}

for _, v in ItemConfig.Query.join({
	Index = {
		IdType = "Moveset"
	},
	Moveset = {
		Type = "Fruit"
	},
	Variant = {
		IsFoundation = true
	}
}) do
	if not (ItemConfig.match("Permanent " .. v.Index.StorageKey, "Redeemable"):asNullable() and v.Moveset and v.Moveset.Physical) then
		continue
	end

	local unwrapped = ItemConfig.match(v.Moveset.Physical):unwrap()
	moneyPrices["Permanent " .. v.Index.StorageKey] = unwrapped.Quality.MoneyPrice or 1e999
	table.insert(result, "Permanent " .. v.Index.StorageKey)
end

table.sort(result, function(a: string, b: string)
	return moneyPrices[a] < moneyPrices[b]
end)
table.freeze(result)
local result2 = {}

for _, v in ipairs(result) do
	table.insert(result2, v:sub(("Permanent "):len() + 1))
end

table.freeze(result2)
return function(flag: boolean?)
	local v = useShopContext()

	if flag == nil then
		flag = v == "ShopGui" or v == "SkinsGui"
	end

	if flag then
		return result
	end

	return result2
end