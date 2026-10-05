local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://91800066883446",
	Description = "Checkerboard cloth in a charcoal seller's colors, worn soft where the sleeves swing over a blade.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 24000
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 130,
		["Max Stamina"] = 40,
		["Movement Speed Factor"] = 0.06
	}
}