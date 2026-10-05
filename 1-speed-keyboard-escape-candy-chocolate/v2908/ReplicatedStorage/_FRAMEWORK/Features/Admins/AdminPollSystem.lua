local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local GlobalStateManager = require(ReplicatedStorage._FRAMEWORK.Features.GlobalStateManager)
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
local PollView = require(script.PollView)
require(script.Types)
local remo = require(ReplicatedStorage.Packages.remo)
local Promise = require(ReplicatedStorage.Packages.remo.Promise)
local PlayerReady = require(ReplicatedStorage._FRAMEWORK.Features.PlayerReady)
local OtherUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.OtherUtils)
local TableUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.TableUtils)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local t = require(ReplicatedStorage.Packages.t)
local numberRange = NumberRange.new(1, 10)
local color = Color3.fromRGB(100, 255, 100)
local messageHandler = MessagingServiceManager.createMessageHandler("ADMIN_POLL")
local messageHandler2 = MessagingServiceManager.createMessageHandler("ADMIN_POLL_REWARD")
local hashMap

if RunService:IsServer() then
	hashMap = MemoryStoreService:GetHashMap("Admin_Poll")
else
	hashMap = nil
end

local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local literal = t.literal("item", "xp", "wins")
local strictInterface = t.strictInterface({
	storeKey = t.string,
	winningChoiceIndex = t.integer,
	kind = literal,
	amount = t.integer,
	itemKey = t.string,
	tier = t.integer
})
local AdminPollSystem = {
	logger = logger,
	remotes = remo.createRemotes({
		updatePollState = remo.remote(),
		endPoll = remo.remote(),
		sendResults = remo.remote(),
		showReward = remo.remote(),
		reply = remo.remote()
	})
}
local v = nil
local v2 = false
local flag = false
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {
	storeKey = "",
	capturedAt = 0,
	question = "",
	choices = {},
	votes = {}
}
local now = 0
local now2 = 0
local v7 = nil
local v8 = 1
local storeKey = nil
local v9 = 0
local now3 = os.clock()
local v10 = {}
local sendAt = 0
local v11 = {
	isThisServer = false,
	resultPerShard = {}
}

function getMassPollReadInterval(p: number)
	return p / 6
end

function observeMutation(p: string, object)
	object:catch(function(p2)
		warn((`[AdminAbuseTreadmill] Failed to {p}: {tostring(p2)}`))
	end)
end

function didTimestampAlreadyPassed(p: number)
	return p < os.time()
end

function isRewardCacheActive()
	return v6.storeKey ~= "" and not didTimestampAlreadyPassed(v6.capturedAt + 3600)
end

function replaceRewardVoteCache(data)
	v6.storeKey = data.storeKey
	v6.capturedAt = os.time()
	v6.question = data.question
	v6.choices = TableUtils.Copy(data.choices, true)
	v6.votes = {}
end

function checkRewardCacheReady()
	if v6.storeKey == "" then
		return false, "No reward poll is cached on this server."
	end

	if didTimestampAlreadyPassed(v6.capturedAt + 3600) then
		return false, "The reward vote cache has expired."
	end

	return true, ""
end

function checkRewardKindReady(data)
	if data.kind ~= "item" and data.kind ~= "xp" and data.kind ~= "wins" then
		return false, "Select a valid reward type."
	end

	local v12 = data.kind == "item" and 100 or 1000000

	if data.amount ~= data.amount or data.amount % 1 ~= 0 or data.amount < 1 or v12 < data.amount then
		return false, string.format("Amount must be between 1 and %d.", v12)
	end

	if data.kind ~= "item" then
		return true, ""
	end

	if Items.ITEMS[data.itemKey] == nil then
		return false, "Select a valid item."
	end

	if data.tier ~= data.tier or data.tier % 1 ~= 0 or data.tier < 0 or data.tier > Items.MAX_TIER then
		return false, string.format("Tier must be between 0 and %d.", Items.MAX_TIER)
	end

	return true, ""
end

function checkRewardBroadcastReady(data)
	local v12, v13 = checkRewardCacheReady()

	if not v12 then
		return false, nil, v13
	end

	if v6.choices[data.winningChoiceIndex] == nil then
		return false, nil, "Select a valid poll choice."
	end

	local v14, v15 = checkRewardKindReady(data)

	if v14 then
		return true, {
			storeKey = v6.storeKey,
			winningChoiceIndex = data.winningChoiceIndex,
			kind = data.kind,
			amount = data.amount,
			itemKey = data.kind ~= "item" and "" or data.itemKey,
			tier = data.kind ~= "item" and 0 or data.tier
		}, ""
	end

	return false, nil, v15
end

