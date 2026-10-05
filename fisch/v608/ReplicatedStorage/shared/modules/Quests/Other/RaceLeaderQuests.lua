local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(0, 153, 255)
local BoatRacingTracks = require(ReplicatedStorage.shared.modules.BoatRacingTracks)
require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local TimeUtils = require(ReplicatedStorage.shared.utils.TimeUtils)
local RaceLeaderQuests = {}

for _, boatRacingTrack in BoatRacingTracks do
	local formatted = `RaceLeader_{boatRacingTrack.Name}`

	if boatRacingTrack.CompletionReward then
		RaceLeaderQuests[`BoatRacing_{boatRacingTrack.Name}_FirstComplete`] = {
			DisplayName = `Boat Racing: {boatRacingTrack.DisplayName or boatRacingTrack.Name}`,
			Icon = "rbxassetid://102498027167551",
			IconColor = color,
			QuestType = "Side",
			Description = `{boatRacingTrack.NpcName} is offering you a reward if you can complete the {boatRacingTrack.DisplayName or boatRacingTrack.Name} Boat Racing course!`,
			QuestSeries = `BoatRacing_{boatRacingTrack.Name}`,
			SeriesIndex = 1,
			List = {
				{ "BoatRace", 1, boatRacingTrack.Name }
			},
			Rewards = boatRacingTrack.CompletionReward,
			AcceptIndicatorTag = formatted,
			NavigationTargets = {
				{
					Zone = boatRacingTrack.ZoneName or boatRacingTrack.DisplayName or boatRacingTrack.Name,
					Tags = { formatted }
				}
			},
			Prerequisites = {
				Level = boatRacingTrack.LevelRequirement or 25
			}
		}
	end

	if not (boatRacingTrack.TargetTime and boatRacingTrack.TargetTimeReward) then
		continue
	end

	local v = TimeUtils:B(boatRacingTrack.TargetTime)
	RaceLeaderQuests[`BoatRacing_{boatRacingTrack.Name}_TargetTime`] = {
		DisplayName = `Boat Racing: {boatRacingTrack.DisplayName or boatRacingTrack.Name} - Time Trial`,
		Icon = "rbxassetid://102498027167551",
		IconColor = color,
		QuestType = "Side",
		Description = `{boatRacingTrack.NpcName} is offering you another reward if you can complete the {boatRacingTrack.DisplayName or boatRacingTrack.Name} Boat Racing course within {v}!`,
		QuestSeries = `BoatRacing_{boatRacingTrack.Name}`,
		SeriesIndex = 2,
		List = {
			{
				"BoatRace",
				1,
				boatRacingTrack.Name,
				boatRacingTrack.TargetTime
			}
		},
		Rewards = boatRacingTrack.TargetTimeReward,
		AcceptIndicatorTag = formatted,
		NavigationTargets = {
			{
				Zone = boatRacingTrack.ZoneName or boatRacingTrack.DisplayName or boatRacingTrack.Name,
				Tags = { formatted }
			}
		},
		Prerequisites = {
			Level = boatRacingTrack.LevelRequirement or 25,
			QuestComplete = { (`BoatRacing_{boatRacingTrack.Name}_FirstComplete`) }
		}
	}
end

return RaceLeaderQuests