local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://103980779054366",
	Description = "Sunflower dye warms this kesa, a field bright cloth that looks out of place under demon haunted eaves.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}