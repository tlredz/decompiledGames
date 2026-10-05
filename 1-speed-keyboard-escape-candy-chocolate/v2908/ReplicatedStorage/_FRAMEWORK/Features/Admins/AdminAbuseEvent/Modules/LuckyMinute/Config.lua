return {
	durationSeconds = 60,
	AAFw_AutoPreloadEnabled = false,
	revealRollSeconds = 1.8,
	revealHoldSeconds = 2.8,
	tiers = {
		{
			weight = 55,
			minimum = 2,
			maximum = 10
		},
		{
			weight = 25,
			minimum = 11,
			maximum = 25
		},
		{
			weight = 14,
			minimum = 26,
			maximum = 50
		},
		{
			weight = 5,
			minimum = 51,
			maximum = 75
		},
		{
			weight = 1,
			minimum = 76,
			maximum = 100
		}
	}
}