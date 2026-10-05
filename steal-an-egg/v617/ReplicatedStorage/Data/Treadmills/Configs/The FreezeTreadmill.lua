local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "The FreezeTreadmill",
	Price = 3000000000,
	ProductId = 3611606701,
	Icon = "rbxassetid://97611802500180",
	Rarity = Rarity.Rarities.Mythic,
	SpeedMultiplier = 100,
	DisplayInShop = true,
	DisplayName = "The Freeze Treadmill"
}
return table.freeze(v)