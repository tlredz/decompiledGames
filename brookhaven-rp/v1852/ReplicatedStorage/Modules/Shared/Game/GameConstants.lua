local GameConstants = {
	PlaceIds = {
		Live = {
			Live = 4924922222,
			PreRelease = 93138165643153,
			QA = 92106543276146
		},
		QA = {
			QA1 = 104134919331021,
			QA2 = 72784727961168,
			QA3 = 132151526704941,
			QA4 = 100502770462002,
			QA5 = 77230535097707,
			QA6 = 73572116079161,
			QA7 = 88583186985920
		},
		Dev = {
			BrookhavenCCTesting = 124464319430543,
			Dev1 = 114115611478241,
			Dev2 = 117823346514407,
			Dev3 = 122816919427697,
			DrakeDev = 91407967357417,
			HouseTesting = 119666190922303,
			DevLeo = 93706329559053,
			DevLeo2 = 95259635538620,
			Filming1 = 118998109032031,
			Filming2 = 76165017172745
		},
		Staging = {
			Staging = 100069974809509
		}
	},
	GameIds = {
		Live = {
			Live = 1686885941,
			PTS = 117023038506979
		},
		QA = {
			QA1 = 7195962939,
			QA2 = 7195965626,
			QA3 = 7195970671,
			QA4 = 7195973684,
			QA5 = 7196085464,
			QA6 = 7196126528,
			QA9 = 7849662336
		},
		Dev = {
			BrookhavenCCTesting = 7195878806,
			Dev1 = 7195878806,
			Dev2 = 7196132081,
			Dev3 = 7196134521,
			DrakeDev = 7196151288,
			Filming1 = 10164459406,
			Filming2 = 10341539916
		},
		Staging = {
			Staging = 10164414807
		}
	}
}
GameConstants.UnrestrictedGamepassAccessGameIds = {
	GameConstants.GameIds.Dev.BrookhavenCCTesting,
	GameConstants.GameIds.Dev.Filming1,
	GameConstants.GameIds.Dev.Filming2
}
GameConstants.WeatherTypes = {
	Cloudy = "Cloudy",
	Darkness = "Darkness",
	Flooding = "Flooding",
	Foggy = "Foggy",
	SkyClouds = "SkyClouds",
	SkyGreen = "SkyGreen",
	SkyOrange = "SkyOrange",
	Snow = "Snow",
	SnowGround = "SnowGround",
	Raining = "Raining"
}
return GameConstants