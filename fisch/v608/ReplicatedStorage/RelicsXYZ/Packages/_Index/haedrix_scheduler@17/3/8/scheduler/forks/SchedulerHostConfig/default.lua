local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local object = LuauPolyfill.Object
local Shared = require(parent.Shared)
local console = Shared.console
local errorToString = Shared.errorToString
local describeError = Shared.describeError
local SafeFlags = require(parent.SafeFlags)

-- equivalent calls inferred from this helper; original call sites unknown
local function fn()
	return os.clock() * 1000
end

local setTimeout = LuauPolyfill.setTimeout
local clearTimeout = LuauPolyfill.clearTimeout
local v = false
local v2 = nil
local none = object.None
local getFInt = SafeFlags.createGetFInt("ReactSchedulerYieldInterval2", 15)
local v3 = SafeFlags.createGetFInt("ReactSchedulerDesiredFrameRate", 60)()
local v4 = SafeFlags.createGetFInt("ReactSchedulerMinFrameRate", 30)()
local deferredWork = SafeFlags.createGetFFlag("ReactSchedulerEnableDeferredWork")()
local heartbeatFrameMarker = SafeFlags.createGetFFlag("ReactSchedulerSetFrameMarkerOnHeartbeatEnd")()
local targetMsByHeartbeatDelta = SafeFlags.createGetFFlag("ReactSchedulerSetTargetMsByHeartbeatDelta")()
local numberOfLookbackFrames = SafeFlags.createGetFInt("ReactSchedulerNumberOfLookbackFrames", 1)()
local lookbackUseRingBuffer = SafeFlags.createGetFFlag("ReactSchedulerLookbackUseRingBuffer")()
local v5 = false
local v6 = 0
local v7 = 1000 / v3
local v8 = 1000 / v4
local v9 = v7
local v10 = v9
local heartbeatConnection = nil
local v11

if lookbackUseRingBuffer then
	v11 = table.create(numberOfLookbackFrames)
else
	v11 = nil
end

local v12 = 1

-- equivalent calls inferred from this helper; original call sites unknown
local function createHeartbeatConnection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not (numberOfLookbackFrames > 1) then
			v9 = math.clamp(dt * 1000, v7, v8)
			return
		end

		if lookbackUseRingBuffer then
			v11[v12] = dt * 1000
			v12 = v12 % numberOfLookbackFrames + 1
			local v13 = numberOfLookbackFrames
			local total = 0

			for i = 1, v13 do
				if v11[i] == nil then
					v13 = i - 1
					break
				else
					total += v11[i]
				end
			end

			v10 = total / v13
		else
			local v13 = numberOfLookbackFrames
			v10 = (v10 * (v13 - 1) + dt * 1000) / v13
		end

		v9 = math.clamp(v10, v7, v8)
	end)
end

if targetMsByHeartbeatDelta then
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not (numberOfLookbackFrames > 1) then
			v9 = math.clamp(dt * 1000, v7, v8)
			return
		end

		if lookbackUseRingBuffer then
			v11[v12] = dt * 1000
			v12 = v12 % numberOfLookbackFrames + 1
			local v13 = numberOfLookbackFrames
			local total = 0

			for i = 1, v13 do
				if v11[i] == nil then
					v13 = i - 1
					break
				else
					total += v11[i]
				end
			end

			v10 = total / v13
		else
			local v13 = numberOfLookbackFrames
			v10 = (v10 * (v13 - 1) + dt * 1000) / v13
		end

		v9 = math.clamp(v10, v7, v8)
	end)
end

local function setFrameMarker()
	v6 = fn()
end

local fInt = getFInt()
local v13 = 0

