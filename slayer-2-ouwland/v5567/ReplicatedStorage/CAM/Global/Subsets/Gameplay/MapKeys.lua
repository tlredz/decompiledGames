local MapKeys = {
	Scope = "Slot",
	Action = "MapSetting",
	Groups = {
		"Bosses",
		"Areas",
		"Shrines",
		"Quests",
		"Markers",
		"Trackers"
	},
	GroupRequires = {
		Trackers = { "Muzan Tracker", "Night Market Locator", "Horse Locator" }
	},
	Keys = {
		{
			Name = "BossNames",
			Path = "Misc/Map/BossNames",
			Default = true,
			Label = "Boss Names",
			Group = "Bosses"
		},
		{
			Name = "BossIcons",
			Path = "Misc/Map/BossIcons",
			Default = true,
			Label = "Boss Icons",
			Group = "Bosses"
		},
		{
			Name = "AreaNames",
			Path = "Misc/Map/AreaNames",
			Default = true,
			Label = "Area Names",
			Group = "Areas"
		},
		{
			Name = "ShrineNames",
			Path = "Misc/Map/ShrineNames",
			Default = true,
			Label = "Shrine Names",
			Group = "Shrines"
		},
		{
			Name = "ShrineIcons",
			Path = "Misc/Map/ShrineIcons",
			Default = true,
			Label = "Shrine Icons",
			Group = "Shrines"
		},
		{
			Name = "RecommendedQuest",
			Path = "Misc/Map/RecommendedQuest",
			Default = true,
			Label = "Recommended Quest",
			Group = "Quests"
		},
		{
			Name = "QuestMarkers",
			Path = "Misc/Map/QuestMarkers",
			Default = true,
			Label = "Quest Markers",
			Group = "Quests"
		},
		{
			Name = "PartyMarkers",
			Path = "Misc/Map/PartyMarkers",
			Default = true,
			Label = "Party Members",
			Group = "Markers"
		},
		{
			Name = "PlacedMarker",
			Path = "Misc/Map/PlacedMarker",
			Default = true,
			Label = "My Marker",
			Group = "Markers"
		},
		{
			Name = "TrackedSpawns",
			Path = "Misc/Map/TrackedSpawns",
			Default = true,
			Label = "Tracked Spawns",
			Group = "Trackers"
		}
	},
	ByName = {}
}

for _, key in MapKeys.Keys do
	MapKeys.ByName[key.Name] = key
end

MapKeys.ByGroup = {}

for _, group in MapKeys.Groups do
	MapKeys.ByGroup[group] = {}
end

for _, key in MapKeys.Keys do
	table.insert(MapKeys.ByGroup[key.Group], key)
end

return MapKeys