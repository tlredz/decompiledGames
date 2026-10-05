local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Food",
	DisplayName = "Food Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#ffffff'>Hope you all are <b><font color='#B66B3E'>Hungry...</font></b></font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 600,
			xp = 1,
			length = 5
		},
		{
			["Turkey Leg"] = 20,
			Cheezburger = 70,
			["Bloxy Cola"] = 10
		},
		13076573,
		134842738473088,
		"Food"
	}
}