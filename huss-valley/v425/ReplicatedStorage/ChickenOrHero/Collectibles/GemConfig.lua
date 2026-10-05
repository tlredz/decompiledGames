return table.freeze({
	Enabled = true,
	EmptyChance = 0.2,
	Layouts = {
		{
			Weight = 50,
			Min = 2,
			Max = 4
		},
		{
			Weight = 38,
			Min = 4,
			Max = 6
		},
		{
			Weight = 12,
			Min = 6,
			Max = 9
		}
	},
	StackValues = {
		{
			Weight = 76,
			Value = 1
		},
		{
			Weight = 20,
			Value = 3
		},
		{
			Weight = 4,
			Value = 6
		}
	},
	MaxGemsPerCrossing = 30,
	EdgeMargin = 9,
	SafeMargin = 9,
	Separation = 15,
	HoverHeight = 2.8,
	PickupRadius = 3.4,
	VerticalTolerance = 5,
	PollInterval = 0.08,
	MaxSampleGap = 0.6,
	MaxSampleSpeed = 110,
	PositionSlack = 5,
	MaxVisibleDistance = 190
})