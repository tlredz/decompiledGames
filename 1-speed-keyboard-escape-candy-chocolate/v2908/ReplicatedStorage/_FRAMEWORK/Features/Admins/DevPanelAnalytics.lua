local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local GlobalStateManager = require(ReplicatedStorage._FRAMEWORK.Features.GlobalStateManager)
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
require(ReplicatedStorage.Utilities.Promise)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local DevPanelAnalytics = {}
local v = {}
local v2 = Signal.new()
local v3 = Signal.new()
local v4 = Signal.new()
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = 0
local count = 0
local count2 = 0
local onMessageSentConnection = nil
local onMessageReceivedConnection = nil
local fn
local clientEvent = AdminRemote.RegisterClientEvent(
	"DevMenu_Analytics_Listen",
	"cui.dev.analytics",
	false,
	function(p, p2)
		return fn(p, p2)
	end
)
local serverEvent = AdminRemote.RegisterServerEvent("DevMenu_Analytics_Push", "cui.dev.analytics", function(_, p)
	if v5[p.panel] then
		local v9

		if p.panel == "messaging" then
			v9 = v2
		else
			v9 = v3
		end

		v9:Fire(p)
	end
end)
local serverEvent2 = AdminRemote.RegisterServerEvent(
	"DevMenu_Analytics_MessagingLog",
	"cui.dev.analytics",
	function(_, p)
		if v5.messaging then
			v4:Fire(p)
		end
	end
)

-- equivalent calls inferred from this helper; original call sites unknown
local function isPanelKind(p)
	return p == "messaging" or p == "globalState"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClientSnapshotSignal(p: string)
	if p == "messaging" then
		return v2
	end

	return v3
end

local function readMessagingDiagnostics()
	local status = MessagingServiceManager.getStatus()
	local handlers = {}

	for _, v10 in MessagingServiceManager.getAllMessageHandlers() do
		table.insert(handlers, {
			topic = v10.topic,
			isSubscribed = v10.isSubscribed,
			subscriberCount = v10.getSubscriberCount()
		})
	end

	table.sort(handlers, function(a, b)
		return string.lower(a.topic) < string.lower(b.topic)
	end)
	return {
		duplicateFound = status.duplicateFound,
		messageSent = status.messageSent,
		messageReceived = status.messageReceived,
		failedSendAttempts = status.failedSendAttempts,
		failedSubscriptionsAttempts = status.failedSubscriptionsAttempts,
		messageSentLastMinute = status.messageSentThisMinuteBucket:getCount(),
		messageReceivedLastMinute = status.messageReceivedThisMinuteBucket:getCount(),
		handlers = handlers
	}
end

local function readSnapshot(panel: string)
	count += 1
	local success, result = pcall(function()
		if panel == "messaging" then
			return (readMessagingDiagnostics())
		end

		return GlobalStateManager.getDiagnostics()
	end)

	if not success then
		return {
			panel = panel,
			ok = false,
			errorMessage = tostring(result),
			timestamp = os.time(),
			sequence = count,
			messaging = nil,
			globalState = nil
		}
	end

	local v9 = {
		panel = panel,
		ok = true,
		errorMessage = "",
		timestamp = os.time(),
		sequence = count,
		messaging = 0,
		globalState = 0
	}
	local messaging

	if panel == "messaging" then
		messaging = result
	end

	v9.messaging = messaging

	if panel ~= "globalState" then
		result = nil
	end

	v9.globalState = result
	return v9
end

local function hasListeners()
	return next(v) ~= nil
end

local function hasMessagingListeners()
	local now = os.clock()

	for k, v9 in v do
		local messaging = v9.messaging

		if k.Parent == Players and messaging and now - messaging.lastSeen <= 18 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function serializePayload(p)
	local success, result = pcall(HttpService.JSONEncode, HttpService, p)

	if not success then
		result = tostring(p)
	end

	local v9 = #result

	if #result > 4000 then
		result = string.sub(result, 1, 4000) .. "... [truncated]"
	end

	return result, v9
end

