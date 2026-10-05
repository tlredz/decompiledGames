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
local desiredFrameRate = SafeFlags.createGetFInt("ReactSchedulerDesiredFrameRate", 60)()
local minimumFrameRate = SafeFlags.createGetFInt("ReactSchedulerMinFrameRate", 30)()
local deferredWork = SafeFlags.createGetFFlag("ReactSchedulerEnableDeferredWork")()
local heartbeatFrameMarker = SafeFlags.createGetFFlag("ReactSchedulerSetFrameMarkerOnHeartbeatEnd")()
local targetMsByHeartbeatDelta = SafeFlags.createGetFFlag("ReactSchedulerSetTargetMsByHeartbeatDelta")()
local numberOfLookbackFrames = SafeFlags.createGetFInt("ReactSchedulerNumberOfLookbackFrames", 1)()
local lookbackUseRingBuffer = SafeFlags.createGetFFlag("ReactSchedulerLookbackUseRingBuffer")()
local v3 = false
local v4 = 0
local v5 = 1000 / desiredFrameRate
local v6 = 1000 / minimumFrameRate
local v7 = v5
local v8 = v7
local heartbeatConnection = nil
local v9

if lookbackUseRingBuffer then
	v9 = table.create(numberOfLookbackFrames)
else
	v9 = nil
end

local v10 = 1

-- equivalent calls inferred from this helper; original call sites unknown
local function resetFrameBudgets()
	v5 = 1000 / desiredFrameRate
	v6 = 1000 / minimumFrameRate
	v7 = v5
	v8 = v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createHeartbeatConnection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not (numberOfLookbackFrames > 1) then
			v7 = math.clamp(dt * 1000, v5, v6)
			return
		end

		if lookbackUseRingBuffer then
			v9[v10] = dt * 1000
			v10 = v10 % numberOfLookbackFrames + 1
			local v11 = numberOfLookbackFrames
			local total = 0

			for i = 1, v11 do
				if v9[i] == nil then
					v11 = i - 1
					break
				else
					total += v9[i]
				end
			end

			v8 = total / v11
		else
			local v11 = numberOfLookbackFrames
			v8 = (v8 * (v11 - 1) + dt * 1000) / v11
		end

		v7 = math.clamp(v8, v5, v6)
	end)
end

if targetMsByHeartbeatDelta then
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not (numberOfLookbackFrames > 1) then
			v7 = math.clamp(dt * 1000, v5, v6)
			return
		end

		if lookbackUseRingBuffer then
			v9[v10] = dt * 1000
			v10 = v10 % numberOfLookbackFrames + 1
			local v11 = numberOfLookbackFrames
			local total = 0

			for i = 1, v11 do
				if v9[i] == nil then
					v11 = i - 1
					break
				else
					total += v9[i]
				end
			end

			v8 = total / v11
		else
			local v11 = numberOfLookbackFrames
			v8 = (v8 * (v11 - 1) + dt * 1000) / v11
		end

		v7 = math.clamp(v8, v5, v6)
	end)
end

local function setFrameMarker()
	v4 = fn()
end

local fInt = getFInt()
local v11 = 0

local function setSchedulerFlags(data)
	if data.yieldInterval ~= nil then
		fInt = data.yieldInterval
	end

	if data.desiredFrameRate ~= nil then
		desiredFrameRate = data.desiredFrameRate
		resetFrameBudgets() -- equivalent call inferred; original call site unknown
	end

	if data.minimumFrameRate ~= nil then
		minimumFrameRate = data.minimumFrameRate
		resetFrameBudgets() -- equivalent call inferred; original call site unknown
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
			v7 = v5
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
		desiredFrameRate = desiredFrameRate,
		minimumFrameRate = minimumFrameRate,
		deferredWork = deferredWork,
		heartbeatFrameMarker = heartbeatFrameMarker,
		targetMsByHeartbeatDelta = targetMsByHeartbeatDelta,
		numberOfLookbackFrames = numberOfLookbackFrames,
		lookbackUseRingBuffer = lookbackUseRingBuffer
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesBudgetRemain()
	local v12 = fn() - v4
	local v13 = v7 - v12
	return fInt < v13
end

local function shouldYieldToHost()
	local v12 = fn() -- equivalent call inferred; original call site unknown
	return v11 <= v12
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

	local v12 = fn() -- equivalent call inferred; original call site unknown
	v11 = v12 + fInt
	local v13 = true

	if deferredWork and not (heartbeatFrameMarker or v3) then
		v4 = v12
	end

	if heartbeatFrameMarker and v3 and not doesBudgetRemain() then
		v13 = false
	end

	local function doWork()
		if v2(v13, v12) then
			if deferredWork then
				if doesBudgetRemain() then
					v3 = true
					task.defer(performWorkUntilDeadline)
				else
					v3 = false
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

	local v14, v15

	if ReactGlobals.__YOLO__ then
		v14 = doWork()
		v15 = true
	else
		v15, v14 = xpcall(doWork, describeError)
	end

	if not v15 then
		task.delay(0, performWorkUntilDeadline)

		if heartbeatFrameMarker then
			task.defer(setFrameMarker)
		end

		error(errorToString(v14))
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
		local _, v12, v13 = coroutine.resume(thread)

		if not v12 then
			error(v13)
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