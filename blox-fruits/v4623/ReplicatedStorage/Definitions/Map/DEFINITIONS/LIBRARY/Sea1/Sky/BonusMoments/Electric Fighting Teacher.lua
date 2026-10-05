local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
return Builders.BonusMoment.Builder.new(script.Name, script.Parent.Parent.Name, script.Parent.Parent.Parent.Name):setRumorDialogue("There's a master on this island who only trains those who hold a piece of the sky..."):setRewardDialogue({
	"You actually brought it. Raw current, still humming. Do you know how many students I have sent up there?",
	"Hold still. This will hurt, and then it will not, and then you will be stronger than you were."
}):build()