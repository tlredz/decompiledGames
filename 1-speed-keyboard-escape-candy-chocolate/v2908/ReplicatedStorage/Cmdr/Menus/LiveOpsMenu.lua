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

-- equivalent calls inferred from this helper; original call sites unknown
local function GetWindow()
	return CUI.GetWindow("LiveOps Menu", 400, function(window)
		local v2 = {
			Window = window
		}
		window:SetTitle("LiveOps")
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

local LiveOpsMenu = {
	Open = function()
		local window = GetWindow() -- equivalent call inferred; original call site unknown
		window:SetMinimize(false)
		window:SetVisible(true)
	end,
	Toggle = function()
		local window = GetWindow() -- equivalent call inferred; original call site unknown
		local v3 = not window:IsVisible()

		if v3 then
			window:SetMinimize(false)
		end

		window:SetVisible(v3)
	end,
	RegisterTab = function(p)
		assert(
			AdminPermissions.registerPermission(p.Permission),
			(`Invalid permission for LiveOps Menu tab {p.DisplayName}`)
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
		LiveOpsMenu.RegisterTab(v4)
	elseif v3 then
		warn((`[LiveOpsMenu] Tab "{v2:GetFullName()}" must return a TabDefinition`))
	else
		warn((`[LiveOpsMenu] Failed to load tab "{v2:GetFullName()}":\n{v4}`))
	end
end

return LiveOpsMenu