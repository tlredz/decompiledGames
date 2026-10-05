local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local Shared = require(parent.Shared)
local console = Shared.console
local LuauPolyfill = require(parent.LuauPolyfill)
local set = LuauPolyfill.Set
local __DEV__ = ReactGlobals.__DEV__
local __YOLO__ = ReactGlobals.__YOLO__
local New = {}
require(parent.Shared)
require(script.Parent.ReactInternalTypes)
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local Scheduler = require(parent.Scheduler)
require(script.Parent["ReactFiberSuspenseComponent.new"])
local ReactFiberStacknew = require(script.Parent["ReactFiberStack.new"])
local Shared2 = require(parent.Shared)
local reactFeatureFlags = Shared2.ReactFeatureFlags
local enableDebugTracing = reactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = reactFeatureFlags.enableSchedulingProfiler
local skipUnmountedBoundaries = reactFeatureFlags.skipUnmountedBoundaries
local enableDoubleInvokingEffects = reactFeatureFlags.enableDoubleInvokingEffects
local deletedTreeCleanUpLevel = reactFeatureFlags.deletedTreeCleanUpLevel
local enableNewTreeCleanupPath = reactFeatureFlags.enableNewTreeCleanupPath
local Shared3 = require(parent.Shared)
local Shared4 = require(parent.Shared)
local describeError = Shared4.describeError
local reactSharedInternals = Shared3.ReactSharedInternals
local invariant = Shared3.invariant
local SchedulerWithReactIntegrationnew = require(script.Parent["SchedulerWithReactIntegration.new"])
local scheduleCallback = SchedulerWithReactIntegrationnew.scheduleCallback
local cancelCallback = SchedulerWithReactIntegrationnew.cancelCallback
local getCurrentPriorityLevel = SchedulerWithReactIntegrationnew.getCurrentPriorityLevel
local runWithPriority = SchedulerWithReactIntegrationnew.runWithPriority
local shouldYield = SchedulerWithReactIntegrationnew.shouldYield
local requestPaint = SchedulerWithReactIntegrationnew.requestPaint
local now = SchedulerWithReactIntegrationnew.now
local noPriority = SchedulerWithReactIntegrationnew.NoPriority
local immediatePriority = SchedulerWithReactIntegrationnew.ImmediatePriority
local userBlockingPriority = SchedulerWithReactIntegrationnew.UserBlockingPriority
local normalPriority = SchedulerWithReactIntegrationnew.NormalPriority
local flushSyncCallbackQueue = SchedulerWithReactIntegrationnew.flushSyncCallbackQueue
local scheduleSyncCallback = SchedulerWithReactIntegrationnew.scheduleSyncCallback
local DebugTracing = require(script.Parent.DebugTracing)
local SchedulingProfiler = require(script.Parent.SchedulingProfiler)
local Scheduler2 = require(parent.Scheduler)
local tracing = Scheduler2.tracing
local __interactionsRef = tracing.__interactionsRef
local __subscriberRef = tracing.__subscriberRef
local ReactFiberHostConfig = require(script.Parent.ReactFiberHostConfig)
local ReactFibernew = require(script.Parent["ReactFiber.new"])
local ReactTypeOfMode = require(script.Parent.ReactTypeOfMode)
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local ReactRootTags = require(script.Parent.ReactRootTags)
local legacyRoot = ReactRootTags.LegacyRoot
local ReactFiberFlags = require(script.Parent.ReactFiberFlags)
local syncLane = ReactFiberLane.SyncLane
local syncBatchedLane = ReactFiberLane.SyncBatchedLane
local noTimestamp = ReactFiberLane.NoTimestamp
local findUpdateLane = ReactFiberLane.findUpdateLane
local findTransitionLane = ReactFiberLane.findTransitionLane
local findRetryLane = ReactFiberLane.findRetryLane
local includesSomeLane = ReactFiberLane.includesSomeLane
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local mergeLanes = ReactFiberLane.mergeLanes
local removeLanes = ReactFiberLane.removeLanes
local pickArbitraryLane = ReactFiberLane.pickArbitraryLane
local hasDiscreteLanes = ReactFiberLane.hasDiscreteLanes
local includesNonIdleWork = ReactFiberLane.includesNonIdleWork
local includesOnlyRetries = ReactFiberLane.includesOnlyRetries
local includesOnlyTransitions = ReactFiberLane.includesOnlyTransitions
local getNextLanes = ReactFiberLane.getNextLanes
local returnNextLanesPriority = ReactFiberLane.returnNextLanesPriority
local setCurrentUpdateLanePriority = ReactFiberLane.setCurrentUpdateLanePriority
local getCurrentUpdateLanePriority = ReactFiberLane.getCurrentUpdateLanePriority
local markStarvedLanesAsExpired = ReactFiberLane.markStarvedLanesAsExpired
local getLanesToRetrySynchronouslyOnError = ReactFiberLane.getLanesToRetrySynchronouslyOnError
local markRootUpdated = ReactFiberLane.markRootUpdated
local markRootPinged = ReactFiberLane.markRootPinged
local markRootExpired = ReactFiberLane.markRootExpired
local markDiscreteUpdatesExpired = ReactFiberLane.markDiscreteUpdatesExpired
local markRootFinished = ReactFiberLane.markRootFinished
local schedulerPriorityToLanePriority = ReactFiberLane.schedulerPriorityToLanePriority
local lanePriorityToSchedulerPriority = ReactFiberLane.lanePriorityToSchedulerPriority
local ReactFiberTransition = require(script.Parent.ReactFiberTransition)
local ReactFiberUnwindWorknew = require(script.Parent["ReactFiberUnwindWork.new"])
local unwindWork = ReactFiberUnwindWorknew.unwindWork
local unwindInterruptedWork = ReactFiberUnwindWorknew.unwindInterruptedWork
local ReactFiberThrownew = require(script.Parent["ReactFiberThrow.new"])
local throwException = ReactFiberThrownew.throwException
local createRootErrorUpdate = ReactFiberThrownew.createRootErrorUpdate
local createClassErrorUpdate = ReactFiberThrownew.createClassErrorUpdate
local ReactFiberCommitWorknew = require(script.Parent["ReactFiberCommitWork.new"])
local commitBeforeMutationLifeCycles = ReactFiberCommitWorknew.commitBeforeMutationLifeCycles
local commitPlacement = ReactFiberCommitWorknew.commitPlacement
local commitWork = ReactFiberCommitWorknew.commitWork
local commitDeletion = ReactFiberCommitWorknew.commitDeletion
local commitPassiveUnmount = ReactFiberCommitWorknew.commitPassiveUnmount
local commitPassiveUnmountInsideDeletedTree = ReactFiberCommitWorknew.commitPassiveUnmountInsideDeletedTree
local commitPassiveMount = ReactFiberCommitWorknew.commitPassiveMount
local commitDetachRef = ReactFiberCommitWorknew.commitDetachRef
local invokeLayoutEffectMountInDEV = ReactFiberCommitWorknew.invokeLayoutEffectMountInDEV
local invokePassiveEffectMountInDEV = ReactFiberCommitWorknew.invokePassiveEffectMountInDEV
local invokeLayoutEffectUnmountInDEV = ReactFiberCommitWorknew.invokeLayoutEffectUnmountInDEV
local invokePassiveEffectUnmountInDEV = ReactFiberCommitWorknew.invokePassiveEffectUnmountInDEV
local recursivelyCommitLayoutEffects = ReactFiberCommitWorknew.recursivelyCommitLayoutEffects
local Promise = require(parent.Promise)
local ReactUpdateQueuenew = require(script.Parent["ReactUpdateQueue.new"])
local enqueueUpdate = ReactUpdateQueuenew.enqueueUpdate
local ReactFiberNewContextnew = require(script.Parent["ReactFiberNewContext.new"])
local resetContextDependencies = ReactFiberNewContextnew.resetContextDependencies
local RobloxReactProfiling = require(script.Parent.RobloxReactProfiling)
local fn
local v = {
	resetHooksAfterThrowRef = nil,
	ContextOnlyDispatcherRef = nil,
	getIsUpdatingOpaqueValueInRenderPhaseInDEVRef = nil,
	originalBeginWorkRef = nil,
	completeWorkRef = nil
}

local function fn2(p, p2, p3)
	if not v.originalBeginWorkRef then
		local v2 = v
		local ReactFiberBeginWorknew = require(script.Parent["ReactFiberBeginWork.new"])
		v2.originalBeginWorkRef = ReactFiberBeginWorknew.beginWork
	end

	return v.originalBeginWorkRef(p, p2, p3)
end

local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function initReactFiberHooks()
	local ReactFiberHooksnew = require(script.Parent["ReactFiberHooks.new"])
	v2 = ReactFiberHooksnew
	v.resetHooksAfterThrowRef = v2.resetHooksAfterThrow
	v.ContextOnlyDispatcherRef = v2.ContextOnlyDispatcher
	v.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef = v2.getIsUpdatingOpaqueValueInRenderPhaseInDEV
end

local ReactCapturedValue = require(script.Parent.ReactCapturedValue)
local createCapturedValue = ReactCapturedValue.createCapturedValue
local push = ReactFiberStacknew.push
local pop = ReactFiberStacknew.pop
local createCursor = ReactFiberStacknew.createCursor
local ReactProfilerTimernew = require(script.Parent["ReactProfilerTimer.new"])
local Shared5 = require(parent.Shared)
local getComponentName = Shared5.getComponentName
local ReactStrictModeWarningsnew = require(script.Parent["ReactStrictModeWarnings.new"])
local ReactCurrentFiber = require(script.Parent.ReactCurrentFiber)
local current = ReactCurrentFiber.current
local resetCurrentFiber = ReactCurrentFiber.resetCurrentFiber
local setCurrentFiber = ReactCurrentFiber.setCurrentFiber
local Shared6 = require(parent.Shared)
local reactErrorUtils = Shared6.ReactErrorUtils
local invokeGuardedCallback = reactErrorUtils.invokeGuardedCallback
local hasCaughtError = reactErrorUtils.hasCaughtError
local clearCaughtError = reactErrorUtils.clearCaughtError
local ReactFiberDevToolsHooknew = require(script.Parent["ReactFiberDevToolsHook.new"])
local onCommitRoot = ReactFiberDevToolsHooknew.onCommitRoot
local ReactTestSelectors = require(script.Parent.ReactTestSelectors)
local onCommitRoot2 = ReactTestSelectors.onCommitRoot
local Shared7 = require(parent.Shared)
local enqueueTask = Shared7.enqueueTask
local ReactFiberTreeReflection = require(script.Parent.ReactFiberTreeReflection)
local doesFiberContain = ReactFiberTreeReflection.doesFiberContain
local reactCurrentDispatcher = reactSharedInternals.ReactCurrentDispatcher
local reactCurrentOwner = reactSharedInternals.ReactCurrentOwner
local isSomeRendererActing = reactSharedInternals.IsSomeRendererActing
local fn3
local v3 = {}
New.NoContext = 0
New.RetryAfterError = 64
local _ = {
	Incomplete = 0,
	FatalErrored = 1,
	Errored = 2,
	Suspended = 3,
	SuspendedWithDelay = 4,
	Completed = 5
}
local v4 = 0
local v5 = nil
local v6 = nil
local noLanes = ReactFiberLane.NoLanes
New.subtreeRenderLanes = ReactFiberLane.NoLanes
local cursor = createCursor(ReactFiberLane.NoLanes)
local v7 = 0
local v8 = nil
local noLanes2 = ReactFiberLane.NoLanes
local ReactFiberWorkInProgress = require(script.Parent.ReactFiberWorkInProgress)
local workInProgressRootSkippedLanes = ReactFiberWorkInProgress.workInProgressRootSkippedLanes
local noLanes3 = ReactFiberLane.NoLanes
local noLanes4 = ReactFiberLane.NoLanes
local v9 = nil
local v10 = 0
local v11 = 1e999
local v12 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function resetRenderTimer()
	v11 = now() + 500
