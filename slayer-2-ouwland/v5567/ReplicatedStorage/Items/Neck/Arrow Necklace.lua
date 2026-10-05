local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://130799220289367",
	Description = "A red arrowhead hung point down, cut to the same pattern the arrow demon leaves in anyone who runs.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	},
	Stats = {
		["Max Health"] = 25,
		["Max Stamina"] = 10,
		["Movement Speed Factor"] = 0.02
	}
}