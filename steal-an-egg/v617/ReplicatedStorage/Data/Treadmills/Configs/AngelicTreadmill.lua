local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "AngelicTreadmill",
	Price = 1000000000000000,
	ProductId = 3611606732,
	Icon = "rbxassetid://104277706019985",
	Rarity = Rarity.Rarities.Divine,
	SpeedMultiplier = 2000,
	DisplayInShop = true,
	DisplayName = "Angelic Treadmill"
}
return table.freeze(v)