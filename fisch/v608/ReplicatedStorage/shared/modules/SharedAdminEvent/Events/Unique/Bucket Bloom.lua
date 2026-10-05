local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Bucket Bloom",
	DisplayName = "Bucket Bloom",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Lighting",
		"Fish",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color = '#7b03fc'><b>Buckets</b> are falling from the sky!</font>",
		"Bucket Bloom",
		{
			Mustard = 50
		},
		{
			Mace = 10
		},
		122422179953749,
		129539748953446,
		"Bucket Bloom"
	}
}