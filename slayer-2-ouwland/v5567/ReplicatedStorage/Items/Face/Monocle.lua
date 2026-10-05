local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://120552605139387",
	Description = "A single cold polished lens for reading faded maps when snow glare makes every mark on them look the same.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	}
}