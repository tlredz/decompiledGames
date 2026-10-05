local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
return Builders.BonusMoment.Builder.new(script.Name, script.Parent.Parent.Name, script.Parent.Parent.Parent.Name):setRumorDialogue("I've heard rumors there's a prisoner here who lives very comfortably."):setRewardDialogue({
	"You walked out of that tower wearing his coat?! Do you even know whose coat that is?!",
	"You know what... forget it. I didn't see anything. Just get out of here before you bring trouble down on all of us!"
}):setIslandCompleteDialogue("You stole THE Don Megalo's coat? Oh no, you're in danger... Pretend we never met!"):build()