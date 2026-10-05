local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local PlayerReady = require(ReplicatedStorage._FRAMEWORK.Features.PlayerReady)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local GlobalStateManager = require(ReplicatedStorage._FRAMEWORK.Features.GlobalStateManager)
local remo = require(ReplicatedStorage.Packages.remo)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
require(ReplicatedStorage.Utilities.Promise)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local LegacyAdapter = require(script.LegacyAdapter)
require(script.ModuleDriverTypes)
local Config = require(ReplicatedStorage.Config)
local AdminAbuseUtils = require(script.AdminAbuseUtils)
local AdminAbuseEvent = {
	logger = LoggerManager.createLogger(script.Name, {
		feature = script.Name
	}),
	remotes = remo.createRemotes({
		Activated = remo.remote(),
		Deactivated = remo.remote(),
		Message = remo.remote(),
		ClientEvent = remo.remote(),
		TimelineSeeked = remo.remote()
	})
}
local v = { "main", "event", "overlay" }
local v2 = {}
local v3 = {}
local dataByChildName = {}
local aAFw_AutoPreloadIDsByChildName = {}
local v4 = {}
local v5 = {}
local v6 = nil
local flag = false

local function getActiveSession(p: string, p2: number?)
	for _, v7 in v2 do
		if v7.state.name == p and (p2 == nil or v7.state.startedAt == p2) then
			return v7
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function observeGlobalMutation(p: string, object)
	object:catch(function(p2)
		AdminAbuseEvent.logger:warn((`Failed to {p}: {tostring(p2)}`))
	end)
end

local function readAutoPreloadIDs(childName: string)
	local child = script.Modules:FindFirstChild(childName)
	local config = child and child:FindFirstChild("Config")

	if config then
		local module = require(config)

		if module.AAFw_AutoPreloadEnabled then
			return module.AAFw_AutoPreloadIDs
		end
	end

	return nil
end

local function preloadRequestedAssets(p: string, p2)
	local music = p2.music
	local animations = p2.animations
	local v7 = music and #music or 0
	local v8 = animations and #animations or 0
	print(string.format("[PRELOAD] %s: %d music, %d animations", p, v7, v8))

	if music then
		for _, v9 in music do
			if not AdminAbuseUtils.Musics.preload(v9) then
				print(string.format("[PRELOAD] %s Musics.preload returned nil for %s", p, (tostring(v9))))
			end
		end
	end

	if animations then
		AdminAbuseUtils.Animations.preloadAsync(animations)
	end

	print(string.format("[PRELOAD] %s finished", p))
end

local function makeContext(state, flag2: boolean)
	local state2 = state.state
	local elapsedSeconds = math.max(0, Workspace:GetServerTimeNow() - state2.startedAt + state.timelineOffsetSeconds)
	local context = state.context

	if context then
		context.elapsedSeconds = elapsedSeconds
		return context
	end

	local context2 = {
		name = state2.name,
		slot = state2.slot,
		startedAt = state2.startedAt,
		durationSeconds = state2.durationSeconds,
		elapsedSeconds = elapsedSeconds,
		isCatchUp = flag2,
		janitor = state.janitor,
		FireServerEventToPlayer = function(p, p2)
			AdminAbuseEvent.remotes.Message:fire(p, state2.name, state2.startedAt, p2)
		end,
		FireServerEventToAll = function(p)
			AdminAbuseEvent.remotes.Message:fireAll(state2.name, state2.startedAt, p)
		end,
		FireClientEvent = function(p)
			AdminAbuseEvent.remotes.ClientEvent:fire(state2.name, state2.startedAt, p)
		end
	}
	state.context = context2
	return context2
end

local function tracebackError(p)
	return debug.traceback(tostring(p), 2)
end

local function runCallback(p: string, p2: string, callback, ...)
	if callback == nil then
		return true, nil
	end

	local traceback = nil
	local v7 = xpcall(callback, function(p3)
		traceback = debug.traceback(tostring(p3), 2)
	end, ...)

	if not v7 then
		AdminAbuseEvent.logger:warn((`'{p}' {p2} failed: {traceback or "unknown error"}`))
	end

	return v7, traceback
end

