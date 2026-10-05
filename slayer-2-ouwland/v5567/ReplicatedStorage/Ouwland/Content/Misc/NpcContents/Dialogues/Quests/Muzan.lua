local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Muzan Quest"] = {
		QuestInstance = Quests.Quest(
			"Muzan Quest",
			{ Quests.QuestTask("Spider Lilies", 9), Quests.QuestTask("Deliver Dr. Higoshima", 1) }
		),
		Rewards = {
			["Muzan's Blood"] = {
				Quantity = 1
			}
		},
		Category = "Muzan",
		Priority = 1,
		OfferNpc = false,
		CompletionNotify = {
			Icon = BunchaIcons.MuzanIcon,
			Text = "So, you've done as I asked of you. Drink, and shed that fragile, dying shell for good.",
			Duration = 8
		}
	}
}