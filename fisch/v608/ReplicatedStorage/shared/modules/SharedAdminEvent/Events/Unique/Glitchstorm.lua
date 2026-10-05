local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
Color3.fromRGB()
return {
	Identity = "Glitchstorm",
	DisplayName = "Glitchstorm Event",
	Duration = 300,
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
		"<font color='#00A194'>everything is glitching...</font>",
		{
			luck = 453495,
			xp = 1.15372,
			length = 5
		},
		"Glitchstorm",
		{
			["Glitched Shades"] = 20,
			["Glitch Cap"] = 20,
			["Broken Scylla"] = 3
		},
		{
			Fragmented = 100
		},
		81751962847320,
		102735269145151,
		"Glitchstorm"
	}
}