local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://104818765738329",
	Description = "A gilded laurel handed to whoever wins the grove's yearly bout. It proves nothing, which is rather the point.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 3000
	}
}