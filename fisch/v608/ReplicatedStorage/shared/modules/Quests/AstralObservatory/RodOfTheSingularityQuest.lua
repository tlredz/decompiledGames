local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(178, 143, 255)
local count = 0

local function seriesIndex()
	count += 1
	return count
end

count += 1
local rotS_Awaken = {
	DisplayName = "Rod of the Singularity: An Unstable Gift",
	QuestType = "Major",
	Icon = "rbxassetid://0",
	IconColor = color,
	AutoNavigate = true,
	AcceptIndicatorTag = "Corvus",
	NavigationTargets = {
		{
			Zone = "Sunstone",
			Tags = { "Merlin" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Rod of the Singularity",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Bring the Dyson Sphere to Merlin" }
	},
	DisplayRewardsFrom = "RotS_Ingredients",
	Rewards = {}
}
count += 1
local RodOfTheSingularityQuest = {
	RotS_Awaken = rotS_Awaken,
	RotS_Ingredients = {
		DisplayName = "Rod of the Singularity: Collapse",
		QuestType = "Major",
		Icon = "rbxassetid://0",
		IconColor = color,
		CompletedDescription = "You have every piece. Bring them to Merlin.",
		AutoNavigate = true,
		AcceptIndicatorTag = "Merlin",
		NavigationTargets = {
			{
				Zone = "Astral Observatory",
				Tags = { "AstralSubarea1" },
				Objectives = { 1 }
			},
			{
				Zone = "Astral Observatory",
				Tags = { "AstralSubarea2" },
				Objectives = { 2 }
			},
			{
				Zone = "Astral Observatory",
				Tags = { "AstralSubarea3" },
				Objectives = { 3 }
			},
			{
				Zone = "Astral Observatory",
				Tags = { "AstralSubarea4" },
				Objectives = { 4 }
			},
			{
				Zone = "Astral Observatory",
				Tags = { "AstralSubarea5" },
				Objectives = { 5 }
			},
			{
				Zone = "Sunstone",
				Tags = { "Merlin" },
				AllComplete = true
			}
		},
		QuestSeries = "Rod of the Singularity",
		SeriesIndex = count,
		List = {
			module.CatchFishAny({
				Fish = "Stabilizer Core",
				AndReturn = true
			}),
			module.CatchFishAny({
				Fish = "Unstable Crystal",
				AndReturn = true
			}),
			module.CatchFishAny({
				Fish = "Umbral Matrix",
				AndReturn = true
			}),
			module.CatchFishAny({
				Fish = "Singularity Control Unit",
				AndReturn = true
			}),
			module.CatchFishAny({
				Fish = "Stellar Wiring",
				AndReturn = true
			})
		},
		Rewards = {
			{ "Rod", "Rod of the Singularity" }
		}
	}
}
local v3 = {}

for k, v4 in RodOfTheSingularityQuest do
	v3[v4.SeriesIndex] = k
end

for k, v4 in v3 do
	local v5 = v3[k - 1]

	if not v5 then
		continue
	end

	local v6 = RodOfTheSingularityQuest[v4]

	if not v6.Prerequisites then
		v6.Prerequisites = {
			QuestComplete = { v5 }
		}
	end
end

return RodOfTheSingularityQuest