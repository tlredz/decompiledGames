local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local frozen = table.freeze({
	table.freeze({ "Spike", 39 }),
	table.freeze({ "Manta Ray", 24 }),
	table.freeze({ "Megalodon", 18 }),
	table.freeze({ "Electric Eel", 11 }),
	table.freeze({ "Terra Snapper", 6.5 }),
	table.freeze({ "Cthulhu", 0.5 })
})
local frozen2 = table.freeze({
	table.freeze({ "Depths Spike", 39 }),
	table.freeze({ "Depths Manta Ray", 24 }),
	table.freeze({ "Depths Megalodon", 18 }),
	table.freeze({ "Depths Electric Eel", 11 }),
	table.freeze({ "Depths Terra Snapper", 6.5 }),
	table.freeze({ "Depths Cthulhu", 0.5 })
})
assert(#frozen == 6, "Luminous egg presentation requires exactly six drop entries")
assert(#frozen2 == 6, "Luminous egg presentation requires exactly six mecha drop entries")

local function buildEntries(frozen3)
	local values = {}

	for i, v in ipairs(frozen3) do
		local assetId = v[1]
		local weight = v[2]
		t.strict(t.string)(assetId)
		t.strict(t.number)(weight)
		assert(weight > 0, (`Luminous egg drop entry {i} requires positive weight`))
		table.insert(values, table.freeze({
			AssetId = assetId,
			Weight = weight
		}))
	end

	return table.freeze(values)
end

return (table.freeze({
	DisplayName = "Luminous Egg",
	BackgroundImage = "rbxassetid://108209625322017",
	DropTable = frozen,
	Entries = buildEntries(frozen),
	MechaEntries = buildEntries(frozen2)
}))