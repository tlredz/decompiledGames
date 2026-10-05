local SnowbladeQuest = {
	Snowblade1 = {
		DisplayName = "Snowblade",
		Icon = "rbxassetid://139914327883023",
		IconColor = Color3.fromRGB(141, 156, 166),
		QuestType = "Major",
		Description = "Find the Manatee Sno asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.SnowbladeQuest",
				true,
				"Bring a Frozen \"Manatee\" to Sno"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Lapis Lazuli",
				{
					Mutation = "Blighted",
					Weight = 0.9
				},
				1
			},
			{
				"ItemOrFish",
				"Ancient Thread",
				nil,
				1
			}
		}
	},
	Snowblade2 = {
		DisplayName = "Snowblade",
		Icon = "rbxassetid://139914327883023",
		IconColor = Color3.fromRGB(181, 200, 213),
		QuestType = "Major",
		Description = "Find the Warty Frogfish Sno asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.SnowbladeQuest",
				true,
				"Bring a Darkened \"Warty Frogfish\" to Sno"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Golden Sea Pearl",
				{
					Mutation = "Frozen",
					Weight = 0.2
				},
				1
			},
			{
				"ItemOrFish",
				"Lunar Thread",
				nil,
				1
			}
		}
	},
	Snowblade3 = {
		DisplayName = "Snowblade",
		Icon = "rbxassetid://139914327883023",
		IconColor = Color3.fromRGB(217, 240, 255),
		QuestType = "Major",
		Description = "Find the Blobfish Sno asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.SnowbladeQuest",
				true,
				"Bring a Shiny OR Sparkling Blessed \"Blobfish\" to Sno"
			}
		},
		Rewards = {
			{ "Rod", "Fallen Snowblade" }
		}
	}
}

for _, v in SnowbladeQuest do
	v.WishLocked = "FallenSnowblade"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return SnowbladeQuest