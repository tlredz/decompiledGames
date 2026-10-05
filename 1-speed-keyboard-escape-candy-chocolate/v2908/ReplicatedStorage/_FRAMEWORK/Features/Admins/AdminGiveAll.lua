local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
require(ReplicatedStorage.Utilities.Promise)
local t = require(ReplicatedStorage.Packages.t)
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local intersection = t.intersection(t.integer, t.numberConstrained(0, Items.MAX_TIER))
local intersection2 = t.intersection(t.integer, t.numberConstrained(1, 100))
local intersection3 = t.intersection(t.integer, t.numberConstrained(1, 100))
local literal = t.literal("direct", "fakeGift")
local strictInterface = t.strictInterface({
	itemKey = t.string,
	tier = intersection,
	amount = intersection2,
	deliveryMode = literal,
	randomRecipients = t.boolean,
	minimumPlayerCount = intersection3,
	recipientCount = intersection3,
	giftSenderUserId = t.intersection(t.integer, t.numberMin(1))
})
local strictInterface2 = t.strictInterface({
	version = t.literal(1),
	itemKey = t.string,
	tier = intersection,
	amount = intersection2,
	deliveryMode = literal,
	randomRecipients = t.boolean,
	minimumPlayerCount = intersection3,
	recipientCount = intersection3,
	senderUserId = t.intersection(t.integer, t.numberMin(1)),
	senderName = t.string,
	sentAt = t.integer
})
local v = {}

for k, v2 in Items.ITEMS do
	table.insert(v, {
		key = k,
		displayName = tostring(v2.name or k),
		rarity = tostring(v2.rarity or "Unknown")
	})
end

table.sort(v, function(a, b)
	local displayName = string.lower(a.displayName)
	local displayName2 = string.lower(b.displayName)

	if displayName == displayName2 then
		return a.key < b.key
	end

	return displayName < displayName2
end)
local messageHandler = MessagingServiceManager.createMessageHandler("AdminGiveAll_V1")

-- equivalent calls inferred from this helper; original call sites unknown
local function isDeliveryMode(p)
	return p == "direct" or p == "fakeGift"
end

local function validateRequest(data)
	if Items.ITEMS[data.itemKey] == nil then
		return "Select a valid item"
	end

	if data.tier ~= data.tier or data.tier % 1 ~= 0 or data.tier < 0 or data.tier > Items.MAX_TIER then
		return (`Tier must be between 0 and {Items.MAX_TIER}`)
	end

	if data.amount ~= data.amount or data.amount % 1 ~= 0 or data.amount < 1 or data.amount > 100 then
		return (`Amount must be between 1 and {100}`)
	end

	if data.minimumPlayerCount % 1 ~= 0 or data.minimumPlayerCount < 1 or data.minimumPlayerCount > 100 then
		return (`Minimum player count must be between 1 and {100}`)
	end

	if data.recipientCount % 1 ~= 0 or data.recipientCount < 1 or data.recipientCount > 100 then
		return (`Recipient count must be between 1 and {100}`)
	end

	if isDeliveryMode(data.deliveryMode) then
		return nil
	end

	return "Select a valid delivery mode"
end

local function decodeCommand(p)
	if not strictInterface2(p) then
		return nil
	end

	if validateRequest(p) == nil then
		return p
	end

	return nil
end

local function fireFakeGiftNotification(player, data)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local giftReceivedNotify

	if remotes then
		giftReceivedNotify = remotes:FindFirstChild("GiftReceivedNotify")
	end

	if giftReceivedNotify and giftReceivedNotify:IsA("RemoteEvent") then
		local v2 = Items.ITEMS[data.itemKey]
		giftReceivedNotify:FireClient(player, {
			Gift = data.itemKey,
			GiftName = tostring(v2.name or data.itemKey),
			SenderUserId = data.senderUserId,
			SenderName = data.senderName
		})
	end
end

local function deliverDirectGrant(p, data, flag: boolean)
	local DataManager = require(ServerScriptService.DataManager)

	if p.Parent ~= Players then
		return
	end

	local v2, v3 = DataManager:GrantItem(p, data.itemKey, data.tier, data.amount)

	if not v2 then
		logger:warn((`Admin grant failed for {p.UserId}: {v3 or "unknown error"}`))
	elseif flag then
		fireFakeGiftNotification(p, data)
	end
end

local function deliverToPlayer(p, p2)
	local success, result = pcall(function()
		deliverDirectGrant(p, p2, p2.deliveryMode == "fakeGift")
	end)

	if not success then
		logger:warn((`Delivery failed for {p.UserId}: {tostring(result)}`))
	end
