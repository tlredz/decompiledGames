local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "Sci-FiTreadmill",
	Price = 15000,
	ProductId = 3611606667,
	Icon = "rbxassetid://81563639782445",
	Rarity = Rarity.Rarities.Uncommon,
	SpeedMultiplier = 5,
	DisplayInShop = true,
	DisplayName = "Sci-Fi Treadmill"
}
return table.freeze(v)