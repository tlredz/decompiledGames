local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	DeliverMeatToLucy = DeliverAction(
		"Ill restock the pantry(Lv 10)",
		"Bring bear meat back to Lucy",
		"Lucy_Thanks",
		"Lucy_NoMeat"
	),
	DeliverPackageToElara = DeliverAction(
		"Ill deliver the package",
		"Package delivered",
		"Elara_Thanks",
		"Elara_NoPackage"
	)
}