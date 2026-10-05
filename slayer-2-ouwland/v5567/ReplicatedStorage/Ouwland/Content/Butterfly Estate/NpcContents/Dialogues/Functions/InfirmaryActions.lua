local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	DeliverElixirsToShiori = DeliverAction(
		"Ill restock the infirmary(Lv 70)",
		"Return to Shiori",
		"Shiori_Thanks",
		"Shiori_Short"
	),
	DeliverReservesToShiori = DeliverAction(
		"Ill stock the reserves(Lv 75)",
		"Return to Shiori",
		"Shiori_FoodThanks",
		"Shiori_Short"
	),
	DeliverSupplyBoxToShiori = DeliverAction(
		"Ill deliver the supply box(Lv 70)",
		"Deliver to Shiori",
		"Shiori_BoxThanks",
		"Shiori_NoBox"
	)
}