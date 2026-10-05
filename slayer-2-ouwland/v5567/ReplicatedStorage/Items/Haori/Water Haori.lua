local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://123481812741942",
	Description = "Giyen's haori, plain dark on one side and a field of green and gold blocks on the other, calm at the collar and severe at the hem.",
	Rarity = 6,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 150,
		["Max Stamina"] = 80,
		["Block Points"] = 6,
		["Block Regen"] = 0.15
	}
}