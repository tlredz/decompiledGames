local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local array = luaupolyfill.Array
require(script.Parent:WaitForChild("ReactInternalTypes"))
local scheduler = require(script.Parent.Parent:WaitForChild("scheduler"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local decoupleUpdatePriorityFromScheduler = shared.ReactFeatureFlags.decoupleUpdatePriorityFromScheduler
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared2.invariant
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local describeError = shared3.describeError
local ReactFiberLane = require(script.Parent:WaitForChild("ReactFiberLane"))
local syncLanePriority = ReactFiberLane.SyncLanePriority
local getCurrentUpdateLanePriority = ReactFiberLane.getCurrentUpdateLanePriority
local setCurrentUpdateLanePriority = ReactFiberLane.setCurrentUpdateLanePriority
local unstable_runWithPriority = scheduler.unstable_runWithPriority
local unstable_scheduleCallback = scheduler.unstable_scheduleCallback
local unstable_cancelCallback = scheduler.unstable_cancelCallback
local unstable_shouldYield = scheduler.unstable_shouldYield
local unstable_requestPaint = scheduler.unstable_requestPaint
local unstable_now = scheduler.unstable_now
local unstable_getCurrentPriorityLevel = scheduler.unstable_getCurrentPriorityLevel
local unstable_ImmediatePriority = scheduler.unstable_ImmediatePriority
local unstable_UserBlockingPriority = scheduler.unstable_UserBlockingPriority
local unstable_NormalPriority = scheduler.unstable_NormalPriority
local unstable_LowPriority = scheduler.unstable_LowPriority
local unstable_IdlePriority = scheduler.unstable_IdlePriority
local ReactFiberSchedulerPrioritiesroblox = require(script.Parent:WaitForChild("ReactFiberSchedulerPriorities.roblox"))
local immediatePriority = ReactFiberSchedulerPrioritiesroblox.ImmediatePriority
local userBlockingPriority = ReactFiberSchedulerPrioritiesroblox.UserBlockingPriority
local normalPriority = ReactFiberSchedulerPrioritiesroblox.NormalPriority
local lowPriority = ReactFiberSchedulerPrioritiesroblox.LowPriority
local idlePriority = ReactFiberSchedulerPrioritiesroblox.IdlePriority
local noPriority = ReactFiberSchedulerPrioritiesroblox.NoPriority
local fn
local v = {}
local fn2 = unstable_requestPaint == nil and function() end or unstable_requestPaint
local v2 = nil
local v3 = nil
local v4 = false
local v5 = unstable_now()

function reactPriorityToSchedulerPriority(p)
	if p == immediatePriority then
		return unstable_ImmediatePriority
	end

	if p == userBlockingPriority then
		return unstable_UserBlockingPriority
	end

	if p == normalPriority then
		return unstable_NormalPriority
	end

	if p == lowPriority then
		return unstable_LowPriority
	end

	if p == idlePriority then
		return unstable_IdlePriority
	end

	invariant(false, "Unknown priority level.")
	return nil
end

local function runWithPriority(p, callback)
	return unstable_runWithPriority(reactPriorityToSchedulerPriority(p), callback)
end

local function scheduleSyncCallback(callback)
	if v2 == nil then
		v2 = { callback }
		v3 = unstable_scheduleCallback(unstable_ImmediatePriority, fn)
	else
		table.insert(v2, callback)
	end

	return v
end

local function flushSyncCallbackQueue()
	if v3 ~= nil then
		local v6 = v3
		v3 = nil
		unstable_cancelCallback(v6)
	end

	return fn()
end

fn = function()
	if v4 or v2 == nil then
		return false
	end

	v4 = true
	local v6 = 1

	if decoupleUpdatePriorityFromScheduler then
		local currentUpdateLanePriority = getCurrentUpdateLanePriority()
		local v7 = nil
		local v8

		if _G.__YOLO__ then
			v8 = true
			local v9 = v2
			setCurrentUpdateLanePriority(syncLanePriority)

			local function fn3()
				for k, v11 in v9 do
					v6 = k

					repeat
						v11 = v11(true)
					until v11 == nil

					v6 += 1
				end
			end

			unstable_runWithPriority(reactPriorityToSchedulerPriority(immediatePriority), fn3)
			v2 = nil
		else
			local v9 = v2
			setCurrentUpdateLanePriority(syncLanePriority)
			v8, v7 = xpcall(runWithPriority, describeError, immediatePriority, function()
				for k, v10 in v9 do
					v6 = k

					repeat
						v10 = v10(true)
					until v10 == nil
				end
			end)
			v2 = nil
		end

		setCurrentUpdateLanePriority(currentUpdateLanePriority)
		v4 = false

		if not v8 then
			if v2 ~= nil then
				v2 = array.slice(v2, v6 + 1)
			end

			unstable_scheduleCallback(unstable_ImmediatePriority, flushSyncCallbackQueue)
			error(v7)
		end
	else
		local v7 = nil
		local v8

		if _G.__YOLO__ then
			v8 = true
			local v9 = v2

			local function fn3()
				for k, v11 in v9 do
					v6 = k

					repeat
						v11 = v11(true)
					until v11 == nil
				end
			end

			unstable_runWithPriority(reactPriorityToSchedulerPriority(immediatePriority), fn3)
			v2 = nil
		else
			local v9 = v2
			v8, v7 = xpcall(runWithPriority, describeError, immediatePriority, function()
				for k, v10 in v9 do
					v6 = k

					repeat
						v10 = v10(true)
					until v10 == nil
				end
			end)
			v2 = nil
		end

		v4 = false

		if not v8 then
			if v2 ~= nil then
				v2 = array.slice(v2, v6 + 1)
			end

			unstable_scheduleCallback(unstable_ImmediatePriority, flushSyncCallbackQueue)
			error(v7)
		end
	end

	return true
end

local New = {}
New.ImmediatePriority = immediatePriority
New.UserBlockingPriority = userBlockingPriority
New.NormalPriority = normalPriority
New.LowPriority = lowPriority
New.IdlePriority = idlePriority
New.NoPriority = noPriority

function New.getCurrentPriorityLevel()
	local v6 = unstable_getCurrentPriorityLevel()

	if v6 == unstable_ImmediatePriority then
		return immediatePriority
	end

	if v6 == unstable_UserBlockingPriority then
		return userBlockingPriority
	end

	if v6 == unstable_NormalPriority then
		return normalPriority
	end

	if v6 == unstable_LowPriority then
		return lowPriority
	end

	if v6 == unstable_IdlePriority then
		return idlePriority
	end

	invariant(false, "Unknown priority level.")
	return noPriority
end

New.flushSyncCallbackQueue = flushSyncCallbackQueue
New.runWithPriority = runWithPriority

function New.scheduleCallback(p, callback, p2)
	return unstable_scheduleCallback(reactPriorityToSchedulerPriority(p), callback, p2)
end

New.scheduleSyncCallback = scheduleSyncCallback

function New.cancelCallback(p)
	if p ~= v then
		unstable_cancelCallback(p)
	end
end

function New.now()
	return unstable_now() - v5
end

New.requestPaint = fn2
New.shouldYield = unstable_shouldYield
return New