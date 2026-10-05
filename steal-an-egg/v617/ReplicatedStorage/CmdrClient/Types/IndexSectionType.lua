local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Areas = require(ReplicatedStorage.Data.Areas)
local v = {}

for k in pairs(Areas.Directory) do
	table.insert(v, k)
end

table.sort(v, function(a, b)
	local rank = Areas.Directory[a].Rarity.Rank
	local rank2 = Areas.Directory[b].Rarity.Rank

	if rank == rank2 then
		return a < b
	end

	return rank < rank2
end)

for _, v2 in {
	"LimitedEgg",
	"LuminousEgg",
	"MonsterEgg",
	"BrainrotEgg",
	"Rift"
} do
	table.insert(v, v2)
end

return function(registry)
	registry:RegisterType("indexSection", registry.Cmdr.Util.MakeEnumType("IndexSection", v))
end