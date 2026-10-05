local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73956090777283",
	Description = "Mid-sized training gourd. A steady breath consumes it and pushes a Slayer's practice onward.",
	EquipType = Menum.ItemEquipType.Toolbar,
	Rarity = 2,
	ToolScript = "Small Gourd",
	ShowRemainder = true,
	Price = {
		Wen = 3000
	}
}