function checkIncomingRewardReady(p)
	local v12 = checkRewardKindReady(p) and isRewardCacheActive()

	if v12 then
		if p.storeKey == v6.storeKey then
			return v6.choices[p.winningChoiceIndex] ~= nil
		else
			return false
		end
	end

	return v12
end

function deliverRewardToPlayer(p, data)
	if p.Parent ~= Players then
		return
	end

	local DataManager = require(ServerScriptService.DataManager)
	local success, result = pcall(function()
		if data.kind == "item" then
			local v12, v13 = DataManager:GrantItem(p, data.itemKey, data.tier, data.amount)

			if v12 then
				showPollReward(p, data)
			else
				logger:warn((`Poll reward grant failed for {p.UserId}: {v13 or "unknown error"}`))
			end
		else
			if data.kind == "xp" then
				DataManager:AddXP(p, data.amount)
			else
				DataManager:IncrementStat(p, "Wins", data.amount)
			end

			notifyPollStatReward(p, data)
		end
	end)

	if not success then
		logger:warn((`Poll reward delivery failed for {p.UserId}: {tostring(result)}`))
	end
end

function showPollReward(p, data)
	AdminPollSystem.remotes.showReward:fire(p, {
		kind = data.kind,
		amount = data.amount,
		itemKey = data.itemKey,
		tier = data.tier
	})
end

function notifyPollStatReward(p, p2)
	local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
	local v12 = p2.kind == "xp" and "XP" or "Wins"
	NotificationSystem:ShowGeneralNotificationForPlayer(
		p,
		`Reward received for your poll answer! +{p2.amount} {v12}`,
		color,
		4
	)
end

function applyRewardGrant(p)
	for _, v12 in Players:GetPlayers() do
		if v6.votes[v12.UserId] == p.winningChoiceIndex then
			task.spawn(deliverRewardToPlayer, v12, p)
		end
	end
end

function applyRewardBroadcast(data)
	local messageValid, v12 = messageHandler2.isMessageValid(data)

	if not messageValid then
		return {
			success = false,
			message = string.format("Messaging broadcast is invalid: %s", v12)
		}
	end

	local v13, v14 = messageHandler2.send(data, 15):await()

	if not v13 then
		return {
			success = false,
			message = string.format("Reward broadcast failed: %s", (tostring(v14)))
		}
	end

	logger:info((`Broadcast poll reward {data.kind} x{data.amount} for choice {data.winningChoiceIndex}`))
	return {
		success = true,
		message = "Reward broadcast sent."
	}
end

function onRewardCommandReceived(p)
	if not strictInterface(p) then
		return
	end

	if checkIncomingRewardReady(p) then
		applyRewardGrant(p)
	end
end

function buildRemoteData()
	return {
		state = TableUtils.Copy(v or {}, true),
		results = getCurrentResults()
	}
end

function getCurrentResults()
	local copy = TableUtils.Copy(v4, false)

	for k, v12 in v3 do
		copy[k] = (copy[k] or 0) + v12
	end

	return copy
end

function clearAdminServerData()
	v11.isThisServer = false
	v11.resultPerShard = {}
end

function setupAdminServerDataForThisServer(items, p: number)
	v11.isThisServer = true
	v11.resultPerShard = {}

	for _, v12 in getAllServerShardKeys(p) do
		v11.resultPerShard[v12] = {}

		for k, _ in items do
			v11.resultPerShard[v12][k] = 0
		end
	end
end

function hash(value: string)
	local v12 = 5381

	for i = 1, #value do
		v12 = (v12 * 33 + string.byte(value, i)) % 4294967296
	end

	return v12
end

function getServerShardKey()
	assert(v, "cannot get shard count without an ongoing poll")
	return (tostring(hash(game.JobId) % v.shardCount + 1))
end

function getAllServerShardKeys(p: number)
	local result = {}

	for i = 1, p do
		table.insert(result, (tostring(i)))
	end

	return result
end

function writeInfoToShard(p: string, callback)
	assert(v, "Cannot write info from shard without storeKey")
	local formatted = `{v.storeKey}_{p}`
	return Promise.new(function(callback2)
		local success, result = pcall(hashMap.UpdateAsync, hashMap, formatted, callback, 3600)

		if success then
			return callback2(result)
		end

		logger:warn((`Failed to write on shard {p}: {tostring(result)}`))
		return callback2(nil)
	end)
end

