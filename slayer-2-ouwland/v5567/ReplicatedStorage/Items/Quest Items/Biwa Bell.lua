local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://72205792901462",
	Description = "Ringing it opens the covered road to Muzan's lair. The tone belongs to demons even when lent to humans.",
	Rarity = 4,
	EquipType = Menum.ItemEquipType.Toolbar,
	Requirements = {
		Race = { "Demon", "Hybrid" }
	},
	NoSaveRequirements = {
		Race = "Human"
	}
}