end

function New.getRenderTargetTime()
	return v11
end

local flag = false
local v13 = nil
local v14 = nil
local flag2 = false
local v15 = nil
local v16 = noPriority
local noLanes5 = ReactFiberLane.NoLanes
local v17 = nil
local count = 0
local v18 = nil
local count2 = 0
local v19 = nil
local v20 = noTimestamp
local noLanes6 = ReactFiberLane.NoLanes
local noLanes7 = ReactFiberLane.NoLanes
local v21 = nil
local flag3 = false

function New.getWorkInProgressRoot()
	return v5
end

function New.requestEventTime()
	if bit32.band(v4, 48) ~= 0 then
		return now()
	end

	if v20 ~= noTimestamp then
		return v20
	end

	v20 = now()
	return v20
end

function New.requestUpdateLane(p)
	local mode = p.mode

	if bit32.band(mode, ReactTypeOfMode.BlockingMode) == ReactTypeOfMode.NoMode then
		return syncLane
	end

	if bit32.band(mode, ReactTypeOfMode.ConcurrentMode) == ReactTypeOfMode.NoMode then
		if getCurrentPriorityLevel() == immediatePriority then
			return syncLane
		end

		return syncBatchedLane
	else
		if not reactFeatureFlags.deferRenderPhaseUpdateToNextBatch and bit32.band(v4, 16) ~= 0 and noLanes ~= ReactFiberLane.NoLanes then
			return pickArbitraryLane(noLanes)
		end

		if noLanes6 == ReactFiberLane.NoLanes then
			noLanes6 = noLanes2
		end

		if ReactFiberTransition.requestCurrentTransition() ~= ReactFiberTransition.NoTransition then
			if noLanes7 ~= ReactFiberLane.NoLanes then
				if v9 == nil then
					noLanes7 = ReactFiberLane.NoLanes
				else
					noLanes7 = v9.pendingLanes
				end
			end

			return findTransitionLane(noLanes6, noLanes7)
		else
			local currentPriorityLevel = getCurrentPriorityLevel()

			if bit32.band(v4, 4) ~= 0 and currentPriorityLevel == userBlockingPriority then
				return (findUpdateLane(ReactFiberLane.InputDiscreteLanePriority, noLanes6))
			end

			local v22 = schedulerPriorityToLanePriority(currentPriorityLevel)

			if reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
				local currentUpdateLanePriority = getCurrentUpdateLanePriority()

				if v22 ~= currentUpdateLanePriority and currentUpdateLanePriority ~= ReactFiberLane.NoLanePriority and __DEV__ then
					console.error(
						"Expected current scheduler lane priority %s to match current update lane priority %s",
						tostring(v22),
						(tostring(currentUpdateLanePriority))
					)
				end
			end

			return (findUpdateLane(v22, noLanes6))
		end
	end
end

function requestRetryLane(p)
	local mode = p.mode

	if bit32.band(mode, ReactTypeOfMode.BlockingMode) == ReactTypeOfMode.NoMode then
		return syncLane
	end

	if bit32.band(mode, ReactTypeOfMode.ConcurrentMode) == ReactTypeOfMode.NoMode then
		if getCurrentPriorityLevel() == immediatePriority then
			return syncLane
		end

		return syncBatchedLane
	else
		if noLanes6 == ReactFiberLane.NoLanes then
			noLanes6 = noLanes2
		end

		return findRetryLane(noLanes6)
	end
end

function New.scheduleUpdateOnFiber(p, p2, p3: number)
	v3.checkForNestedUpdates()
	local v22 = v3.markUpdateLaneFromFiberToRoot(p, p2)

	if v22 == nil then
		return nil
	end

	markRootUpdated(v22, p2, p3)

	if v22 == v5 then
		v3.warnAboutRenderPhaseUpdatesInDEV(p)

		if reactFeatureFlags.deferRenderPhaseUpdateToNextBatch or bit32.band(v4, 16) == 0 then
			noLanes3 = mergeLanes(noLanes3, p2)
		end

		if v7 == 4 then
			v3.markRootSuspended(v22, noLanes)
		end
	end

	local currentPriorityLevel = getCurrentPriorityLevel()

	if p2 == syncLane then
		if bit32.band(v4, 8) == 0 or bit32.band(v4, 48) ~= 0 then
			fn(v22, p3)
			v3.schedulePendingInteractions(v22, p2)

			if v4 == 0 then
				resetRenderTimer() -- equivalent call inferred; original call site unknown
				flushSyncCallbackQueue()
			end
		else
			v3.schedulePendingInteractions(v22, p2)
			v3.performSyncWorkOnRoot(v22)
		end
	else
		if bit32.band(v4, 4) ~= 0 and (currentPriorityLevel == userBlockingPriority or currentPriorityLevel == immediatePriority) then
			if v17 == nil then
				v17 = set.new({ v22 })
			else
				v17:add(v22)
			end
		end

		fn(v22, p3)
		v3.schedulePendingInteractions(v22, p2)
	end

	v9 = v22
	return v22
end

function v3:markUpdateLaneFromFiberToRoot(p)
	self.lanes = mergeLanes(self.lanes, p)
	local alternate = self.alternate

	if alternate ~= nil then
		alternate.lanes = mergeLanes(alternate.lanes, p)
	end

	if __DEV__ and alternate == nil and bit32.band(
		self.flags,
		(bit32.bor(ReactFiberFlags.Placement, ReactFiberFlags.Hydrating))
	) ~= ReactFiberFlags.NoFlags then
		v3.warnAboutUpdateOnNotYetMountedFiberInDEV(self)
	end

	local return_ = self.return_
	local v22 = self

	while return_ ~= nil do
		return_.childLanes = mergeLanes(return_.childLanes, p)
		local alternate2 = return_.alternate

		if alternate2 == nil then
			if __DEV__ and bit32.band(return_.flags, (bit32.bor(ReactFiberFlags.Placement, ReactFiberFlags.Hydrating))) ~= ReactFiberFlags.NoFlags then
				v3.warnAboutUpdateOnNotYetMountedFiberInDEV(self)
			end
		else
			alternate2.childLanes = mergeLanes(alternate2.childLanes, p)
		end

		v22 = return_
		return_ = return_.return_
	end

	if v22.tag == ReactWorkTags.HostRoot then
		return v22.stateNode
	end

	return nil
end

fn = function(state, p: number)
	local callbackNode = state.callbackNode
	markStarvedLanesAsExpired(state, p)
	local v22

	if state == v5 then
		v22 = noLanes
	else
		v22 = ReactFiberLane.NoLanes
	end

	local nextLanes = getNextLanes(state, v22)
	local callbackPriority = returnNextLanesPriority()

	if nextLanes == ReactFiberLane.NoLanes then
		if callbackNode ~= nil then
			cancelCallback(callbackNode)
			state.callbackNode = nil
			state.callbackPriority = ReactFiberLane.NoLanePriority
		end
	else
		if callbackNode ~= nil then
			if state.callbackPriority == callbackPriority then
				return
			else
				cancelCallback(callbackNode)
			end
		end

		local callbackNode2

		if callbackPriority == ReactFiberLane.SyncLanePriority then
			callbackNode2 = scheduleSyncCallback(function()
				local profileRootBeforeUnitOfWork = RobloxReactProfiling.profileRootBeforeUnitOfWork(state)
				local v25 = v3.performSyncWorkOnRoot(state)
				RobloxReactProfiling.profileRootAfterYielding(profileRootBeforeUnitOfWork)
				return v25
			end)
		elseif callbackPriority == ReactFiberLane.SyncBatchedLanePriority then
			callbackNode2 = scheduleCallback(immediatePriority, function()
				local profileRootBeforeUnitOfWork = RobloxReactProfiling.profileRootBeforeUnitOfWork(state)
				local v25 = v3.performSyncWorkOnRoot(state)
				RobloxReactProfiling.profileRootAfterYielding(profileRootBeforeUnitOfWork)
				return v25
			end)
		else
			callbackNode2 = scheduleCallback(lanePriorityToSchedulerPriority(callbackPriority), function()
				local profileRootBeforeUnitOfWork = RobloxReactProfiling.profileRootBeforeUnitOfWork(state)
				local v26 = v3.performConcurrentWorkOnRoot(state)
				RobloxReactProfiling.profileRootAfterYielding(profileRootBeforeUnitOfWork)
				return v26
			end)
		end

		state.callbackPriority = callbackPriority
		state.callbackNode = callbackNode2
	end
end

