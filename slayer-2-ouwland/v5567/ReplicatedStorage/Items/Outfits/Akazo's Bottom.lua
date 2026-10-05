local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = true
	},
	Icon = "rbxassetid://72246927346753",
	Description = "Akazo's wide pale trousers, hung with red tassels at the waist and left loose so bare feet can drive through broken ground.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		Pants = true,
		EquippedPants = true,
		Shoes = true,
		EquippedShoes = true
	},
	ClothingTag = "Pants",
	Stats = {
		["Max Health"] = 240,
		["Max Stamina"] = 80,
		["Movement Speed Factor"] = 0.09
	}
}