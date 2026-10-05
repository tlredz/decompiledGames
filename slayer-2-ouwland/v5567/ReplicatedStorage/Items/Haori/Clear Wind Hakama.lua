local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://135934319904611",
	Description = "Pale hakama that move cleanly in a gale, with cuffs kept narrow for hill paths and sudden footwork.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 2
	},
	ClothingTag = "Pants"
}