function v3:performConcurrentWorkOnRoot()
	v20 = noTimestamp
	noLanes6 = ReactFiberLane.NoLanes
	noLanes7 = ReactFiberLane.NoLanes
	invariant(bit32.band(v4, 48) == 0, "Should not already be working.")
	local callbackNode = self.callbackNode

	if New.flushPassiveEffects() and self.callbackNode ~= callbackNode then
		return nil
	end

	local v23

	if self == v5 then
		v23 = noLanes
	else
		v23 = ReactFiberLane.NoLanes
	end

	local finishedLanes = getNextLanes(self, v23)

	if finishedLanes == ReactFiberLane.NoLanes then
		return nil
	end

	local rootConcurrent = v3.renderRootConcurrent(self, finishedLanes)

	if includesSomeLane(noLanes2, noLanes3) then
		v3.prepareFreshStack(self, ReactFiberLane.NoLanes)
	elseif rootConcurrent ~= 0 then
		if rootConcurrent == 2 then
			v4 = bit32.bor(v4, 64)

			if self.hydrate then
				self.hydrate = false
				ReactFiberHostConfig.clearContainer(self.containerInfo)
			end

			finishedLanes = getLanesToRetrySynchronouslyOnError(self)

			if finishedLanes ~= ReactFiberLane.NoLanes then
				rootConcurrent = v3.renderRootSync(self, finishedLanes)
			end
		end

		if rootConcurrent == 1 then
			local v25 = v8
			v3.prepareFreshStack(self, ReactFiberLane.NoLanes)
			v3.markRootSuspended(self, finishedLanes)
			fn(self, now())
			error(v25)
		end

		self.finishedWork = self.current.alternate
		self.finishedLanes = finishedLanes
		v3.finishConcurrentRender(self, rootConcurrent, finishedLanes)
	end

	fn(self, now())

	if self.callbackNode == callbackNode then
		return function()
			local profileRootBeforeUnitOfWork = RobloxReactProfiling.profileRootBeforeUnitOfWork(self)
			local v25 = v3.performConcurrentWorkOnRoot(self)
			RobloxReactProfiling.profileRootAfterYielding(profileRootBeforeUnitOfWork)
			return v25
		end
	end

	return nil
end

local v22 = 0
local v23 = false

function shouldForceFlushFallbacksInDEV()
	return __DEV__ and v22 > 0
end

function v3:finishConcurrentRender(p2, p3)
	if p2 == 0 or p2 == 1 then
		invariant(false, "Root did not complete. This is a bug in React.")
	elseif p2 == 2 then
		v3.commitRoot(self)
	elseif p2 == 3 then
		v3.markRootSuspended(self, p3)

		if includesOnlyRetries(p3) and not shouldForceFlushFallbacksInDEV() then
			local v24 = v10 + 500 - now()

			if v24 > 10 then
				if getNextLanes(self, ReactFiberLane.NoLanes) ~= ReactFiberLane.NoLanes then
					return
				end

				local suspendedLanes = self.suspendedLanes

				if isSubsetOfLanes(suspendedLanes, p3) then
					self.timeoutHandle = ReactFiberHostConfig.scheduleTimeout(function()
						return v3.commitRoot(self)
					end, v24)
					return
				end

				markRootPinged(self, suspendedLanes, (New.requestEventTime()))
				return
			end
		end

		v3.commitRoot(self)
	elseif p2 == 4 then
		v3.markRootSuspended(self, p3)

		if includesOnlyTransitions(p3) then
			return
		end

		if not shouldForceFlushFallbacksInDEV() then
			local mostRecentEventTime = ReactFiberLane.getMostRecentEventTime(self, p3)
			local v24 = now() - mostRecentEventTime
			local v25 = jnd(v24) - v24

			if v25 > 10 then
				self.timeoutHandle = ReactFiberHostConfig.scheduleTimeout(function()
					return v3.commitRoot(self)
				end, v25)
				return
			end
		end

		v3.commitRoot(self)
	elseif p2 == 5 then
		v3.commitRoot(self)
	else
		invariant(false, "Unknown root exit status.")
	end
end

function v3.markRootSuspended(p, p2)
	local v25 = removeLanes(removeLanes(p2, noLanes4), noLanes3)
	ReactFiberLane.markRootSuspended(p, v25)
end

function v3:performSyncWorkOnRoot()
	invariant(bit32.band(v4, 48) == 0, "Should not already be working.")
	New.flushPassiveEffects()
	local finishedLanes, v25

	if self == v5 and includesSomeLane(self.expiredLanes, noLanes) then
		finishedLanes = noLanes
		v25 = v3.renderRootSync(self, finishedLanes)

		if includesSomeLane(noLanes2, noLanes3) then
			finishedLanes = getNextLanes(self, finishedLanes)
			v25 = v3.renderRootSync(self, finishedLanes)
		end
	else
		finishedLanes = getNextLanes(self, ReactFiberLane.NoLanes)
		v25 = v3.renderRootSync(self, finishedLanes)
	end

	if self.tag ~= legacyRoot and v25 == 2 then
		v4 = bit32.bor(v4, 64)

		if self.hydrate then
			self.hydrate = false
			ReactFiberHostConfig.clearContainer(self.containerInfo)
		end

		finishedLanes = getLanesToRetrySynchronouslyOnError(self)

		if finishedLanes ~= ReactFiberLane.NoLanes then
			v25 = v3.renderRootSync(self, finishedLanes)
		end
	end

	if v25 == 1 then
		local v26 = v8
		v3.prepareFreshStack(self, ReactFiberLane.NoLanes)
		v3.markRootSuspended(self, finishedLanes)
		fn(self, now())
		error(v26)
	end

	self.finishedWork = self.current.alternate
	self.finishedLanes = finishedLanes
	v3.commitRoot(self)
	fn(self, now())
	return nil
end

function New.flushRoot(p, p2)
	markRootExpired(p, p2)
	fn(p, now())

	if bit32.band(v4, 48) == 0 then
		resetRenderTimer() -- equivalent call inferred; original call site unknown
		flushSyncCallbackQueue()
	end
end

function New.getExecutionContext()
	return v4
end

function New.flushDiscreteUpdates()
	if bit32.band(v4, 49) == 0 then
		v3.flushPendingDiscreteUpdates()
		New.flushPassiveEffects()
	elseif __DEV__ and bit32.band(v4, 16) ~= 0 then
		console.error("unstable_flushDiscreteUpdates: Cannot flush updates when React is already rendering.")
	end
end

function New.deferredUpdates(callback)
	if not reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
		return runWithPriority(normalPriority, callback)
	end

	local currentUpdateLanePriority = getCurrentUpdateLanePriority()
	local selected, v25

	if __YOLO__ then
		setCurrentUpdateLanePriority(ReactFiberLane.DefaultLanePriority)
		selected = runWithPriority(normalPriority, callback)
		v25 = true
	else
		setCurrentUpdateLanePriority(ReactFiberLane.DefaultLanePriority)
		v25, selected = xpcall(runWithPriority, describeError, normalPriority, callback)
	end

	setCurrentUpdateLanePriority(currentUpdateLanePriority)

	if v25 then
		return selected
	end

	error(selected)
end

function v3.flushPendingDiscreteUpdates()
	if v17 ~= nil then
		local v24 = v17
		v17 = nil
		v24:forEach(function(p)
			markDiscreteUpdatesExpired(p)
			fn(p, now())
		end)
	end

	flushSyncCallbackQueue()
end

function New.batchedUpdates(callback, p)
	local v24 = v4
	v4 = bit32.bor(v4, 1)
	local v25, v26

	if __YOLO__ then
		v25 = callback(p)
		v26 = true
	else
		v26, v25 = xpcall(callback, describeError, p)
	end

	v4 = v24

	if v4 == 0 then
		resetRenderTimer() -- equivalent call inferred; original call site unknown
		flushSyncCallbackQueue()
	end

	if v26 then
		return v25
	end

	error(v25)
end

function New.batchedEventUpdates(callback, p)
	local v24 = v4
	v4 = bit32.bor(v4, 2)
	local v25, v26

	if __YOLO__ then
		v25 = callback(p)
		v26 = true
	else
		v26, v25 = xpcall(callback, describeError, p)
	end

	v4 = v24

	if v4 == 0 then
		resetRenderTimer() -- equivalent call inferred; original call site unknown
		flushSyncCallbackQueue()
	end

	if v26 then
		return v25
	end

	error(v25)
end

function New.discreteUpdates(callback, p, p2, p3, p4)
	local v24 = v4
	v4 = bit32.bor(v4, 4)

	if reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
		local currentUpdateLanePriority = getCurrentUpdateLanePriority()
		setCurrentUpdateLanePriority(ReactFiberLane.InputDiscreteLanePriority)
		local v25, v26 = xpcall(runWithPriority, describeError, userBlockingPriority, function()
			return callback(p, p2, p3, p4)
		end)
		setCurrentUpdateLanePriority(currentUpdateLanePriority)
		v4 = v24

		if v4 == 0 then
			resetRenderTimer() -- equivalent call inferred; original call site unknown
			flushSyncCallbackQueue()
		end

		if v25 then
			return v26
		end

		error(v26)
	else
		local v25, v26 = xpcall(runWithPriority, describeError, userBlockingPriority, function()
			return callback(p, p2, p3, p4)
		end)
		v4 = v24

		if v4 == 0 then
			resetRenderTimer() -- equivalent call inferred; original call site unknown
			flushSyncCallbackQueue()
		end

		if v25 then
			return v26
		end

		error(v26)
	end
end

function New.unbatchedUpdates(callback, p)
	local v24 = v4
	v4 = bit32.band(v4, 4294967294)
	v4 = bit32.bor(v4, 8)
	local v25, v26

	if __YOLO__ then
		v25 = callback(p)
		v26 = true
	else
		v26, v25 = xpcall(callback, describeError, p)
	end

	v4 = v24

	if v4 == 0 then
		resetRenderTimer() -- equivalent call inferred; original call site unknown
		flushSyncCallbackQueue()
	end

	if v26 then
		return v25
	end

	error(v25)
end

function New.flushSync(callback, p)
	local v24 = v4

	if bit32.band(v24, 48) == 0 then
		v4 = bit32.bor(v4, 1)

		if reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
			local currentUpdateLanePriority = getCurrentUpdateLanePriority()
			setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
			local v25, v26

			if __YOLO__ then
				v25 = true
				setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)

				if callback then
					v26 = runWithPriority(immediatePriority, function()
						return callback(p)
					end)
				end
			elseif callback then
				v25, v26 = xpcall(runWithPriority, describeError, immediatePriority, function()
					return callback(p)
				end)
			else
				v25 = true
			end

			setCurrentUpdateLanePriority(currentUpdateLanePriority)
			v4 = v24
			flushSyncCallbackQueue()

			if not v25 then
				error(v26)
			end

			return v26
		else
			local v25, v26

			if __YOLO__ then
				v25 = true

				if callback then
					v26 = runWithPriority(immediatePriority, function()
						return callback(p)
					end)
				end
			elseif callback then
				v25, v26 = xpcall(runWithPriority, describeError, immediatePriority, function()
					return callback(p)
				end)
			else
				v25 = true
			end

			v4 = v24
			flushSyncCallbackQueue()

			if not v25 then
				error(v26)
			end

			return v26
		end
	else
		if __DEV__ then
			console.error("flushSync was called from inside a lifecycle method. React cannot flush when React is already rendering. Consider moving this call to a scheduler task or micro task.")
		end

		return callback(p)
	end
