return table.freeze({
	Enabled = true,
	DefaultMap = "Map1",
	VoteSeconds = 12,
	ArrivalBreatherSeconds = 4,
	AfterSummarySeconds = 0.5,
	BackgroundBlurSize = 8,
	ResultSeconds = 2,
	Maps = table.freeze({
		{
			Id = "Map1",
			Name = "THE VALLEY",
			Subtitle = "The original crossing.",
			Accent = Color3.fromRGB(129, 211, 178)
		},
		{
			Id = "Map2",
			Name = "THE BARN",
			Subtitle = "Huss across the hay.",
			Accent = Color3.fromRGB(238, 192, 124)
		}
	})
})