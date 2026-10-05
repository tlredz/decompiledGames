local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local DefaultTriggerAnimation = require(ReplicatedStorage._FRAMEWORK.Libraries.easterEggKeycaps.DefaultTriggerAnimation)
local Constants = require(ReplicatedStorage._FRAMEWORK.Libraries.easterEggKeycaps.Constants)
local KeycapStreamConfig = require(ReplicatedStorage.Utilities.KeycapsRendering.KeycapStreamConfig)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
require(ReplicatedStorage._FRAMEWORK.Libraries.easterEggKeycaps.Types)
local easterEggTag = Constants.easterEggTag
local clientModuleTag = Constants.clientModuleTag
local sessionAssetTag = Constants.sessionAssetTag
local sessionIdAttribute = Constants.sessionIdAttribute
local eventNameAttribute = Constants.eventNameAttribute
local eventModeAttribute = Constants.eventModeAttribute
local positionAttributeName = KeycapStreamConfig.PositionAttributeName
local v = {
	maxPositionStuds = 0.18,
	maxRotationRadians = 0.06981317007977318,
	baseFrequencyHz = 5,
	frequencyGainHz = 7
}
local EasterEggKeycaps = {}
local intersection = t.intersection(t.integer, t.numberMin(1))
local interface = t.interface({
	sessionId = t.string,
	cycle = intersection,
	progress = t.numberConstrained(0, 1)
})
local interface2 = t.interface({
	sessionId = t.string,
	cycle = intersection
})
EasterEggKeycaps.remotes = remo.createRemotes({
	Progress = remo.remote(interface),
	Completed = remo.remote(interface2),
	Stop = remo.remote(interface2),
	ReplayReady = remo.remote(interface2)
})
local flag = false
local count = 0
local now = 0
local parent = nil
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local connections = {}
local connections2 = {}
local fn
local fn2
local fn3

local function reportCallbackError(p)
	warn((`[EasterEggKeycaps] Client callback failed: {tostring(p)}\n{debug.traceback()}`))
	return (tostring(p))
end

local function getSessionId(instance)
	local attribute = instance:GetAttribute(sessionIdAttribute)

	if typeof(attribute) == "string" and attribute ~= "" then
		return attribute
	end

	return nil
end

local function finishDeliveredRemoval(p: string, data)
	if data.removePending and not data.starting and not data.stopping and not data.stopPending and v4[p] == data then
		v4[p] = nil

		if flag then
			for _, v12 in CollectionService:GetTagged(clientModuleTag) do
				local attribute = v12:GetAttribute(sessionIdAttribute)

				if typeof(attribute) ~= "string" or attribute == "" then
					attribute = nil
				end

				if attribute ~= p then
					continue
				end

				fn3(v12)
				return
			end
		end
	end
end

local function makeSeed(value: string)
	local v12 = 0

	for i = 1, #value do
		v12 = (v12 * 31 + string.byte(value, i)) % 10000
	end

	return v12 / 97
end

local function readLocalTransparencyModifier(instance)
	if instance:IsA("BasePart") or instance:IsA("Fire") or instance:IsA("Sparkles") or instance:IsA("Smoke") or instance:IsA("ParticleEmitter") or instance:IsA("Decal") or instance:IsA("Texture") then
		return instance.LocalTransparencyModifier
	end

	return nil
end

local function writeLocalTransparencyModifier(instance, localTransparencyModifier: number)
	if instance:IsA("BasePart") or instance:IsA("Fire") or instance:IsA("Sparkles") or instance:IsA("Smoke") or instance:IsA("ParticleEmitter") or instance:IsA("Decal") or instance:IsA("Texture") then
		instance.LocalTransparencyModifier = localTransparencyModifier
	end
end

local function shouldRevealSessionAsset(p: string)
	return v6[p] == true and v7[p] ~= true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSessionAssetDescendant(p, p2, flag2: boolean)
	local v12 = readLocalTransparencyModifier(p2)

	if v12 == nil then
		return
	end

	local v13 = p.originalTransparency[p2]

	if v13 == nil then
		p.originalTransparency[p2] = v12
		v13 = v12
	end

	writeLocalTransparencyModifier(p2, not flag2 and 1 or v13)
end