end

function New.flushControlled(callback)
	local v24 = v4
	v4 = bit32.bor(v4, 1)

	if reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
		local currentUpdateLanePriority = getCurrentUpdateLanePriority()
		setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
		local v25, v26 = xpcall(runWithPriority, describeError, immediatePriority, callback)
		setCurrentUpdateLanePriority(currentUpdateLanePriority)
		v4 = v24

		if v4 == 0 then
			resetRenderTimer() -- equivalent call inferred; original call site unknown
			flushSyncCallbackQueue()
		end

		if not v25 then
			error(v26)
		end
	else
		local v25, v26 = xpcall(runWithPriority, describeError, immediatePriority, callback)
		v4 = v24

		if v4 == 0 then
			resetRenderTimer() -- equivalent call inferred; original call site unknown
			flushSyncCallbackQueue()
		end

		if not v25 then
			error(v26)
		end
	end
end

function New.pushRenderLanes(p, p2)
	push(cursor, New.subtreeRenderLanes, p)
	New.subtreeRenderLanes = mergeLanes(New.subtreeRenderLanes, p2)
	noLanes2 = mergeLanes(noLanes2, p2)
end

function New.popRenderLanes(p)
	New.subtreeRenderLanes = cursor.current
	pop(cursor, p)
end

function v3:prepareFreshStack(subtreeRenderLanes)
	self.finishedWork = nil
	self.finishedLanes = ReactFiberLane.NoLanes
	local timeoutHandle = self.timeoutHandle

	if timeoutHandle ~= ReactFiberHostConfig.noTimeout then
		self.timeoutHandle = ReactFiberHostConfig.noTimeout
		ReactFiberHostConfig.cancelTimeout(timeoutHandle)
	end

	if v6 ~= nil then
		local return_ = v6.return_

		while return_ ~= nil do
			unwindInterruptedWork(return_)
			return_ = return_.return_
		end
	end

	v5 = self
	v6 = ReactFibernew.createWorkInProgress(self.current, nil)
	noLanes = subtreeRenderLanes
	New.subtreeRenderLanes = subtreeRenderLanes
	noLanes2 = subtreeRenderLanes
	v7 = 0
	v8 = nil
	workInProgressRootSkippedLanes(ReactFiberLane.NoLanes)
	noLanes3 = ReactFiberLane.NoLanes
	noLanes4 = ReactFiberLane.NoLanes

	if reactFeatureFlags.enableSchedulerTracing then
		v19 = nil
	end

	if __DEV__ then
		ReactStrictModeWarningsnew.discardPendingWarnings()
	end
end

function v3.handleError(p, p2)
	while true do
		local return_ = v6
		local success, result = pcall(function()
			resetContextDependencies()

			if not v.resetHooksAfterThrowRef then
				initReactFiberHooks() -- equivalent call inferred; original call site unknown
			end

			v.resetHooksAfterThrowRef()
			resetCurrentFiber()
			reactCurrentOwner.current = nil

			if return_ == nil or return_.return_ == nil then
				v7 = 1
				v8 = p2
				v6 = nil
			else
				if reactFeatureFlags.enableProfilerTimer and bit32.band(return_.mode, ReactTypeOfMode.ProfileMode) ~= 0 then
					ReactProfilerTimernew.stopProfilerTimerIfRunningAndRecordDelta(return_, true)
				end

				throwException(p, return_.return_, return_, p2, noLanes, New.onUncaughtError, New.renderDidError)
				v3.completeUnitOfWork(return_)
			end
		end)

		if success then
			break
		end

		p2 = result

		if v6 == return_ and return_ ~= nil then
			return_ = return_.return_
			v6 = return_
		else
			return_ = v6
		end
	end
end

function v3.pushDispatcher()
	local current2 = reactCurrentDispatcher.current
	local reactCurrentDispatcher2 = reactCurrentDispatcher

	if not v.ContextOnlyDispatcherRef then
		initReactFiberHooks() -- equivalent call inferred; original call site unknown
	end

	reactCurrentDispatcher2.current = v.ContextOnlyDispatcherRef

	if current2 ~= nil then
		return current2
	end

	if not v.ContextOnlyDispatcherRef then
		initReactFiberHooks() -- equivalent call inferred; original call site unknown
	end

	return v.ContextOnlyDispatcherRef
end

function v3.popDispatcher(current2)
	reactCurrentDispatcher.current = current2
end

function v3.pushInteractions(p)
	if not reactFeatureFlags.enableSchedulerTracing then
		return nil
	end

	local current2 = __interactionsRef.current
	__interactionsRef.current = p.memoizedInteractions
	return current2
end

function v3.popInteractions(current2)
	if reactFeatureFlags.enableSchedulerTracing then
		__interactionsRef.current = current2
	end
end

function New.markCommitTimeOfFallback()
	v10 = now()
end

function New.markSkippedUpdateLanes(p)
	ReactFiberWorkInProgress.markSkippedUpdateLanes(p)
end

function New.renderDidSuspend()
	if v7 == 0 then
		v7 = 3
	end
end

function New.renderDidSuspendDelayIfPossible()
	if v7 == 0 or v7 == 3 then
		v7 = 4
	end

	if v5 ~= nil and (includesNonIdleWork(workInProgressRootSkippedLanes()) or includesNonIdleWork(noLanes3)) then
		v3.markRootSuspended(v5, noLanes)
	end
end

function New.renderDidError()
	if v7 ~= 5 then
		v7 = 2
	end
end

function New.renderHasNotSuspendedYet()
	return v7 == 0
end

function v3.renderRootSync(p, p2)
	local v24 = v4
	v4 = bit32.bor(v4, 16)
	local v25 = v3.pushDispatcher()

	if v5 ~= p or noLanes ~= p2 then
		v3.prepareFreshStack(p, p2)
		v3.startWorkOnPendingInteractions(p, p2)
	end

	local v26 = v3.pushInteractions(p)

	if __DEV__ and enableDebugTracing then
		DebugTracing.logRenderStarted(p2)
	end

	if enableSchedulingProfiler then
		SchedulingProfiler.markRenderStarted(p2)
	end

	while true do
		local v27 = nil
		local v28

		if __YOLO__ then
			v3.workLoopSync()
			v28 = true
		else
			v28, v27 = xpcall(v3.workLoopSync, describeError)
		end

		if v28 then
			resetContextDependencies()

			if reactFeatureFlags.enableSchedulerTracing then
				v3.popInteractions(v26)
			end

			v4 = v24
			v3.popDispatcher(v25)

			if v6 ~= nil then
				invariant(
					false,
					"Cannot commit an incomplete root. This error is likely caused by a bug in React. Please file an issue."
				)
			end

			if __DEV__ and enableDebugTracing then
				DebugTracing.logRenderStopped()
			end

			if enableSchedulingProfiler then
				SchedulingProfiler.markRenderStopped()
			end

			v5 = nil
			noLanes = ReactFiberLane.NoLanes
			return v7
		else
			v3.handleError(p, v27)
		end
	end
end

function v3.workLoopSync()
	while v6 ~= nil do
		v3.performUnitOfWork(v6)
	end
end

function v3.renderRootConcurrent(p, p2)
	local v24 = v4
	v4 = bit32.bor(v4, 16)
	local v25 = v3.pushDispatcher()

	if v5 ~= p or noLanes ~= p2 then
		resetRenderTimer() -- equivalent call inferred; original call site unknown
		v3.prepareFreshStack(p, p2)
		v3.startWorkOnPendingInteractions(p, p2)
	end

	local v26 = v3.pushInteractions(p)

	if __DEV__ and enableDebugTracing then
		DebugTracing.logRenderStarted(p2)
	end

	if enableSchedulingProfiler then
		SchedulingProfiler.markRenderStarted(p2)
	end

	while true do
		local v27, v28

		if __YOLO__ then
			v3.workLoopConcurrent()
			v27 = "break"
			v28 = true
		else
			v28, v27 = xpcall(v3.workLoopConcurrent, describeError)

			if v28 then
				v27 = "break"
			end
		end

		if v27 == "break" then
			resetContextDependencies()

			if reactFeatureFlags.enableSchedulerTracing then
				v3.popInteractions(v26)
			end

			v3.popDispatcher(v25)
			v4 = v24

			if __DEV__ and enableDebugTracing then
				DebugTracing.logRenderStopped()
			end

			if v6 == nil then
				if enableSchedulingProfiler then
					SchedulingProfiler.markRenderStopped()
				end

				v5 = nil
				noLanes = ReactFiberLane.NoLanes
				return v7
			else
				if enableSchedulingProfiler then
					SchedulingProfiler.markRenderYielded()
				end

				return 0
			end
		elseif not v28 then
			v3.handleError(p, v27)
		end
	end
end

function v3.workLoopConcurrent()
	while v6 ~= nil and not shouldYield() do
		v3.performUnitOfWork(v6)
	end
end

function v3:performUnitOfWork()
	local profileUnitOfWorkBefore = RobloxReactProfiling.profileUnitOfWorkBefore(self)
	local alternate = self.alternate
	setCurrentFiber(self)
	local v24

	if reactFeatureFlags.enableProfilerTimer and bit32.band(self.mode, ReactTypeOfMode.ProfileMode) ~= ReactTypeOfMode.NoMode then
		ReactProfilerTimernew.startProfilerTimer(self)
		v24 = v3.beginWork(alternate, self, New.subtreeRenderLanes)
		ReactProfilerTimernew.stopProfilerTimerIfRunningAndRecordDelta(self, true)
	else
		v24 = v3.beginWork(alternate, self, New.subtreeRenderLanes)
	end

	resetCurrentFiber()
	self.memoizedProps = self.pendingProps

	if v24 == nil then
		v3.completeUnitOfWork(self)
	else
		v6 = v24
	end

	reactCurrentOwner.current = nil
	RobloxReactProfiling.profileUnitOfWorkAfter(profileUnitOfWorkBefore)
end

