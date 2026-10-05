local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
return table.freeze({
	DisplayName = "Sakura Crystals",
	Rarity = Rarity.Rarities.Epic,
	Desc = "",
	Icon = "rbxassetid://71612969542341",
	Sounds = {
		Single = {
			Data = {
				Volume = 0.5,
				Speed = { 0.95, 1.05 }
			},
			Ids = { "rbxassetid://122083641072193" }
		}
	},
	_id = "SakuraCrystals"
})