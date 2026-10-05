require(script.Parent.Types)
local directory = {
	OnboardingQuestline = {
		ExperimentId = "OnboardingQuestline",
		ConfigKey = "onboarding_questline_variant",
		DefaultVariant = "Control",
		PayloadByVariant = {
			Control = {
				QuestlineEnabled = false
			},
			Questline = {
				QuestlineEnabled = true
			}
		}
	}
}
return {
	Ids = {
		OnboardingQuestline = "OnboardingQuestline"
	},
	Directory = directory,
	Lookup = function(p)
		return directory[p]
	end
}