local function resolveDuration(p: number?, p2: number?, p3: number?)
	local v7 = p or p2

	if v7 == nil then
		return nil, nil
	end

	if v7 ~= v7 or v7 == 1e999 or v7 == -1e999 or v7 <= 0 then
		return nil, "durationSeconds must be a finite number greater than zero"
	end

	if p3 == nil then
		return v7, nil
	end

	if p3 ~= p3 or p3 == 1e999 or p3 <= 0 then
		return nil, "maxDurationSeconds must be a finite number greater than zero"
	end

	v7 = math.min(v7, p3)
	return v7, nil
end

local function hasExpired(p)
	return p.expiresAt ~= nil and os.time() >= p.expiresAt
end

local function checkDefinitionCanStart(p: string)
	local v7 = dataByChildName[p]
	local canStart

	if v7 then
		canStart = v7.canStart
	end

	if canStart == nil then
		return true, nil
	end

	local v8, v9 = canStart()

	if v8 then
		return true, nil
	end

	return false, v9 or `Admin Abuse module '{p}' refused to start`
end

local function createGlobalState(name: string, p2: number?)
	local v7 = v4[name]

	if v7 == nil then
		return nil, (`Unknown Admin Abuse module '{name}'`)
	end

	local v8 = dataByChildName[name]
	local canStart

	if v8 then
		canStart = v8.canStart
	end

	local v9, v10

	if canStart == nil then
		v9 = true
	else
		local v11
		v11, v10 = canStart()

		if v11 then
			v9 = true
			v10 = nil
		else
			v9 = false

			if not v10 then
				v10 = `Admin Abuse module '{name}' refused to start`
			end
		end
	end

	if not v9 then
		return nil, v10
	end

	local info = v7.info
	local durationSeconds

	if v7.usesDuration then
		local defaultDurationSeconds = info.defaultDurationSeconds
		local maxDurationSeconds = info.maxDurationSeconds
		durationSeconds = p2 or defaultDurationSeconds

		if durationSeconds == nil or durationSeconds ~= durationSeconds or durationSeconds == 1e999 or durationSeconds == -1e999 or durationSeconds <= 0 then
			durationSeconds = nil
		elseif maxDurationSeconds ~= nil then
			if maxDurationSeconds == maxDurationSeconds and maxDurationSeconds ~= 1e999 and not (maxDurationSeconds <= 0) then
				durationSeconds = math.min(durationSeconds, maxDurationSeconds)
			else
				durationSeconds = nil
			end
		end
	end

	local now = os.time()
	local v12 = {
		kind = "active",
		id = HttpService:GenerateGUID(false),
		name = name,
		slot = info.slot,
		startedAt = now,
		durationSeconds = durationSeconds,
		expiresAt = 0,
		runtimeData = nil
	}
	local expiresAt

	if durationSeconds then
		expiresAt = now + durationSeconds
	end

	v12.expiresAt = expiresAt
	local v14 = v7.prepare and v7.prepare({
		id = v12.id,
		name = v12.name,
		slot = v12.slot,
		startedAt = v12.startedAt,
		durationSeconds = v12.durationSeconds,
		isCatchUp = false,
		runtimeData = nil
	})

	if v14 then
		v12.runtimeData = v14.runtimeData
		v12.expiresAt = v14.expiresAt or v12.expiresAt
	end

	return v12, nil
end

local function stopLocalSession(state, p)
	local state2 = state.state
	local slot = state2.slot

	if v2[slot] ~= state or state.phase ~= "active" then
		return false
	end

	state.phase = "stopping"
	makeContext(state, false)
	runCallback(state2.name, "onStop", state.callbacks.onStop, p)
	runCallback(state2.name, "cleanup", function()
		state.janitor:Cleanup()
	end)

	if RunService:IsServer() then
		AdminAbuseEvent.remotes.Deactivated:fireAll(state2.name, p)
	end

	v2[slot] = nil
	return true
end

local function skipsAdminAbuseMainSlot(p)
	return p == "main" and Config.WORLD == "TradingHub"
end

