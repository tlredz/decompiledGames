local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75576382097685",
	Description = "A painted temari ball on a cord, its lacquer chipped where Sumari's art pulled the thread tight.",
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