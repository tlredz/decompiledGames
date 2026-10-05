local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local PermissionsMenu = require(ReplicatedStorage.Cmdr.Menus.PermissionsMenu)
AdminPermissions.linkCommandToPermission("permissionsmenu", "cui.permissions")
return {
	Name = "permissionsmenu",
	Aliases = { "permissions" },
	Description = "Open the admin permission debugger.",
	Group = "Admin",
	Args = {},
	ClientRun = function()
		if PermissionsMenu.Open() then
			return "Permissions menu opened"
		end

		return "You do not have permission to view the permissions menu"
	end
}