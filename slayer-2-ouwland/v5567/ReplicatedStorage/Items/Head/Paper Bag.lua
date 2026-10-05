local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	DisableClothing = {
		Hair = true
	},
	Icon = "rbxassetid://93957963256195",
	Description = "A sack with a hole torn for the eyes. Costs almost nothing, hides very nearly everything.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	}
}