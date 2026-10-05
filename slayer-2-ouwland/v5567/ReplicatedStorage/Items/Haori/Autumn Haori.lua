local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75559116975929",
	Description = "Cloth dyed in turning maple, cut for long marches, its hem darkened by wet roads and harbor smoke.",
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