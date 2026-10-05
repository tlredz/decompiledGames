local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "CelebrityTreadmill",
	Price = 5000000,
	ProductId = 3611606688,
	Icon = "rbxassetid://75188836342954",
	Rarity = Rarity.Rarities.Epic,
	SpeedMultiplier = 30,
	DisplayInShop = true,
	DisplayName = "Celebrity Treadmill"
}
return table.freeze(v)