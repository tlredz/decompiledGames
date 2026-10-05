local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://85069247380039",
	Description = "Shinora's haori, its sleeves fading from gray into butterfly wing, sharp with the memory of poisoned thrusts.",
	Rarity = 6,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 90,
		["Max Stamina"] = 80,
		["Movement Speed Factor"] = 0.1,
		["Stamina Regen Speed"] = 0.1
	}
}