local function startLocalSession(name: string, p2, durationSeconds: number?, startedAt: number, flag2: boolean, globalId: string?)
	local slot = p2.slot or "main"
	local v7

	if slot == "main" then
		v7 = Config.WORLD == "TradingHub"
	else
		v7 = false
	end

	if v7 then
		return false, "Admin Abuse is skipped on Trading Hub"
	end

	local v8 = v2[slot]

	if v8 then
		if v8.phase ~= "active" then
			return false, (`Admin Abuse module '{v8.state.name}' is currently {v8.phase}`)
		end

		if v8.state.name == name and v8.state.startedAt == startedAt and v8.globalId == globalId then
			return true, nil
		else
			stopLocalSession(v8, "replaced")
		end
	end

	local v9 = {
		state = {
			name = name,
			source = "framework",
			slot = slot,
			startedAt = startedAt,
			durationSeconds = durationSeconds,
			isGlobal = globalId ~= nil
		},
		janitor = Janitor.new(),
		context = nil,
		callbacks = {},
		lastUpdateClock = os.clock(),
		globalId = globalId,
		timelineOffsetSeconds = 0,
		phase = "starting"
	}
	v2[slot] = v9
	local context = makeContext(v9, flag2)
	local v10, callbacks = xpcall(p2.load, tracebackError, context)

	if v10 and type(callbacks) == "table" then
		v9.callbacks = callbacks
		local v12, v13 = runCallback(name, "onStart", callbacks.onStart)

		if v12 then
			v9.phase = "active"

			if RunService:IsServer() then
				AdminAbuseEvent.remotes.Activated:fireAll(name, startedAt, durationSeconds or -1, flag2)
			elseif flag2 and Players.LocalPlayer then
				runCallback(name, "onPlayerAdded", callbacks.onPlayerAdded, Players.LocalPlayer)
			end

			return true, nil
		else
			v9.phase = "stopping"
			makeContext(v9, false)
			runCallback(name, "onStop", callbacks.onStop, "shutdown")
			runCallback(name, "cleanup", function()
				v9.janitor:Cleanup()
			end)
			v2[slot] = nil
			return false, v13
		end
	else
		runCallback(name, "cleanup", function()
			v9.janitor:Cleanup()
		end)
		v2[slot] = nil
		local v12 = false

		if v10 then
			return false, "load must return a callback table"
		end

		return v12, (tostring(callbacks))
	end
end

local function applyClientActivation(name: string, startedAt: number, p3: number, flag2: boolean)
	local v7 = dataByChildName[name]

	if v7 == nil then
		return
	end

	local v8

	if (v7.slot or "main") == "main" then
		v8 = Config.WORLD == "TradingHub"
	else
		v8 = false
	end

	if v8 then
		return
	end

	if p3 == -1 then
		p3 = nil
	end

	local v9, v10 = startLocalSession(name, v7, p3, startedAt, flag2, nil)

	if not v9 then
		AdminAbuseEvent.logger:warn((`Failed to start '{name}' on the client: {v10 or "unknown error"}`))
	end
end

local function applyClientDeactivation(p: string, p2: string)
	local v7 = nil

	for _, v9 in v2 do
		if v9.state.name ~= p then
			continue
		end

		v7 = v9
		break
	end

	if v7 then
		stopLocalSession(v7, p2)
	end
end

