local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local LiveOpsMenu = require(ReplicatedStorage.Cmdr.Menus.LiveOpsMenu)
AdminPermissions.linkCommandToPermission("liveopsmenu", "cui.liveops")
return {
	Name = "liveopsmenu",
	Aliases = {},
	Description = "Open the LiveOps menu.",
	Group = "Admin",
	Args = {},
	ClientRun = function(_)
		LiveOpsMenu.Open()
		return "LiveOps Menu Opened"
	end
}