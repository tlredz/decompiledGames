local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "FlameTreadmill",
	Price = 250000,
	ProductId = 3611606677,
	Icon = "rbxassetid://103122274001487",
	Rarity = Rarity.Rarities.Rare,
	SpeedMultiplier = 12,
	DisplayInShop = true,
	DisplayName = "Flame Treadmill"
}
return table.freeze(v)