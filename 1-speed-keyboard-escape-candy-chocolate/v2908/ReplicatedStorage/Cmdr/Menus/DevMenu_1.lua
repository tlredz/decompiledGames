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
	return CUI.GetWindow("Dev Menu", 400, function(window)
		window:SetTitle("Dev Menu")
		window.Components:AddTab(function(object2)
			local accessibleTabs = GetAccessibleTabs()
			local displayNames = {}

			for _, v3 in accessibleTabs do
				table.insert(displayNames, v3.DisplayName)
			end

			object2:SetTabs(displayNames)
			local signalsByDisplayName = {}
			local v3 = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function isTabVisible(p: string)
				return window:IsVisible() and not window:IsMinimized() and object2:GetOpenTabName() == p
			end

			local function updateVisibility()
				for k, v4 in signalsByDisplayName do
					local v5 = window:IsVisible() and not window:IsMinimized() and object2:GetOpenTabName() == k

					if v3[k] == v5 then
						continue
					end

					v3[k] = v5
					v4:Fire(v5)
				end
			end

			for _, v4 in accessibleTabs do
				local signal = CUI.Signal.new()
				signalsByDisplayName[v4.DisplayName] = signal
				local displayName = v4.DisplayName
				local displayName2 = v4.DisplayName
				v3[displayName] = window:IsVisible() and not window:IsMinimized() and object2:GetOpenTabName() == displayName2
				local v5 = v4
				v4.Setup(object2:GetComponentCtn(v4.DisplayName), {
					Window = window,
					isVisible = function()
						return isTabVisible(v5.DisplayName)
					end,
					visibilityChanged = signal
				})
			end

			local v4 = window
			object2.OnTabOpened:Connect(updateVisibility)
			v4.UI:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
			v4.UI.Content:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
			v4.UI.Destroying:Connect(function()
				for _, v5 in signalsByDisplayName do
					v5:Destroy()
				end

				table.clear(signalsByDisplayName)
				table.clear(v3)
			end)
		end)
	end)
end

local DevMenu = {
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
			(`Invalid permission for Dev Menu tab {p.DisplayName}`)
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
		DevMenu.RegisterTab(v4)
	elseif v3 then
		warn((`[DevMenu] Tab "{v2:GetFullName()}" must return a TabDefinition`))
	else
		warn((`[DevMenu] Failed to load tab "{v2:GetFullName()}":\n{v4}`))
	end
end

return DevMenu