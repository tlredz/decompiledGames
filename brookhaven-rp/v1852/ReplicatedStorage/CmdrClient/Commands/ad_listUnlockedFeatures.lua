return {
	Name = "ad_listUnlockedFeatures",
	Aliases = {},
	Description = "List the unlocked features by ad",
	Group = "Ads",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to be fetch the unlocked features by ad",
			Optional = true
		}
	}
}