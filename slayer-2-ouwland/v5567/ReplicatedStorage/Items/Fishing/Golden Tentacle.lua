local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75370137621065",
	Description = "Gleaming tentacle bait that draws the deepest bites. Each resolved bite spends bait from the stack.",
	Rarity = 5,
	BaitTier = 3,
	EquipType = Menum.ItemEquipType.Bait,
	FishingStats = {
		FishLuck = 0.4,
		BiteSpeedMultiplier = 1,
		CatchChance = 0.25
	}
}