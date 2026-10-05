local ChrysalisQuest = {
	Chrysalis1 = {
		DisplayName = "Chrysalis",
		Icon = "rbxassetid://104890116657151",
		IconColor = Color3.fromRGB(101, 75, 111),
		QuestType = "Major",
		Description = "Find the Globe Jellyfish Hex asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.ChrysalisQuest",
				true,
				"Bring an Aurora \"Globe Jellyfish\" to Hex"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Exalted Relic",
				{
					Mutation = "Bloom",
					Weight = 21
				},
				5
			},
			{ "Xp", 50000 }
		}
	},
	Chrysalis2 = {
		DisplayName = "Chrysalis",
		Icon = "rbxassetid://104890116657151",
		IconColor = Color3.fromRGB(147, 105, 159),
		QuestType = "Major",
		Description = "Find the Magician Narwhal Hex asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.ChrysalisQuest",
				true,
				"Bring a Hexed \"Magician Narwhal\" to Hex"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Exalted Relic",
				{
					Mutation = "Flora",
					Weight = 21
				},
				10
			},
			{
				"ItemOrFish",
				"Song of the Deep",
				{
					Mutation = "Flora",
					Weight = 21
				},
				1
			},
			{ "Xp", 500000 }
		}
	},
	Chrysalis3 = {
		DisplayName = "Chrysalis",
		Icon = "rbxassetid://104890116657151",
		IconColor = Color3.fromRGB(240, 164, 255),
		QuestType = "Major",
		Description = "Find the Moon Idol Hex asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.ChrysalisQuest",
				true,
				"Bring a Hexed \"Moon Idol\" to Hex"
			}
		},
		Rewards = {
			{ "Rod", "Chrysalis" },
			{ "Xp", 1500000 }
		}
	}
}

for _, v in ChrysalisQuest do
	v.WishLocked = "Chrysalis"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return ChrysalisQuest