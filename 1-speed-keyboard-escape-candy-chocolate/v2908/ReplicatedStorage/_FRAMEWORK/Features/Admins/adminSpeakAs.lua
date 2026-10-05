local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
local FabAdminAnnouncement = require(ReplicatedStorage._FRAMEWORK.Features.Specials.FabAdminAnnouncement)
local WCFinaleAdminAbuseConfig = require(ReplicatedStorage.AdminAbuse.Modules.WCFinaleAdminAbuse.WCFinaleAdminAbuseConfig)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
require(script.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local strictInterface = t.strictInterface({
	speaker = t.literal("fab", "masked", "headless"),
	scope = t.literal("global", "server", "player"),
	text = t.string,
	targetUserId = t.optional(t.integer)
})
local AdminSpeakAs = {}
local v = nil
local v2 = {}
AdminSpeakAs.remotes = remo.createRemotes({
	showSpeakAs = remo.remote()
})

local function checkRequest(p, data)
	if not RunService:IsServer() then
		return false, nil, "Speak as announcements can only be sent by the server."
	end

	if not strictInterface(data) then
		return false, nil, "Invalid announcement request."
	end

	if v2[p] and os.clock() < v2[p] then
		return false, nil, "Please wait before sending another announcement."
	end

	if #data.text > 800 then
		return false, nil, "Use valid UTF-8 text, up to 200 characters."
	end

	local v3 = utf8.len(data.text)

	if v3 == nil or v3 > 200 then
		return false, nil, "Use valid UTF-8 text, up to 200 characters."
	end

	if string.match(data.text, "%S") == nil then
		return false, nil, "Announcement message cannot be empty."
	end

	if data.scope ~= "player" then
		return true, nil, ""
	end

	local playerByUserId

	if data.targetUserId then
		playerByUserId = Players:GetPlayerByUserId(data.targetUserId)
	end

	return playerByUserId ~= nil, playerByUserId, "Select a player who is still in this server."
end

local function deliverRequest(data, p)
	local v3 = {
		speaker = data.speaker,
		text = data.text
	}

	if data.scope == "global" then
		local messageValid, message = v.isMessageValid(v3)

		if not messageValid then
			return {
				ok = false,
				message = message
			}
		end

		local ok = v.send(v3):await()
		return {
			ok = ok,
			message = ok and "Announcement sent globally." or "Could not send the announcement. Please try again."
		}
	elseif data.scope == "player" then
		AdminSpeakAs.remotes.showSpeakAs:fire(p, v3)
		return {
			ok = true,
			message = `Announcement sent to {p.Name}.`
		}
	else
		AdminSpeakAs.remotes.showSpeakAs:fireAll(v3)
		return {
			ok = true,
			message = "Announcement sent to this server."
		}
	end
end

local function showAnnouncement(p)
	if p.speaker == "fab" then
		FabAdminAnnouncement.announce({
			text = p.text
		})
	elseif p.speaker == "headless" then
		for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
			if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
				bindableEvent:Fire({
					text = p.text,
					senderName = "Headless Horseman",
					senderUserId = WCFinaleAdminAbuseConfig.DefaultSenderId,
					isOwner = false,
					icon = "rbxassetid://89764802501872"
				})
			end
		end
	else
		for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
			if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
				bindableEvent:Fire({
					text = p.text,
					senderName = WCFinaleAdminAbuseConfig.MessageSenderName,
					senderUserId = WCFinaleAdminAbuseConfig.DefaultSenderId,
					isOwner = false,
					icon = WCFinaleAdminAbuseConfig.bossIcon
				})
			end
		end
	end
end

function AdminSpeakAs.sendAnnouncement(p, p2)
	local v3, v4, message = checkRequest(p, p2)

	if not v3 then
		return {
			ok = false,
			message = message
		}
	end

	v2[p] = os.clock() + 1
	local success, result = pcall(deliverRequest, p2, v4)

	if success then
		return result
	end

	logger.warn(logger, string.format("Speak as announcement failed: %s", (tostring(result))))
	return {
		ok = false,
		message = "Could not send the announcement. Please try again."
	}
end

function AdminSpeakAs.getPermission()
	return "cui.admin.general.announcement"
end

function AdminSpeakAs.getMaxLength()
	return 200
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not RunService:IsServer() then
			AdminSpeakAs.remotes.showSpeakAs:connect(showAnnouncement)
			return
		end

		v = MessagingServiceManager.createMessageHandler("AdminSpeakAs")
		v.connect(function(p)
			AdminSpeakAs.remotes.showSpeakAs:fireAll(p)
		end)
		Players.PlayerRemoving:Connect(function(player)
			v2[player] = nil
		end)
	end
})
return AdminSpeakAs