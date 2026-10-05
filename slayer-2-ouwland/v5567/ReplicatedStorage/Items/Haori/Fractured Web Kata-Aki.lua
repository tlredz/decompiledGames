local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://138779996049645",
	Description = "Red webbing cracks across black cloth, each broken line pulled taut like a snare set in the tower dark.",
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
		["Max Health"] = 160,
		["Max Stamina"] = 80,
		["Block Points"] = 5,
		["Block Regen"] = 0.15
	}
}