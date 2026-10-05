require(script.Parent.Types)
local Timing = require(script.Parent.Timing)
local v = {
	Fisherman = {
		ActorRole = "Fisherman",
		ChaseTitle = "Fisherman",
		ChaseText = "Stay away! Ye're scaring the fish off!",
		CrateContent = {
			TemplateFolderName = "Fish",
			GrabTemplateName = "Mossback",
			ItemNamePrefix = "LookoutFailureFish",
			PileCount = 8,
			RandomizeTemplates = true,
			FloppyLanding = true
		},
		CrateReactionText = "What the?.. It's all fish!",
		ReactionDelay = Timing.Failure.CrateReactionHoldTimes.Fisherman
	},
	Doghouse = {
		ActorRole = "Doghouse",
		ChaseTitle = "Doghouse",
		ChaseText = "DONT BBOTHA MME!! AM TRY TO GO FIND MY M ASTA!",
		CrateContent = {
			TemplateFolderName = "Letters",
			GrabTemplateName = "Letter",
			ItemNamePrefix = "LookoutFailureLetter",
			PileCount = 8,
			RandomizeTemplates = false,
			FloppyLanding = true
		},
		CrateReactionText = "What the?.. It's all love letters!",
		ReactionDelay = Timing.Failure.CrateReactionHoldTimes.Doghouse
	}
}
return table.freeze({
	get = function(p)
		return v[p]
	end
})