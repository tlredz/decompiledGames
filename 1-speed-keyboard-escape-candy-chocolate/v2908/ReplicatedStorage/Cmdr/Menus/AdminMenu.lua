local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Types)
local CUI = require(ReplicatedStorage.CUI)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local v = {}

local function GetAccessibleTabs()
	local result = {}
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return result
	end

	for _, v2 in v do
		if AdminPermissions.hasPermission(localPlayer.UserId, v2.Permission) then
			table.insert(result, v2)
		end
	end

	return result
end

local AdminMenu = {
	Open = function()
		CUI.GetWindow("Admin Menu V2", 400, function(window)
			local v2 = {
				Window = window
			}
			window:SetTitle("Admin Menu V2")
			window.Components:AddTab(function(object2)
				local accessibleTabs = GetAccessibleTabs()
				local displayNames = {}

				for _, v4 in accessibleTabs do
					table.insert(displayNames, v4.DisplayName)
				end

				object2:SetTabs(displayNames)

				for _, v4 in accessibleTabs do
					v4.Setup(object2:GetComponentCtn(v4.DisplayName), v2)
				end
			end)
		end):SetVisible(true)
	end,
	RegisterTab = function(p)
		assert(
			AdminPermissions.registerPermission(p.Permission),
			(`Invalid permission for Admin Menu tab {p.DisplayName}`)
		)
		table.insert(v, p)
		table.sort(v, function(a, b)
			if a.Order == b.Order then
				return a.DisplayName < b.DisplayName
			end

			return a.Order < b.Order
		end)
	end
}

for _, v2 in script.Tabs:QueryDescendants(">ModuleScript") do
	local v3, v4 = xpcall(require, function(p)
		return debug.traceback(tostring(p), 2)
	end, v2)

	if v3 then
		if type(v4) == "table" then
			AdminMenu.RegisterTab(v4)
		else
			warn((`[AdminMenu] Tab "{v2:GetFullName()}" must return a TabDefinition`))
		end
	else
		warn((`[AdminMenu] Failed to load tab "{v2:GetFullName()}":\n{v4}`))
	end
end

return AdminMenu