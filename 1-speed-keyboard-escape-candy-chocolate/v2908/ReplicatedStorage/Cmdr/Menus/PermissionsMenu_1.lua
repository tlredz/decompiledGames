local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local CUI = require(ReplicatedStorage.CUI)
require(script.Types)
local v = {}

local function GetAccessibleTabs()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return {}
	end

	local result = {}

	for _, v2 in v do
		if not ((not v2.IsAvailable or v2.IsAvailable()) and AdminPermissions.hasPermission(
			localPlayer.UserId,
			v2.Permission
		)) then
			continue
		end

		table.insert(result, v2)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetWindow()
	return CUI.GetWindow("Permissions Menu", 460, function(window)
		local v2 = {
			Window = window
		}
		window:SetTitle("Permission Debugger")
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
	end)
end

local PermissionsMenu = {
	Open = function()
		local localPlayer = Players.LocalPlayer

		if not (localPlayer and AdminPermissions.hasPermission(localPlayer.UserId, "cui.permissions")) then
			return false
		end

		local window = GetWindow() -- equivalent call inferred; original call site unknown
		window:SetMinimize(false)
		window:SetVisible(true)
		return true
	end,
	Toggle = function()
		local localPlayer = Players.LocalPlayer

		if not (localPlayer and AdminPermissions.hasPermission(localPlayer.UserId, "cui.permissions")) then
			return false
		end

		local window = GetWindow() -- equivalent call inferred; original call site unknown
		local v3 = not window:IsVisible()

		if v3 then
			window:SetMinimize(false)
		end

		window:SetVisible(v3)
		return true
	end,
	RegisterTab = function(p)
		assert(
			AdminPermissions.registerPermission(p.Permission),
			(`Invalid permission for Permissions Menu tab {p.DisplayName}`)
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

	if v3 and type(v4) == "table" then
		PermissionsMenu.RegisterTab(v4)
	elseif v3 then
		warn((`[PermissionsMenu] Tab "{v2:GetFullName()}" must return a TabDefinition`))
	else
		warn((`[PermissionsMenu] Failed to load tab "{v2:GetFullName()}":\n{v4}`))
	end
end

return PermissionsMenu