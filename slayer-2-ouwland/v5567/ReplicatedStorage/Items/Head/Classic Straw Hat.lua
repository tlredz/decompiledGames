local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73075271147224",
	Description = "Honest farmer's straw, woven wide and tight enough to turn back daylight. The plainest thing a demon can wear outdoors.",
	Rarity = 6,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 160,
		["Max Stamina"] = 55,
		["Movement Speed Factor"] = 0.07,
		["Sun Immunity"] = true
	}
}