function massPollRead()
	local v12 = v

	if not (v11.isThisServer and v12) then
		return
	end

	local now4 = os.clock()
	local massPollReadInterval = getMassPollReadInterval(v12.shardCount)
	local v13 = math.max(1, massPollReadInterval)

	if storeKey == v12.storeKey then
		v9 = math.min(v13, v9 + (now4 - now3) * massPollReadInterval)
	else
		storeKey = v12.storeKey
		v8 = 1
		v9 = 1
	end

	now3 = now4
	local storeKey2 = v12.storeKey
	local v14 = math.floor(v9)

	while v14 > 0 do
		local v15 = nil
		local v16 = nil

		for _ = 1, v12.shardCount do
			local v17 = tostring(v8)
			v8 = v8 % v12.shardCount + 1
			local formatted = `{storeKey2}_{v17}`

			if v10[formatted] then
				continue
			end

			v16 = formatted
			v15 = v17
			break
		end

		if not (v15 and v16) then
			break
		end

		v14 -= 1
		v9 -= 1
		v10[v16] = true
		Promise.new(function(callback)
			local success, async = pcall(hashMap.GetAsync, hashMap, v16)
			local v17 = v

			if success and async ~= nil and v11.isThisServer and v17 ~= nil and v17.storeKey == storeKey2 then
				v11.resultPerShard[v15] = async
			elseif not success then
				logger:warn((`Failed to read on shard {v15}: {tostring(async)}`))
			end

			callback()
		end):finally(function()
			v10[v16] = nil
		end)
	end
end

function pushLocalVotes()
	if flag then
		return
	end

	if not v then
		logger:warn("trying to push local votes without a poll current state?")
		return
	end

	if os.time() > v.endTime or next(v3) == nil then
		return
	end

	local v12 = math.max(0, os.clock() - (now or 0))
	v7 = v7 or OtherUtils.getValueFromNumberRange(numberRange)

	if v12 < v7 then
		return
	end

	v7 = nil
	now = os.clock()
	local v13 = v3
	v3 = {}

	for k, v14 in v13 do
		v4[k] = (v4[k] or 0) + v14
	end

	writeInfoToShard(getServerShardKey(), function(options)
		local result = options or {}

		for k, v14 in v13 do
			result[k] = (result[k] or 0) + v14
		end

		return result
	end)
end

function broadcastPollResults()
	if not v or not v11.isThisServer or os.clock() - now2 < 2 then
		return
	end

	now2 = os.clock()
	local votes = {}

	for _, v13 in v11.resultPerShard do
		for k, v14 in v13 do
			votes[k] = (votes[k] or 0) + v14
		end
	end

	local v13 = messageHandler.send({
		sendAt = os.time(),
		votes = votes,
		storeKey = v.storeKey
	}, 6)
	observeMutation("broadcast current vote results", v13)
end

function setPollVisible(flag2: boolean, p, p2)
	if flag2 and RunService:IsClient() then
		assert(p, "setting the poll visible requires data.")
	end

	v2 = flag2

	if RunService:IsServer() then
		if flag2 then
			local remoteData = buildRemoteData()
			remoteData.state.endTime += 5

			if p2 then
				AdminPollSystem.remotes.updatePollState:fire(p2, true, remoteData)
			else
				AdminPollSystem.remotes.updatePollState:fireAll(true, remoteData)
			end
		elseif p2 then
			AdminPollSystem.remotes.updatePollState:fire(p2, false)
		else
			AdminPollSystem.remotes.updatePollState:fireAll(false)
		end
	else
		if p then
			PollView.setData(p)
		end

		PollView.setVisible(flag2)
	end
end

function endPoll(p, p2)
	flag = true

	if not RunService:IsServer() then
		PollView.setEndPoll(p)
	elseif p2 then
		AdminPollSystem.remotes.endPoll:fire(p2, p)
	else
		AdminPollSystem.remotes.endPoll:fireAll(p)
	end
end

function sendResults(items)
	if RunService:IsServer() then
		AdminPollSystem.remotes.sendResults:fireAll(items)
		return
	end

	for k, item in items do
		PollView.setChoiceAmount(k, item)
	end
end

function presentPollReward(data)
	if data.kind ~= "item" then
		return
	end

	local v12 = Items.ITEMS[data.itemKey]

	if v12 then
		local ItemRewardUISystem = require(ReplicatedStorage.ItemRewardUISystem)
		local play = ItemRewardUISystem.play
		local v13 = {
			icon = v12.icon,
			itemName = 0,
			topText = "Reward received for your poll answer!",
			nameColor = 0,
			tier = 0
		}
		local itemName

		if data.amount > 1 then
			itemName = `{v12.name} x{data.amount}`
		else
			itemName = v12.name
		end

		v13.itemName = itemName
		v13.nameColor = Items.RARITY_COLORS[v12.rarity]
		v13.tier = data.tier or 0
		play(v13)
	end
end

function onGlobalStateChanged(state)
	if not state or type(state) ~= "table" then
		return
	end

	if didTimestampAlreadyPassed(state.endTime or 0) then
		state.state = "stop"
	end

	if state.state == "start" then
		if v and v.storeKey ~= state.storeKey or not v then
			v = state
			now = os.clock()
			v5 = {}
			v3 = {}
			v4 = {}
			flag = false

			if state.rewardAttached == true then
				replaceRewardVoteCache(state)
			end
		end

		setPollVisible(true)
	elseif state.state == "stop" then
		setPollVisible(false)
		clearAdminServerData()
		v5 = {}
		v3 = {}
		v4 = {}
		v = nil
	end