local function updateSessionAssets(p: string)
	local v12

	if v6[p] == true then
		v12 = v7[p] ~= true
	else
		v12 = false
	end

	for folder, v13 in v11 do
		local attribute = folder:GetAttribute(sessionIdAttribute)

		if typeof(attribute) ~= "string" or attribute == "" then
			attribute = nil
		end

		if attribute ~= p then
			continue
		end

		updateSessionAssetDescendant(v13, folder, v12) -- equivalent call inferred; original call site unknown

		for _, descendant in folder:GetDescendants() do
			updateSessionAssetDescendant(v13, descendant, v12) -- equivalent call inferred; original call site unknown
		end
	end
end

local function untrackSessionAsset(p)
	local v12 = v11[p]

	if v12 == nil then
		return
	end

	if v12.descendantAddedConnection ~= nil then
		v12.descendantAddedConnection:Disconnect()
	end

	v11[p] = nil
end

local function trackSessionAsset(folder)
	if v11[folder] ~= nil or not folder:IsDescendantOf(Workspace) then
		return
	end

	local attribute = folder:GetAttribute(sessionIdAttribute)

	if typeof(attribute) ~= "string" or attribute == "" then
		attribute = nil
	end

	if attribute == nil then
		return
	end

	local v12 = {
		root = folder,
		originalTransparency = {},
		descendantAddedConnection = nil
	}
	v12.descendantAddedConnection = folder.DescendantAdded:Connect(function(descendant)
		local v14 = attribute
		updateSessionAssetDescendant(v12, descendant, v6[v14] == true and v7[v14] ~= true) -- equivalent call inferred; original call site unknown
	end)
	v11[folder] = v12
	local v13

	if v6[attribute] == true then
		v13 = v7[attribute] ~= true
	else
		v13 = false
	end

	updateSessionAssetDescendant(v12, folder, v13) -- equivalent call inferred; original call site unknown

	for _, descendant in folder:GetDescendants() do
		updateSessionAssetDescendant(v12, descendant, v6[attribute] == true and v7[attribute] ~= true) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClientContext(sessionId: string, eventName: string)
	return {
		runtime = "client",
		sessionId = sessionId,
		eventName = eventName
	}
end

local function getAnimationContext(sessionId: string, eventName: string)
	return {
		sessionId = sessionId,
		eventName = eventName
	}
end

local function cleanupProxy(state)
	if state.keycap.Parent ~= nil then
		state.keycap.LocalTransparencyModifier = state.originalTransparency
	end

	for k, localTransparencyModifier in state.originalDescendantTransparency do
		if k.Parent ~= nil then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	table.clear(state.originalDescendantTransparency)

	if state.proxy ~= nil then
		state.proxy:Destroy()
		state.proxy = nil
	end

	state.elapsedTime = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreBaseKeycaps(p)
	for k, hiddenBaseKeycap in p.hiddenBaseKeycaps do
		k.LocalTransparencyModifier = hiddenBaseKeycap
	end

	table.clear(p.hiddenBaseKeycaps)
end

local function hideUnderlyingKeycap(p)
	for k, hiddenBaseKeycap in p.hiddenBaseKeycaps do
		local attribute = k:GetAttribute(positionAttributeName)

		if k.Parent == nil or typeof(attribute) ~= "Vector3" or (attribute - p.keycap.Position).Magnitude > 0.1 then
			k.LocalTransparencyModifier = hiddenBaseKeycap
			p.hiddenBaseKeycaps[k] = nil
		else
			k.LocalTransparencyModifier = 1
		end
	end

	local keycaps = Workspace:FindFirstChild("Keycaps")

	if keycaps == nil then
		return
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { keycaps }
	local v12 = p.keycap.Size + createVector(0.2, 4, 0.2)

	for _, v13 in Workspace:GetPartBoundsInBox(p.keycap.CFrame, v12, overlapParams) do
		local attribute = v13:GetAttribute(positionAttributeName)

		if not (typeof(attribute) == "Vector3" and (attribute - p.keycap.Position).Magnitude <= 0.1) then
			continue
		end

		if p.hiddenBaseKeycaps[v13] == nil then
			p.hiddenBaseKeycaps[v13] = v13.LocalTransparencyModifier
		end

		v13.LocalTransparencyModifier = 1
	end
end

