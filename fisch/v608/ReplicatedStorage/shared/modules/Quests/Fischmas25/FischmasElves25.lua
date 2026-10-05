local module = require("../../EventConfig/Fischmas25")
return {
	Fischmas25_Elf_WrappingPaper = {
		DisplayName = "Fischmas Factory Assistant: Clumsy Elf",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "ClumsyElf",
		NavigationTargets = {
			{
				Zone = "Toy Factory",
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "ClumsyElf" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas Factory Assistant",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Clumsy Elf dropped a bunch of wrapping paper all over the factory and needs some help cleaning it up.",
		CompletedDescription = "Wrapping paper cleaned! Go and tell Clumsy Elf the good news.",
		Prerequisites = {
			QuestActive = { "Fischmas25_Santa_ElfComplete" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_Elf_WrappingPaper",
				5,
				"Clean up the wrapping paper around the Toy Factory"
			}
		},
		Rewards = {}
	},
	Fischmas25_Elf_Ribbons = {
		DisplayName = "Fischmas Factory Assistant: Lazy Elf",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "LazyElf",
		NavigationTargets = {
			{
				Zone = "Toy Factory",
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "LazyElf" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas Factory Assistant",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Lazy Elf needs some present ribbons, but doesn't feel like going to get them.",
		CompletedDescription = "Bring the present ribbons back to Lazy Elf!",
		Prerequisites = {
			QuestActive = { "Fischmas25_Santa_ElfComplete" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_Elf_Ribbons",
				3,
				"Collect present ribbons"
			}
		},
		Rewards = {}
	},
	Fischmas25_Elf_Hat = {
		DisplayName = "Fischmas Factory Assistant: Bald Elf",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "BaldElf",
		NavigationTargets = {
			{
				Zone = "Toy Factory",
				Tags = { "ElfHat" },
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "BaldElf" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas Factory Assistant",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Bald Elf lost his hat somewhere in the factory...",
		CompletedDescription = "You found the Bald Elf's hat! Go ahead and return it to him, quickly! Please...",
		Prerequisites = {
			QuestActive = { "Fischmas25_Santa_ElfComplete" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_Elf_Hat",
				1,
				"Find the Bald Elf's missing hat"
			}
		},
		Rewards = {}
	},
	Fischmas25_Elf_Stockings = {
		DisplayName = "Fischmas Factory Assistant: Short Elf",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "ShortElf",
		NavigationTargets = {
			{
				Zone = "Toy Factory",
				Tags = { "ElfStocking" },
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "ElfStockingHang" },
				Objectives = { 2 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "ShortElf" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas Factory Assistant",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Short Elf needs to hang up some stockings, but can't reach high enough.",
		CompletedDescription = "Stockings are in place! Go and tell Short Elf the good news.",
		Prerequisites = {
			QuestActive = { "Fischmas25_Santa_ElfComplete" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_Elf_Stockings",
				5,
				"Pick up the stockings"
			},
			{
				"DataInstanceValue",
				"Cache.Fischmas25_Elf_StockingsHang",
				5,
				"Hang up the stockings"
			}
		},
		Rewards = {}
	}
}