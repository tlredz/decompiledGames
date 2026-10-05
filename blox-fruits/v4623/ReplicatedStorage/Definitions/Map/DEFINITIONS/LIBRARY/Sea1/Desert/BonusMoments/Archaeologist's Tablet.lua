local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
return Builders.BonusMoment.Builder.new(script.Name, script.Parent.Parent.Name, script.Parent.Parent.Parent.Name):setRumorDialogue("The sandstorms have covered up more than you'd think..."):setRewardDialogue({
	"You woke the pillars out in the ruins? I've been scraping at that sand for years!",
	"These carvings are a record of ancient power... the study of it, more than the use of it.",
	"Whoever left them moved on to the frozen north. Get that far and you'll have much more to learn.",
	"Here, take this for the find. You've earned it, explorer."
}):setIslandCompleteDialogue("So those stones were real after all! Who knows what else the desert has buried.."):build()