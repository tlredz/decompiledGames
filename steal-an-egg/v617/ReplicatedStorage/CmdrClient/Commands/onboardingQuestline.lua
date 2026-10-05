return {
	Name = "onboardingQuestline",
	Description = "Drives the onboarding questline A/B feature for testing.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to act on."
		},
		{
			Type = "string",
			Name = "Action",
			Description = "enroll | reset | fill | completeSet | expire | status"
		}
	}
}