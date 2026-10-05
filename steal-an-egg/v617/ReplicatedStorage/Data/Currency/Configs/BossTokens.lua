local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
return table.freeze({
	DisplayName = "Boss Tokens",
	Rarity = Rarity.Rarities.Epic,
	Desc = "",
	Icon = "rbxassetid://84787104764975",
	_id = "BossTokens"
})