local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	_id = "Treadmill",
	Price = 0,
	ProductId = nil,
	Icon = "rbxassetid://84421204509494",
	Rarity = Rarity.Rarities.Common,
	SpeedMultiplier = 2,
	DisplayInShop = true,
	DisplayName = "Treadmill"
}
return table.freeze(v)