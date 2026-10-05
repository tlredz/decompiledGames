local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://",
	Description = "The haori of the Slayer Corps' head, dusk shading into still water at the lining. Whoever wears it is not expected to draw, only to be stood behind.",
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