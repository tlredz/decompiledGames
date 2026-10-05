local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Pond Emperor Uprising",
	DisplayName = "Pond Emperor Uprising Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#3999ed'>THE <b>BABY POND EMPERORS</b> ARE RISING!</font>",
		{
			luck = 5,
			xp = 5,
			length = 3
		},
		"Pond Emperor",
		{
			["Baby Pond Emperor"] = 100
		},
		{
			Female = 10,
			Sandy = 10,
			Mango = 10,
			Doomsday = 10,
			Red = 10,
			Green = 10,
			Blue = 10,
			Pink = 10,
			Yellow = 10,
			Cursed = 10
		},
		122422179953749,
		133380935500735,
		"Pond Emperor Uprising"
	}
}