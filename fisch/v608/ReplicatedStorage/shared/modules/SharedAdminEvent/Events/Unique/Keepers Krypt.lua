local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Keepers Krypt",
	DisplayName = "Keepers Krypt Event",
	Duration = 186,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Lighting",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"THE KEEPERS ARE BLESSING THE SEAS WITH <font color = '#c490ff'><b>ALL TYPES OF RELICS</b>!</font>",
		"Keepers Krypt",
		{
			["Exalted Relic"] = 20,
			["Cosmic Relic"] = 15,
			["Enchant Relic"] = 30,
			["Twisted Relic"] = 10,
			["Sovereign Relic"] = 2,
			["Admin Relic"] = 3,
			["Song of the Deep"] = 5,
			["Invincible Relic"] = 5
		},
		122422179953749,
		121846459340728,
		"Keepers Krypt"
	}
}