local function pushMessagingLog(direction: string, topic: string, p3)
	local v9 = serverEvent2

	if not v9 then
		return
	end

	count2 += 1
	local payload, payloadBytes = serializePayload(p3) -- equivalent call inferred; original call site unknown
	local v12 = {
		id = count2,
		timestampMillis = DateTime.now().UnixTimestampMillis,
		direction = direction,
		topic = topic,
		payload = payload,
		payloadBytes = payloadBytes
	}
	local now = os.clock()

	for k, v13 in v do
		local messaging = v13.messaging

		if k.Parent == Players and messaging and now - messaging.lastSeen <= 18 then
			pcall(v9.Fire, v9, k, v12)
		end
	end
end

local function updateMessagingLogConnections()
	if hasMessagingListeners() then
		if not onMessageSentConnection then
			onMessageSentConnection = MessagingServiceManager.onMessageSent:Connect(function(topic, p2)
				pushMessagingLog("sent", topic, p2)
			end)
		end

		if not onMessageReceivedConnection then
			onMessageReceivedConnection = MessagingServiceManager.onMessageReceived:Connect(function(topic, p2)
				pushMessagingLog("received", topic, p2)
			end)
		end
	else
		if onMessageSentConnection then
			onMessageSentConnection:Disconnect()
			onMessageSentConnection = nil
		end

		if onMessageReceivedConnection then
			onMessageReceivedConnection:Disconnect()
			onMessageReceivedConnection = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeListener(p, p2: string, sessionId: string)
	local v9 = v[p]

	if not v9 then
		return
	end

	local v10 = v9[p2]

	if v10 and v10.sessionId == sessionId then
		v9[p2] = nil
	end

	if next(v9) == nil then
		v[p] = nil
	end

	if p2 == "messaging" then
		updateMessagingLogConnections()
	end
end

fn = function(p, data)
	if typeof(data) ~= "table" then
		return {
			ok = false,
			errorMessage = "Invalid analytics subscription request.",
			updateIntervalSeconds = 3,
			leaseSeconds = 18,
			snapshot = nil
		}
	end

	local panel = data.panel
	local listening = data.listening
	local requestSnapshot = data.requestSnapshot
	local sessionId = data.sessionId

	if not isPanelKind(panel) or typeof(listening) ~= "boolean" or typeof(requestSnapshot) ~= "boolean" or typeof(sessionId) ~= "string" or #sessionId < 1 or #sessionId > 64 then
		return {
			ok = false,
			errorMessage = "Invalid analytics subscription fields.",
			updateIntervalSeconds = 3,
			leaseSeconds = 18,
			snapshot = nil
		}
	end

	local panel2 = panel == "messaging" and "messaging" or "globalState"

	if not AdminPermissions.hasPermission(p.UserId, (`cui.dev.analytics.{panel2}`)) then
		return {
			ok = false,
			errorMessage = "You do not have permission to inspect this analytics panel.",
			updateIntervalSeconds = 3,
			leaseSeconds = 18,
			snapshot = nil
		}
	end

	if listening then
		local now = os.clock()
		local v10 = next(v) == nil
		local v11 = v[p]

		if not v11 then
			v11 = {}
			v[p] = v11
		end

		v11[panel2] = {
			sessionId = sessionId,
			lastSeen = now
		}

		if panel2 == "messaging" then
			updateMessagingLogConnections()
		end

		if v10 then
			v8 = os.clock() + 3
		end

		local snapshot = nil

		if requestSnapshot then
			local nows = v7[p]

			if not nows then
				nows = {}
				v7[p] = nows
			end

			if now - (nows[panel2] or -1e999) >= 1 then
				nows[panel2] = now
				snapshot = readSnapshot(panel2)
			end
		end

		return {
			ok = true,
			errorMessage = "",
			updateIntervalSeconds = 3,
			leaseSeconds = 18,
			snapshot = snapshot
		}
	else
		removeListener(p, panel2, sessionId) -- equivalent call inferred; original call site unknown
		return {
			ok = true,
			errorMessage = "",
			updateIntervalSeconds = 3,
			leaseSeconds = 18,
			snapshot = nil
		}
	end
end

local function fireClientError(panel: string, errorMessage: string)
	local clientSnapshotSignal = getClientSnapshotSignal(panel) -- equivalent call inferred; original call site unknown
	clientSnapshotSignal:Fire({
		panel = panel,
		ok = false,
		errorMessage = errorMessage,
		timestamp = os.time(),
		sequence = 0,
		messaging = nil,
		globalState = nil
	})
