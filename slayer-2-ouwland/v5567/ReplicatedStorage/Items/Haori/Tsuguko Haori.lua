local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://80963940820163",
	Rarity = 9,
	EquipType = Menum.ItemEquipType.Clothing,
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	AccountWide = true,
	NoDiscard = true
}