local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://98419001767236",
	Description = "Knotted lure from Isao's lost line. It is not spent by the bite, and the river favors empty reels around it.",
	Rarity = 5,
	Unique = true,
	NoSell = true,
	NoDelete = true,
	BaitTier = 99,
	EquipType = Menum.ItemEquipType.Bait,
	FishingStats = {
		BiteSpeedMultiplier = 1,
		CatchChance = 0.25
	}
}