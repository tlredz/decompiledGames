local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Dragons!",
	DisplayName = "Dragons! Event",
	Duration = 240,
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
		"<font color='#cceafc'><font color='#57c7ff'><b>Dragon-Like Fish</b></font> are near!</font> (Colossal Dragons, Leviathans, Frostwyrm Obtainable Globally)",
		"Dragons!",
		{
			Leviathan = 25,
			["Colossal Blue Dragon"] = 25,
			["Colossal Ancient Dragon"] = 15,
			Frostwyrm = 15,
			["Profane Leviathan"] = 7,
			["Colossal Ethereal Dragon"] = 7
		},
		122422179953749,
		88811851792692,
		"Dragons!"
	}
}