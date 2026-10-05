return {
	Name = "registerTreadmillMedia",
	Description = "No args: bulk-sync the shipped catalog with RecommendationService (idempotent, ~1 entry/sec; re-run to check progress). With media: add a new video to the live feed via the overlay DataStore",
	Group = "Moderator",
	Args = {
		{
			Type = "string",
			Name = "media",
			Description = "Asset id or link of the video to add live (omit to bulk-sync)",
			Optional = true
		},
		{
			Type = "string",
			Name = "bucket",
			Description = "Bucket for new media: Brainrot, Funny, Satisfying, WeirdOrHorror, Music",
			Optional = true
		},
		{
			Type = "string",
			Name = "coverImage",
			Description = "Cover image asset id or link",
			Optional = true
		},
		{
			Type = "number",
			Name = "duration",
			Description = "Video duration in seconds (auto-measured from your client when omitted)",
			Optional = true
		}
	}
}