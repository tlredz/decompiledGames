local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Olympian Ordinance",
	DisplayName = "Olympian Ordinance Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#52333d'><font color='#700d00'><b>OLYMPUS HUNTS</b></font> ARE NEAR!</font> (ALL OLYMPUS HUNTS GLOBALLY)",
		{
			luck = 800000,
			xp = 8,
			length = 3
		},
		"Olympian Ordinance",
		{
			["Legionnaire Lamprey"] = 10,
			["Helios Sunray"] = 8,
			["Tidecrasher Archon"] = 7,
			["Kerauno Wyrm"] = 6,
			["Styx Angler"] = 5,
			["Olympian Devil"] = 4,
			["Primordial Devourer"] = 10,
			["Spectral Whale"] = 10,
			["Skybreaker Leviathan"] = 10,
			["Tsunami Whale"] = 10,
			["Empyrean Sunwhale"] = 10,
			["Warlord Sturgeon"] = 10
		},
		122422179953749,
		76624061920334,
		"Olympian Ordinance"
	}
}