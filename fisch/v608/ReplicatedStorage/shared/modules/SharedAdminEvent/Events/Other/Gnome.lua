local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Gnome",
	DisplayName = "Gnome",
	Duration = 1,
	RunGlobally = false,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Execute" },
	Arguments = { "The green arrows...", function()
			local GnomeBossfight = require(game.ServerStorage.resources.GnomeBossfight)
			GnomeBossfight.Start()
			return function() end
		end }
}