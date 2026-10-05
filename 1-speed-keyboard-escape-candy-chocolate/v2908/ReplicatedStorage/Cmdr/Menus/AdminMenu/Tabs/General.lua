local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local DevMenu = require(ReplicatedStorage.Cmdr.Menus.DevMenu)
local KnownUsers = require(ReplicatedStorage.Cmdr.Menus.AdminMenu.KnownUsers)
local LiveOpsMenu = require(ReplicatedStorage.Cmdr.Menus.LiveOpsMenu)
local PermissionsMenu = require(ReplicatedStorage.Cmdr.Menus.PermissionsMenu)
require(ReplicatedStorage.Cmdr.Menus.AdminMenu.Types)
local AdminMessaging = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminMessaging)
local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_SendAnnouncement",
	"cui.admin.general.announcement",
	true,
	function(instance, data)
		if type(data) ~= "table" then
			return {
				Ok = false,
				Message = "Invalid announcement request"
			}
		end

		local v = type(data.Scope) ~= "string" and "" or string.lower(data.Scope)

		if v ~= "player" and v ~= "server" and v ~= "global" then
			return {
				Ok = false,
				Message = "Invalid announcement scope"
			}
		end

		if type(data.Text) ~= "string" or string.match(data.Text, "%S") == nil then
			return {
				Ok = false,
				Message = "Announcement message cannot be empty"
			}
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local adminAnnounce = remotes and remotes:FindFirstChild("AdminAnnounce")

		if not (adminAnnounce and adminAnnounce:IsA("RemoteEvent")) then
			return {
				Ok = false,
				Message = "Announcement API is unavailable"
			}
		end

		local AdminConfig = require(ServerScriptService.AdminConfig)

		local function GetRoleByUserId(userId: number)
			local priority = -1e999
			local v2 = nil

			for k, v3 in AdminConfig.ROLES do
				for _, userId2 in v3.UserIds do
					if not (userId2 == userId and priority < v3.Priority) then
						continue
					end

					priority = v3.Priority
					v2 = k
				end
			end

			return v2
		end

		local nameFromUserIdAsync = instance.Name
		local userId = instance.UserId

		if data.SpeakerUserId ~= nil then
			if type(data.SpeakerUserId) ~= "number" or data.SpeakerUserId <= 0 or data.SpeakerUserId % 1 ~= 0 then
				return {
					Ok = false,
					Message = "Custom speaker UserId is invalid"
				}
			end

			local success
			success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, data.SpeakerUserId)

			if not success then
				return {
					Ok = false,
					Message = "Could not resolve the custom speaker UserId"
				}
			end

			userId = data.SpeakerUserId
		end

		local adminRole = GetRoleByUserId(userId)
		local v3 = {
			text = data.Text,
			senderName = nameFromUserIdAsync,
			senderUserId = userId,
			isOwner = adminRole == "Creator" or adminRole == "HeadManager",
			adminRole = 0
		}

		if instance:GetAttribute("AdminChatTagEnabled") ~= true then
			adminRole = nil
		end

		v3.adminRole = adminRole

		if v == "player" then
			if type(data.TargetUserId) ~= "number" then
				return {
					Ok = false,
					Message = "Select a player to receive the announcement"
				}
			end

			local playerByUserId = Players:GetPlayerByUserId(data.TargetUserId)

			if not playerByUserId then
				return {
					Ok = false,
					Message = "The selected player left the server"
				}
			end

			adminAnnounce:FireClient(playerByUserId, v3)
			return {
				Ok = true,
				Message = `Announcement sent to {playerByUserId.Name}`
			}
		else
			if v == "server" then
				adminAnnounce:FireAllClients(v3)
				return {
					Ok = true,
					Message = "Announcement sent to this server"
				}
			end

			local v4, v5 = AdminMessaging.adminAnnouncementMessageHandler.send(v3):await()

			if v4 then
				return {
					Ok = true,
					Message = "Announcement sent globally"
				}
			end

			return {
				Ok = false,
				Message = `Global announcement failed: {tostring(v5)}`
			}
		end
	end
)
return {
	DisplayName = "General",
	Permission = "cui.admin.general",
	Order = 0,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local adminTagToggle = remotes and remotes:FindFirstChild("AdminTagToggle")

		if not (adminTagToggle and adminTagToggle:IsA("RemoteEvent")) then
			adminTagToggle = nil
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local localPlayer = Players.LocalPlayer
		local scope = "server"
		local targetUserId = nil
		local v3 = false
		local v4 = ""
		local text = ""
		local flag = false
		local userIds = {}
		local v6 = KnownUsers
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Notify(message: string, ok: boolean)
			local v12

			if ok then
				v12 = Color3.fromRGB(100, 255, 100)
			else
				v12 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v12, 4)
		end

		local function RefreshPlayers()
			table.clear(userIds)
			local values = {}

			for _, v12 in Players:GetPlayers() do
				local formatted = `{v12.Name}_{v12.UserId}`
				table.insert(values, formatted)
				userIds[formatted] = v12.UserId
			end

			table.sort(values)
			local value = v7:GetValue()
			local v12

			if userIds[value] then
				v12 = value
			else
				v12 = values[1] or "No players"
			end

			targetUserId = userIds[v12]
			v7:SetChoiceList(not (#values > 0) and { v12 } or values)

			if value ~= v12 then
				v7:SetSelected(v12)
			end
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Role Tag Visibility")
		end)
		object:AddSplit(function(p)
			v10 = p.LeftComponents:AddCheckbox(function(object2)
				local v12 = object2:SetText("Head tag"):SetValue(localPlayer:GetAttribute("AdminHeadTagEnabled") == true):SetEnabledPermission("cui.admin.general")
				local v13

				if adminTagToggle == nil then
					v13 = false
				else
					v13 = localPlayer:GetAttribute("AdminHeadTagEnabled") ~= nil
				end

				v12:SetEnabled(v13):SetOnChanged(function()
					if adminTagToggle then
						adminTagToggle:FireServer("Head")
					end
				end)
			end)
			v11 = p.RightComponents:AddCheckbox(function(object2)
				local v12 = object2:SetText("Chat tag"):SetValue(localPlayer:GetAttribute("AdminChatTagEnabled") == true):SetEnabledPermission("cui.admin.general")
				local v13

				if adminTagToggle == nil then
					v13 = false
				else
					v13 = localPlayer:GetAttribute("AdminChatTagEnabled") ~= nil
				end

				v12:SetEnabled(v13):SetOnChanged(function()
					if adminTagToggle then
						adminTagToggle:FireServer("Chat")
					end
				end)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Announcement")
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Scope"):SetChoiceList({ "Player", "Server", "Global" }):SetSelected("Server"):SetOnChanged(function(value)
					scope = string.lower(value)
					v7:SetEnabled(scope == "player")
				end)
			end)
			v7 = p.RightComponents:AddDropdown(function(object2)
				object2:SetText("Player"):SetChoiceList({ "No players" }):SetSelected("No players"):SetEnabled(false):SetOnChanged(function(p2)
					targetUserId = userIds[p2]
				end)
			end)
		end)
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(22)
			object2.LeftComponents:AddCheckbox(function(object3)
				object3:ShowCheckboxOnly():SetYSize(22):SetValue(false):SetOnChanged(function(p)
					v3 = p
					v8:SetEnabled(p)
					v9:SetEnabled(p)
				end)
			end)
			object2.RightComponents:AddSplit(function(object3)
				object3:SetLeftSizePercent(0.5)
				v8 = object3.LeftComponents:AddDropdown(function(object4)
					object4:SetTextVisible(false):SetChoiceList({ "Loading..." }):SetSelected("Loading..."):SetEnabled(false):SetOnChanged(function(p)
						local v12 = v6[p]

						if not v12 then
							return
						end

						v4 = tostring(v12)
						v9:SetValue(v4)
					end)
				end)
				v9 = object3.RightComponents:AddField(function(object4)
					object4:SetTextVisible(false):SetPlaceholder("UserId..."):SetValue(""):SetEnabled(false):SetOnChangedRaw(function(p)
						v4 = p
					end)
				end)
			end)
		end)
		object:AddRichtextEditor(function(object2)
			object2:SetText("Announcement message"):SetValue(""):SetOnChanged(function(p)
				text = p
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Send announcement"):SetYSize(22):SetEnabledPermission("cui.admin.general.announcement"):SetButtonCallback(function()
				if flag then
					return
				end

				if string.match(text, "%S") == nil then
					NotificationSystem:ShowGeneralNotification(
						"Announcement message cannot be empty",
						Color3.fromRGB(255, 100, 100),
						4
					)
				elseif scope == "player" and targetUserId == nil then
					NotificationSystem:ShowGeneralNotification(
						"Select a player to receive the announcement",
						Color3.fromRGB(255, 100, 100),
						4
					)
				else
					flag = true
					local speakerUserId

					if v3 then
						speakerUserId = tonumber(v4)
					end

					if v3 and (not speakerUserId or speakerUserId <= 0 or speakerUserId % 1 ~= 0) then
						NotificationSystem:ShowGeneralNotification(
							"Custom speaker UserId is invalid",
							Color3.fromRGB(255, 100, 100),
							4
						)
						flag = false
					else
						if clientEvent then
							clientEvent:Fire({
								Scope = scope,
								Text = text,
								TargetUserId = targetUserId,
								SpeakerUserId = speakerUserId
							}):andThen(function(p)
								flag = false

								if p then
									Notify(p.Message, p.Ok) -- equivalent call inferred; original call site unknown
								else
									NotificationSystem:ShowGeneralNotification(
										"Announcement request was rejected",
										Color3.fromRGB(255, 100, 100),
										4
									)
								end
							end):catch(function(p)
								flag = false
								NotificationSystem:ShowGeneralNotification(
									`Announcement failed: {tostring(p)}`,
									Color3.fromRGB(255, 100, 100),
									4
								)
							end)
							return
						end

						NotificationSystem:ShowGeneralNotification(
							"Announcement API is unavailable",
							Color3.fromRGB(255, 100, 100),
							4
						)
						flag = false
					end
				end
			end)
		end)
		local playerAddedConnection = Players.PlayerAdded:Connect(RefreshPlayers)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function()
			task.defer(RefreshPlayers)
		end)
		local adminHeadTagEnabledChangedConnection = localPlayer:GetAttributeChangedSignal("AdminHeadTagEnabled"):Connect(function()
			v10:SetValue(localPlayer:GetAttribute("AdminHeadTagEnabled") == true):SetEnabled(adminTagToggle ~= nil)
		end)
		local adminChatTagEnabledChangedConnection = localPlayer:GetAttributeChangedSignal("AdminChatTagEnabled"):Connect(function()
			v11:SetValue(localPlayer:GetAttribute("AdminChatTagEnabled") == true):SetEnabled(adminTagToggle ~= nil)
		end)
		v7:GetUI().Destroying:Connect(function()
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
			adminHeadTagEnabledChangedConnection:Disconnect()
			adminChatTagEnabledChangedConnection:Disconnect()
		end)
		RefreshPlayers()
		local v12 = {}

		for k in v6 do
			table.insert(v12, k)
		end

		table.sort(v12)
		local v13 = v12[1]
		v8:SetChoiceList(v12):SetSelected(v13)
		v4 = tostring(v6[v13])
		v9:SetValue(v4)
		object:AddTitle(function(object2)
			object2:SetTitle("Advanced Menus")
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("LiveOps"):SetYSize(22):SetEnabledPermission("cui.liveops"):SetButtonCallback(function()
					LiveOpsMenu.Toggle()
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Dev Menu"):SetYSize(22):SetEnabledPermission("cui.dev"):SetButtonCallback(function()
					DevMenu.Toggle()
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Permissions"):SetYSize(22):SetEnabledPermission("cui.permissions"):SetButtonCallback(function()
				PermissionsMenu.Open()
			end)
		end)
	end
}