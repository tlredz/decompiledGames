local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = true
	},
	Icon = "rbxassetid://83191377684888",
	Description = "Hiyozu's wrapped trousers are scuffed at the knees, made for a reaper who fought low and close.",
	Rarity = 5,
	Class = "Sentinel",
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
		["Max Health"] = 100,
		["Max Stamina"] = 50,
		["Block Points"] = 3,
		["Block Regen"] = 0.12
	}
}