function v3.completeUnitOfWork(state)
	while true do
		local alternate = state.alternate
		local return_ = state.return_

		if bit32.band(state.flags, ReactFiberFlags.Incomplete) == ReactFiberFlags.NoFlags then
			setCurrentFiber(state)
			local v24

			if reactFeatureFlags.enableProfilerTimer and bit32.band(state.mode, ReactTypeOfMode.ProfileMode) ~= ReactTypeOfMode.NoMode then
				ReactProfilerTimernew.startProfilerTimer(state)
				local subtreeRenderLanes = New.subtreeRenderLanes

				if not v.completeWorkRef then
					local v25 = v
					local ReactFiberCompleteWorknew = require(script.Parent["ReactFiberCompleteWork.new"])
					v25.completeWorkRef = ReactFiberCompleteWorknew.completeWork
				end

				v24 = v.completeWorkRef(alternate, state, subtreeRenderLanes)
				ReactProfilerTimernew.stopProfilerTimerIfRunningAndRecordDelta(state, false)
			else
				local subtreeRenderLanes = New.subtreeRenderLanes

				if not v.completeWorkRef then
					local v25 = v
					local ReactFiberCompleteWorknew = require(script.Parent["ReactFiberCompleteWork.new"])
					v25.completeWorkRef = ReactFiberCompleteWorknew.completeWork
				end

				v24 = v.completeWorkRef(alternate, state, subtreeRenderLanes)
			end

			resetCurrentFiber()

			if v24 ~= nil then
				v6 = v24
				break
			end
		else
			local v24 = unwindWork(state, New.subtreeRenderLanes)

			if v24 == nil then
				if reactFeatureFlags.enableProfilerTimer and bit32.band(state.mode, ReactTypeOfMode.ProfileMode) ~= ReactTypeOfMode.NoMode then
					ReactProfilerTimernew.stopProfilerTimerIfRunningAndRecordDelta(state, false)
					local actualDuration = state.actualDuration or 0
					local child = state.child

					while child ~= nil do
						actualDuration += child.actualDuration or 0
						child = child.sibling
					end

					state.actualDuration = actualDuration
				end

				if return_ ~= nil then
					return_.flags = bit32.bor(return_.flags, ReactFiberFlags.Incomplete)
					return_.subtreeFlags = ReactFiberFlags.NoFlags
					return_.deletions = nil
				end
			else
				v24.flags = bit32.band(v24.flags, ReactFiberFlags.HostEffectMask)
				v6 = v24
				break
			end
		end

		local sibling = state.sibling

		if sibling ~= nil then
			v6 = sibling
			break
		end

		v6 = return_

		if return_ == nil then
			if v7 == 0 then
				v7 = 5
			end

			break
		else
			state = return_
		end
	end
end

function v3.commitRoot(p)
	local currentPriorityLevel = getCurrentPriorityLevel()
	runWithPriority(immediatePriority, function()
		RobloxReactProfiling.profileCommitBefore()
		local commitRootImpl = v3.commitRootImpl(p, currentPriorityLevel)
		RobloxReactProfiling.profileCommitAfter()
		return commitRootImpl
	end)
	return nil
end

function v3:commitRootImpl(p)
	repeat
		New.flushPassiveEffects()
	until v15 == nil

	flushRenderPhaseStrictModeWarningsInDEV()
	invariant(bit32.band(v4, 48) == 0, "Should not already be working.")
	local finishedWork = self.finishedWork
	local finishedLanes = self.finishedLanes

	if __DEV__ and enableDebugTracing then
		DebugTracing.logCommitStarted(finishedLanes)
	end

	if enableSchedulingProfiler then
		SchedulingProfiler.markCommitStarted(finishedLanes)
	end

	if finishedWork == nil then
		if __DEV__ and enableDebugTracing then
			DebugTracing.logCommitStopped()
		end

		if enableSchedulingProfiler then
			SchedulingProfiler.markCommitStopped(self)
		end

		return nil
	else
		self.finishedWork = nil
		self.finishedLanes = ReactFiberLane.NoLanes
		invariant(
			finishedWork ~= self.current,
			"Cannot commit the same tree as before. This error is likely caused by a bug in React. Please file an issue."
		)
		self.callbackNode = nil
		local v24 = mergeLanes(finishedWork.lanes, finishedWork.childLanes)
		markRootFinished(self, v24)

		if v17 ~= nil and not hasDiscreteLanes(v24) and v17:has(self) then
			v17:delete(self)
		end

		if self == v5 then
			v5 = nil
			v6 = nil
			noLanes = ReactFiberLane.NoLanes
		end

		local v25 = bit32.band(
			finishedWork.subtreeFlags,
			(bit32.bor(
				ReactFiberFlags.BeforeMutationMask,
				ReactFiberFlags.MutationMask,
				ReactFiberFlags.LayoutMask,
				ReactFiberFlags.PassiveMask
			))
		) ~= ReactFiberFlags.NoFlags
		local v26 = bit32.band(
			finishedWork.flags,
			(bit32.bor(
				ReactFiberFlags.BeforeMutationMask,
				ReactFiberFlags.MutationMask,
				ReactFiberFlags.LayoutMask,
				ReactFiberFlags.PassiveMask
			))
		) ~= ReactFiberFlags.NoFlags

		if v25 or v26 then
			local v27

			if reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
				v27 = getCurrentUpdateLanePriority()
				setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
			end

			local v28 = v4
			v4 = bit32.bor(v4, 32)
			local v29 = v3.pushInteractions(self)
			reactCurrentOwner.current = nil
			v21 = ReactFiberHostConfig.prepareForCommit(self.containerInfo)
			flag3 = false
			v3.commitBeforeMutationEffects(finishedWork)
			v21 = nil

			if reactFeatureFlags.enableProfilerTimer then
				ReactProfilerTimernew.recordCommitTime()
			end

			v3.commitMutationEffects(finishedWork, self, p)

			if flag3 then
				ReactFiberHostConfig.afterActiveInstanceBlur()
			end

			ReactFiberHostConfig.resetAfterCommit(self.containerInfo)
			self.current = finishedWork

			if __DEV__ and enableDebugTracing then
				DebugTracing.logLayoutEffectsStarted(finishedLanes)
			end

			if enableSchedulingProfiler then
				SchedulingProfiler.markLayoutEffectsStarted(finishedLanes)
			end

			if __DEV__ then
				setCurrentFiber(finishedWork)
				invokeGuardedCallback(
					nil,
					recursivelyCommitLayoutEffects,
					nil,
					finishedWork,
					self,
					New.captureCommitPhaseError,
					New.schedulePassiveEffectCallback
				)

				if hasCaughtError() then
					local v30 = clearCaughtError()
					fn3(finishedWork, finishedWork, v30)
				end

				resetCurrentFiber()
			else
				local v30 = nil
				local v31

				if __YOLO__ then
					recursivelyCommitLayoutEffects(
						finishedWork,
						self,
						New.captureCommitPhaseError,
						New.schedulePassiveEffectCallback
					)
					v31 = true
				else
					v31, v30 = xpcall(
						recursivelyCommitLayoutEffects,
						describeError,
						finishedWork,
						self,
						New.captureCommitPhaseError,
						New.schedulePassiveEffectCallback
					)
				end

				if not v31 then
					fn3(finishedWork, finishedWork, v30)
				end
			end

			if __DEV__ and enableDebugTracing then
				DebugTracing.logLayoutEffectsStopped()
			end

			if enableSchedulingProfiler then
				SchedulingProfiler.markLayoutEffectsStopped()
			end

			if (bit32.band(finishedWork.subtreeFlags, ReactFiberFlags.PassiveMask) ~= ReactFiberFlags.NoFlags or bit32.band(
				finishedWork.flags,
				ReactFiberFlags.PassiveMask
			) ~= ReactFiberFlags.NoFlags) and not flag2 then
				flag2 = true
				scheduleCallback(normalPriority, function()
					New.flushPassiveEffects()
					return nil
				end)
			end

			requestPaint()

			if reactFeatureFlags.enableSchedulerTracing then
				v3.popInteractions(v29)
			end

			v4 = v28

			if reactFeatureFlags.decoupleUpdatePriorityFromScheduler and v27 ~= nil then
				setCurrentUpdateLanePriority(v27)
			end
		else
			self.current = finishedWork

			if reactFeatureFlags.enableProfilerTimer then
				ReactProfilerTimernew.recordCommitTime()
			end
		end

		local v27 = flag2

		if flag2 then
			flag2 = false
			v15 = self
			noLanes5 = finishedLanes
			v16 = p
		end

		local pendingLanes = self.pendingLanes

		if pendingLanes == ReactFiberLane.NoLanes then
			v14 = nil
		elseif reactFeatureFlags.enableSchedulerTracing then
			if v19 ~= nil then
				local v28 = v19
				v19 = nil

				for i = 1, #v28 do
					scheduleInteractions(self, v28[i], self.memoizedInteractions)
				end
			end

			v3.schedulePendingInteractions(self, pendingLanes)
		end

		if __DEV__ and enableDoubleInvokingEffects and not v27 then
			commitDoubleInvokeEffectsInDEV(self.current, false)
		end

		if reactFeatureFlags.enableSchedulerTracing and not v27 then
			v3.finishPendingInteractions(self, finishedLanes)
		end

		if pendingLanes == syncLane then
			if self == v18 then
				count += 1
			else
				count = 0
				v18 = self
			end
		else
			count = 0
		end

		onCommitRoot(finishedWork.stateNode, p)

		if __DEV__ then
			onCommitRoot2()
		end

		fn(self, now())

		if flag then
			flag = false
			local v28 = v13
			v13 = nil
			error(v28)
		end

		if bit32.band(v4, 8) == 0 then
			flushSyncCallbackQueue()
		end

		if __DEV__ and enableDebugTracing then
			DebugTracing.logCommitStopped()
		end

		if enableSchedulingProfiler then
			SchedulingProfiler.markCommitStopped(self)
		end

		return nil
	end
end

function v3.commitBeforeMutationEffects(sibling)
	while sibling ~= nil do
		if sibling.deletions ~= nil then
			v3.commitBeforeMutationEffectsDeletions(sibling.deletions)
		end

		if sibling.child ~= nil and bit32.band(sibling.subtreeFlags, ReactFiberFlags.BeforeMutationMask) ~= ReactFiberFlags.NoFlags then
			v3.commitBeforeMutationEffects(sibling.child)
		end

		if __DEV__ then
			setCurrentFiber(sibling)
			invokeGuardedCallback(nil, v3.commitBeforeMutationEffectsImpl, nil, sibling)

			if hasCaughtError() then
				local v24 = clearCaughtError()
				New.captureCommitPhaseError(sibling, sibling.return_, v24)
			end

			resetCurrentFiber()
		else
			local v24 = nil
			local v25

			if __YOLO__ then
				v3.commitBeforeMutationEffectsImpl(sibling)
				v25 = true
			else
				v25, v24 = xpcall(v3.commitBeforeMutationEffectsImpl, describeError, sibling)
			end

			if not v25 then
				New.captureCommitPhaseError(sibling, sibling.return_, v24)
			end
		end

		sibling = sibling.sibling
	end
end

