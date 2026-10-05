local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	KazumaTakeCatch = DeliverAction("Ill learn the Soryu Style(Lv 62)", "Common Fish", "Kazuma_Catch", "Kazuma_NoCatch"),
	RenjiroTakeCatch = DeliverAction(
		"Ill learn the Tai Chi Style(Lv 65)",
		"Common Fish",
		"Renjiro_Catch",
		"Renjiro_NoCatch"
	),
	ZurinyzTakeCatch = DeliverAction(
		"Ill learn the Reaping Blades Style(Lv 100)",
		"Common Fish",
		"Zurinyz_Catch",
		"Zurinyz_NoCatch"
	)
}