local function createProxy(state)
	if state.proxy ~= nil and state.proxy.Parent ~= nil then
		return state.proxy
	end

	if state.keycap.Parent == nil or parent == nil then
		return nil
	end

	local clone = state.keycap:Clone()
	CollectionService:RemoveTag(clone, easterEggTag)
	clone.Name = "EasterEggKeycapVisual"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.CFrame = state.keycap.CFrame
	clone.Parent = parent
	state.originalTransparency = state.keycap.LocalTransparencyModifier
	state.keycap.LocalTransparencyModifier = 1

	for _, part in state.keycap:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		state.originalDescendantTransparency[part] = part.LocalTransparencyModifier
		part.LocalTransparencyModifier = 1
	end

	state.proxy = clone
	return clone
end

local function stopDeliveredEvent(sessionId: string, lastKeycap)
	local v12 = v4[sessionId]

	if v12 == nil then
		return
	end

	if v12.stopping or v12.stopped and not v12.stopPending then
		finishDeliveredRemoval(sessionId, v12)
		return
	end

	v12.stopped = true

	if v12.starting then
		v12.stopPending = true
		return
	end

	local v13 = lastKeycap or v12.lastKeycap

	if v13 == nil then
		v12.stopFailed = true
		v12.pendingReplayCycle = nil
		finishDeliveredRemoval(sessionId, v12)
	else
		if v12.sessionStarted and not v12.sessionStopped then
			v12.sessionStopped = true
			local stopSessionClient

			if v12.mode == "split" then
				stopSessionClient = v12.api.stopSessionClient
			end

			if stopSessionClient ~= nil then
				xpcall(
					stopSessionClient,
					reportCallbackError,
					Players.LocalPlayer,
					v13,
					getClientContext(sessionId, v12.eventName)
				)
			end
		end

		if v12.stopPending or v12.started then
			v12.stopPending = false

			if not v12.started then
				return
			end

			v12.stopping = true
			local clientContext = getClientContext(sessionId, v12.eventName) -- equivalent call inferred; original call site unknown
			local v14

			if v12.mode == "split" then
				local api = v12.api
				v14 = xpcall(function()
					api.stopClient(Players.LocalPlayer, v13, clientContext)
				end, reportCallbackError)
			else
				local api = v12.api
				v14 = xpcall(function()
					api.stop(Players.LocalPlayer, v13, clientContext)
				end, reportCallbackError)
			end

			v12.stopping = false
			v12.stopFailed = not v14
			local pendingReplayCycle = v12.pendingReplayCycle

			if pendingReplayCycle == nil or not v14 then
				if not v14 then
					v12.pendingReplayCycle = nil
				end
			else
				fn(sessionId, pendingReplayCycle)
			end

			finishDeliveredRemoval(sessionId, v12)
		else
			local pendingReplayCycle = v12.pendingReplayCycle

			if pendingReplayCycle ~= nil then
				fn(sessionId, pendingReplayCycle)
			end

			finishDeliveredRemoval(sessionId, v12)
		end
	end
end

fn = function(p: string, p2: number)
	v9[p] = p2
	v5[p] = 0
	v6[p] = nil
	v7[p] = nil
	v8[p] = nil
	local v12 = v3[p]

	if v12 ~= nil then
		cleanupProxy(v12)
		v12.progress = 0
	end

	local v13 = v4[p]

	if v13 == nil then
		for _, v15 in CollectionService:GetTagged(clientModuleTag) do
			local attribute = v15:GetAttribute(sessionIdAttribute)

			if typeof(attribute) ~= "string" or attribute == "" then
				attribute = nil
			end

			if attribute ~= p then
				continue
			end

			fn3(v15)
			break
		end
	else
		if v13.removePending then
			return
		end

		v13.completed = false
		v13.started = false
		v13.starting = false
		v13.stopped = false
		v13.stopping = false
		v13.stopFailed = false
		v13.stopPending = false
		v13.removePending = false
		v13.pendingReplayCycle = nil
	end

	updateSessionAssets(p)
	fn2(p, p2)
end

local function getQueuedCycleMessages(sessionId: string, cycle: number)
	local v12 = v10[sessionId]

	if v12 == nil then
		v12 = {}
		v10[sessionId] = v12
	end

	local v13 = v12[cycle]

	if v13 == nil then
		v13 = {}
		v12[cycle] = v13
	end

	return v13
end

