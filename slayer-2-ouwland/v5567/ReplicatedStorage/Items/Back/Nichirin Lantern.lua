local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://99427781350355",
	Description = "A back lantern polished to the pale sheen of Corps steel, made to keep the dark from closing in.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 85,
		["Max Stamina"] = 45,
		["Additional Damage"] = 2,
		Illumination = 0.65
	}
}