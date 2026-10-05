local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Floppy Fiesta",
	DisplayName = "Floppy Fiesta Event",
	Duration = 180,
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
		"A <b><font color='#f5b338'>Floppy Fiesta</font></b> is falling from the sky!",
		"Floppy Fiesta",
		{
			Floppy = 10,
			["Supersized Floppy"] = 10,
			["Squished Floppy"] = 10,
			["Broken Floppy"] = 9,
			["Corrupted Floppy"] = 1,
			["Silly Floppy"] = 10,
			["Disguised Floppy"] = 10,
			["Holy Floppy"] = 10,
			["Sleepy Floppy"] = 10,
			["Sad Floppy"] = 10,
			["Overjoyed Floppy"] = 10
		},
		125442582476047,
		106183842303947,
		"Floppy Fiesta"
	}
}