local function tryStartDeliveredEvent(sessionId: string)
	local v12 = v4[sessionId]
	local v13 = v3[sessionId]
	local lastKeycap

	if v13 == nil then
		if v12 == nil then
			lastKeycap = nil
		else
			lastKeycap = v12.lastKeycap
		end
	else
		lastKeycap = v13.keycap
	end

	if v12 == nil or lastKeycap == nil or not v12.completed or v12.started or v12.stopped or v7[sessionId] then
		return
	end

	v12.started = true
	v12.starting = true
	v12.lastKeycap = lastKeycap
	local clientContext = getClientContext(sessionId, v12.eventName) -- equivalent call inferred; original call site unknown

	if v12.mode == "split" then
		local api = v12.api
		xpcall(function()
			api.startClient(Players.LocalPlayer, lastKeycap, clientContext)
		end, reportCallbackError)
	else
		local api = v12.api
		xpcall(function()
			api.start(Players.LocalPlayer, lastKeycap, clientContext)
		end, reportCallbackError)
	end

	v12.starting = false

	if v12.stopPending then
		stopDeliveredEvent(sessionId, lastKeycap)
	end
end

local function tryStartDeliveredSession(attribute: string)
	local v12 = v4[attribute]
	local v13 = v3[attribute]

	if v12 == nil or v13 == nil or v12.sessionStarted or v12.stopped then
		return
	end

	v12.sessionStarted = true
	v12.lastKeycap = v13.keycap
	local startSessionClient

	if v12.mode == "split" then
		startSessionClient = v12.api.startSessionClient
	end

	if startSessionClient ~= nil then
		xpcall(
			startSessionClient,
			reportCallbackError,
			Players.LocalPlayer,
			v13.keycap,
			getClientContext(attribute, v12.eventName)
		)
	end
end

local function untrackKeycap(instance)
	local attribute = instance:GetAttribute(sessionIdAttribute)

	if typeof(attribute) ~= "string" or attribute == "" then
		attribute = nil
	end

	if attribute == nil then
		return
	end

	local v12 = v3[attribute]

	if v12 == nil or v12.keycap ~= instance then
		return
	end

	cleanupProxy(v12)
	restoreBaseKeycaps(v12) -- equivalent call inferred; original call site unknown
	v3[attribute] = nil
end

local function trackKeycap(part)
	if not (part:IsA("BasePart") and part:IsDescendantOf(Workspace)) then
		return
	end

	local attribute = part:GetAttribute(sessionIdAttribute)

	if typeof(attribute) ~= "string" or attribute == "" then
		attribute = nil
	end

	if attribute == nil then
		return
	end

	local v12 = v3[attribute]

	if v12 ~= nil and v12.keycap == part then
		return
	end

	if v12 ~= nil then
		cleanupProxy(v12)
		restoreBaseKeycaps(v12) -- equivalent call inferred; original call site unknown
	end

	count += 1
	local v13 = v3
	local v14 = {
		keycap = part,
		generation = count,
		proxy = nil,
		originalTransparency = part.LocalTransparencyModifier,
		originalDescendantTransparency = {},
		progress = v5[attribute] or 0,
		elapsedTime = 0,
		seed = 0,
		hiddenBaseKeycaps = 0
	}
	local v15 = 0

	for i = 1, #attribute do
		v15 = (v15 * 31 + string.byte(attribute, i)) % 10000
	end

	v14.seed = v15 / 97
	v14.hiddenBaseKeycaps = {}
	v13[attribute] = v14
	local v16 = v4[attribute]

	if v16 ~= nil and not v16.stopped then
		v16.lastKeycap = part
	end

	tryStartDeliveredSession(attribute)
	tryStartDeliveredEvent(attribute)
end

local function validateDeliveredApi(result, p: string)
	if p == "split" then
		if typeof(result.startClient) == "function" and typeof(result.stopClient) == "function" and (result.startSessionClient == nil or typeof(result.startSessionClient) == "function") and (result.stopSessionClient == nil or typeof(result.stopSessionClient) == "function") and (result.updateProgressClient == nil or typeof(result.updateProgressClient) == "function") then
			return result.animateTriggerClient == nil or typeof(result.animateTriggerClient) == "function"
		else
			return false
		end
	else
		return typeof(result.Active) == "boolean" and typeof(result.start) == "function" and typeof(result.stop) == "function" and (result.animateTrigger == nil or typeof(result.animateTrigger) == "function")
	end
end