function v3.commitBeforeMutationEffectsImpl(data)
	local alternate = data.alternate
	local flags = data.flags

	if not flag3 and v21 ~= nil and data.tag == ReactWorkTags.SuspenseComponent and ReactFiberCommitWorknew.isSuspenseBoundaryBeingHidden(
		alternate,
		data
	) and doesFiberContain(data, v21) then
		flag3 = true
		ReactFiberHostConfig.beforeActiveInstanceBlur()
	end

	if bit32.band(flags, ReactFiberFlags.Snapshot) ~= ReactFiberFlags.NoFlags then
		setCurrentFiber(data)
		commitBeforeMutationLifeCycles(alternate, data)
		resetCurrentFiber()
	end

	if bit32.band(flags, ReactFiberFlags.Passive) ~= ReactFiberFlags.NoFlags and not flag2 then
		flag2 = true
		scheduleCallback(normalPriority, function()
			New.flushPassiveEffects()
			return nil
		end)
	end
end

function v3.commitBeforeMutationEffectsDeletions(list)
	for i = 1, #list do
		if not doesFiberContain(list[i], v21) then
			continue
		end

		flag3 = true
		ReactFiberHostConfig.beforeActiveInstanceBlur()
	end
end

function v3.commitMutationEffects(sibling, p, p2)
	while sibling ~= nil do
		local deletions = sibling.deletions

		if deletions ~= nil then
			for _, deletion in deletions do
				local v24, v25 = xpcall(commitDeletion, describeError, p, deletion, sibling, p2)

				if not v24 then
					New.captureCommitPhaseError(deletion, sibling, v25)
				end
			end
		end

		if sibling.child ~= nil and bit32.band(sibling.subtreeFlags, ReactFiberFlags.MutationMask) ~= ReactFiberFlags.NoFlags then
			v3.commitMutationEffects(sibling.child, p, p2)
		end

		if __DEV__ then
			setCurrentFiber(sibling)
			invokeGuardedCallback(nil, v3.commitMutationEffectsImpl, nil, sibling, p, p2)

			if hasCaughtError() then
				local v24 = clearCaughtError()
				New.captureCommitPhaseError(sibling, sibling.return_, v24)
			end

			resetCurrentFiber()
		else
			local v24 = nil
			local v25

			if __YOLO__ then
				v3.commitMutationEffectsImpl(sibling, p, p2)
				v25 = true
			else
				v25, v24 = xpcall(v3.commitMutationEffectsImpl, describeError, sibling, p, p2)
			end

			if not v25 then
				New.captureCommitPhaseError(sibling, sibling.return_, v24)
			end
		end

		sibling = sibling.sibling
	end
end

function v3:commitMutationEffectsImpl(_, _)
	local flags = self.flags

	if bit32.band(flags, ReactFiberFlags.Ref) ~= 0 then
		local alternate = self.alternate

		if alternate ~= nil then
			commitDetachRef(alternate)
		end
	end

	local v24 = bit32.band(
		flags,
		(bit32.bor(ReactFiberFlags.Placement, ReactFiberFlags.Update, ReactFiberFlags.Hydrating))
	)

	if v24 == ReactFiberFlags.Placement then
		commitPlacement(self)
		self.flags = bit32.band(self.flags, (bit32.bnot(ReactFiberFlags.Placement)))
	elseif v24 == ReactFiberFlags.PlacementAndUpdate then
		commitPlacement(self)
		self.flags = bit32.band(self.flags, (bit32.bnot(ReactFiberFlags.Placement)))
		commitWork(self.alternate, self)
	elseif v24 == ReactFiberFlags.Update then
		commitWork(self.alternate, self)
	end
end

function v3.commitMutationEffectsDeletions(items, p, p2, p3)
	for _, item in items do
		local v24, v25 = xpcall(commitDeletion, describeError, p2, item, p, p3)

		if not v24 then
			New.captureCommitPhaseError(item, p, v25)
		end
	end
end

function New.schedulePassiveEffectCallback()
	if not flag2 then
		flag2 = true
		scheduleCallback(normalPriority, function()
			New.flushPassiveEffects()
			return nil
		end)
	end
end

local fn4

function New.flushPassiveEffects()
	if v16 == noPriority then
		return false
	end

	local v24

	if normalPriority < v16 then
		v24 = normalPriority
	else
		v24 = v16
	end

	v16 = noPriority

	if not reactFeatureFlags.decoupleUpdatePriorityFromScheduler then
		return runWithPriority(v24, fn4)
	end

	local currentUpdateLanePriority = getCurrentUpdateLanePriority()
	setCurrentUpdateLanePriority(schedulerPriorityToLanePriority(v24))
	local v25, v26

	if __YOLO__ then
		setCurrentUpdateLanePriority(schedulerPriorityToLanePriority(v24))
		v25 = runWithPriority(v24, fn4)
		v26 = true
	else
		v26, v25 = xpcall(runWithPriority, describeError, v24, fn4)
	end

	setCurrentUpdateLanePriority(currentUpdateLanePriority)

	if not v26 then
		error(v25)
	end

	return v25
end

local fn5

fn5 = function(p, sibling)
	while sibling ~= nil do
		local v24

		if reactFeatureFlags.enableProfilerTimer and reactFeatureFlags.enableProfilerCommitHooks and sibling.tag == ReactWorkTags.Profiler then
			v24 = v12
			v12 = sibling
		end

		local v25 = bit32.band(sibling.subtreeFlags, ReactFiberFlags.PassiveMask)

		if sibling.child ~= nil and v25 ~= ReactFiberFlags.NoFlags then
			fn5(p, sibling.child)
		end

		if bit32.band(sibling.flags, ReactFiberFlags.Passive) ~= ReactFiberFlags.NoFlags then
			if __DEV__ then
				setCurrentFiber(sibling)
				invokeGuardedCallback(nil, commitPassiveMount, nil, p, sibling)

				if hasCaughtError() then
					local v26 = clearCaughtError()
					New.captureCommitPhaseError(sibling, sibling.return_, v26)
				end

				resetCurrentFiber()
			else
				local v26 = nil
				local v27

				if __YOLO__ then
					commitPassiveMount(p, sibling)
					v27 = true
				else
					v27, v26 = xpcall(commitPassiveMount, describeError, p, sibling)
				end

				if not v27 then
					New.captureCommitPhaseError(sibling, sibling.return_, v26)
				end
			end
		end

		if reactFeatureFlags.enableProfilerTimer and reactFeatureFlags.enableProfilerCommitHooks and sibling.tag == ReactWorkTags.Profiler then
			if v24 ~= nil then
				v24.stateNode.passiveEffectDuration += sibling.stateNode.passiveEffectDuration
			end

			v12 = v24
		end

		sibling = sibling.sibling
	end
end

local flushPassiveUnmountEffects

flushPassiveUnmountEffects = function(sibling)
	while sibling ~= nil do
		local deletions = sibling.deletions

		if deletions ~= nil then
			for i = 1, #deletions do
				local deletion = deletions[i]
				v3.flushPassiveUnmountEffectsInsideOfDeletedTree(deletion, sibling)

				if not (enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2) then
					v3.detachFiberAfterEffects(deletion)
				end
			end

			if enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 1 then
				local alternate = sibling.alternate

				if alternate ~= nil then
					local child = alternate.child

					if child ~= nil then
						alternate.child = nil

						while true do
							local sibling2 = child.sibling
							child.sibling = nil

							if sibling2 == nil then
								break
							end

							child = sibling2
						end
					end
				end
			end
		end

		local child = sibling.child

		if child ~= nil and bit32.band(sibling.subtreeFlags, ReactFiberFlags.PassiveMask) ~= ReactFiberFlags.NoFlags then
			flushPassiveUnmountEffects(child)
		end

		if bit32.band(sibling.flags, ReactFiberFlags.Passive) ~= ReactFiberFlags.NoFlags then
			setCurrentFiber(sibling)
			commitPassiveUnmount(sibling)
			resetCurrentFiber()
		end

		sibling = sibling.sibling
	end
end

function v3.flushPassiveUnmountEffectsInsideOfDeletedTree(data, p)
	if bit32.band(data.subtreeFlags, ReactFiberFlags.PassiveStatic) ~= ReactFiberFlags.NoFlags or enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2 then
		local child = data.child

		while child ~= nil do
			local sibling = child.sibling
			v3.flushPassiveUnmountEffectsInsideOfDeletedTree(child, p)
			child = sibling
		end
	end

	if bit32.band(data.flags, ReactFiberFlags.PassiveStatic) ~= ReactFiberFlags.NoFlags then
		setCurrentFiber(data)
		commitPassiveUnmountInsideDeletedTree(data, p)
		resetCurrentFiber()
	end

	if enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2 then
		v3.detachFiberAfterEffects(data)
	end
end

fn4 = function()
	if v15 == nil then
		return false
	end

	local v24 = v15
	local v25 = noLanes5
	v15 = nil
	noLanes5 = ReactFiberLane.NoLanes
	invariant(bit32.band(v4, 48) == 0, "Cannot flush passive effects while already rendering.")

	if __DEV__ and enableDebugTracing then
		DebugTracing.logPassiveEffectsStarted(v25)
	end

	if enableSchedulingProfiler then
		SchedulingProfiler.markPassiveEffectsStarted(v25)
	end

	local v26 = v4
	v4 = bit32.bor(v4, 32)
	local v27 = v3.pushInteractions(v24)
	flushPassiveUnmountEffects(v24.current)
	fn5(v24, v24.current)

	if __DEV__ and enableDebugTracing then
		DebugTracing.logPassiveEffectsStopped()
	end

	if enableSchedulingProfiler then
		SchedulingProfiler.markPassiveEffectsStopped(v24)
	end

	if __DEV__ and enableDoubleInvokingEffects then
		commitDoubleInvokeEffectsInDEV(v24.current, true)
	end

	if reactFeatureFlags.enableSchedulerTracing then
		v3.popInteractions(v27)
		v3.finishPendingInteractions(v24, v25)
	end

	v4 = v26
	flushSyncCallbackQueue()

	if v15 == nil then
		count2 = 0
	else
		count2 += 1
	end

	return true
end

function New.isAlreadyFailedLegacyErrorBoundary(p)
	return v14 ~= nil and v14:has(p)
end

function New.markLegacyErrorBoundaryAsFailed(p)
	if v14 == nil then
		v14 = set.new({ p })
	else
		v14:add(p)
	end
end

local function prepareToThrowUncaughtError(p)
	if not flag then
		flag = true
		v13 = p
	end
end

New.onUncaughtError = prepareToThrowUncaughtError

