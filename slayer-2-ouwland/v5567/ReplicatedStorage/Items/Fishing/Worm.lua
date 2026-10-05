local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://135332724894170",
	Description = "Fresh dock bait for the shallow table. Resolved bites take from the stack, whether the hook comes back full or bare.",
	Rarity = 1,
	Price = {
		Wen = 6
	},
	BaitTier = 1,
	EquipType = Menum.ItemEquipType.Bait,
	FishingStats = {
		BiteSpeedMultiplier = 0.25,
		CatchChance = 0.05
	}
}