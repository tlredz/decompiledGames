return {
	HalibutHarpoon1 = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 1,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			Level = 1000
		},
		IsSecret = true
	},
	HalibutHarpoon2 = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 2,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon1" }
		},
		IsSecret = true
	},
	HalibutHarpoon3 = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 3,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon2" }
		},
		IsSecret = true
	},
	HalibutHarpoon3_Intermission = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 4,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon3" }
		},
		IsSecret = true
	},
	HalibutHarpoon4 = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 5,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon3_Intermission" }
		},
		IsSecret = true
	},
	HalibutHarpoon5 = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 6,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon4" }
		},
		IsSecret = true
	},
	HalibutHarpoon6 = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 7,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon5" }
		},
		IsSecret = true
	},
	HalibutHarpoon6_FinalPayment = {
		DisplayName = "???",
		QuestType = "Major",
		QuestSeries = "Halibut Harpoon",
		SeriesIndex = 8,
		AcceptIndicatorTag = "DrMonty",
		Prerequisites = {
			QuestComplete = { "HalibutHarpoon6" }
		},
		IsSecret = true
	}
}