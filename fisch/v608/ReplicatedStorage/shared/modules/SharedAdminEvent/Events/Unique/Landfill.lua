local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Landfill",
	DisplayName = "Landfill Event",
	Duration = 30,
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
		"A <b><font color='#4f3833'>Landfill</font></b> of trash is falling from the sky!",
		"Landfill",
		{
			Basalt = 3.33,
			Bone = 3.33,
			Boot = 3.33,
			["Broken Arrow"] = 3.33,
			["Broken Gear"] = 3.33,
			["Chipped Crown"] = 3.33,
			["Communication Circuit"] = 3.33,
			["Destroyed Fossil"] = 3.33,
			["Device Display"] = 3.33,
			["Dissolved Bone"] = 3.33,
			Driftwood = 3.33,
			Dripstone = 3.33,
			["Freezing Shroom"] = 3.33,
			["Fungal Cluster"] = 3.33,
			["Honey Clump"] = 3.33,
			Ice = 3.33,
			Log = 3.33,
			["Oversized Leaf"] = 3.33,
			Rock = 3.33,
			["Rusty Bolt"] = 3.33,
			["Rusty Hook"] = 3.33,
			["Scrap Metal"] = 3.33,
			Seaweed = 3.33,
			Skull = 3.33,
			Slag = 3.33,
			Stalactite = 3.33,
			String = 3.33,
			Tire = 3.33,
			["Toxic Jellymass"] = 3.33,
			["Translator Core"] = 3.33
		},
		125442582476047,
		110794774066299,
		"Landfill"
	}
}