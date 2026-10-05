local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
AdminPermissions.linkCommandToPermission("huntbadge", "cmdr")
return {
	Name = "huntbadge",
	Aliases = { "badgegui" },
	Description = "Debug: play the hunt badge reward popup.",
	Group = "Debug",
	Args = {},
	ClientRun = function()
		local Config = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules["20YearsEvent"].Config)
		local ItemRewardUISystem = require(ReplicatedStorage.ItemRewardUISystem)
		ItemRewardUISystem.playForBadge(Config.huntBadgeId)
		return "Played hunt badge reward"
	end
}