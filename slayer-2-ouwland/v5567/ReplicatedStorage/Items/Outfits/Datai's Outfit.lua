local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://140248745348256",
	Description = "Datai's sashwork outfit still holds the crease of long reaches, as if the cloth remembers how to snare.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 145,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 85,
		["Stamina Regen Speed"] = 0.09,
		["Additional Damage Factor"] = 0.04
	}
}