local function removeDeliveredModule(instance)
	local attribute = instance:GetAttribute(sessionIdAttribute)

	if typeof(attribute) ~= "string" or attribute == "" then
		attribute = nil
	end

	if attribute == nil then
		return
	end

	local v12 = v4[attribute]

	if v12 == nil or v12.moduleScript ~= instance then
		return
	end

	v12.removePending = true
	v12.pendingReplayCycle = nil
	local v13 = v3[attribute]
	local v15

	if v13 ~= nil then
		v15 = v13.keycap
	end

	stopDeliveredEvent(attribute, v15)
	finishDeliveredRemoval(attribute, v12)
end

fn3 = function(moduleScript)
	if not moduleScript:IsA("ModuleScript") then
		return
	end

	local attribute = moduleScript:GetAttribute(sessionIdAttribute)

	if typeof(attribute) ~= "string" or attribute == "" then
		attribute = nil
	end

	local attribute2 = moduleScript:GetAttribute(eventNameAttribute)
	local attribute3 = moduleScript:GetAttribute(eventModeAttribute)

	if attribute == nil or typeof(attribute2) ~= "string" or attribute3 ~= "split" and attribute3 ~= "shared" then
		warn("[EasterEggKeycaps] Rejected malformed delivered event module")
		return
	end

	if v4[attribute] ~= nil or v7[attribute] then
		return
	end

	local success, result = pcall(require, moduleScript)

	if not success or typeof(result) ~= "table" then
		warn((`[EasterEggKeycaps] Failed to load delivered module {moduleScript.Name}: {tostring(result)}`))
		return
	end

	local mode = attribute3 == "split" and "split" or "shared"

	if not validateDeliveredApi(result, mode) then
		warn((`[EasterEggKeycaps] Delivered module {moduleScript.Name} violates its {mode} contract`))
		return
	end

	local v13 = v4
	local v14 = {
		moduleScript = moduleScript,
		api = result,
		mode = mode,
		eventName = attribute2,
		completed = v6[attribute] == true,
		started = false,
		starting = false,
		stopped = false,
		stopping = false,
		stopFailed = false,
		stopPending = false,
		removePending = false,
		pendingReplayCycle = nil,
		lastKeycap = 0,
		sessionStarted = false,
		sessionStopped = false
	}
	local lastKeycap

	if v3[attribute] ~= nil then
		lastKeycap = v3[attribute].keycap
	end

	v14.lastKeycap = lastKeycap
	v13[attribute] = v14
	tryStartDeliveredSession(attribute)
	tryStartDeliveredEvent(attribute)
end

local function fn4(progress)
	local v12 = v9[progress.sessionId]

	if v12 == nil then
		v9[progress.sessionId] = progress.cycle
	elseif v12 ~= progress.cycle then
		if v12 < progress.cycle then
			local queuedCycleMessages = getQueuedCycleMessages(progress.sessionId, progress.cycle)
			queuedCycleMessages.progress = progress
		end

		return
	end

	if v7[progress.sessionId] then
		return
	end

	local v13 = v3[progress.sessionId]
	v5[progress.sessionId] = math.clamp(progress.progress, 0, 1)
	local v14 = v4[progress.sessionId]

	if v14 ~= nil and v14.mode == "split" then
		local updateProgressClient = v14.api.updateProgressClient
		local lastKeycap

		if v13 == nil then
			lastKeycap = v14.lastKeycap
		else
			lastKeycap = v13.keycap
		end

		if updateProgressClient ~= nil and lastKeycap ~= nil then
			xpcall(
				updateProgressClient,
				reportCallbackError,
				Players.LocalPlayer,
				lastKeycap,
				math.clamp(progress.progress, 0, 1),
				{
					runtime = "client",
					sessionId = progress.sessionId,
					eventName = v14.eventName
				}
			)
		end
	end

	if v13 == nil then
		return
	end

	v13.progress = math.clamp(progress.progress, 0, 1)

	if v13.progress <= 0 then
		cleanupProxy(v13)
	end
end

local function fn5(completed)
	local v12 = v9[completed.sessionId]

	if v12 == nil then
		v9[completed.sessionId] = completed.cycle
	elseif v12 ~= completed.cycle then
		if v12 < completed.cycle then
			local queuedCycleMessages = getQueuedCycleMessages(completed.sessionId, completed.cycle)
			queuedCycleMessages.completed = completed
		end

		return
	end

	if v7[completed.sessionId] then
		return
	end

	v6[completed.sessionId] = true
	v5[completed.sessionId] = 1
	local v13 = v4[completed.sessionId]

	if v13 ~= nil then
		v13.completed = true
		tryStartDeliveredEvent(completed.sessionId)
	end

	local v14 = v3[completed.sessionId]

	if v14 ~= nil then
		v14.progress = 1
	end

	updateSessionAssets(completed.sessionId)
