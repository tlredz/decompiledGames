local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "DemonicTreadmill",
	Price = 50000000000000,
	ProductId = 3611606728,
	Icon = "rbxassetid://99849961715962",
	Rarity = Rarity.Rarities.Eternal,
	SpeedMultiplier = 1000,
	DisplayInShop = true,
	DisplayName = "Demonic Treadmill"
}
return table.freeze(v)