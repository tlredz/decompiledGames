local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	DeliverLetterToChaka = DeliverAction(
		"Ill get this letter delivered",
		"Deliver the Letter to Chaka",
		"Chaka_Thanks",
		"Chaka_NoLetter"
	)
}