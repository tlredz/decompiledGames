local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://127724981989109",
	Description = "Kaiden's ragged top leaves the arms free, bandit cloth made for gauntlets rather than ceremony.",
	Rarity = 4,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	DisableClothing = {
		Shirt = true,
		EquippedShirt = true
	},
	ClothingTag = "Shirt",
	Stats = {
		["Max Health"] = 55,
		["Max Stamina"] = 30,
		["Additional Damage"] = 1
	}
}