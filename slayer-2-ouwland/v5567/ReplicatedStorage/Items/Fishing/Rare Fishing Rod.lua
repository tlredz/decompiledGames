local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://89541897353265",
	Description = "A better built rod earned with Golden Fish. It reaches the brighter catches that the permit rod mostly misses.",
	Rarity = 3,
	Price = {
		Wen = 10000,
		["Golden Fish"] = 5
	},
	EquipType = Menum.ItemEquipType.Toolbar,
	Refinable = true,
	RefineStats = { "FishLuck" },
	FishingStats = {
		CatchTier = "Rare",
		CastRadius = 40,
		FishLuck = 0.25,
		BiteSpeedMultiplier = 1.5,
		CatchChance = 0.95
	}
}