local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MessagingServiceManager = require(script.Parent.MessagingServiceManager)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local TableUtils = require(ReplicatedStorage.Utilities.TableUtils)
local Map = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Map)
local OtherUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.OtherUtils)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local GlobalStateManager = {
	onAnyGlobalStateChanged = Signal.new()
}
local messageHandler = MessagingServiceManager.createMessageHandler("FRAMEWORK_GlobalState")
local v = {
	data = {},
	metadata = {
		lastChange = -1
	}
}
local v2 = Map.new()
local v3 = Map.new()
local v4 = Map.new()
local v5 = {}
local v6 = {}

function hash(value: string)
	local v7 = 5381

	for i = 1, #value do
		v7 = (v7 * 33 + string.byte(value, i)) % 4294967296
	end

	return v7
end

function getServerShardKey()
	return (tostring(hash(game.JobId) % 64 + 1))
end

function makeSureThisIsAState(p)
	if type(p) ~= "table" then
		return TableUtils.Copy(v)
	end

	local v7 = TableUtils.Reconcile(p, v)

	if type(v7.metadata) ~= "table" then
		v7.metadata = {}
	end

	if type(v7.metadata.lastChange) ~= "number" then
		v7.metadata.lastChange = -1
	end

	return v7
end

function getAllServerShardKeys()
	local result = {}

	for i = 1, 64 do
		table.insert(result, (tostring(i)))
	end

	return result
end

function getStore(p: string)
	local v7 = v2:get(p)

	if v7 then
		return v7
	end

	local hashMap = MemoryStoreService:GetHashMap(p)
	v2:set(p, hashMap)
	return hashMap
end

function cancelOngoingWrites(p: string)
	local v7 = v5[p]

	if not v7 then
		return
	end

	for _, v8 in v7 do
		v8.ongoingPromise:cancel()
	end
end

function createTrackedWritePromise(p: string, p2: string, callback)
	local flag = false
	local v7 = nil
	local ongoingPromise = Promise.new(function(callback2, callback3, callback4)
		callback4(function()
			flag = true
		end)

		local function shouldContinue()
			return not flag
		end

		local v9, v10 = OtherUtils.retryOperation(function()
			return callback(shouldContinue)
		end, {
			exponentialBackoff = true,
			tryInterval = 1,
			maxInterval = 16,
			shouldContinue = shouldContinue,
			onRetry = function(_, retryAmount)
				if v7 then
					v7.retryAmount = retryAmount
				end
			end
		})

		if flag then
			return
		end

		if v9 then
			callback2(v10)
		else
			callback3(v10)
		end
	end)
	local v9 = v5[p]

	if not v9 then
		v9 = {}
		v5[p] = v9
	end

	local v10 = v9[p2]

	if v10 then
		v10.ongoingPromise:cancel()
	end

	v7 = {
		ongoingPromise = ongoingPromise,
		retryAmount = 0
	}
	v9[p2] = v7
	return ongoingPromise
end

function retrieveFromStore(p: string, p2: string?)
	local v7 = p2 or getServerShardKey()
	return Promise.new(function(callback, _)
		local v8, v9 = OtherUtils.retryOperation(function()
			return getStore(p):GetAsync(v7)
		end, {
			exponentialBackoff = true,
			tryInterval = 1,
			maxInterval = 16
		})

		if v8 then
			callback(v8, v9)
		else
			callback(v8, (tostring(v9)))
		end
	end)
end

function requestReadFromStore(p: string, p2: string?)
	local v7 = p2 or getServerShardKey()
	local formatted = `{p}:{v7}`

	if v6[formatted] and v6[formatted]:getStatus() == "Started" then
		return v6[formatted]
	end

	local v8 = nil
	v8 = retrieveFromStore(p, p2):andThen(function(p3, p4)
		if not p3 then
			return error((`[{script.Name}] Couldn't retrieve data from memory store {p} (shard {v7}): {tostring(p4)}`))
		end

		receiveNewDataFromStore(p, p4)
	end):finally(function()
		if v6[formatted] == v8 then
			v6[formatted] = nil
		end
	end)
	v6[formatted] = v8
	return v8
