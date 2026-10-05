local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://120264081284969",
	Description = "Bone white and striped in red, the face that surfaces when a fighter stops arguing with the hollow thing inside and lets it cut.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 70,
		["Max Stamina"] = 35,
		["Additional Damage"] = 2
	}
}