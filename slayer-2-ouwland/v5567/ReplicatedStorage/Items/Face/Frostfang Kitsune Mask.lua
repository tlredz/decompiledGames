local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://136273190944120",
	Description = "A pale kitsune with frost blue fangs, said to watch the cold paths where careless breath turns white.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6
	}
}