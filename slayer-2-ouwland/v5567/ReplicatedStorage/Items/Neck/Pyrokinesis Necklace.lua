local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://98247098531021",
	Description = "A violet flame caught on the cord, for blood arts that answer like fire and give none of its warmth.",
	Rarity = 4,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 20,
		["Additional Damage Factor"] = 0.035
	}
}