local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	DeliverSuppliesToShiro = DeliverAction(
		"Ill help you survive the winter(Lv 100)",
		"Return to Shiro",
		"Shiro_Thanks",
		"Shiro_Short"
	),
	DeliverWinterCatchToShiro = DeliverAction(
		"Ill fill the winter stores(Lv 105)",
		"Return to Shiro",
		"Shiro_CatchThanks",
		"Shiro_Short"
	),
	DeliverDeepCatchToAkio = DeliverAction(
		"Ill haul in the deep catch(Lv 125)",
		"Return to Akio",
		"Akio_FishThanks",
		"Akio_FishShort"
	)
}