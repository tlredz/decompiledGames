local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Apex Leviathan",
	DisplayName = "Apex Leviathan Event",
	Duration = 300,
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
		"<font color='#ff3838'><font color='#89c5d3'><b>Apex Leviathans</b></font> are near!</font> (Apex Leviathan Obtainable Globally)",
		"Apex Leviathan",
		{
			["Apex Leviathan"] = 5
		},
		122422179953749,
		84284963960836,
		"Apex Leviathans"
	}
}