local function applyClientMessage(p: string, p2: number, p3)
	local activeSession = getActiveSession(p, p2)

	if activeSession == nil then
		return
	end

	makeContext(activeSession, false)
	runCallback(p, "onServerEvent", activeSession.callbacks.onServerEvent, p3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSessionTimeline(p, p2: number)
	p.timelineOffsetSeconds = p2 - math.max(0, Workspace:GetServerTimeNow() - p.state.startedAt)
	makeContext(p, false)
end

local function applyClientTimelineSeek(p: string, p2: number, value: number)
	local activeSession = getActiveSession(p, p2)

	if activeSession == nil or activeSession.state.slot ~= "main" then
		return
	end

	local durationSeconds = activeSession.state.durationSeconds
	local v7

	if durationSeconds then
		v7 = math.clamp(value, 0, durationSeconds)
	else
		v7 = math.max(0, value)
	end

	setSessionTimeline(activeSession, v7) -- equivalent call inferred; original call site unknown
end

local function applyServerClientEvent(p, p2: string, p3: number, p4)
	local activeSession = getActiveSession(p2, p3)

	if activeSession == nil then
		return
	end

	makeContext(activeSession, false)
	runCallback(p2, "onClientEvent", activeSession.callbacks.onClientEvent, p, p4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeDriverActivation(data, flag2: boolean)
	return {
		id = data.id,
		name = data.name,
		slot = data.slot,
		startedAt = data.startedAt,
		durationSeconds = data.durationSeconds,
		isCatchUp = flag2,
		runtimeData = data.runtimeData
	}
end

local function stopGlobalStateLocally(data, p)
	if v5[data.slot] ~= data then
		return false
	end

	v5[data.slot] = nil

	if v3[data.slot] == data.id then
		v3[data.slot] = nil
		return true
	end

	local v7 = v4[data.name]

	if v7 == nil then
		return false
	end

	local v8, v9 = v7.stop(makeDriverActivation(data, false), p)

	if not v8 then
		AdminAbuseEvent.logger:warn((`Failed to stop module '{data.name}': {v9 or "unknown error"}`))
	end

	return v8
end

local function startGlobalStateLocally(data, flag2: boolean)
	local v7 = v4[data.name]

	if v7 == nil or v7.info.slot ~= data.slot then
		return false, (`Admin Abuse module '{data.name}' is unavailable in slot '{data.slot}'`)
	end

	local v8 = v5[data.slot]

	if v8 then
		if v8.id == data.id then
			return true, nil
		else
			stopGlobalStateLocally(v8, "replaced")
		end
	end

	local v9 = v2[data.slot]

	if v9 then
		if v9.phase ~= "active" then
			return false, (`Admin Abuse module '{v9.state.name}' is currently {v9.phase}`)
		end

		stopLocalSession(v9, "replaced")
	end

	local v10, v11 = v7.start(makeDriverActivation(data, flag2))

	if not v10 then
		return false, v11
	end

	v5[data.slot] = data
	return true, nil
end

local function applyGlobalState(data, flag2: boolean)
	local v7

	if data.slot == "main" then
		v7 = Config.WORLD == "TradingHub"
	else
		v7 = false
	end

	if v7 or v3[data.slot] == data.id then
		return
	end

	if v4[data.name] == nil then
		AdminAbuseEvent.logger:warn(`Ignored global module '{data.name}' for slot '{data.slot}': no local driver is registered ` .. `under that name on this server (JobId={game.JobId}). This server's deployed code may ` .. "predate that module's registration, or the name doesn't match its ModuleScript name.")
		return
	end

	v3[data.slot] = nil
	local v8, v9 = startGlobalStateLocally(data, flag2)

	if not v8 then
		AdminAbuseEvent.logger:warn((`Failed to apply global module '{data.name}': {v9 or "unknown error"}`))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGlobalId(p, p2: string?, reason)
	local v7 = v5[p]

	if v7 and (p2 == nil or v7.id == p2) then
		stopGlobalStateLocally(v7, reason)
	end
end

local function applyGlobalSnapshot(p)
	if type(p) ~= "table" then
		AdminAbuseEvent.logger:warn("Ignored malformed global state")
		return
	end

	local v7 = v6
	local clone = table.clone(p)
	v6 = clone

	for _, v8 in v do
		local v9 = clone[v8]

		if v9 == nil then
			local v10 = v5[v8]

			if v10 then
				stopGlobalStateLocally(v10, "manual")
			end
		elseif type(v9) == "table" then
			if v9.kind == "removed" then
				stopGlobalId(v8, v9.removedId, v9.reason) -- equivalent call inferred; original call site unknown

				if v9.removedId == nil then
					local v10 = v2[v8]

					if v10 then
						stopLocalSession(v10, v9.reason)
					end

					LegacyAdapter.stopSlotLocally(v8)
				end
			elseif v9.kind == "active" then
				local v10

				if v9.expiresAt == nil then
					v10 = false
				else
					v10 = os.time() >= v9.expiresAt
				end

				if v10 then
					stopGlobalId(v8, v9.id, "durationElapsed") -- equivalent call inferred; original call site unknown
				else
					applyGlobalState(v9, os.time() - v9.startedAt >= 30)
				end
			else
				local v10

				if v7 then
					v10 = v7[v8]
				end

				clone[v8] = v10
				AdminAbuseEvent.logger:warn((`Ignored malformed '{v8}' global record`))
			end
		else
			local v10

			if v7 then
				v10 = v7[v8]
			end

			clone[v8] = v10
			AdminAbuseEvent.logger:warn((`Ignored malformed '{v8}' global record`))
		end
	end
end

local function setGlobalRecord(slot, p)
	if not GlobalStateManager.isReadyToMutate("AdminAbuseEvent_State") then
		return false, "Admin Abuse global state is still loading"
	end

	local clone = table.clone(v6 or {})
	clone[slot] = p
	local success, result, v7 = pcall(function()
		return GlobalStateManager.setState("AdminAbuseEvent_State", clone)
	end)

	if not success then
		return false, (tostring(result))
	end

	observeGlobalMutation("broadcast global state", result) -- equivalent call inferred; original call site unknown
	observeGlobalMutation("persist global state", v7) -- equivalent call inferred; original call site unknown
	return true, nil
end

local v7 = false

local function handlePlayerAdded(localPlayer)
	if RunService:IsClient() and localPlayer == Players.LocalPlayer and not v7 then
		v7 = true
		local count = 0

		for _ in aAFw_AutoPreloadIDsByChildName do
			count += 1
		end

		print(string.format("[PRELOAD] join warmup for %d event(s)", count))

		for k, v8 in aAFw_AutoPreloadIDsByChildName do
			task.spawn(preloadRequestedAssets, k, v8)
		end
	end

	for _, v8 in v do
		local v9 = v2[v8]

		if not (v9 and v9.phase == "active") then
			continue
		end

		local state = v9.state

		if RunService:IsServer() then
			AdminAbuseEvent.remotes.Activated:fire(
				localPlayer,
				state.name,
				state.startedAt,
				state.durationSeconds or -1,
				true
			)
		end

		makeContext(v9, true)
		runCallback(state.name, "onPlayerAdded", v9.callbacks.onPlayerAdded, localPlayer)
	end
end

local function updateActiveSessions()
	if RunService:IsServer() then
		local v8

		if not flag then
			v8 = LegacyAdapter.getDrivers()
		end

		if v8 then
			flag = true

			for _, v9 in v8 do
				if v4[v9.info.name] == nil then
					v4[v9.info.name] = v9
				end
			end

			if v6 then
				applyGlobalSnapshot(v6)
			end
		end
	end

	local now = os.clock()

	for _, v8 in v do
		local v9 = v2[v8]

		if not (v9 and v9.phase == "active") then
			continue
		end

		local state = v9.state

		if state.durationSeconds and os.time() >= state.startedAt + state.durationSeconds then
			task.spawn(stopLocalSession, v9, "durationElapsed")
		else
			local v10 = math.max(0, now - v9.lastUpdateClock)
			v9.lastUpdateClock = now
			makeContext(v9, false)
			runCallback(state.name, "onUpdate", v9.callbacks.onUpdate, v10)
		end
	end
end

function AdminAbuseEvent.register(childName: string, data)
	assert(childName ~= "", "AdminAbuseEvent.register requires a non-empty name")
	assert(type(data.load) == "function", "AdminAbuseEvent.register requires a load callback")
	assert(
		data.slot == nil or data.slot == "main" or data.slot == "event" or data.slot == "overlay",
		"AdminAbuseEvent.register slot must be 'main', 'event', or 'overlay'"
	)
	assert(v4[childName] == nil, (`Admin Abuse event '{childName}' is already registered`))
	dataByChildName[childName] = data
	local child = script.Modules:FindFirstChild(childName)
	local config = child and child:FindFirstChild("Config")
	local aAFw_AutoPreloadIDs

	if config then
		local module = require(config)

		if module.AAFw_AutoPreloadEnabled then
			aAFw_AutoPreloadIDs = module.AAFw_AutoPreloadIDs
		end
	end

	if aAFw_AutoPreloadIDs then
		aAFw_AutoPreloadIDsByChildName[childName] = aAFw_AutoPreloadIDs
	end

	local slot = data.slot or "main"
	v4[childName] = {
		info = {
			name = childName,
			displayName = data.displayName or childName,
			source = "framework",
			slot = slot,
			hidden = data.hidden == true,
			needsDuration = data.needsDuration == true,
			defaultDurationSeconds = data.defaultDurationSeconds,
			maxDurationSeconds = data.maxDurationSeconds,
			loadError = nil
		},
		usesDuration = true,
		start = function(data2)
			local v9, v10 = startLocalSession(
				childName,
				data,
				data2.durationSeconds,
				data2.startedAt,
				data2.isCatchUp,
				data2.id
			)
			return v9, v10
		end,
		stop = function(p, p2)
			local v9 = v2[slot]

			if v9 and v9.globalId == p.id then
				stopLocalSession(v9, p2)
			end

			return true, nil
		end
	}
end

function AdminAbuseEvent.start(name: string, p2: number?)
	assert(RunService:IsServer(), "AdminAbuseEvent.start can only be called on the server")
	local v8 = dataByChildName[name]

	if v8 == nil then
		return LegacyAdapter.startLocally(name, p2)
	end

	local v9 = dataByChildName[name]
	local canStart

	if v9 then
		canStart = v9.canStart
	end

	local v10, v11

	if canStart == nil then
		v10 = true
	else
		local v12
		v12, v11 = canStart()

		if v12 then
			v10 = true
			v11 = nil
		else
			v10 = false

			if not v11 then
				v11 = `Admin Abuse module '{name}' refused to start`
			end
		end
	end

	if not v10 then
		return false, v11
	end

	local slot = v8.slot or "main"
	local v12 = v2[slot]

	if v12 then
		local v13 = false

		if v12.phase == "active" then
			return false, (`Admin Abuse slot '{slot}' is occupied by '{v12.state.name}'`)
		end

		return v13, (`Admin Abuse module '{v12.state.name}' is currently {v12.phase}`)
	else
		local v13 = v5[slot]
		local defaultDurationSeconds, maxDurationSeconds, v14, v15

		if v13 then
			local v16

			if v13.expiresAt == nil then
				v16 = false
			else
				v16 = os.time() >= v13.expiresAt
			end

			if v16 then
				stopGlobalStateLocally(v13, "durationElapsed")
				defaultDurationSeconds = v8.defaultDurationSeconds
				maxDurationSeconds = v8.maxDurationSeconds
				v14 = p2 or defaultDurationSeconds

				if v14 == nil then
					v14 = nil
				elseif v14 == v14 and v14 ~= 1e999 and v14 ~= -1e999 and not (v14 <= 0) then
					if maxDurationSeconds ~= nil then
						if maxDurationSeconds == maxDurationSeconds and maxDurationSeconds ~= 1e999 and not (maxDurationSeconds <= 0) then
							v14 = math.min(v14, maxDurationSeconds)
						else
							v15 = "maxDurationSeconds must be a finite number greater than zero"
							v14 = nil
						end
					end
				else
					v15 = "durationSeconds must be a finite number greater than zero"
					v14 = nil
				end

				if v15 then
					return false, v15
				end

				return startLocalSession(name, v8, v14, os.time(), false, nil)
			end
		end

		if v13 and v3[slot] ~= v13.id then
			return false, (`Admin Abuse slot '{slot}' is occupied by '{v13.name}'`)
		end

		defaultDurationSeconds = v8.defaultDurationSeconds
		maxDurationSeconds = v8.maxDurationSeconds
		v14 = p2 or defaultDurationSeconds

		if v14 == nil then
			v15 = nil
			v14 = nil
		elseif v14 == v14 and v14 ~= 1e999 and v14 ~= -1e999 and not (v14 <= 0) then
			if maxDurationSeconds == nil then
				v15 = nil
			elseif maxDurationSeconds == maxDurationSeconds and maxDurationSeconds ~= 1e999 and not (maxDurationSeconds <= 0) then
				v14 = math.min(v14, maxDurationSeconds)
				v15 = nil
			else
				v15 = "maxDurationSeconds must be a finite number greater than zero"
				v14 = nil
			end
		else
			v15 = "durationSeconds must be a finite number greater than zero"
			v14 = nil
		end

		if v15 then
			return false, v15
		end

		return startLocalSession(name, v8, v14, os.time(), false, nil)
	end
end

function AdminAbuseEvent.startGlobally(name2: string, p2: number?)
	assert(RunService:IsServer(), "AdminAbuseEvent.startGlobally can only be called on the server")

	if not GlobalStateManager.isReadyToMutate("AdminAbuseEvent_State") then
		return false, "Admin Abuse global state is still loading"
	end

	local globalState, v8 = createGlobalState(name2, p2)

	if globalState == nil then
		return false, v8
	end

	local slot = globalState.slot
	local v9 = v2[slot]

	if v9 and v9.phase ~= "active" then
		return false, (`Admin Abuse module '{v9.state.name}' is currently {v9.phase}`)
	end

	local v10 = v5[slot]
	local name

	if v9 then
		name = v9.state.name
	elseif v10 then
		local v11

		if v10.expiresAt == nil then
			v11 = false
		else
			v11 = os.time() >= v10.expiresAt
		end

		if not v11 then
			name = v10.name
		end
	end

	if name then
		return false, (`Admin Abuse slot '{slot}' is occupied by '{name}'`)
	end

	local v11 = (v6 or {})[slot]

	if not v11 or v11.kind ~= "active" then
		return setGlobalRecord(slot, globalState)
	end

	local v12

	if v11.expiresAt == nil then
		v12 = false
	else
		v12 = os.time() >= v11.expiresAt
	end

	if not v12 then
		return false, (`Admin Abuse global slot '{slot}' is occupied by '{v11.name}'`)
	end

	return setGlobalRecord(slot, globalState)
end

function AdminAbuseEvent.stopModule(p: string, value)
	assert(RunService:IsServer(), "AdminAbuseEvent.stopModule can only be called on the server")
	local v8 = nil

	for _, v10 in v2 do
		if v10.state.name ~= p then
			continue
		end

		v8 = v10
		break
	end

	if v8 and v8.phase ~= "active" then
		return false, (`Admin Abuse module '{p}' is currently {v8.phase}`)
	end

	if v8 and v8.globalId == nil then
		return stopLocalSession(v8, value or "manual"), nil
	end

	local v10 = nil

	if v6 then
		for _, v12 in v6 do
			if not (v12.kind == "active" and v12.name == p) then
				continue
			end

			v10 = v12
			break
		end
	end

	if v10 == nil then
		return LegacyAdapter.stopLocally(p)
	end

	return setGlobalRecord(v10.slot, {
		kind = "removed",
		removedId = v10.id,
		reason = value or "manual"
	})
end

function AdminAbuseEvent.stopAllGlobally(value)
	assert(RunService:IsServer(), "AdminAbuseEvent.stopAllGlobally can only be called on the server")

	if not GlobalStateManager.isReadyToMutate("AdminAbuseEvent_State") then
		return false, "Admin Abuse global state is still loading"
	end

	local reason = value or "manual"
	local v9 = {}

	for _, v10 in v do
		v9[v10] = {
			kind = "removed",
			removedId = nil,
			reason = reason
		}
	end

	local success, result, v10 = pcall(function()
		return GlobalStateManager.setState("AdminAbuseEvent_State", v9)
	end)

	if not success then
		return false, (tostring(result))
	end

	observeGlobalMutation("broadcast emergency stop", result) -- equivalent call inferred; original call site unknown
	observeGlobalMutation("persist emergency stop", v10) -- equivalent call inferred; original call site unknown
	return true, nil
end

function AdminAbuseEvent.stopModuleLocally(p: string, value)
	assert(RunService:IsServer(), "AdminAbuseEvent.stopModuleLocally can only be called on the server")
	local v8 = nil

	for _, v10 in v2 do
		if v10.state.name ~= p then
			continue
		end

		v8 = v10
		break
	end

	if v8 == nil then
		return false, (`Framework Admin Abuse module '{p}' is not active in this server`)
	end

	if v8.phase ~= "active" then
		return false, (`Admin Abuse module '{p}' is currently {v8.phase}`)
	end

	if v8.globalId then
		v3[v8.state.slot] = v8.globalId
	end

	return stopLocalSession(v8, value or "manual"), nil
end

function AdminAbuseEvent.seekMainEvent(value: number)
	assert(RunService:IsServer(), "AdminAbuseEvent.seekMainEvent can only be called on the server")

	if value ~= value or value == 1e999 or value == -1e999 then
		return false, "elapsedSeconds must be a finite number"
	end

	local main = v2.main

	if main == nil then
		return false, "No framework main event is active in this server"
	end

	local durationSeconds = main.state.durationSeconds

	if durationSeconds == nil then
		return false, (`Admin Abuse module '{main.state.name}' has no finite duration`)
	end

	local v8 = math.clamp(value, 0, durationSeconds)
	setSessionTimeline(main, v8) -- equivalent call inferred; original call site unknown
	AdminAbuseEvent.remotes.TimelineSeeked:fireAll(main.state.name, main.state.startedAt, v8)
	return true, nil
end

function AdminAbuseEvent.getActiveTimeline(slot)
	local v8 = v2[slot]

	if v8 then
		local context = makeContext(v8, false)
		return {
			name = v8.state.name,
			source = v8.state.source,
			slot = slot,
			elapsedSeconds = context.elapsedSeconds,
			durationSeconds = v8.state.durationSeconds
		}
	end

	local v9 = v5[slot]
	local v10

	if v9 then
		v10 = v4[v9.name]
	end

	if not v9 or not v10 or v3[slot] == v9.id then
		return nil
	end

	local v11

	if v9.expiresAt == nil then
		v11 = false
	else
		v11 = os.time() >= v9.expiresAt
	end

	if not v11 then
		return {
			name = v9.name,
			source = v10.info.source,
			slot = slot,
			elapsedSeconds = math.max(0, Workspace:GetServerTimeNow() - v9.startedAt),
			durationSeconds = v9.durationSeconds
		}
	end

	return nil
end

function AdminAbuseEvent.getActiveStates()
	local result = {}

	for _, slot in v do
		local v9 = v2[slot]

		if v9 then
			table.insert(result, table.clone(v9.state))
		end

		local v10 = v5[slot]
		local v11

		if v10 then
			v11 = v4[v10.name]
		end

		if not (v10 and v11 and (v9 == nil or v9.globalId ~= v10.id) and v3[slot] ~= v10.id) then
			continue
		end

		local v12

		if v10.expiresAt == nil then
			v12 = false
		else
			v12 = os.time() >= v10.expiresAt
		end

		if not v12 then
			table.insert(result, {
				name = v10.name,
				source = v11.info.source,
				slot = slot,
				startedAt = v10.startedAt,
				durationSeconds = v10.durationSeconds,
				isGlobal = true
			})
		end
	end

	if not RunService:IsServer() then
		return result
	end

	for _, v8 in LegacyAdapter.getActiveStates() do
		local v9 = false

		for _, v10 in result do
			if v10.slot == v8.slot and v10.name == v8.name then
				v9 = true
			end
		end

		if not v9 then
			table.insert(result, v8)
		end
	end

	return result
end

function AdminAbuseEvent.getModules()
	local clones = {}

	for _, v8 in v4 do
		table.insert(clones, (table.clone(v8.info)))
	end

	table.sort(clones, function(a, b)
		local displayName = string.lower(a.displayName)
		local displayName2 = string.lower(b.displayName)

		if displayName == displayName2 then
			return a.name < b.name
		end

		return displayName < displayName2
	end)
	return clones
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -100,
	OnInit = function()
		if RunService:IsServer() then
			GlobalStateManager.subscribeToState("AdminAbuseEvent_State", applyGlobalSnapshot)
			task.spawn(function()
				local v8, v9 = LegacyAdapter.initialize()

				if not v8 then
					AdminAbuseEvent.logger:warn((`Legacy controls are unavailable: {v9 or "unknown error"}`))
				end
			end)
			AdminAbuseEvent.remotes.ClientEvent:connect(applyServerClientEvent)
			PlayerReady.onPlayerReady:Connect(handlePlayerAdded)
		else
			Players.PlayerAdded:Connect(handlePlayerAdded)

			if Players.LocalPlayer then
				handlePlayerAdded(Players.LocalPlayer)
			end

			AdminAbuseEvent.remotes.Activated:connect(applyClientActivation)
			AdminAbuseEvent.remotes.Deactivated:connect(applyClientDeactivation)
			AdminAbuseEvent.remotes.Message:connect(applyClientMessage)
			AdminAbuseEvent.remotes.TimelineSeeked:connect(applyClientTimelineSeek)
		end
	end,
	OnUpdate = updateActiveSessions
})
return AdminAbuseEvent