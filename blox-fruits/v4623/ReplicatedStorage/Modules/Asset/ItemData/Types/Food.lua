local Food = require(game.ReplicatedStorage.Modules.Consumables.Food)
local Food2 = {}

for _, v in pairs(Food.Food) do
	Food2[v.StorageName] = { v.Rarity, v.MaxStack }
end

return Food2