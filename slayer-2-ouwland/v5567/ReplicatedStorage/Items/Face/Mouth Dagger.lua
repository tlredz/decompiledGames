local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://125588708952800",
	Description = "A short blade clenched in the teeth, on the reasoning that two hands and two swords were never going to be enough.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6
	}
}