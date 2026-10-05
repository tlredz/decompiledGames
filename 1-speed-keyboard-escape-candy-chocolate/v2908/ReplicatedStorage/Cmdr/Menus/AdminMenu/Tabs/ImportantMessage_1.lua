local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local KnownUsers = require(script.Parent.Parent.KnownUsers)
require(script.Parent.Parent.Types)
local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_SendImportantMessage",
	"cui.admin.importantMessage.send",
	true,
	function(p, p2)
		if type(p2) ~= "table" then
			return {
				Ok = false,
				Message = "Invalid important message request"
			}
		end

		local targetUserId = p2.TargetUserId
		local message = p2.Message

		if type(targetUserId) ~= "number" or targetUserId <= 0 or targetUserId % 1 ~= 0 then
			return {
				Ok = false,
				Message = "Enter a valid target UserId"
			}
		end

		if type(message) ~= "string" or string.match(message, "%S") == nil then
			return {
				Ok = false,
				Message = "Important message cannot be empty"
			}
		end

		if #message > 1000 then
			return {
				Ok = false,
				Message = `Important messages are limited to {1000} characters`
			}
		end

		local dataStore = DataStoreService:GetDataStore("MessageToPlayer")
		local success, result = pcall(dataStore.SetAsync, dataStore, tostring(targetUserId), message)

		if not success then
			return {
				Ok = false,
				Message = `Could not store the message: {tostring(result)}`
			}
		end

		local success2, result2 = pcall(MessagingService.PublishAsync, MessagingService, "MessageToPlayerTopic", {
			userId = targetUserId,
			message = message
		})
		local WebhookLogger = require(ServerScriptService.WebhookLogger)
		WebhookLogger:LogImportantMessage(p, targetUserId, message)

		if success2 then
			return {
				Ok = true,
				Message = `Important message sent to UserId {targetUserId}`
			}
		end

		return {
			Ok = true,
			Message = `Message stored for UserId {targetUserId}; live delivery failed: {tostring(result2)}`
		}
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	"AdminMenu_GetImportantReplies",
	"cui.admin.importantMessage.replies",
	false,
	function()
		local dataStore = DataStoreService:GetDataStore("MessageToPlayer")
		local success, async = pcall(dataStore.GetAsync, dataStore, "Reply")

		if not success then
			return {
				Ok = false,
				Message = `Could not load replies: {tostring(async)}`,
				Replies = {}
			}
		end

		local replies = {}

		if type(async) == "table" then
			for _, v2 in async do
				if type(v2) ~= "table" then
					continue
				end

				local timestamp = nil

				if type(v2.Timestamp) == "string" and v2.Timestamp ~= "" then
					timestamp = v2.Timestamp
				elseif type(v2.Timestamp) == "number" and v2.Timestamp == v2.Timestamp and v2.Timestamp > 0 and v2.Timestamp < 1e999 then
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", (math.floor(v2.Timestamp)))
				end

				local v3

				if timestamp then
					v3 = string.match(timestamp, "^(%d%d%d%d%-%d%d%-%d%d)T(%d%d):(%d%d):%d%dZ$")
				end

				table.insert(replies, {
					Sender = type(v2.Sender) ~= "string" and "Unknown" or v2.Sender,
					UserId = type(v2.UserId) ~= "number" and 0 or v2.UserId,
					Message = type(v2.Message) ~= "string" and "" or v2.Message,
					Time = timestamp or type(v2.Time) ~= "string" and "" or v2.Time,
					Timestamp = timestamp
				})
			end
		end

		return {
			Ok = true,
			Message = `{#replies} player {#replies == 1 and "reply" or "replies"}`,
			Replies = replies
		}
	end
)
local clientEvent3 = AdminRemote.RegisterClientEvent(
	"AdminMenu_ClearImportantReplies",
	"cui.admin.importantMessage.replies.clear",
	true,
	function()
		local dataStore = DataStoreService:GetDataStore("MessageToPlayer")
		local success, result = pcall(dataStore.RemoveAsync, dataStore, "Reply")

		if success then
			return {
				Ok = true,
				Message = "Important-message replies cleared"
			}
		end

		return {
			Ok = false,
			Message = `Could not clear replies: {tostring(result)}`
		}
	end
)
return {
	DisplayName = "Important Message",
	Permission = "cui.admin.importantMessage",
	Order = 5,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = ""
		local message2 = ""
		local flag = false
		local v3 = false
		local v4 = ""
		local v5 = nil
		local v6 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Notify(message: string, ok: boolean)
			local v8

			if ok then
				v8 = Color3.fromRGB(100, 255, 100)
			else
				v8 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v8, 4)
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Important Message")
		end)
		object:AddSplit(function(p)
			local v7 = { "Known user..." }

			for k in KnownUsers do
				table.insert(v7, k)
			end

			table.sort(v7, function(a, b)
				return a == "Known user..." or b ~= "Known user..." and a < b
			end)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetTextVisible(false):SetChoiceList(v7):SetSelected("Known user..."):SetOnChanged(function(p2)
					local knownUser = KnownUsers[p2]

					if not knownUser then
						return
					end

					v = tostring(knownUser)
					v6:SetValue(v)
				end)
			end)
			v6 = p.RightComponents:AddField(function(object2)
				object2:SetTextVisible(false):SetPlaceholder("Target UserId..."):SetValue(""):SetOnChangedRaw(function(p2)
					v = p2
				end)
			end)
		end)
		object:AddRichtextEditor(function(object2)
			object2:SetText("Content"):SetValue(""):SetOnChanged(function(p)
				message2 = p
			end)
		end)
		local v7 = nil
		local v8 = nil

		local function RenderReplies(p)
			for _, v9 in v7.Components:GetAll() do
				v9:Destroy()
			end

			local clone = table.clone(p.Replies)
			table.sort(clone, function(a, b)
				if a.Timestamp == b.Timestamp then
					return a.Time > b.Time
				end

				return a.Timestamp ~= nil and (b.Timestamp == nil or a.Timestamp > b.Timestamp)
			end)
			local count = 0

			for _, v9 in clone do
				local v10 = string.lower((`{v9.Sender} {v9.UserId} {v9.Message} {v9.Time}`))

				if not (v4 == "" or string.find(v10, v4, 1, true)) then
					continue
				end

				count += 1
				local v11 = v9
				v7.Components:AddExpandable(function(object2)
					object2:SetText((`{v11.Sender}_{v11.UserId}{v11.Time == "" and "" or `  [{v11.Time}]`}`))
					local v12

					if count % 2 == 0 then
						v12 = Color3.fromRGB(42, 42, 42)
					else
						v12 = Color3.fromRGB(36, 36, 36)
					end

					object2:SetBackgroundColor(v12)
					object2.Components:AddText(function(object3)
						object3:SetText(v11.Message):SetYSize(34)
					end)
				end)
			end

			if count == 0 then
				v7.Components:AddText(function(object2)
					object2:SetText(#p.Replies == 0 and "No replies are waiting." or "No replies match the search."):SetTextColor(Color3.fromRGB(
						150,
						150,
						150
					)):SetYSize(22)
				end)
			end

			v8:SetEnabled(true)
			v8:SetButtonColor(Color3.fromRGB(190, 45, 45))
		end

		local function RefreshReplies()
			if v3 or not clientEvent2 then
				return
			end

			v3 = true
			clientEvent2:Fire({}):andThen(function(p)
				v3 = false

				if not p then
					NotificationSystem:ShowGeneralNotification(
						"Important-message replies request was rejected",
						Color3.fromRGB(255, 100, 100),
						4
					)
				elseif p.Ok then
					v5 = p
					RenderReplies(p)
				else
					NotificationSystem:ShowGeneralNotification(p.Message, Color3.fromRGB(255, 100, 100), 4)
				end
			end):catch(function(p)
				v3 = false
				NotificationSystem:ShowGeneralNotification(
					`Could not load important-message replies: {tostring(p)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Send important message"):SetYSize(22):SetEnabledPermission("cui.admin.importantMessage.send"):SetButtonCallback(function()
					if flag then
						return
					end

					local targetUserId = tonumber(v)

					if not targetUserId or targetUserId <= 0 or targetUserId % 1 ~= 0 then
						NotificationSystem:ShowGeneralNotification(
							"Enter a valid target UserId",
							Color3.fromRGB(255, 100, 100),
							4
						)
						return
					end

					if string.match(message2, "%S") == nil then
						NotificationSystem:ShowGeneralNotification(
							"Important message cannot be empty",
							Color3.fromRGB(255, 100, 100),
							4
						)
						return
					end

					if not clientEvent then
						NotificationSystem:ShowGeneralNotification(
							"Important message API is unavailable",
							Color3.fromRGB(255, 100, 100),
							4
						)
						return
					end

					flag = true
					clientEvent:Fire({
						TargetUserId = targetUserId,
						Message = message2
					}):andThen(function(p2)
						flag = false

						if not p2 then
							NotificationSystem:ShowGeneralNotification(
								"Important message request was rejected",
								Color3.fromRGB(255, 100, 100),
								4
							)
							return
						end

						Notify(p2.Message, p2.Ok) -- equivalent call inferred; original call site unknown
					end):catch(function(p2)
						flag = false
						NotificationSystem:ShowGeneralNotification(
							`Important message failed: {tostring(p2)}`,
							Color3.fromRGB(255, 100, 100),
							4
						)
					end)
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Check replies"):SetYSize(22):SetEnabledPermission("cui.admin.importantMessage.replies"):SetButtonCallback(function()
					RefreshReplies()
				end)
			end)
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search replies..."):SetValue(""):SetOnChangedRaw(function(value)
				v4 = string.lower(value)

				if v5 then
					RenderReplies(v5)
				end
			end)
		end)
		v7 = object:AddList(function(object2)
			object2:SetSizeY(132)
			object2.Components:AddText(function(object3)
				object3:SetText("Use Check replies to refresh."):SetTextColor(Color3.fromRGB(150, 150, 150)):SetYSize(22)
			end)
		end)
		v8 = object:AddButton(function(object2)
			object2:SetButtonText("Clear all replies"):SetYSize(22):SetEnabledPermission("cui.admin.importantMessage.replies.clear")
			object2:DoNeedConfirmation(true):SetButtonColor(Color3.fromRGB(190, 45, 45)):SetButtonCallback(function()
				if not clientEvent3 then
					return
				end

				clientEvent3:Fire({}):andThen(function(p)
					if not p then
						return
					end

					Notify(p.Message, p.Ok) -- equivalent call inferred; original call site unknown

					if p.Ok then
						RefreshReplies()
					end
				end):catch(function(p)
					NotificationSystem:ShowGeneralNotification(
						`Could not clear important-message replies: {tostring(p)}`,
						Color3.fromRGB(255, 100, 100),
						4
					)
				end)
			end)
		end)
	end
}