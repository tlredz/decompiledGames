local parent = script.Parent
local ReactGlobals = require(parent.ReactGlobals)
local Scheduler = require(script.Scheduler)

local function onlyInTestError(p: string)
	return function()
		error(p .. " is only available in tests, not in production")
	end
end

local scheduler = Scheduler(nil)
local Tracing = require(script.Tracing)
local TracingSubscriptions = require(script.TracingSubscriptions)

if ReactGlobals.__ROACT_17_MOCK_SCHEDULER__ then
	return require(script.unstable_mock)
end

local Scheduler2 = {
	unstable_ImmediatePriority = scheduler.unstable_ImmediatePriority,
	unstable_UserBlockingPriority = scheduler.unstable_UserBlockingPriority,
	unstable_NormalPriority = scheduler.unstable_NormalPriority,
	unstable_IdlePriority = scheduler.unstable_IdlePriority,
	unstable_LowPriority = scheduler.unstable_LowPriority,
	unstable_runWithPriority = scheduler.unstable_runWithPriority,
	unstable_next = scheduler.unstable_next,
	unstable_scheduleCallback = scheduler.unstable_scheduleCallback,
	unstable_cancelCallback = scheduler.unstable_cancelCallback,
	unstable_wrapCallback = scheduler.unstable_wrapCallback,
	unstable_getCurrentPriorityLevel = scheduler.unstable_getCurrentPriorityLevel,
	unstable_shouldYield = scheduler.unstable_shouldYield,
	unstable_requestPaint = scheduler.unstable_requestPaint,
	unstable_continueExecution = scheduler.unstable_continueExecution,
	unstable_pauseExecution = scheduler.unstable_pauseExecution,
	unstable_getFirstCallbackNode = scheduler.unstable_getFirstCallbackNode,
	unstable_now = scheduler.unstable_now,
	unstable_forceFrameRate = scheduler.unstable_forceFrameRate,
	unstable_setSchedulerFlags = scheduler.unstable_setSchedulerFlags,
	unstable_getSchedulerFlags = scheduler.unstable_getSchedulerFlags,
	unstable_flushAllWithoutAsserting = 0,
	unstable_flushAll = 0,
	unstable_flushNumberOfYields = 0,
	unstable_clearYields = 0,
	unstable_flushUntilNextPaint = 0,
	unstable_advanceTime = 0,
	unstable_flushExpired = 0,
	unstable_yieldValue = 0,
	tracing = 0
}
local v2 = "unstable_flushAllWithoutAsserting"

function Scheduler2.unstable_flushAllWithoutAsserting()
	error(v2 .. " is only available in tests, not in production")
end

local v3 = "unstable_flushAll"

function Scheduler2.unstable_flushAll()
	error(v3 .. " is only available in tests, not in production")
end

local v4 = "unstable_flushNumberOfYields"

function Scheduler2.unstable_flushNumberOfYields()
	error(v4 .. " is only available in tests, not in production")
end

local v5 = "unstable_clearYields"

function Scheduler2.unstable_clearYields()
	error(v5 .. " is only available in tests, not in production")
end

local v6 = "unstable_clearYields"

function Scheduler2.unstable_flushUntilNextPaint()
	error(v6 .. " is only available in tests, not in production")
end

local v7 = "unstable_advanceTime"

function Scheduler2.unstable_advanceTime()
	error(v7 .. " is only available in tests, not in production")
end

local v8 = "unstable_flushExpired"

function Scheduler2.unstable_flushExpired()
	error(v8 .. " is only available in tests, not in production")
end

local v9 = "unstable_yieldValue"

function Scheduler2.unstable_yieldValue()
	error(v9 .. " is only available in tests, not in production")
end

local v11 = "unstable_wrap"
Scheduler2.tracing = {
	unstable_wrap = function()
		error(v11 .. " is only available in tests, not in production")
	end,
	__interactionsRef = {},
	__subscriberRef = {}
}

for k, v12 in Tracing do
	Scheduler2.tracing[k] = v12
end

for k, tracingSubscription in TracingSubscriptions do
	Scheduler2.tracing[k] = tracingSubscription
end

return Scheduler2