local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://118015689064265",
	Description = "Plain black shop cloth from Mistfall, tailored for quiet entrances and no questions at the counter.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		Wen = 12900
	},
	ResistCoat = true
}