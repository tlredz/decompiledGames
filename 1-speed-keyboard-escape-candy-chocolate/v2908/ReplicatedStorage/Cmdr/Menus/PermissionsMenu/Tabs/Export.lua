local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.PermissionsMenu.Types)
return {
	DisplayName = "Export",
	Permission = "cui.permissions",
	Order = 20,
	Setup = function(object, _)
		local allPermissions = AdminPermissions.getAllPermissions()
		object:AddTitle(function(object2)
			object2:SetTitle((`All permissions ({#allPermissions})`))
		end)
		object:AddText(function(object2)
			object2:SetText("Focus the field to select the complete list, then copy it."):SetTextColor(Color3.fromRGB(
				165,
				175,
				190
			)):SetAutoResize(true)
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetDoSelectAllOnFocus(true):SetPlaceholder("No permissions are available."):SetValue(table.concat(
				allPermissions,
				"\n"
			))
		end)
	end
}