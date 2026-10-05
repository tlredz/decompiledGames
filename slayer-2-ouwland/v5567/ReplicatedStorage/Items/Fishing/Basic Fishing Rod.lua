local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://139725940129333",
	Description = "A plain permit rod for Mistfall's everyday catch. Its line can be refined, but it will not truly reach deep water.",
	Rarity = 1,
	Price = {
		Wen = 3500
	},
	EquipType = Menum.ItemEquipType.Toolbar,
	ToolScript = "Rare Fishing Rod",
	Refinable = true,
	RefineStats = { "FishLuck" },
	FishingStats = {
		CatchTier = "Common"
	}
}