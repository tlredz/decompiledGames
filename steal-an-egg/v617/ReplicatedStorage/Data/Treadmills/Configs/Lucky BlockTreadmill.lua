local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "Lucky BlockTreadmill",
	Price = 75000000000,
	ProductId = 3611606706,
	Icon = "rbxassetid://85546442623094",
	Rarity = Rarity.Rarities.Cosmic,
	SpeedMultiplier = 200,
	DisplayInShop = true,
	DisplayName = "Lucky Block Treadmill"
}
return table.freeze(v)