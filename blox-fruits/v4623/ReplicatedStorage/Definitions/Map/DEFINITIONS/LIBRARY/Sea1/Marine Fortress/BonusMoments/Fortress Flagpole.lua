local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
return Builders.BonusMoment.Builder.new(script.Name, script.Parent.Parent.Name, script.Parent.Parent.Parent.Name):setRumorDialogue("That same flag's been raised here forever..."):setRewardDialogue({
	"YOOO NO WAY MY BOY YOU REALLY DID THAT LOL. The marines have to deal with the fact some regular homies managed to raise a flag at a whole military base LOL. No way.",
	"Take this, bro, you earned every bit of it. I'm gonna go feed on some of those Marine tears. ROFL."
}):setIslandCompleteDialogue("That new flag's certainly one way to leave your mark on the fortress. Nice touch!"):build()