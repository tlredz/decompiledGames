local createVector = vector.create
return {
	Positions = {
		Pierre = createVector(391.389, 135.348, 196.712),
		Phineas = createVector(469.912, 150.693, 277.955),
		Agaric = createVector(2601.32, 132.388, -729.615),
		Angler = createVector(480.102, 150.501, 302.227),
		Pier = createVector(337.87537, 134.9881, 215.388)
	},
	List = {
		{
			QuestTracker = "baitQuest_Start",
			TargetPosition = "Phineas",
			HideTargetTracker = true,
			GivePosition = "Phineas"
		},
		{
			QuestTracker = "baitQuest_Completed",
			TargetPosition = "Phineas",
			HideTargetTracker = true
		},
		{
			QuestTracker = "baitQuest_Closed",
			TargetPosition = "Phineas",
			HideTargetTracker = true,
			GivePosition = "Phineas"
		},
		{
			QuestTracker = "Angler",
			TargetPosition = "Phineas",
			HideTargetTracker = true,
			GivePosition = "Angler"
		},
		{
			QuestTracker = "agaric_started",
			TargetPosition = "Phineas",
			HideTargetTracker = true,
			GivePosition = "Agaric"
		}
	}
}