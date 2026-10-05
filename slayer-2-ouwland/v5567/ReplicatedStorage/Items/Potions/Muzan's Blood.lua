local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://93295955877845",
	Description = "Muzan's sealed flask, meant for Humans only. Drinking it locks the body and remakes it as a Demon.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Toolbar,
	Unique = true,
	EquipOnGrant = true,
	Requirements = {
		Race = { "Human" }
	}
}