end

local function applyCommand(data)
	local players = Players:GetPlayers()

	if data.randomRecipients then
		if #players < data.minimumPlayerCount then
			return
		end

		for i = #players, 2, -1 do
			local integer = Common.GetRandom():NextInteger(1, i)
			local player = players[integer]
			local player2 = players[i]
			players[i] = player
			players[integer] = player2
		end

		for i = #players, data.recipientCount + 1, -1 do
			table.remove(players, i)
		end
	end

	for _, player in players do
		task.spawn(deliverToPlayer, player, data)
	end
end

local function handleMessagingMessage(p)
	if strictInterface2(p) then
		if validateRequest(p) ~= nil then
			p = nil
		end
	else
		p = nil
	end

	if p == nil then
		return
	end

	applyCommand(p)
end

local function publishCommand(userId: number, name: string, data)
	assert(RunService:IsServer(), "AdminGiveAll publishing can only run on the server")
	local message = validateRequest(data)

	if message then
		return {
			ok = false,
			message = message
		}
	end

	local v3 = {
		version = 1,
		itemKey = data.itemKey,
		tier = data.tier,
		amount = data.amount,
		deliveryMode = data.deliveryMode,
		randomRecipients = data.randomRecipients,
		minimumPlayerCount = data.minimumPlayerCount,
		recipientCount = data.recipientCount,
		senderUserId = userId,
		senderName = name,
		sentAt = os.time()
	}
	local messageValid, v4 = messageHandler.isMessageValid(v3)

	if not messageValid then
		return {
			ok = false,
			message = `Messaging broadcast is invalid: {v4}`
		}
	end

	local v5, v6 = messageHandler.send(v3, 15):await()

	if not v5 then
		return {
			ok = false,
			message = `MessagingServiceManager broadcast failed: {tostring(v6)}`
		}
	end

	local v7 = Items.ITEMS[v3.itemKey]
	logger:info((`{name} ({userId}) broadcast {v3.amount}x {v3.itemKey} tier {v3.tier} as {v3.deliveryMode} ({not v3.randomRecipients and "all players" or `{v3.recipientCount} random per eligible server`})`))
	return {
		ok = true,
		message = `Broadcast queued for {v3.amount}x {tostring(v7.name or v3.itemKey)} [Tier {v3.tier}] as {v3.deliveryMode}`
	}
end

local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminGiveAll_Broadcast",
	"cui.liveops.giveAll",
	true,
	function(p, p2)
		local v2, v3 = strictInterface(p2)

		if not v2 then
			return {
				ok = false,
				message = `Invalid request: {v3 or "unknown validation error"}`
			}
		end

		local userId = p.UserId
		local name = p.Name

		if p2.deliveryMode ~= "fakeGift" or p2.giftSenderUserId == p.UserId then
			return (publishCommand(userId, name, p2))
		end

		local playerByUserId = Players:GetPlayerByUserId(p2.giftSenderUserId)

		if playerByUserId then
			userId = playerByUserId.UserId
			name = playerByUserId.Name
			return (publishCommand(userId, name, p2))
		else
			local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, p2.giftSenderUserId)

			if not success then
				return {
					ok = false,
					message = "Could not resolve the gift sender UserId"
				}
			end

			userId = p2.giftSenderUserId
			name = tostring(nameFromUserIdAsync)
			return (publishCommand(userId, name, p2))
		end
	end
)
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not RunService:IsServer() then
			return
		end

		messageHandler.connect(handleMessagingMessage)
	end
})
local AdminGiveAll = {}

function AdminGiveAll.getItems()
	local clones = table.create(#v)

	for k, v2 in v do
		clones[k] = table.clone(v2)
	end

	return clones
end

function AdminGiveAll.getMaxTier()
	return Items.MAX_TIER
end

function AdminGiveAll.getMaxAmount()
	return 100
end

function AdminGiveAll.getMaxRecipientSetting()
	return 100
end

function AdminGiveAll.requestBroadcast(p)
	assert(RunService:IsClient(), "AdminGiveAll.requestBroadcast can only be called on the client")
	local v2 = clientEvent
	assert(v2 ~= nil, "AdminGiveAll admin remote is not initialized")
	return v2:Fire(p)
end

function AdminGiveAll.broadcast(p, p2)
	assert(RunService:IsServer(), "AdminGiveAll.broadcast can only be called on the server")
	return (publishCommand(p.UserId, p.Name, p2))
end

return AdminGiveAll