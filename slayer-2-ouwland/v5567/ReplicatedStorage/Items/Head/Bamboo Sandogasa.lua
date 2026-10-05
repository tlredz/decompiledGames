local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://126436271923367",
	Description = "A domed bamboo hat marked with a white cross, layered until no daylight reaches the head beneath it.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 35,
		["Movement Speed Factor"] = 0.05,
		["Sun Immunity"] = true
	}
}