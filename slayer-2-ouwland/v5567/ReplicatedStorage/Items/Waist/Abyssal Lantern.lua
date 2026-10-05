local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://100815138511992",
	Description = "A violet lamp in a spined black frame, its glow sitting deep and heavy, like light seen from under still water.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 60,
		["Health Regen Speed"] = 0.05,
		["Max Stamina"] = 20,
		Illumination = 0.5
	}
}