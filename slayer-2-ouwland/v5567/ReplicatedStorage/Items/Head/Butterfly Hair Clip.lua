local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://107030028975847",
	Description = "Shinora's violet wing clip, light enough that a fast fighter forgets it is pinned there at all.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 55,
		["Stamina Regen Speed"] = 0.09,
		["Movement Speed Factor"] = 0.08
	}
}