local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105216813633697",
	Description = "Layered paper and lacquer holding the shape of a face somebody could not stand to let go of.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6
	}
}