local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://132496277553184",
	Description = "Spiral dyed yukata whose pattern draws the eye inward, popular with travelers who listen before they speak.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}