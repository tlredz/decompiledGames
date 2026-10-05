local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://100352912514673",
	Description = "Final Selection issue, plain Corps cloth that marks a survivor and is never meant for a demon's keeping.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Costume,
	ResistCoat = true,
	Unique = true,
	NoDelete = true,
	Requirements = {
		Race = { "Slayer", "Hybrid" }
	}
}