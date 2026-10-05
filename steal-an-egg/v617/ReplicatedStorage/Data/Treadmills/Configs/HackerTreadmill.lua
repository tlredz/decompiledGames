local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "HackerTreadmill",
	Price = 2000000000000,
	ProductId = 3611606718,
	Icon = "rbxassetid://114661675379027",
	Rarity = Rarity.Rarities.Secret,
	SpeedMultiplier = 500,
	DisplayInShop = true,
	DisplayName = "Hacker Treadmill"
}
return table.freeze(v)