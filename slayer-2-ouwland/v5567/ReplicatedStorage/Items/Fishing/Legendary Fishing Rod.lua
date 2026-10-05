local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://76409861443267",
	Description = "Isao's handmade rod, raised from the river. It reaches sunken gear when other lines still find only fish.",
	Rarity = 5,
	Unique = true,
	NoSell = true,
	NoDelete = true,
	EquipType = Menum.ItemEquipType.Toolbar,
	ToolScript = "Rare Fishing Rod",
	Refinable = true,
	RefineStats = { "FishLuck" },
	FishingStats = {
		CatchTier = "Items",
		CastRadius = 60,
		FishLuck = 0.5,
		BiteSpeedMultiplier = 3,
		CatchChance = 0.95
	}
}