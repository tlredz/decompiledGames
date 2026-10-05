local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local set = LuauPolyfill.Set
local map = LuauPolyfill.Map
require(script.Parent.ReactInternalTypes)
local ReactRootTags = require(script.Parent.ReactRootTags)
local ReactFiberHostConfig = require(script.Parent.ReactFiberHostConfig)
local noTimeout = ReactFiberHostConfig.noTimeout
local supportsHydration = ReactFiberHostConfig.supportsHydration
local ReactFibernew = require(script.Parent["ReactFiber.new"])
local createHostRootFiber = ReactFibernew.createHostRootFiber
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local noLanes = ReactFiberLane.NoLanes
local noLanePriority = ReactFiberLane.NoLanePriority
local noTimestamp = ReactFiberLane.NoTimestamp
local createLaneMap = ReactFiberLane.createLaneMap
local Shared = require(parent.Shared)
local reactFeatureFlags = Shared.ReactFeatureFlags
local enableSchedulerTracing = reactFeatureFlags.enableSchedulerTracing
local enableSuspenseCallback = reactFeatureFlags.enableSuspenseCallback
local Scheduler = require(parent.Scheduler)
local unstable_getThreadID = Scheduler.tracing.unstable_getThreadID
local ReactUpdateQueuenew = require(script.Parent["ReactUpdateQueue.new"])
local initializeUpdateQueue = ReactUpdateQueuenew.initializeUpdateQueue
local legacyRoot = ReactRootTags.LegacyRoot
local blockingRoot = ReactRootTags.BlockingRoot
local concurrentRoot = ReactRootTags.ConcurrentRoot

local function FiberRootNode(containerInfo, tag, hydrate)
	local v = {
		tag = tag,
		containerInfo = containerInfo,
		pendingChildren = nil,
		current = nil,
		pingCache = nil,
		finishedWork = nil,
		timeoutHandle = noTimeout,
		context = nil,
		pendingContext = nil,
		hydrate = hydrate,
		callbackNode = nil,
		callbackPriority = noLanePriority,
		eventTimes = createLaneMap(noLanes),
		expirationTimes = createLaneMap(noTimestamp),
		pendingLanes = noLanes,
		suspendedLanes = noLanes,
		pingedLanes = noLanes,
		expiredLanes = noLanes,
		mutableReadLanes = noLanes,
		finishedLanes = noLanes,
		entangledLanes = noLanes,
		entanglements = createLaneMap(noLanes)
	}

	if supportsHydration then
		v.mutableSourceEagerHydrationData = nil
	end

	if enableSchedulerTracing then
		v.interactionThreadID = unstable_getThreadID()
		v.memoizedInteractions = set.new()
		v.pendingInteractionMap = map.new()
	end

	if enableSuspenseCallback then
		v.hydrationCallbacks = nil
	end

	if not ReactGlobals.__DEV__ then
		return v
	end

	if tag == blockingRoot then
		v._debugRootType = "createBlockingRoot()"
		return v
	end

	if tag == concurrentRoot then
		v._debugRootType = "createRoot()"
		return v
	elseif tag == legacyRoot then
		v._debugRootType = "createLegacyRoot()"
	end

	return v
end

return {
	createFiberRoot = function(containerInfo, tag, hydrate: boolean, hydrationCallbacks)
		local stateNode = FiberRootNode(containerInfo, tag, hydrate)

		if enableSuspenseCallback then
			stateNode.hydrationCallbacks = hydrationCallbacks
		end

		local hostRootFiber = createHostRootFiber(tag)
		stateNode.current = hostRootFiber
		hostRootFiber.stateNode = stateNode
		initializeUpdateQueue(hostRootFiber)
		return stateNode
	end
}