end

function shouldIgnoreNewState(p, p2)
	return p.metadata.lastChange >= p2.metadata.lastChange
end

function mutateState(stateKey: string, callback)
	if not GlobalStateManager.isReadyToMutate(stateKey) then
		return error((`[{script.Name}] tried mutating key {stateKey} before it could load latest data. please check isReadyToMutate() or try forceReadFromStore() before trying to mutate the globalState.`))
	end

	local cachedState = GlobalStateManager.getCachedState(stateKey)
	local v7 = callback(cachedState.data)
	local stateValidForMessaging, v8 = GlobalStateManager.isStateValidForMessaging(stateKey, v7)

	if not stateValidForMessaging then
		error((`[{script.Name}] tried sending a new state to key {stateKey} that isn't valid: {v8}`))
	end

	local body = {
		metadata = TableUtils.Reconcile(cachedState.metadata, v.metadata),
		data = v7
	}
	body.metadata.lastChange = math.max(DateTime.now().UnixTimestampMillis, cachedState.metadata.lastChange + 1)
	local v10 = messageHandler.send({
		stateKey = stateKey,
		body = body
	})
	receiveNewDataFromStore(stateKey, body)
	return v10, (Promise.new(function(callback2, callback3)
		local store = getStore(stateKey)
		cancelOngoingWrites(stateKey)
		local v11 = {}

		for _, v12 in getAllServerShardKeys() do
			local v13 = v12
			table.insert(v11, (createTrackedWritePromise(stateKey, v12, function(callback4)
				return store:UpdateAsync(v13, function(p2)
					if callback4() and not shouldIgnoreNewState(makeSureThisIsAState(p2), body) then
						return body
					end

					return p2
				end, 3888000)
			end)))
		end

		local v12, v13 = Promise.all(v11):await()

		if not v12 then
			callback3(v13)
			return
		end

		messageHandler.send({
			stateKey = stateKey,
			body = body
		}):catch(function(p2)
			warn((`[{script.Name}] Convergence broadcast failed for {stateKey}: {tostring(p2)}`))
		end)
		callback2(body)
	end))
end

function receiveNewDataFromStore(p: string, p2)
	local sureThisIsAState = makeSureThisIsAState(p2)
	local cachedState = GlobalStateManager.getCachedState(p)

	if cachedState and shouldIgnoreNewState(cachedState, sureThisIsAState) then
		return
	end

	v3:set(p, sureThisIsAState)
	local v7 = v4:get(p)

	if v7 then
		for _, v8 in v7 do
			local v9 = v8
			xpcall(function()
				return v9(sureThisIsAState.data, sureThisIsAState.metadata)
			end, function(p3)
				return warn((`[{script.Name}] Error while running globalState callback: {p3} {debug.traceback()}`))
			end)
		end
	end

	GlobalStateManager.onAnyGlobalStateChanged:Fire(p, sureThisIsAState.data, sureThisIsAState.metadata)
end

function GlobalStateManager.getCachedState(p: string)
	assert(RunService:IsServer(), "GlobalStateManager.getCachedState can only be called on the server.")
	return v3:get(p)
end

function GlobalStateManager.subscribeToState(p: string, callback)
	assert(RunService:IsServer(), "GlobalStateManager.subscribeToState can only be called on the server.")
	local callbacks = v4:get(p)

	if not callbacks then
		callbacks = {}
		v4:set(p, callbacks)
	end

	table.insert(callbacks, callback)
	local cachedState = GlobalStateManager.getCachedState(p)

	if cachedState then
		xpcall(function()
			return callback(cachedState.data, cachedState.metadata)
		end, function(p2)
			return warn((`[{script.Name}] Error while running globalState callback: {p2} {debug.traceback()}`))
		end)
	else
		requestReadFromStore(p):catch(function(p2)
			return warn((`[{script.Name}] Error while reading data from {p} (shard {getServerShardKey()}): {p2}`))
		end)
	end

	return function()
		local index = table.find(callbacks, callback)

		if index and index > 0 then
			table.remove(callbacks, index)
		end
	end
