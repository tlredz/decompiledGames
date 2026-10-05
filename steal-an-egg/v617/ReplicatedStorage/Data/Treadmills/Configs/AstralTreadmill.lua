local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "AstralTreadmill",
	Price = 1.5e16,
	ProductId = 3712487576,
	Icon = "rbxassetid://118444572497588",
	Rarity = Rarity.Rarities.Titan,
	SpeedMultiplier = 3000,
	DisplayInShop = true,
	DisplayName = "Astral Treadmill"
}
return table.freeze(v)