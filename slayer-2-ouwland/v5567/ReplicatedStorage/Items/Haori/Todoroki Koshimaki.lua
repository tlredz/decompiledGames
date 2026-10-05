local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://129359931559286",
	Description = "Split red and white waist cloth, singed at the edge and frost pale through the inner wrap.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 60,
		["Max Stamina"] = 45,
		["Stamina Regen Speed"] = 0.09,
		["Movement Speed Factor"] = 0.08
	}
}