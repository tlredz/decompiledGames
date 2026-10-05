local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local frozen = table.freeze({
	table.freeze({ "Tung Tung Sahur", 39 }),
	table.freeze({ "Bananita Dolphinita", 25 }),
	table.freeze({ "Belula Beluga", 20 }),
	table.freeze({ "Mangolini Parrochini", 10 }),
	table.freeze({ "Bomboclat Crocolat", 5 }),
	table.freeze({ "Strawberry Elephant", 1 })
})
assert(#frozen == 6, "Brainrot egg presentation requires exactly six drop entries")
local values = {}

for i, v in ipairs(frozen) do
	local assetId = v[1]
	local weight = v[2]
	t.strict(t.string)(assetId)
	t.strict(t.number)(weight)
	assert(weight > 0, (`Brainrot egg drop entry {i} requires positive weight`))
	table.insert(values, table.freeze({
		AssetId = assetId,
		Weight = weight
	}))
end

return (table.freeze({
	DisplayName = "Brainrot Egg",
	BackgroundImage = "rbxassetid://70476079280223",
	DropTable = frozen,
	Entries = table.freeze(values)
}))