end

local function fn6(stop)
	local v12 = v9[stop.sessionId]

	if v12 == nil then
		v9[stop.sessionId] = stop.cycle
	elseif v12 ~= stop.cycle then
		if v12 < stop.cycle then
			local queuedCycleMessages = getQueuedCycleMessages(stop.sessionId, stop.cycle)
			queuedCycleMessages.stop = stop
		end

		return
	end

	v7[stop.sessionId] = true
	v8[stop.sessionId] = os.clock()
	v5[stop.sessionId] = 0
	local v13 = v3[stop.sessionId]
	local sessionId = stop.sessionId
	local v15

	if v13 ~= nil then
		v15 = v13.keycap
	end

	stopDeliveredEvent(sessionId, v15)

	if v13 ~= nil then
		cleanupProxy(v13)
		v13.progress = 0
	end

	updateSessionAssets(stop.sessionId)
end

local function fn7(replayReady)
	local v12 = v9[replayReady.sessionId] or 0

	if replayReady.cycle <= v12 then
		return
	end

	local v13 = v4[replayReady.sessionId]

	if v13 ~= nil and (v13.stopFailed or v13.removePending) then
		return
	end

	if v12 > 0 then
		local cycle = replayReady.cycle

		if v12 + 1 < cycle then
			local queuedCycleMessages = getQueuedCycleMessages(replayReady.sessionId, replayReady.cycle)
			queuedCycleMessages.replayReady = replayReady
			return
		end
	end

	if v13 ~= nil and v13.pendingReplayCycle ~= nil and replayReady.cycle > v13.pendingReplayCycle then
		local queuedCycleMessages_2 = getQueuedCycleMessages(replayReady.sessionId, replayReady.cycle)
		queuedCycleMessages_2.replayReady = replayReady
		return
	end

	if v13 == nil then
		fn(replayReady.sessionId, replayReady.cycle)
		return
	end

	v13.pendingReplayCycle = replayReady.cycle

	if not v13.starting and not v13.stopping and v13.stopped then
		fn(replayReady.sessionId, replayReady.cycle)
		return
	end

	local v14 = v3[replayReady.sessionId]
	local sessionId = replayReady.sessionId
	local v16

	if v14 ~= nil then
		v16 = v14.keycap
	end

	stopDeliveredEvent(sessionId, v16)
end

fn2 = function(p: string, p2: number)
	local v12 = v10[p]

	if v12 == nil then
		return
	end

	local v13 = v12[p2]

	if v13 ~= nil then
		v12[p2] = nil

		if v13.progress ~= nil then
			fn4(v13.progress)
		end

		if v13.completed ~= nil then
			fn5(v13.completed)
		end

		if v13.stop ~= nil then
			fn6(v13.stop)
		end
	end

	local v14 = v12[(v9[p] or p2) + 1]

	if v14 ~= nil and v14.replayReady ~= nil then
		local replayReady = v14.replayReady
		v14.replayReady = nil
		fn7(replayReady)
	end

	if next(v12) == nil then
		v10[p] = nil
	end
end

function EasterEggKeycaps.start()
	assert(Players.LocalPlayer ~= nil, "EasterEggKeycaps client host requires a local player")

	if flag then
		return
	end

	flag = true
	local folder = Instance.new("Folder")
	folder.Name = "EasterEggKeycapVisuals"
	folder.Parent = Workspace
	parent = folder

	for _, v12 in CollectionService:GetTagged(easterEggTag) do
		trackKeycap(v12)
	end

	for _, v12 in CollectionService:GetTagged(clientModuleTag) do
		fn3(v12)
	end

	for _, v12 in CollectionService:GetTagged(sessionAssetTag) do
		trackSessionAsset(v12)
	end

	table.insert(connections, CollectionService:GetInstanceAddedSignal(easterEggTag):Connect(trackKeycap))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(easterEggTag):Connect(untrackKeycap))
	table.insert(connections, CollectionService:GetInstanceAddedSignal(clientModuleTag):Connect(fn3))
	table.insert(
		connections,
		CollectionService:GetInstanceRemovedSignal(clientModuleTag):Connect(removeDeliveredModule)
	)
	table.insert(connections, CollectionService:GetInstanceAddedSignal(sessionAssetTag):Connect(trackSessionAsset))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(sessionAssetTag):Connect(untrackSessionAsset))
	table.insert(connections2, EasterEggKeycaps.remotes.Progress:connect(fn4))
	table.insert(connections2, EasterEggKeycaps.remotes.Completed:connect(fn5))
	table.insert(connections2, EasterEggKeycaps.remotes.Stop:connect(fn6))
	table.insert(connections2, EasterEggKeycaps.remotes.ReplayReady:connect(fn7))
