local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
return Builders.BonusMoment.Builder.new(script.Name, script.Parent.Parent.Name, script.Parent.Parent.Parent.Name):setRumorDialogue("I hear noises coming from beneath the pyramid sometimes... I swear I'm not crazy!"):setRewardDialogue({
	"What! You saved Hasan?! I've been wondering where he went, but since it's the season for the cacti to bloom.. I couldn't just leave my business behind to collapse..",
	"I appreciate you for finding Hasan and letting me know about his whereabouts. I have other pressing matters to address right now."
}):setIslandCompleteDialogue("Phew! I thought we'd lost Hasan for sure. Thanks for saving him!"):build()