end

function GlobalStateManager.setState(p: string, p2)
	assert(RunService:IsServer(), "GlobalStateManager.setState can only be called on the server.")
	return mutateState(p, function(_)
		return p2
	end)
end

function GlobalStateManager.updateState(p: string, callback)
	assert(RunService:IsServer(), "GlobalStateManager.updateState can only be called on the server.")
	return mutateState(p, callback)
end

function GlobalStateManager.deleteState(p: string)
	assert(RunService:IsServer(), "GlobalStateManager.deleteState can only be called on the server.")
	return mutateState(p, function(_)
		return {}
	end)
end

function GlobalStateManager.forceReadFromStore(p: string, p2: string?)
	assert(RunService:IsServer(), "GlobalStateManager.forceReadFromStore can only be called on the server.")
	return requestReadFromStore(p, p2)
end

function GlobalStateManager.isReadyToMutate(p: string)
	assert(RunService:IsServer(), "GlobalStateManager.isReadyToMutate can only be called on the server.")
	return GlobalStateManager.getCachedState(p) ~= nil
end

function GlobalStateManager.isStateValidForMessaging(stateKey: string, p2)
	assert(RunService:IsServer(), "GlobalStateManager.isStateValidForMessaging can only be called on the server.")
	local v7 = {
		stateKey = stateKey,
		body = TableUtils.Copy(v, true)
	}
	v7.body.data = p2
	v7.body.metadata.lastChange = DateTime.now().UnixTimestampMillis
	local success, result, v8 = pcall(messageHandler.isMessageValid, v7)

	if success then
		return result, v8
	end

	return false, (tostring(result))
end

function GlobalStateManager.getDiagnostics()
	assert(RunService:IsServer(), "GlobalStateManager.getDiagnostics can only be called on the server.")
	local count = 0

	for _ in v6 do
		count += 1
	end

	local count2 = 0

	for _, v7 in v5 do
		for _ in v7 do
			count2 += 1
		end
	end

	local states = {}

	for _, v8 in v3:entries() do
		local key = v8.key
		local value = v8.value
		local shardEntries = {}
		local v9 = v5[key]

		if v9 then
			for k, v10 in v9 do
				table.insert(shardEntries, {
					shardKey = k,
					status = v10.ongoingPromise:getStatus(),
					retryAmount = v10.retryAmount
				})
			end

			table.sort(shardEntries, function(a, b)
				return a.shardKey < b.shardKey
			end)
		end

		local stateValidForMessaging, messageValidationError = GlobalStateManager.isStateValidForMessaging(
			key,
			value.data
		)
		local v11 = v4:get(key)
		local v13

		if type(value.data) == "table" then
			v13 = TableUtils.Copy(value.data, true)
		else
			v13 = value.data
		end

		local v12 = {
			key = key,
			data = v13,
			lastChange = value.metadata.lastChange,
			subscriberCount = v11 and #v11 or 0,
			messageValid = stateValidForMessaging,
			messageValidationError = messageValidationError,
			writes = shardEntries
		}
		table.insert(states, v12)
	end

	table.sort(states, function(a, b)
		return string.lower(a.key) < string.lower(b.key)
	end)
	return {
		serverShardKey = getServerShardKey(),
		shardCount = 64,
		stateExpirationSeconds = 3888000,
		cachedStoreCount = v2:size(),
		cachedStateCount = v3:size(),
		ongoingReadCount = count,
		trackedWriteCount = count2,
		states = states
	}
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -990,
	OnInit = function()
		if RunService:IsClient() then
			return
		end

		messageHandler.connect(function(p)
			if type(p) ~= "table" then
				return
			end

			receiveNewDataFromStore(p.stateKey, p.body)
		end)
	end
})
return GlobalStateManager