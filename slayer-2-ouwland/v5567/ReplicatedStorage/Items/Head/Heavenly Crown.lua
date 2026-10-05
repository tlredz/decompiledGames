local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105707850103031",
	Description = "A crown of dark spines rather than gold, the kind of thing carved for a figure nobody living has actually met.",
	Rarity = 6,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 65000
	},
	Stats = {
		["Max Health"] = 225,
		["Health Regen Speed"] = 0.15,
		["Max Stamina"] = 80
	}
}