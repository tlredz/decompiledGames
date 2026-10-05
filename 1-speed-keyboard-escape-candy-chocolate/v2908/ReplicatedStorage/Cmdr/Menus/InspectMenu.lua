local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(script.Types)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local CUI = require(ReplicatedStorage.CUI)
local ProfileAccess = require(script.ProfileAccess)
local Signal = require(ReplicatedStorage.Utilities.Signal)
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

local clientEvent = AdminRemote.RegisterClientEvent("Inspect_GetPresence", "cui.inspect", false, function(_, p)
	local v2 = ProfileAccess.Read(p.UserId)
	local v3 = {
		UserId = p.UserId,
		Presence = ProfileAccess.GetPresence(v2),
		JobId = 0,
		ProfileReady = 0
	}
	local jobId

	if v2.IsOnlineElsewhere or v2.IsLocal then
		jobId = v2.ServerJobId
	end

	v3.JobId = jobId
	v3.ProfileReady = v2.Ok
	return v3
end)
local InspectMenu = {
	Open = function(userId: number)
		local localPlayer = Players.LocalPlayer
		CUI.GetWindow(`Inspect_{userId}`, 400, function(window)
			local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
			local v2 = false
			local v3 = false
			local flag = true
			local v4 = nil
			local presenceChanged = Signal.new()
			local profileChanged = Signal.new()
			local v7 = {
				UserId = userId,
				Window = window,
				PresenceChanged = presenceChanged,
				ProfileChanged = profileChanged,
				NotifyProfileError = function(p2: string)
					if v2 or p2 == "" then
						return
					end

					v2 = true
					NotificationSystem:ShowGeneralNotification(p2, Color3.fromRGB(255, 100, 100), 4)
				end
			}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function ApplyPresence(data)
				if data.UserId ~= userId then
					return
				end

				local formatted = `{data.Presence}:{data.JobId or ""}:{data.ProfileReady}`

				if v4 ~= nil and formatted ~= v4 then
					presenceChanged:Fire()
				end

				v4 = formatted
			end

			local function CheckPresence()
				if v3 or not clientEvent then
					return
				end

				v3 = true
				clientEvent:Fire({
					UserId = userId
				}):andThen(function(data)
					v3 = false

					if not flag or not window:IsVisible() or window:IsMinimized() then
						return
					end

					ApplyPresence(data) -- equivalent call inferred; original call site unknown
				end):catch(function()
					v3 = false
				end)
			end

			local _maid = window._maid
			_maid:GiveTask(presenceChanged)
			_maid:GiveTask(profileChanged)
			_maid:GiveTask(function()
				flag = false
			end)
			task.spawn(function()
				while flag do
					if localPlayer:GetAttribute("HasCmdr") == true then
						if window:IsVisible() and not window:IsMinimized() then
							CheckPresence()
						end

						task.wait(10)
					else
						flag = false
						window:SetVisible(false)
						break
					end
				end
			end)
			task.defer(function()
				if window:IsVisible() and not window:IsMinimized() then
					CheckPresence()
				end
			end)
			window:SetTitle((`Player_{userId}`))
			task.spawn(function()
				window:SetTitle((`{Players:GetNameFromUserIdAsync(userId)}_{userId}`))
			end)
			window.Components:AddTab(function(object2)
				local accessibleTabs = GetAccessibleTabs()
				local displayNames = {}
				local v9 = {}
				local v10 = {}

				for _, v11 in accessibleTabs do
					table.insert(displayNames, v11.DisplayName)
					v9[v11.DisplayName] = v11
				end

				object2.OnTabOpened:Connect(function(p2)
					local v11 = v9[p2]

					if v11 and not v10[p2] then
						v10[p2] = true
						v11.Setup(object2:GetComponentCtn(p2), v7)
					end
				end)
				object2:SetTabs(displayNames)
			end)
		end):SetVisible(true)
	end,
	RegisterTab = function(p)
		assert(
			AdminPermissions.registerPermission(p.Permission),
			(`Invalid permission for Inspect Menu tab {p.DisplayName}`)
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
			InspectMenu.RegisterTab(v4)
		else
			warn((`[InspectMenu] Tab "{v2:GetFullName()}" must return a TabDefinition`))
		end
	else
		warn((`[InspectMenu] Failed to load tab "{v2:GetFullName()}":\n{v4}`))
	end
end

return InspectMenu