end

function EasterEggKeycaps.update(p: number)
	if not flag then
		return
	end

	for k, v12 in v3 do
		if v12.keycap.Parent == nil then
			local keycap = v12.keycap
			local attribute = keycap:GetAttribute(sessionIdAttribute)

			if typeof(attribute) ~= "string" or attribute == "" then
				attribute = nil
			end

			if attribute ~= nil then
				local v13 = v3[attribute]

				if v13 ~= nil and v13.keycap == keycap then
					cleanupProxy(v13)
					restoreBaseKeycaps(v13) -- equivalent call inferred; original call site unknown
					v3[attribute] = nil
				end
			end
		else
			hideUnderlyingKeycap(v12)

			if not (v12.progress <= 0) then
				local proxy = createProxy(v12)

				if proxy ~= nil then
					v12.elapsedTime += math.max(p, 0)
					local cFrame = v12.keycap.CFrame
					proxy.CFrame = cFrame
					local v13 = v4[k]
					local animateTrigger = nil
					local eventName = v13 == nil and "" or v13.eventName

					if v13 == nil or v13.mode ~= "split" then
						if v13 ~= nil then
							animateTrigger = v13.api.animateTrigger
						end
					else
						animateTrigger = v13.api.animateTriggerClient
					end

					if animateTrigger == nil then
						DefaultTriggerAnimation.apply(proxy, cFrame, v12.progress, v12.elapsedTime, v12.seed, v)
					else
						local generation = v12.generation
						xpcall(
							animateTrigger,
							reportCallbackError,
							Players.LocalPlayer,
							v12.keycap,
							proxy,
							math.clamp(v12.progress, 0, 1),
							p,
							{
								sessionId = k,
								eventName = eventName
							}
						)

						if v3[k] ~= v12 or v12.generation ~= generation then
							cleanupProxy(v12)
						end
					end
				end
			end
		end
	end

	local now2 = os.clock()

	for k, v12 in v8 do
		if not (now2 - v12 >= 30 and v3[k] == nil and v4[k] == nil) then
			continue
		end

		v5[k] = nil
		v6[k] = nil
		v7[k] = nil
		v8[k] = nil
		v9[k] = nil
		v10[k] = nil
	end
end

function EasterEggKeycaps.cleanup()
	if not flag then
		return
	end

	flag = false

	for _, v12 in v3 do
		cleanupProxy(v12)
		restoreBaseKeycaps(v12) -- equivalent call inferred; original call site unknown
	end

	for k in v4 do
		local v12 = v4[k]

		if v12 == nil then
			continue
		end

		v12.removePending = true
		v12.pendingReplayCycle = nil
		local v13 = v3[k]
		local v15

		if v13 ~= nil then
			v15 = v13.keycap
		end

		stopDeliveredEvent(k, v15)
		finishDeliveredRemoval(k, v12)
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	for _, v12 in v11 do
		if v12.descendantAddedConnection ~= nil then
			v12.descendantAddedConnection:Disconnect()
		end

		for k, v13 in v12.originalTransparency do
			if k.Parent ~= nil then
				writeLocalTransparencyModifier(k, v13)
			end
		end
	end

	for _, connection in connections2 do
		connection()
	end

	if parent ~= nil then
		parent:Destroy()
		parent = nil
	end

	table.clear(v3)
	table.clear(v5)
	table.clear(v6)
	table.clear(v7)
	table.clear(v8)
	table.clear(v9)
	table.clear(v10)
	table.clear(v11)
	table.clear(connections)
	table.clear(connections2)
end

function EasterEggKeycaps.isRunning()
	return flag
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			now = os.clock()
			EasterEggKeycaps.start()
		end
	end,
	OnRender = function()
		if RunService:IsClient() then
			local now2 = os.clock()
			EasterEggKeycaps.update((math.min(now2 - now, 0.1)))
			now = now2
		end
	end
})
return EasterEggKeycaps