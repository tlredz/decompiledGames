local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://101622974081610",
	Description = "A deep navy drape scattered with frost, long enough to pull across the face when the weather turns against you.",
	Rarity = 6,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 90,
		["Stamina Regen Speed"] = 0.1,
		["Movement Speed Factor"] = 0.1
	}
}