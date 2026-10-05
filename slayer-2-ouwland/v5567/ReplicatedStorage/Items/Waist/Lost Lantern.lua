local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106558617417287",
	Description = "Taken from the Lost set, this lantern burns with a nervous glow, made for hands that never stopped moving.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 70,
		["Max Stamina"] = 40,
		["Stamina Regen Speed"] = 0.03,
		["Additional Damage Factor"] = 0.03,
		Illumination = 0.8
	}
}