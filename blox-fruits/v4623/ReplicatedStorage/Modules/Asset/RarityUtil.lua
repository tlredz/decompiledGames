local Option = require(game.ReplicatedStorage.Packages.Option)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local RarityData = require(script.RarityData)
local count = 0
local v = {}

for _, v2 in pairs(RarityData) do
	count += 1
	v[tostring(v2.Value)] = v2
	v[v2.Name] = v2
end

table.freeze(v)
local RarityUtil = {
	DATA = RarityData
}
local names = {}

for k, v2 in pairs(RarityUtil.DATA) do
	names[k] = v2.Name
end

RarityUtil.VALUE_TO_TYPE = table.freeze(names)
RarityUtil.RARITY_COUNT = count

function RarityUtil.tryGetRarity(p)
	assert(p, "No input")
	local v2 = v[tostring(p)]

	if not v2 then
		warn((`No rarity found for {p}`))
	end

	return v2
end

function RarityUtil.matchRarity(p)
	return Option.from(RarityUtil.tryGetRarity(p))
end

RarityUtil.Types = {}
RarityUtil.Types.RarityType = TypeUtil.Types.BetterLiteral(
	"Common",
	"Uncommon",
	"Rare",
	"Legendary",
	"Mythical",
	"Premium"
)
RarityUtil.Raw = RarityData
RarityUtil.NumRarities = count
RarityUtil.getRarity = RarityUtil.tryGetRarity
return RarityUtil