local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "GoldenTreadmill",
	Price = 120000000,
	ProductId = 3611606694,
	Icon = "rbxassetid://99555941892079",
	Rarity = Rarity.Rarities.Legendary,
	SpeedMultiplier = 80,
	DisplayInShop = true,
	DisplayName = "Golden Treadmill"
}
return table.freeze(v)