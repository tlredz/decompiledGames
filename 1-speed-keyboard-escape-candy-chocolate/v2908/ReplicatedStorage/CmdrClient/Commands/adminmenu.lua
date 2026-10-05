local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local AdminMenu = require(ReplicatedStorage.Cmdr.Menus.AdminMenu)
AdminPermissions.linkCommandToPermission("adminmenu", "cui.admin")
return {
	Name = "adminmenu",
	Aliases = {},
	Description = "Open the admin menu.",
	Group = "Admin",
	Args = {},
	ClientRun = function(_)
		AdminMenu.Open()
		return "Menu Opened"
	end
}