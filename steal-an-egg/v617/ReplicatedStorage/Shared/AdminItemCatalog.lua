local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gears = require(ReplicatedStorage.Data.Gears)
local values = {}

for k, v in Gears.Directory do
	if k ~= "Bat" then
		values[k] = table.freeze({
			Kind = "Gear",
			DisplayName = v.DisplayName,
			MaxPerRun = v.OneTime and 1 or math.min(v.MaxShopStockQuantity or 1000, 1000)
		})
	end
end

values.MonsterChest = table.freeze({
	Kind = "MonsterChest",
	DisplayName = "Monster Chest",
	MaxPerRun = 25
})
values.MutationConsumable = table.freeze({
	Kind = "MutationConsumable",
	DisplayName = "Fractured Crystal",
	MaxPerRun = 1000
})
local v = {}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function addChoice(p: string, k: string)
	if v2[p] == nil then
		v2[p] = k
		table.insert(v, p)
	end
end

for k in values do
	addChoice(k, k) -- equivalent call inferred; original call site unknown
end

for k, v3 in values do
	addChoice(v3.DisplayName, k) -- equivalent call inferred; original call site unknown
end

for _, v3 in { "Bee Gun", "BeeGun", "Bee Launcher" } do
	addChoice(v3, "BeeLauncher") -- equivalent call inferred; original call site unknown
end

for _, v3 in {
	"Fractured Crystals",
	"FracturedCrystal",
	"FracturedCrystals",
	"Mutation Consumable"
} do
	addChoice(v3, "MutationConsumable") -- equivalent call inferred; original call site unknown
end

table.sort(v)
return table.freeze({
	Directory = table.freeze(values),
	Choices = table.freeze(v),
	IdByChoice = table.freeze(v2)
})