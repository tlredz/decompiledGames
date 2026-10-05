local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MessagingBudget = require(script.MessagingBudget)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local CountBucket = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.CountBucket)
local Map = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Map)
local OtherUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.OtherUtils)
local Set = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Set)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local MessagingServiceManager = {
	onMessageReceived = Signal.new(),
	onMessageSent = Signal.new()
}
local v = Map.new()
local v2 = {
	duplicateFound = 0,
	messageSent = 0,
	messageReceived = 0,
	failedSendAttempts = 0,
	failedSubscriptionsAttempts = 0,
	messageSentThisMinuteBucket = CountBucket.new(60, 1),
	messageReceivedThisMinuteBucket = CountBucket.new(60, 1)
}

function buildMessage(content)
	if type(content) == "table" and content.guid and content.content then
		return content
	end

	return {
		content = content,
		guid = HttpService:GenerateGUID()
	}
end

function handleTopicSubscription(p: string, callback)
	return OtherUtils.retryOperation(function()
		return MessagingService:SubscribeAsync(p, callback)
	end, {
		exponentialBackoff = true,
		maxInterval = 30,
		onRetry = function(p2, p3)
			v2.failedSubscriptionsAttempts += 1

			if p3 >= 10 then
				warn((`[{script.Name}] Couldn't connect to topic {p} after {p3} retries: {p2}`))
			end
		end
	})
end

function getDataSize(p)
	local v3

	if type(p) == "table" then
		v3 = HttpService:JSONEncode(p)
	else
		v3 = tostring(p)
	end

	return #v3
end

function doesMessageRespectMaxSize(p)
	local dataSize = getDataSize(p)
	local messageSize = MessagingBudget.messageSize

	if messageSize < dataSize then
		return false, (`message over budget (expected {messageSize} bytes, got {dataSize} bytes)`)
	end

	return true
end

function MessagingServiceManager.createMessageHandler(topic: string)
	if RunService:IsClient() then
		return (setmetatable({}, {
			__index = function(_, _)
				error("Cannot index MessageHandler within client context.")
			end,
			__newindex = function(_, _)
				error("Cannot write to MessageHandler within client context.")
			end
		}))
	end

	local v3 = v:get(topic)

	if v3 then
		warn((`[{script.Name}] tried creating a MessageService handler with same key {topic}. Only create one handler or get the existing one.`))
		return v3
	end

	if #topic < 1 then
		return error((`[{script.Name}] attempt to subscribe to an invalid topic {topic} (length is {#topic}, expected more than 1 character)`))
	end

	if #topic > MessagingBudget.topicLength then
		return error((`[{script.Name}] attempt to subscribe to an invalid topic {topic} (length is {#topic}, expected {MessagingBudget.topicLength} or lower)`))
	end

	if v:size() >= MessagingBudget.maxActiveSubscription then
		return error((`[{script.Name}] Could not create handler for topic {topic}. The maximum amount of ActiveSubscription for this server has been reached.`))
	end

	local v4 = Signal.new()
	local v5 = Set.new()
	local flag = false
	local v6 = nil
	local v7 = nil
	v7 = {
		topic = topic,
		isSubscribed = false,
		connect = function(callback)
			v7.subscribe()
			return v4:Connect(callback)
		end,
		getSubscriberCount = function()
			return #v4:GetConnections()
		end,
		isMessageValid = function(p)
			local message = buildMessage(p)
			local v8, v9 = doesMessageRespectMaxSize(message)

			if v8 then
				return true, ""
			end

			return false, v9
		end,
		send = function(p, value: number?)
			local timeOut = value or 60
			local message = buildMessage(p)
			local messageValid, v9 = v7.isMessageValid(message)

			if messageValid then
				return Promise.new(function(callback, callback2)
					local v10, v11 = OtherUtils.retryOperation(function()
						return MessagingService:PublishAsync(topic, message)
					end, {
						tryInterval = 3,
						timeOut = timeOut,
						onRetry = function(p2, p3)
							v2.failedSendAttempts += 1

							if p3 < 5 then
								return
							end

							warn((`[{script.Name}] Tried sending message to topic {topic} failed {p3} times: {p2}`))
						end
					})

					if not v10 then
						callback2(`[{script.Name}] Failed to send message on topic {topic}:` .. tostring(v11))
						return
					end

					MessagingServiceManager.onMessageSent:Fire(topic, p)
					v2.messageSent += 1
					callback()
				end)
			end

			return error((`[{script.Name}] {v9}: {HttpService:JSONEncode(message)}`))
		end,
		subscribe = function()
			if flag then
				return v6
			end

			flag = true
			v6 = Promise.new(function(callback, _)
				handleTopicSubscription(topic, function(p)
					if type(p.Data) ~= "table" or not p.Data.guid or type(p.Data.guid) ~= "string" then
						warn((`[{script.Name}] Received a malformed message in topic {topic}, did you forget to remove a legacy messaging service call?`))
					elseif v5:has(p.Data.guid) then
						LogService:Warn((`[{script.Name}] Found duplicate message for topic {topic}.`))
						v2.duplicateFound += 1
					else
						v5:add(p.Data.guid)
						task.delay(300, function()
							v5:delete(p.Data.guid)
						end)
						v4:Fire(p.Data.content)
						MessagingServiceManager.onMessageReceived:Fire(topic, p.Data.content)
						v2.messageReceived += 1
					end
				end)
				v7.isSubscribed = true
				callback()
			end)
			return v6
		end
	}
	v:set(topic, v7)
	return v7
end

function MessagingServiceManager.getHandlerByTopic(p: string)
	assert(RunService:IsServer(), "MessagingServiceManager cannot be used on client.")
	return v:get(p)
end

function MessagingServiceManager.getAllMessageHandlers()
	assert(RunService:IsServer(), "MessagingServiceManager cannot be used on client.")
	return v:values()
end

function MessagingServiceManager.getAllTopics()
	assert(RunService:IsServer(), "MessagingServiceManager cannot be used on client.")
	return v:keys()
end

function MessagingServiceManager.getStatus()
	assert(RunService:IsServer(), "MessagingServiceManager cannot be used on client.")
	return v2
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -999,
	OnInit = function()
		if RunService:IsClient() then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function listenForMessage(object, object2)
			object:Connect(function(_, _)
				object2:increment(1)
			end)
		end

		listenForMessage(MessagingServiceManager.onMessageReceived, v2.messageReceivedThisMinuteBucket) -- equivalent call inferred; original call site unknown
		listenForMessage(MessagingServiceManager.onMessageSent, v2.messageSentThisMinuteBucket) -- equivalent call inferred; original call site unknown
	end
})
return MessagingServiceManager