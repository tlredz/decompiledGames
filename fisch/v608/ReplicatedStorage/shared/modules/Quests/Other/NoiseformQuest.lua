local dateTime = DateTime.fromUniversalTime(2026, 8, 29, 16)
local NoiseformQuest = {
	Noiseform1 = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Noiseform",
		SeriesIndex = 1,
		IsSecret = true
	},
	Noiseform2 = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Noiseform",
		SeriesIndex = 2,
		Prerequisites = {
			QuestComplete = { "Noiseform1" }
		},
		IsSecret = true
	},
	Noiseform3 = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Noiseform",
		SeriesIndex = 3,
		Prerequisites = {
			QuestComplete = { "Noiseform2" }
		},
		IsSecret = true
	},
	Noiseform4 = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Noiseform",
		SeriesIndex = 4,
		Prerequisites = {
			QuestComplete = { "Noiseform3" }
		},
		IsSecret = true
	},
	Noiseform5 = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Noiseform",
		SeriesIndex = 5,
		Prerequisites = {
			QuestComplete = { "Noiseform4" }
		},
		IsSecret = true
	}
}

for _, v in NoiseformQuest do
	v.WishLocked = "Noiseform"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return NoiseformQuest