local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local frozen = table.freeze({
	table.freeze({ "Scorpio", 39 }),
	table.freeze({ "Froggo", 24 }),
	table.freeze({ "Crawler", 18 }),
	table.freeze({ "Crocodon", 11 }),
	table.freeze({ "Krakenoid", 6.5 }),
	table.freeze({ "Dreadscale", 0.5 })
})
local frozen2 = table.freeze({
	table.freeze({ "Mecha Scorpio", 40 }),
	table.freeze({ "Mecha Froggo", 24 }),
	table.freeze({ "Mecha Crawler", 18 }),
	table.freeze({ "Mecha Crocodon", 11 }),
	table.freeze({ "Mecha Krakenoid", 6.5 }),
	table.freeze({ "Mecha Dreadscale", 0.5 })
})
assert(#frozen == 6, "Monster egg presentation requires exactly six drop entries")
assert(#frozen2 == 6, "Monster egg presentation requires exactly six mecha drop entries")

local function buildEntries(frozen3)
	local values = {}

	for i, v in ipairs(frozen3) do
		local assetId = v[1]
		local weight = v[2]
		t.strict(t.string)(assetId)
		t.strict(t.number)(weight)
		assert(weight > 0, (`Monster egg drop entry {i} requires positive weight`))
		table.insert(values, table.freeze({
			AssetId = assetId,
			Weight = weight
		}))
	end

	return table.freeze(values)
end

return (table.freeze({
	DisplayName = "Monster Egg",
	BackgroundImage = "rbxassetid://97929357121314",
	DropTable = frozen,
	Entries = buildEntries(frozen),
	MechaEntries = buildEntries(frozen2)
}))