end

function onGlobalMessageReceived(data)
	if not v or data.sendAt < sendAt or data.storeKey ~= v.storeKey then
		return
	end

	sendAt = data.sendAt

	for k, _ in data.votes do
		v4[k] = math.max(data.votes[k], v4[k] or 0)
	end

	sendResults(getCurrentResults())
end

function onReceivedPlayerReply(p, p2: number)
	if v5[p.UserId] or not v or not v.choices[p2] or didTimestampAlreadyPassed(v.endTime) then
		return
	end

	v5[p.UserId] = p2

	if v.rewardAttached == true and v6.storeKey == v.storeKey then
		v6.votes[p.UserId] = p2
	end

	v3[p2] = (v3[p2] or 0) + 1
	sendResults(getCurrentResults())
end

function AdminPollSystem.isPollOngoing()
	return v ~= nil
end

function AdminPollSystem.broadcastPoll(p: number, question: string, choices, shardCount: number, flag2: boolean)
	assert(not AdminPollSystem.isPollOngoing(), "A poll is already ongoing")
	setupAdminServerDataForThisServer(choices, shardCount)
	local v12, v13 = GlobalStateManager.setState("ADMIN_POLL_STATE", {
		state = "start",
		question = question,
		choices = choices,
		endTime = os.time() + p,
		storeKey = HttpService:GenerateGUID(),
		shardCount = shardCount,
		rewardAttached = flag2
	})
	observeMutation("broadcast global poll state", v12)
	observeMutation("write to global poll state", v13)
	return v12, v13
end

function AdminPollSystem.broadcastForceStop()
	local v12, v13 = GlobalStateManager.setState("ADMIN_POLL_STATE", {
		state = "stop",
		question = "",
		choices = {},
		endTime = 0,
		storeKey = "",
		shardCount = 128,
		rewardAttached = false
	})
	observeMutation("broadcast global forcestop poll state", v12)
	observeMutation("write to global forcestop poll state", v13)
	return v12, v13
end

function AdminPollSystem.getRewardPollSnapshot()
	assert(RunService:IsServer(), "Poll reward publishing can only run on the server")

	if isRewardCacheActive() then
		return {
			storeKey = v6.storeKey,
			question = v6.question,
			choices = TableUtils.Copy(v6.choices, true),
			capturedAt = v6.capturedAt,
			expiresAt = v6.capturedAt + 3600
		}
	end

	return nil
end

function AdminPollSystem.broadcastReward(p)
	assert(RunService:IsServer(), "Poll reward publishing can only run on the server")
	local v12, v13, message = checkRewardBroadcastReady(p)

	if v12 and v13 then
		return applyRewardBroadcast(v13)
	end

	return {
		success = false,
		message = message
	}
end

function AdminPollSystem.getMaxItemAmount()
	return 100
end

function AdminPollSystem.getMaxStatAmount()
	return 1000000
end

function AdminPollSystem.getMaxTier()
	return Items.MAX_TIER
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsServer() then
			GlobalStateManager.subscribeToState("ADMIN_POLL_STATE", onGlobalStateChanged)
			messageHandler.connect(onGlobalMessageReceived)
			messageHandler2.connect(onRewardCommandReceived)
			AdminPollSystem.remotes.reply:connect(onReceivedPlayerReply)
			PlayerReady.onPlayerReady:Connect(function(p)
				if v and v2 then
					setPollVisible(v2, nil, p)

					if flag then
						endPoll(v4, p)
					end
				end
			end)
		else
			AdminPollSystem.remotes.updatePollState:connect(setPollVisible)
			AdminPollSystem.remotes.endPoll:connect(endPoll)
			AdminPollSystem.remotes.sendResults:connect(sendResults)
			AdminPollSystem.remotes.showReward:connect(presentPollReward)
		end
	end,
	OnUIInit = function()
		if RunService:IsClient() then
			PollView.mount(function(p, _)
				AdminPollSystem.remotes.reply:fire(p)
			end)
		end
	end,
	OnUpdate = function()
		if RunService:IsClient() or not v or not v2 then
			return
		end

		if not flag and didTimestampAlreadyPassed(v.endTime + 5) then
			endPoll(v4)
		end

		if didTimestampAlreadyPassed(v.endTime + 5 + 5) then
			onGlobalStateChanged(v)
		end

		if not flag then
			pushLocalVotes()
			massPollRead()
			broadcastPollResults()
		end
	end
})
return AdminPollSystem