local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Sharks",
	DisplayName = "Shark Event",
	Duration = 300,
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
		"<font color='#ffffff'>A <b><font color='#3a8dc5'>Sharknado</font></b> has arisen from the sea.</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 101,
			xp = 1,
			length = 5
		},
		"Sharks",
		{
			["Phantom Megalodon"] = 0.05,
			["Ancient Megalodon"] = 1,
			Megalodon = 1,
			["Great Goldcursed Shark"] = 2.5,
			["Scalloped Hammerhead"] = 2.5,
			["Whale Shark"] = 2.5,
			["Great Hammerhead Shark"] = 2.5,
			["Great White Shark"] = 2.5,
			["Crystal Frilled Shark"] = 5,
			["Kitefin Shark"] = 5,
			["Gemstone Whale Shark"] = 5,
			["Bull Shark"] = 5,
			["Cookiecutter Shark"] = 5,
			["Nurse Shark"] = 5,
			["Umbral Shark"] = 5,
			["Barbed Shark"] = 5,
			["Ginsu Shark"] = 5,
			["Goblin Shark"] = 5,
			["Icebeard Shark"] = 5,
			["Maelstorm Shark"] = 5,
			["Carrot Shark"] = 5,
			["Frilled Shark"] = 17.95
		},
		81751962847320,
		75393043537250,
		"SHARKKSSSSS"
	}
}