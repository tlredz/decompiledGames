local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Tidefall Resurgence",
	DisplayName = "Tidefall Resurgence Event",
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
		"<font color='#ccfcdd'><font color='#2d5e48'><b>TIDEFALL HUNTS</b></font> are near!</font> (All Tidefall Hunts Globally)",
		{
			luck = 500000,
			xp = 5,
			length = 3
		},
		"Tidefall Resurgence",
		{
			["Admin Bait Crate"] = 2,
			["Admin Crate"] = 2,
			["Admin Fish Barrel"] = 2,
			Plesiosaur = 5,
			["Reef Titan"] = 5,
			Omnithal = 5,
			Pliosaur = 5,
			Goldwraith = 5,
			["Ancient Goldwraith"] = 1,
			["Ancestral Pliosaur"] = 1,
			["Awakened Omnithal"] = 1,
			["Colossus Reef Titan"] = 1,
			["Forbidden Plesiosaur"] = 0.001
		},
		122422179953749,
		122781517104204,
		"Tidefall Resurgence"
	}
}