local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://84401276840566",
	Description = "Sour bait that draws better bites and is spent when the line resolves. Fit it to a rod that can hold brighter fish.",
	Rarity = 3,
	Price = {
		Wen = 9
	},
	BaitTier = 2,
	EquipType = Menum.ItemEquipType.Bait,
	FishingStats = {
		FishLuck = 0.1,
		BiteSpeedMultiplier = 0.5,
		CatchChance = 0.1
	}
}