local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local color = Color3.fromRGB(190, 210, 255)
DateTime.fromUniversalTime(2026, 10, 3, 17)
local RyuseiWish = {
	Ryusei_Introduction = {
		DisplayName = "Wish of the Sky: The One Who Listens",
		QuestType = "Major",
		Description = "A figure waits at the Skycrest Sanctuary, listening for something that isn't the wind.",
		CompletedDescription = "Speak to Ryusei at the Skycrest Sanctuary.",
		AutoNavigate = true,
		QuestSeries = "Wish of the Sky",
		SeriesIndex = 1,
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main1" }
		},
		List = {
			{ "Custom", 1, "Complete any Ancient Idol's fifth trial" }
		},
		Rewards = {
			{ "DisplayOnly", "<b>Ryusei</b> will now hear your wish" }
		}
	},
	Ryusei_HarnessPower = {
		DisplayName = "Wish of the Sky: Harnessing Power",
		QuestType = "Challenge",
		Description = "Every day Ryusei sends you to a different Ancient Idol. The sky forgives one lapse, not two.",
		CompletedDescription = "Return to Ryusei to receive the Siren's Tear.",
		AutoNavigate = true,
		IsRepeatable = true,
		Prerequisites = {
			QuestComplete = { "Ryusei_Introduction" }
		},
		List = {
			{ "Custom", 14, "Complete Ryusei's daily trial 14 days in a row" }
		},
		Rewards = {
			{
				"ItemOrFish",
				"Siren's Tear",
				{
					Mutation = "Unsellable"
				},
				1
			}
		}
	}
}

for _, v in RyuseiWish do
	v.AcceptIndicatorTag = "Ryusei"
	v.Icon = ""
	v.IconColor = color

	if not v.NavigationTargets then
		v.NavigationTargets = {}
	end

	table.insert(v.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "Ryusei" },
		AllComplete = true
	})
end

return RyuseiWish