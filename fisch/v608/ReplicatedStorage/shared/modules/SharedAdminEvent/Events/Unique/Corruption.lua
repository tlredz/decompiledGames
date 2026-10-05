local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Corruption",
	DisplayName = "Corruption Event",
	Duration = 240,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"Rod",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<b><font color='#730000'>CORRUPTION</font></b> HAS BEGUN! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 2000,
			xp = 4,
			length = 4
		},
		"Corruption",
		{
			["Corrupted Floppy"] = 25,
			["Corrupted Kraken"] = 15,
			["Corrupted Scylla"] = 10,
			["Corrupted Mosslurker"] = 7,
			["Corrupted Megalodon"] = 5
		},
		{
			Mayhem = 15
		},
		"Sanguine Spire",
		81751962847320,
		136314743557411,
		"CORRUPTION"
	}
}