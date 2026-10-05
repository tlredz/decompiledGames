local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://78008431255446",
	Description = "Zentaro's orange haori, its hem broken into white scales. That pattern is the last thing most people see before he is already past them.",
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