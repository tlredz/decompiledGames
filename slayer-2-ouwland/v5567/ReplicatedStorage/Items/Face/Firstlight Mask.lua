local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://94433181557823",
	Description = "A high crowned faceplate in set white and gold, made for a calm guard and the long work of standing until the sky returns.",
	Rarity = 6,
	Series = "Firstlight",
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 180,
		["Health Regen Speed"] = 0.09,
		["Max Stamina"] = 75,
		["Damage Reduction Factor"] = 0.046
	}
}