local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Merge(function(items, p)
	local v = {}

	for k, item in items do
		v[k] = item
	end

	for k, v2 in p do
		v[k] = v2
	end

	if p.Rarity then
		local rarityValueFromType = Parse.RarityValueFromType(p.Rarity)

		if rarityValueFromType.Ok == false then
			return rarityValueFromType
		else
			v.RarityValue = rarityValueFromType.Value
		end
	end

	return {
		Ok = true,
		Value = v
	}
end, Parse.Chain(Parse.Map(Parse.Translate({
	["Fragments Price"] = "FragmentsPrice",
	["Money Price"] = "MoneyPrice",
	["Stock Chance"] = "StockChance",
	["Stock Offset"] = "StockOffset"
}), Parse.Optional(Parse.Any)), Parse.Interface({
	FragmentsPrice = Parse.Optional(Parse.UnsignedInteger),
	MoneyPrice = Parse.Optional(Parse.UnsignedInteger),
	StockChance = Parse.Optional(Parse.Percent),
	StockOffset = Parse.Optional(Parse.UnsignedInteger)
})), Parse.Interface({
	Rarity = Parse.Optional(Parse.RarityType)
})))