local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local adminSpeakAs = require(ReplicatedStorage._FRAMEWORK.Features.Admins.adminSpeakAs)
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage._FRAMEWORK.Features.Admins.adminSpeakAs.Types)
require(ReplicatedStorage.CUI)
require(script.Parent.Parent.Types)
local v = {
	Fab = "fab",
	["The Masked"] = "masked",
	Headless = "headless"
}
local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_SpeakAs",
	adminSpeakAs.getPermission(),
	true,
	adminSpeakAs.sendAnnouncement
)
return {
	DisplayName = "Speak as",
	Permission = adminSpeakAs.getPermission(),
	Order = 1000,
	Setup = function(object)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v2 = clientEvent
		local maxLength = adminSpeakAs.getMaxLength()
		local userIds = {}
		local speaker = "fab"
		local scope = "server"
		local targetUserId = nil
		local text = ""
		local flag = false
		local v7 = false
		local v8 = nil
		local v9 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function notify(message: string, ok: boolean)
			local v11

			if ok then
				v11 = Color3.fromRGB(100, 255, 100)
			else
				v11 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v11, 4)
		end

		local function checkAnnouncement()
			local v10 = utf8.len(text)

			if v10 == nil or maxLength < v10 then
				return false, string.format("Use valid UTF-8 text, up to %d characters.", maxLength)
			end

			if string.match(text, "%S") == nil then
				return false, "Announcement message cannot be empty."
			end

			if scope == "player" and targetUserId == nil then
				return false, "Select a player to receive the announcement."
			end

			return true, ""
		end

		local function refreshPlayers(p)
			table.clear(userIds)
			local v10 = {}

			for _, v11 in Players:GetPlayers() do
				if v11 == p then
					continue
				end

				local formatted = `{v11.Name}_{v11.UserId}`
				table.insert(v10, formatted)
				userIds[formatted] = v11.UserId
			end

			table.sort(v10)
			table.insert(v10, 1, "Select a player...")
			local value = v8:GetValue()
			local v11 = not userIds[value] and "Select a player..." or value
			targetUserId = userIds[v11]
			v8:SetChoiceList(v10):SetSelected(v11)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function finishSend(p)
			if not v7 then
				flag = false
				v9:SetButtonText("Send announcement"):SetEnabled(true)
				notify(p.message, p.ok) -- equivalent call inferred; original call site unknown
			end
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Speak as")
		end)
		object:AddDropdown(function(object2)
			object2:SetText("Speaker"):SetChoiceList({ "Fab", "The Masked", "Headless" }):SetSelected("Fab"):SetOnChanged(function(p)
				speaker = v[p]
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Scope"):SetChoiceList({ "Player", "Server", "Global" }):SetSelected("Server"):SetOnChanged(function(value)
					scope = string.lower(value)
					v8:SetEnabled(scope == "player")
				end)
			end)
			v8 = p.RightComponents:AddDropdown(function(object2)
				object2:SetText("Player"):SetChoiceList({ "Select a player..." }):SetSelected("Select a player..."):SetEnabled(false):SetOnChanged(function(p2)
					targetUserId = userIds[p2]
				end)
			end)
		end)
		object:AddRichtextEditor(function(object2)
			object2:SetText((`Announcement message ({maxLength} characters max)`)):SetValue(""):SetOnChanged(function(p)
				text = p
			end)
		end)
		v9 = object:AddButton(function(object2)
			object2:SetButtonText("Send announcement"):SetYSize(22):SetEnabledPermission(adminSpeakAs.getPermission()):SetButtonCallback(function()
				if flag then
					return
				end

				local v10, v11 = checkAnnouncement()

				if not v10 then
					NotificationSystem:ShowGeneralNotification(v11, Color3.fromRGB(255, 100, 100), 4)
					return
				end

				flag = true
				v9:SetButtonText("Sending..."):SetEnabled(false)
				v2:Fire({
					speaker = speaker,
					scope = scope,
					text = text,
					targetUserId = targetUserId
				}):andThen(function(p)
					finishSend(p or {
						ok = false,
						message = "Could not send the announcement. Please try again."
					}) -- equivalent call inferred; original call site unknown
				end):catch(function()
					finishSend({
						ok = false,
						message = "Could not send the announcement. Please try again."
					}) -- equivalent call inferred; original call site unknown
				end)
			end)
		end)
		local playerAddedConnection = Players.PlayerAdded:Connect(function()
			refreshPlayers(nil)
		end)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(refreshPlayers)
		v8:GetUI().Destroying:Once(function()
			v7 = true
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
		end)
		refreshPlayers(nil)
	end
}