fn3 = function(p, p2, p3)
	enqueueUpdate(p, (createRootErrorUpdate(p, createCapturedValue(p3, p2), syncLane, New.onUncaughtError)))
	local eventTime = New.requestEventTime()
	local v24 = v3.markUpdateLaneFromFiberToRoot(p, syncLane)

	if v24 ~= nil then
		markRootUpdated(v24, syncLane, eventTime)
		fn(v24, eventTime)
		v3.schedulePendingInteractions(v24, syncLane)
	end
end

function New.captureCommitPhaseError(p, return_, p2)
	if p.tag == ReactWorkTags.HostRoot then
		fn3(p, p, p2)
		return
	end

	if not skipUnmountedBoundaries then
		return_ = p.return_
	end

	while return_ ~= nil do
		if return_.tag == ReactWorkTags.HostRoot then
			fn3(return_, p, p2)
			break
		end

		if return_.tag == ReactWorkTags.ClassComponent then
			local type = return_.type
			local stateNode = return_.stateNode

			if typeof(type.getDerivedStateFromError) == "function" or typeof(stateNode.componentDidCatch) == "function" and not New.isAlreadyFailedLegacyErrorBoundary(stateNode) then
				enqueueUpdate(return_, (createClassErrorUpdate(return_, createCapturedValue(p2, p), syncLane)))
				local eventTime = New.requestEventTime()
				local v24 = v3.markUpdateLaneFromFiberToRoot(return_, syncLane)

				if v24 ~= nil then
					markRootUpdated(v24, syncLane, eventTime)
					fn(v24, eventTime)
					v3.schedulePendingInteractions(v24, syncLane)
				end

				break
			end
		end

		return_ = return_.return_
	end
end

function New.pingSuspendedRoot(p, p2, p3)
	local pingCache = p.pingCache

	if pingCache ~= nil then
		pingCache[p2] = nil
	end

	local eventTime = New.requestEventTime()
	markRootPinged(p, p3, eventTime)

	if v5 == p and isSubsetOfLanes(noLanes, p3) then
		if v7 == 4 or v7 == 3 and includesOnlyRetries(noLanes) and now() - v10 < 500 then
			v3.prepareFreshStack(p, ReactFiberLane.NoLanes)
		else
			noLanes4 = mergeLanes(noLanes4, p3)
		end
	end

	fn(p, eventTime)
	v3.schedulePendingInteractions(p, p3)
end

function retryTimedOutBoundary(p, p2)
	if p2 == ReactFiberLane.NoLane then
		p2 = requestRetryLane(p)
	end

	local eventTime = New.requestEventTime()
	local v24 = v3.markUpdateLaneFromFiberToRoot(p, p2)

	if v24 ~= nil then
		markRootUpdated(v24, p2, eventTime)
		fn(v24, eventTime)
		v3.schedulePendingInteractions(v24, p2)
	end
end

function New.resolveRetryWakeable(p, p2)
	local noLane = ReactFiberLane.NoLane
	local stateNode = p.stateNode

	if stateNode ~= nil then
		stateNode:delete(p2)
	end

	retryTimedOutBoundary(p, noLane)
end

function jnd(p: number)
	if p < 120 then
		return 120
	end

	if p < 480 then
		return 480
	end

	if p < 1080 then
		return 1080
	end

	if p < 1920 then
		return 1920
	end

	if p < 3000 then
		return 3000
	end

	if p < 4320 then
		return 4320
	end

	return math.ceil(p / 1960) * 1960
end

function v3.checkForNestedUpdates()
	if count > 50 then
		count = 0
		v18 = nil
		invariant(
			false,
			"Maximum update depth exceeded. This can happen when a component repeatedly calls setState inside componentWillUpdate or componentDidUpdate. React limits the number of nested updates to prevent infinite loops."
		)
	end

	if __DEV__ and count2 > 50 then
		count2 = 0
		console.error("Maximum update depth exceeded. This can happen when a component calls setState inside useEffect, but useEffect either doesn't have a dependency array, or one of the dependencies changes on every render.")
	end
end

function flushRenderPhaseStrictModeWarningsInDEV()
	if __DEV__ then
		ReactStrictModeWarningsnew.flushLegacyContextWarning()

		if reactFeatureFlags.warnAboutDeprecatedLifecycles then
			ReactStrictModeWarningsnew.flushPendingUnsafeLifecycleWarnings()
		end
	end
end

function commitDoubleInvokeEffectsInDEV(p, flag4: boolean)
	if __DEV__ and enableDoubleInvokingEffects then
		setCurrentFiber(p)
		invokeEffectsInDev(p, ReactFiberFlags.MountLayoutDev, invokeLayoutEffectUnmountInDEV)

		if flag4 then
			invokeEffectsInDev(p, ReactFiberFlags.MountPassiveDev, invokePassiveEffectUnmountInDEV)
		end

		invokeEffectsInDev(p, ReactFiberFlags.MountLayoutDev, invokeLayoutEffectMountInDEV)

		if flag4 then
			invokeEffectsInDev(p, ReactFiberFlags.MountPassiveDev, invokePassiveEffectMountInDEV)
		end

		resetCurrentFiber()
	end
end

function invokeEffectsInDev(sibling, p, callback)
	if __DEV__ and enableDoubleInvokingEffects then
		while sibling ~= nil do
			if sibling.child ~= nil and bit32.band(sibling.subtreeFlags, p) ~= ReactFiberFlags.NoFlags then
				invokeEffectsInDev(sibling.child, p, callback)
			end

			if bit32.band(sibling.flags, p) ~= ReactFiberFlags.NoFlags then
				callback(sibling)
			end

			sibling = sibling.sibling
		end
	end
end

local v24 = nil

function v3.warnAboutUpdateOnNotYetMountedFiberInDEV(data)
	if __DEV__ then
		if bit32.band(v4, 16) ~= 0 then
			return
		end

		if bit32.band(data.mode, (bit32.bor(ReactTypeOfMode.BlockingMode, ReactTypeOfMode.ConcurrentMode))) == 0 then
			return
		end

		local tag = data.tag

		if tag ~= ReactWorkTags.IndeterminateComponent and tag ~= ReactWorkTags.HostRoot and tag ~= ReactWorkTags.ClassComponent and tag ~= ReactWorkTags.FunctionComponent and tag ~= ReactWorkTags.ForwardRef and tag ~= ReactWorkTags.MemoComponent and tag ~= ReactWorkTags.SimpleMemoComponent and tag ~= ReactWorkTags.Block then
			return
		end

		local v25 = getComponentName(data.type) or "ReactComponent"

		if v24 == nil then
			v24 = {
				[v25] = true
			}
		elseif v24[v25] then
			return
		else
			v24[v25] = true
		end

		local current2 = ReactCurrentFiber.current
		local success, result = pcall(function()
			setCurrentFiber(data)
			console.error("Can't perform a React state update on a component that hasn't mounted yet. This indicates that you have a side-effect in your render function that asynchronously later calls tries to update the component. Move this work to useEffect instead.")
		end)

		if current2 then
			setCurrentFiber(data)
		else
			resetCurrentFiber()
		end

		if not success then
			error(result)
		end
	end
end

if __DEV__ and reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback then
	function v3.beginWork(p, p2, p3)
		local v25 = ReactFibernew.assignFiberPropertiesInDEV(nil, p2)
		local v26, v27 = xpcall(fn2, describeError, p, p2, p3)

		if v26 then
			return v27
		end

		if v27 ~= nil and typeof(v27) == "table" and typeof(v27.andThen) == "function" then
			error(v27)
		end

		resetContextDependencies()

		if not v.resetHooksAfterThrowRef then
			initReactFiberHooks() -- equivalent call inferred; original call site unknown
		end

		v.resetHooksAfterThrowRef()
		unwindInterruptedWork(p2)
		ReactFibernew.assignFiberPropertiesInDEV(p2, v25)

		if reactFeatureFlags.enableProfilerTimer and bit32.band(p2.mode, ReactTypeOfMode.ProfileMode) ~= 0 then
			ReactProfilerTimernew.startProfilerTimer(p2)
		end

		invokeGuardedCallback(nil, fn2, nil, p, p2, p3)

		if not hasCaughtError() then
			error(v27)
			return v27
		end

		local v28 = clearCaughtError()
		error(v28)
		return v27
	end
else
	v3.beginWork = fn2
end

local v25 = false
local v26 = __DEV__ and {} or nil

function v3.warnAboutRenderPhaseUpdatesInDEV(p)
	if __DEV__ and ReactCurrentFiber.isRendering and bit32.band(v4, 16) ~= 0 then
		if not v.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef then
			initReactFiberHooks() -- equivalent call inferred; original call site unknown
		end

		if not v.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef() then
			if p.tag == ReactWorkTags.FunctionComponent or p.tag == ReactWorkTags.ForwardRef or p.tag == ReactWorkTags.SimpleMemoComponent then
				local v27 = v6 and getComponentName(v6.type) or "Unknown"

				if v26[v27] == nil then
					v26[v27] = true
					local v28 = getComponentName(p.type) or "Unknown"
					console.error(
						"Cannot update a component (`%s`) while rendering a different component (`%s`). To locate the bad setState() call inside `%s`, follow the stack trace as described in https://reactjs.org/link/setstate-in-render",
						v28,
						v27,
						v27
					)
				end
			elseif p.tag == ReactWorkTags.ClassComponent and not v25 then
				console.error("Cannot update during an existing state transition (such as within `render`). Render methods should be a pure function of props and state.")
				v25 = true
			end
		end
	end
end

New.IsThisRendererActing = {
	current = false
}

function New.warnIfNotScopedWithMatchingAct(p)
	if __DEV__ and ReactFiberHostConfig.warnsIfNotActing == true and isSomeRendererActing.current == true and New.IsThisRendererActing.current ~= true then
		local current2 = ReactCurrentFiber.current
		local success, result = pcall(function()
			setCurrentFiber(p)
			console.error([[
It looks like you're using the wrong act() around your test interactions.
Be sure to use the matching version of act() corresponding to your renderer:

-- for react-roblox:
local React = require(Packages.React)
-- ...
React.TestUtils.act(function() ... end)

-- for react-test-renderer:
local TestRenderer = require(Packages.ReactTestRenderer)
-- ...
TestRenderer.act(function() ... end)]])
		end)

		if current2 then
			setCurrentFiber(p)
		else
			resetCurrentFiber()
		end

		if not success then
			error(result)
		end
	end
end

