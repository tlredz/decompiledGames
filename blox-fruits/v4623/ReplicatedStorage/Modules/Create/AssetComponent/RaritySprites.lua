local RarityData = require(game.ReplicatedStorage.Modules.Asset.RarityUtil.RarityData)
local vector = Vector2.new(218, 225)

function getRarity(p: string)
	for _, v in pairs(RarityData) do
		if v.Name == p then
			return v.Value
		end
	end

	error((`no entry found for rarity "{p}"`))
end

local backgrounds = {
	[getRarity("Common")] = {
		idle = Vector2.new(1 * vector.X, vector.Y * 3),
		hover = Vector2.new(1 * vector.X, vector.Y * 2)
	},
	[getRarity("Uncommon")] = {
		idle = Vector2.new(0 * vector.X, vector.Y * 3),
		hover = Vector2.new(0 * vector.X, vector.Y * 2)
	},
	[getRarity("Rare")] = {
		idle = Vector2.new(3 * vector.X, vector.Y),
		hover = Vector2.new(3 * vector.X, 0)
	},
	[getRarity("Legendary")] = {
		idle = Vector2.new(2 * vector.X, vector.Y),
		hover = Vector2.new(2 * vector.X, 0)
	},
	[getRarity("Mythical")] = {
		idle = Vector2.new(1 * vector.X, vector.Y),
		hover = Vector2.new(1 * vector.X, 0)
	},
	[getRarity("Premium")] = {
		idle = Vector2.new(0 * vector.X, vector.Y),
		hover = Vector2.new(0 * vector.X, 0)
	}
}
table.freeze(backgrounds)

for _, list in pairs(backgrounds) do
	table.freeze(list)
end

return {
	BACKGROUND_RECT_SIZE = vector,
	Backgrounds = backgrounds
}