local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://88962253942170",
	Description = "Hiyozu's top binds tight across the ribs, leaving the arms free for sickle work.",
	Rarity = 5,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		Shirt = true,
		EquippedShirt = true
	},
	ClothingTag = "Shirt",
	Stats = {
		["Max Health"] = 100,
		["Max Stamina"] = 50,
		["Block Points"] = 3,
		["Block Regen"] = 0.12
	}
}