function New.warnIfNotCurrentlyActingEffectsInDEV(p)
	if __DEV__ and ReactFiberHostConfig.warnsIfNotActing == true and bit32.band(p.mode, ReactTypeOfMode.StrictMode) ~= ReactTypeOfMode.NoMode and isSomeRendererActing.current == false and New.IsThisRendererActing.current == false then
		console.error([=[
An update to %s ran an effect, but was not wrapped in act(...).

When testing, code that causes React state updates should be wrapped into act(...):

act(function()
  --[[ fire events that update state ]]
end)
--[[ assert on the output ]]

This ensures that you're testing the behavior the user would see in the real client. Learn more at https://reactjs.org/link/wrap-tests-with-act]=], getComponentName(p.type))
	end
end

function New.warnIfNotCurrentlyActingUpdatesInDEV(p)
	if __DEV__ and ReactFiberHostConfig.warnsIfNotActing == true and v4 == 0 and isSomeRendererActing.current == false and New.IsThisRendererActing.current == false then
		local success, result = pcall(function()
			setCurrentFiber(p)
			console.error([=[
An update to %s inside a test was not wrapped in act(...).

When testing, code that causes React state updates should be wrapped into act(...):

act(function()
  --[[ fire events that update state ]]
end)
--[[ assert on the output ]]

This ensures that you're testing the behavior the user would see in the client application. Learn more at https://reactjs.org/link/wrap-tests-with-act]=], getComponentName(p.type))
		end)

		if current then
			setCurrentFiber(p)
		else
			resetCurrentFiber()
		end

		if success then
			return result
		end
	end
end

local v27 = false

function New.warnIfUnmockedScheduler(p)
	if __DEV__ and v27 == false and Scheduler.unstable_flushAllWithoutAsserting == nil then
		if bit32.band(p.mode, ReactTypeOfMode.BlockingMode) == 0 and bit32.band(p.mode, ReactTypeOfMode.ConcurrentMode) == 0 then
			if reactFeatureFlags.warnAboutUnmockedScheduler == true then
				v27 = true
				console.error([[
Starting from React v18, the 'scheduler' module will need to be mocked to guarantee consistent behaviour across tests and client applications. For example, with Jest: 
jest.mock('scheduler', function() return require(Packages.Scheduler).unstable_mock end)

For more info, visit https://reactjs.org/link/mock-scheduler]])
			end
		else
			v27 = true
			console.error([[
In Concurrent or Sync modes, the 'scheduler' module needs to be mocked to guarantee consistent behaviour across tests and client application. For example, with Jest: 
jest.mock('scheduler', function() return require(Packages.Scheduler).unstable_mock end)

For more info, visit https://reactjs.org/link/mock-scheduler]])
		end
	end
end

function computeThreadID(p, p2)
	return p2 * 1000 + p.interactionThreadID
end

function New.markSpawnedWork(p)
	if not reactFeatureFlags.enableSchedulerTracing then
		return
	end

	if v19 == nil then
		v19 = { p }
	else
		table.insert(v19, p)
	end
end

function scheduleInteractions(p, p2, p3)
	if not reactFeatureFlags.enableSchedulerTracing then
		return
	end

	if p3.size > 0 then
		local pendingInteractionMap = p.pendingInteractionMap
		local v28 = pendingInteractionMap:get(p2)

		if v28 == nil then
			pendingInteractionMap:set(p2, set.new(p3))

			for _, v29 in p3 do
				v29.__count += 1
			end
		else
			p3:forEach(function(p4)
				if not v28:has(p4) then
					p4.__count += 1
				end

				v28:add(p4)
			end)
		end

		local current2 = __subscriberRef.current

		if current2 ~= nil then
			local v29 = computeThreadID(p, p2)
			current2.onWorkScheduled(p3, v29)
		end
	end
end

function v3.schedulePendingInteractions(p, p2)
	if not reactFeatureFlags.enableSchedulerTracing then
		return
	end

	scheduleInteractions(p, p2, __interactionsRef.current)
end

function v3:startWorkOnPendingInteractions(p2)
	if not reactFeatureFlags.enableSchedulerTracing then
		return
	end

	local memoizedInteractions = set.new()
	self.pendingInteractionMap:forEach(function(object, p3)
		if includesSomeLane(p2, p3) then
			object:forEach(function(p4)
				memoizedInteractions:add(p4)
			end)
		end
	end)
	self.memoizedInteractions = memoizedInteractions

	if memoizedInteractions.size > 0 then
		local current2 = __subscriberRef.current

		if current2 ~= nil then
			local v29 = computeThreadID(self, p2)
			local v30, v31 = xpcall(current2.onWorkStarted, describeError, memoizedInteractions, v29)

			if not v30 then
				scheduleCallback(immediatePriority, function()
					error(v31)
				end)
			end
		end
	end
end

function v3.finishPendingInteractions(data, p)
	if not reactFeatureFlags.enableSchedulerTracing then
		return
	end

	local pendingLanes = data.pendingLanes
	local current2 = nil
	local v28, v29

	if current2 == nil or not (data.memoizedInteractions.size > 0) then
		v28 = true
		v29 = nil
	else
		local v30 = computeThreadID(data, p)
		current2 = __subscriberRef.current
		v28, v29 = xpcall(current2.onWorkStopped, describeError, data.memoizedInteractions, v30)
	end

	local pendingInteractionMap = data.pendingInteractionMap
	pendingInteractionMap:forEach(function(object, p2)
		if not includesSomeLane(pendingLanes, p2) then
			pendingInteractionMap:delete(p2)
			object:forEach(function(p3)
				p3.__count -= 1

				if current2 ~= nil and p3.__count == 0 then
					local v30, v31 = xpcall(current2.onInteractionScheduledWorkCompleted, describeError, p3)

					if not v30 then
						scheduleCallback(immediatePriority, function()
							error(v31)
						end)
					end
				end
			end)
		end
	end)

	if not v28 then
		scheduleCallback(immediatePriority, function()
			error(v29)
		end)
	end
end

local v28 = false
local v29 = false
local unstable_flushAllWithoutAsserting = Scheduler.unstable_flushAllWithoutAsserting
local v30 = typeof(unstable_flushAllWithoutAsserting) == "function"

local function flushActWork()
	if unstable_flushAllWithoutAsserting == nil then
		local v31 = v28
		v28 = true
		local v32, v33 = xpcall(function()
			local v34 = false

			while New.flushPassiveEffects() do
				v34 = true
			end

			return v34
		end, describeError)
		v28 = v31

		if v32 then
			return v33
		end

		error(v33)
	else
		local v31 = v28
		v28 = true
		local v32, v33 = xpcall(unstable_flushAllWithoutAsserting, describeError)
		v28 = v31

		if v32 then
			return v33
		end

		error(v33)
	end
end

local flushWorkAndMicroTasks

flushWorkAndMicroTasks = function(callback)
	local v31, v32 = xpcall(flushActWork, describeError)

	if v31 then
		v31, v32 = xpcall(enqueueTask, describeError, function()
			if flushActWork() then
				flushWorkAndMicroTasks(callback)
			else
				callback()
			end
		end)
	end

	if not v31 then
		callback(v32)
	end
end

function New.act(callback)
	if not __DEV__ and not ReactGlobals.__ROACT_17_MOCK_SCHEDULER__ and v23 == false then
		v23 = true
		console.error("act(...) is not supported in production builds of React, and might not behave as expected.")
	end

	local v31 = v22
	v22 += 1
	local current2 = isSomeRendererActing.current
	local current3 = New.IsThisRendererActing.current
	local v32 = v29
	isSomeRendererActing.current = true
	New.IsThisRendererActing.current = true
	v29 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onDone()
		v22 -= 1
		isSomeRendererActing.current = current2
		New.IsThisRendererActing.current = current3
		v29 = v32

		if __DEV__ and v31 < v22 then
			console.error("You seem to have overlapping act() calls, this is not supported. Be sure to await previous act() calls before making a new one. ")
		end
	end

	local v33, v34 = xpcall(New.batchedUpdates, describeError, callback)

	if not v33 then
		onDone() -- equivalent call inferred; original call site unknown
		error(v34)
	end

	if v34 == nil or typeof(v34) ~= "table" or typeof(v34.andThen) ~= "function" then
		if __DEV__ and v34 ~= nil then
			console.error(
				"The callback passed to act(...) function must return nil, or a Promise. You returned %s",
				(tostring(v34))
			)
		end

		local v35, v36 = xpcall(function()
			if v22 == 1 and (v30 == false or current2 == false) then
				flushActWork()
			end

			onDone() -- equivalent call inferred; original call site unknown
		end, describeError)

		if not v35 then
			onDone() -- equivalent call inferred; original call site unknown
			error(v36)
		end

		return {
			andThen = function(self, callback2, _)
				if __DEV__ then
					console.error("Do not await the result of calling act(...) with sync logic, it is not a Promise.")
				end

				callback2()
			end
		}
	else
		local v35 = false

		if __DEV__ and typeof(Promise) ~= nil then
			Promise.resolve():andThen(function() end):andThen(function()
				if v35 == false then
					console.error("You called act(Promise.new(function() --[[ ... ]] end)) without :await() or :expect(). This could lead to unexpected testing behaviour, interleaving multiple act calls and mixing their scopes. You should - act(function() Promise.new(function() --[[ ... ]] end):await() end);")
				end
			end)
		end

		return {
			andThen = function(self, callback2, callback3)
				v35 = true
				return v34:andThen(function()
					if not (v22 > 1) and (v30 ~= true or current2 ~= true) then
						flushWorkAndMicroTasks(function(p)
							onDone() -- equivalent call inferred; original call site unknown

							if p then
								callback3(p)
							else
								callback2()
							end
						end)
						return
					end

					onDone() -- equivalent call inferred; original call site unknown
					callback2()
				end, function(p)
					onDone() -- equivalent call inferred; original call site unknown
					callback3(p)
				end)
			end
		}
	end
end

function v3:detachFiberAfterEffects()
	if enableNewTreeCleanupPath then
		local alternate = self.alternate

		if alternate ~= nil then
			self.alternate = nil
			v3.detachFiberAfterEffects(alternate)
		end
	end

	if enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2 then
		self.child = nil
		self.deletions = nil
		self.sibling = nil

		if __DEV__ then
			self._debugOwner = nil
		end

		if deletedTreeCleanUpLevel >= 3 then
			self.return_ = nil
			self.dependencies = nil
			self.memoizedProps = nil
			self.memoizedState = nil
			self.pendingProps = nil
			self.stateNode = nil
			self.updateQueue = nil
		end
	else
		self.child = nil
		self.deletions = nil
		self.dependencies = nil
		self.memoizedProps = nil
		self.memoizedState = nil
		self.pendingProps = nil
		self.sibling = nil
		self.stateNode = nil
		self.updateQueue = nil

		if __DEV__ then
			self._debugOwner = nil
		end
	end
end

return New