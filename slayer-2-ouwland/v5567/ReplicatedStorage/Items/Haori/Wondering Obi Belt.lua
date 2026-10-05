local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://134071895386847",
	Description = "A navy waist wrap bound with a thick braided purple cord, its long tail left hanging like a question nobody answered.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ClothingTag = "Belt",
	Stats = {
		["Max Health"] = 160,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 55
	}
}