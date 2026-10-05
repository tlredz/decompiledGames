local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	DeliverKatanasToRooyi = DeliverAction(
		"Ill eliminate the Mizunoto(Lv 62)",
		"Return to the Shady Individual",
		"Shady Individual_Thanks",
		"Shady Individual_NotEnough"
	)
}