end

local function sendClientSubscription(panel: string, sessionId: string, requestSnapshot: boolean)
	local v9 = clientEvent

	if not v9 then
		fireClientError(panel, "Analytics staff remote is not initialized.")
		return
	end

	v6[panel] = os.clock()
	v9:Fire({
		panel = panel,
		listening = true,
		requestSnapshot = requestSnapshot,
		sessionId = sessionId
	}):andThen(function(data)
		if v5[panel] ~= sessionId then
			return
		end

		if not data then
			fireClientError(panel, "Analytics request was rejected.")
		elseif not data.ok then
			fireClientError(panel, data.errorMessage)
		elseif data.snapshot then
			local clientSnapshotSignal = getClientSnapshotSignal(panel) -- equivalent call inferred; original call site unknown
			clientSnapshotSignal:Fire(data.snapshot)
		end
	end):catch(function(p3)
		if v5[panel] == sessionId then
			fireClientError(panel, tostring(p3))
		end
	end)
end

local function updateServer()
	if next(v) == nil then
		return
	end

	local now = os.clock()
	local v9 = {}
	local v10 = {}

	for k, v11 in v do
		if k.Parent == Players then
			for k2, v12 in v11 do
				if now - v12.lastSeen > 18 then
					v11[k2] = nil
				elseif k2 == "messaging" then
					table.insert(v10, k)
				else
					table.insert(v9, k)
				end
			end

			if next(v11) == nil then
				v[k] = nil
			end
		else
			v[k] = nil
		end
	end

	updateMessagingLogConnections()

	if next(v) == nil or now < v8 then
		return
	end

	v8 = now + 3
	local v11 = serverEvent

	if not v11 then
		return
	end

	if #v10 > 0 then
		local v12 = readSnapshot("messaging")

		for _, v13 in v10 do
			v11:Fire(v13, v12)
		end
	end

	if #v9 > 0 then
		local v12 = readSnapshot("globalState")

		for _, v13 in v9 do
			v11:Fire(v13, v12)
		end
	end
end

local function updateClient()
	local now = os.clock()

	for k, v9 in v5 do
		if now - (v6[k] or 0) >= 8 then
			sendClientSubscription(k, v9, false)
		end
	end
end

function DevPanelAnalytics.connectToPanel(p: string, callback)
	assert(RunService:IsClient(), "DevPanelAnalytics.connectToPanel can only be called on the client.")
	local clientSnapshotSignal = getClientSnapshotSignal(p) -- equivalent call inferred; original call site unknown
	return clientSnapshotSignal:Connect(callback)
end

function DevPanelAnalytics.connectToMessagingLog(callback)
	assert(RunService:IsClient(), "DevPanelAnalytics.connectToMessagingLog can only be called on the client.")
	return v4:Connect(callback)
end

function DevPanelAnalytics.setPanelListening(panel: string, flag: boolean)
	assert(RunService:IsClient(), "DevPanelAnalytics.setPanelListening can only be called on the client.")
	local sessionId = v5[panel]

	if flag then
		if sessionId then
			return
		end

		local GUID = HttpService:GenerateGUID(false)
		v5[panel] = GUID
		sendClientSubscription(panel, GUID, true)
	else
		if not sessionId then
			return
		end

		v5[panel] = nil
		v6[panel] = nil
		local v10 = clientEvent

		if v10 then
			v10:Fire({
				panel = panel,
				listening = false,
				requestSnapshot = false,
				sessionId = sessionId
			}):catch(function() end)
		end
	end
end

function DevPanelAnalytics.refreshPanel(panel: string)
	assert(RunService:IsClient(), "DevPanelAnalytics.refreshPanel can only be called on the client.")
	local sessionId = v5[panel]

	if sessionId then
		sendClientSubscription(panel, sessionId, true)
	end
end

function DevPanelAnalytics.getUpdateIntervalSeconds()
	return 3
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -980,
	OnInit = function()
		if RunService:IsServer() then
			Players.PlayerRemoving:Connect(function(player)
				v[player] = nil
				v7[player] = nil
				updateMessagingLogConnections()
			end)
		end
	end,
	OnUpdate = function()
		if RunService:IsServer() then
			updateServer()
		else
			updateClient()
		end
	end
})
return DevPanelAnalytics