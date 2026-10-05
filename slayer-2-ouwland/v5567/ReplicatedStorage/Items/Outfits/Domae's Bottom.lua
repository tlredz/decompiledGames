local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = true
	},
	Icon = "rbxassetid://130703831803818",
	Description = "Domae's white trousers are clean past reason, the cuffs stiff with frost from rooms that never thawed.",
	Rarity = 5,
	Class = "Phantom",
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
		["Max Health"] = 60,
		["Max Stamina"] = 60,
		["Stamina Regen Speed"] = 0.09,
		["Movement Speed Factor"] = 0.08
	}
}