local function setSchedulerFlags(data)
	if data.yieldInterval ~= nil then
		fInt = data.yieldInterval
	end

	if data.deferredWork ~= nil then
		deferredWork = data.deferredWork
	end

	if data.heartbeatFrameMarker ~= nil then
		heartbeatFrameMarker = data.heartbeatFrameMarker
	end

	if data.targetMsByHeartbeatDelta ~= nil then
		targetMsByHeartbeatDelta = data.targetMsByHeartbeatDelta

		if data.targetMsByHeartbeatDelta then
			createHeartbeatConnection() -- equivalent call inferred; original call site unknown
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
			v9 = v7
		end
	end

	if data.numberOfLookbackFrames ~= nil then
		numberOfLookbackFrames = data.numberOfLookbackFrames
	end

	if data.lookbackUseRingBuffer ~= nil then
		lookbackUseRingBuffer = data.lookbackUseRingBuffer
	end
end

local function getSchedulerFlags()
	return {
		yieldInterval = fInt,
		deferredWork = deferredWork,
		heartbeatFrameMarker = heartbeatFrameMarker,
		targetMsByHeartbeatDelta = targetMsByHeartbeatDelta,
		numberOfLookbackFrames = numberOfLookbackFrames,
		lookbackUseRingBuffer = lookbackUseRingBuffer
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesBudgetRemain()
	local v14 = fn() - v6
	local v15 = v9 - v14
	return fInt < v15
end

local function shouldYieldToHost()
	local v14 = fn() -- equivalent call inferred; original call site unknown
	return v13 <= v14
end

local function forceFrameRate(p)
	if p < 0 or p > 125 then
		console.warn("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported")
	elseif p > 0 then
		fInt = math.floor(1000 / p)
	else
		fInt = 5
	end
end

local performWorkUntilDeadline

performWorkUntilDeadline = function()
	if v2 == nil then
		v = false
		return
	end

	local v14 = fn() -- equivalent call inferred; original call site unknown
	v13 = v14 + fInt
	local v15 = true

	if deferredWork and not (heartbeatFrameMarker or v5) then
		v6 = v14
	end

	if heartbeatFrameMarker and v5 and not doesBudgetRemain() then
		v15 = false
	end

	local function doWork()
		if v2(v15, v14) then
			if deferredWork then
				if doesBudgetRemain() then
					v5 = true
					task.defer(performWorkUntilDeadline)
				else
					v5 = false
					task.delay(0, performWorkUntilDeadline)

					if heartbeatFrameMarker then
						task.defer(setFrameMarker)
					end
				end
			else
				task.delay(0, performWorkUntilDeadline)
			end
		else
			v = false
			v2 = nil
		end

		return nil
	end

	local v16, v17

	if ReactGlobals.__YOLO__ then
		v16 = doWork()
		v17 = true
	else
		v17, v16 = xpcall(doWork, describeError)
	end

	if not v17 then
		task.delay(0, performWorkUntilDeadline)

		if heartbeatFrameMarker then
			task.defer(setFrameMarker)
		end

		error(errorToString(v16))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wrapPerformWorkWithCoroutine(callback)
	local thread = coroutine.create(function()
		while true do
			local thread2 = coroutine.wrap(callback)
			local success, result = pcall(thread2)
			coroutine.yield(success, result)
		end
	end)
	return function()
		local _, v14, v15 = coroutine.resume(thread)

		if not v14 then
			error(v15)
		end
	end
end

performWorkUntilDeadline = wrapPerformWorkWithCoroutine(performWorkUntilDeadline)
local Default = {}

function Default.requestHostCallback(p)
	v2 = p

	if not v then
		v = true
		task.delay(0, performWorkUntilDeadline)

		if heartbeatFrameMarker then
			task.defer(setFrameMarker)
		end
	end
end

function Default.cancelHostCallback()
	v2 = nil
end

function Default.requestHostTimeout(callback, p)
	none = setTimeout(function()
		callback(fn())
	end, p)
end

function Default.cancelHostTimeout()
	clearTimeout(none)
	none = object.None
end

Default.shouldYieldToHost = shouldYieldToHost

function Default.requestPaint() end

Default.getCurrentTime = fn
Default.forceFrameRate = forceFrameRate
Default.setSchedulerFlags = setSchedulerFlags
Default.getSchedulerFlags = getSchedulerFlags
return Default