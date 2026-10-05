local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	DisableClothing = {
		Hair = true
	},
	Icon = "rbxassetid://79321258241297",
	Description = "Plain cloth tied back off the brow, the first thing most fighters buy and the last thing they bother replacing.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	}
}