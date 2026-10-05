return {
	Name = "removeTreadmillMedia",
	Description = "Exclude a treadmill media item from the feed everywhere (live, via the overlay DataStore) and remove it from RecommendationService",
	Group = "Moderator",
	Args = {
		{
			Type = "string",
			Name = "media",
			Description = "Media key (Video:123), asset id (123), or asset link"
		}
	}
}