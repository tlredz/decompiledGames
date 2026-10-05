local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://125265576801917",
	Description = "Striped waist cloth wrapped over travel wear, simple work from the same hands that mend dock rope.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	},
	ClothingTag = "Coat"
}