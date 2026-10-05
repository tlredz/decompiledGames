local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local DevMenu = require(ReplicatedStorage.Cmdr.Menus.DevMenu)
AdminPermissions.linkCommandToPermission("devmenu", "cui.dev")
return {
	Name = "devmenu",
	Aliases = {},
	Description = "Open the developer menu.",
	Group = "Admin",
	Args = {},
	ClientRun = function(_)
		DevMenu.Open()
		return "Dev Menu Opened"
	end
}