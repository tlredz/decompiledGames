local __DEV__ = _G.__DEV__
require(script.Parent.Parent:WaitForChild("shared"))
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local array = luaupolyfill.Array
local object = luaupolyfill.Object
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactRootTags = require(script.Parent:WaitForChild("ReactRootTags"))
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
require(script.Parent:WaitForChild("ReactFiberHostConfig"))
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local fundamentalComponent = ReactWorkTags.FundamentalComponent
require(script.Parent.Parent:WaitForChild("shared"))
local ReactFiberLane = require(script.Parent:WaitForChild("ReactFiberLane"))
require(script.Parent:WaitForChild("ReactFiberSuspenseComponent.new"))
local ReactFiberTreeReflection = require(script.Parent:WaitForChild("ReactFiberTreeReflection"))
local findCurrentHostFiber = ReactFiberTreeReflection.findCurrentHostFiber
local findCurrentHostFiberWithNoPortals = ReactFiberTreeReflection.findCurrentHostFiberWithNoPortals
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local get = shared2.ReactInstanceMap.get
local hostComponent = ReactWorkTags.HostComponent
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local suspenseComponent = ReactWorkTags.SuspenseComponent
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared3.getComponentName
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared4.invariant
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local describeError = shared5.describeError
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
local enableSchedulingProfiler = shared6.ReactFeatureFlags.enableSchedulingProfiler
local shared7 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSharedInternals = shared7.ReactSharedInternals
local ReactFiberHostConfig = require(script.Parent:WaitForChild("ReactFiberHostConfig"))
local getPublicInstance = ReactFiberHostConfig.getPublicInstance
local ReactFiberContextnew = require(script.Parent:WaitForChild("ReactFiberContext.new"))
local findCurrentUnmaskedContext = ReactFiberContextnew.findCurrentUnmaskedContext
local processChildContext = ReactFiberContextnew.processChildContext
local emptyContextObject = ReactFiberContextnew.emptyContextObject
local isContextProvider = ReactFiberContextnew.isContextProvider
local ReactFiberRootnew = require(script.Parent:WaitForChild("ReactFiberRoot.new"))
local createFiberRoot = ReactFiberRootnew.createFiberRoot
local ReactFiberDevToolsHooknew = require(script.Parent:WaitForChild("ReactFiberDevToolsHook.new"))
local injectInternals = ReactFiberDevToolsHooknew.injectInternals
local onScheduleRoot = ReactFiberDevToolsHooknew.onScheduleRoot
local ReactFiberWorkLoopnew = require(script.Parent:WaitForChild("ReactFiberWorkLoop.new"))
local requestEventTime = ReactFiberWorkLoopnew.requestEventTime
local requestUpdateLane = ReactFiberWorkLoopnew.requestUpdateLane
local scheduleUpdateOnFiber = ReactFiberWorkLoopnew.scheduleUpdateOnFiber
local flushRoot = ReactFiberWorkLoopnew.flushRoot
local batchedEventUpdates = ReactFiberWorkLoopnew.batchedEventUpdates
local batchedUpdates = ReactFiberWorkLoopnew.batchedUpdates
local unbatchedUpdates = ReactFiberWorkLoopnew.unbatchedUpdates
local flushSync = ReactFiberWorkLoopnew.flushSync
local flushControlled = ReactFiberWorkLoopnew.flushControlled
local deferredUpdates = ReactFiberWorkLoopnew.deferredUpdates
local discreteUpdates = ReactFiberWorkLoopnew.discreteUpdates
local flushDiscreteUpdates = ReactFiberWorkLoopnew.flushDiscreteUpdates
local flushPassiveEffects = ReactFiberWorkLoopnew.flushPassiveEffects
local warnIfNotScopedWithMatchingAct = ReactFiberWorkLoopnew.warnIfNotScopedWithMatchingAct
local warnIfUnmockedScheduler = ReactFiberWorkLoopnew.warnIfUnmockedScheduler
local isThisRendererActing = ReactFiberWorkLoopnew.IsThisRendererActing
local act = ReactFiberWorkLoopnew.act
local ReactUpdateQueuenew = require(script.Parent:WaitForChild("ReactUpdateQueue.new"))
local createUpdate = ReactUpdateQueuenew.createUpdate
local enqueueUpdate = ReactUpdateQueuenew.enqueueUpdate
local ReactCurrentFiber = require(script.Parent:WaitForChild("ReactCurrentFiber"))
local isRendering = ReactCurrentFiber.isRendering
local resetCurrentFiber = ReactCurrentFiber.resetCurrentFiber
local setCurrentFiber = ReactCurrentFiber.setCurrentFiber
local ReactTypeOfMode = require(script.Parent:WaitForChild("ReactTypeOfMode"))
local strictMode = ReactTypeOfMode.StrictMode
local syncLane = ReactFiberLane.SyncLane
local inputDiscreteHydrationLane = ReactFiberLane.InputDiscreteHydrationLane
local selectiveHydrationLane = ReactFiberLane.SelectiveHydrationLane
local noTimestamp = ReactFiberLane.NoTimestamp
local getHighestPriorityPendingLanes = ReactFiberLane.getHighestPriorityPendingLanes
local higherPriorityLane = ReactFiberLane.higherPriorityLane
local getCurrentUpdateLanePriority = ReactFiberLane.getCurrentUpdateLanePriority
local setCurrentUpdateLanePriority = ReactFiberLane.setCurrentUpdateLanePriority
local SchedulingProfiler = require(script.Parent:WaitForChild("SchedulingProfiler"))
local markRenderScheduled = SchedulingProfiler.markRenderScheduled
local New = {
	ReactRootTags = ReactRootTags,
	ReactWorkTags = ReactWorkTags,
	ReactTypeOfMode = ReactTypeOfMode,
	ReactFiberFlags = ReactFiberFlags,
	getNearestMountedFiber = ReactFiberTreeReflection.getNearestMountedFiber,
	findCurrentFiberUsingSlowPath = ReactFiberTreeReflection.findCurrentFiberUsingSlowPath
}
local ReactPortal = require(script.Parent:WaitForChild("ReactPortal"))
New.createPortal = ReactPortal.createPortal
local v, v2

if __DEV__ then
	v = {}
	v2 = false
else
	v = nil
	v2 = nil
end

local function getContextForSubtree(p)
	if not p then
		return emptyContextObject
	end

	local v3 = get(p)
	local currentUnmaskedContext = findCurrentUnmaskedContext(v3)

	if v3.tag ~= classComponent then
		return currentUnmaskedContext
	end

	local type = v3.type

	if isContextProvider(type) then
		return processChildContext(v3, type, currentUnmaskedContext)
	end

	return currentUnmaskedContext
end

local function findHostInstance(p)
	local v3 = get(p)

	if v3 == nil then
		if typeof(p.render) == "function" then
			invariant(false, "Unable to find node on an unmounted component.")
		else
			invariant(false, "Argument appears to not be a ReactComponent. Keys: %s", table.concat(object.keys(p)))
		end
	end

	local currentHostFiber = findCurrentHostFiber(v3)

	if currentHostFiber == nil then
		return nil
	end

	return currentHostFiber.stateNode
end

function New.createContainer(p, p2, flag: boolean, p3)
	return createFiberRoot(p, p2, flag, p3)
end

function New.updateContainer(none, state, p, callback)
	if __DEV__ then
		onScheduleRoot(state, none)
	end

	local current = state.current
	local v3 = requestEventTime()

	if __DEV__ and _G.__TESTEZ_RUNNING_TEST__ then
		warnIfUnmockedScheduler(current)
		warnIfNotScopedWithMatchingAct(current)
	end

	local v4 = requestUpdateLane(current)

	if enableSchedulingProfiler then
		markRenderScheduled(v4)
	end

	local v5

	if p then
		local v6 = get(p)
		v5 = findCurrentUnmaskedContext(v6)

		if v6.tag == classComponent then
			local type = v6.type

			if isContextProvider(type) then
				v5 = processChildContext(v6, type, v5)
			end
		end
	else
		v5 = emptyContextObject
	end

	if state.context == nil then
		state.context = v5
	else
		state.pendingContext = v5
	end

	if __DEV__ and isRendering and ReactCurrentFiber.current ~= nil and not v2 then
		v2 = true
		console.error([[
Render methods should be a pure function of props and state; triggering nested component updates from render is not allowed. If necessary, trigger nested updates in componentDidUpdate.

Check the render method of %s.]], getComponentName(ReactCurrentFiber.current.type) or "Unknown")
	end

	local update = createUpdate(v3, v4)

	if none == nil then
		none = object.None
	end

	update.payload = {
		element = none
	}

	if callback ~= nil then
		if __DEV__ and typeof(callback) ~= "function" then
			console.error(
				"render(...): Expected the last optional `callback` argument to be a function. Instead received: %s.",
				(tostring(callback))
			)
		end

		update.callback = callback
	end

	enqueueUpdate(current, update)
	scheduleUpdateOnFiber(current, v4, v3)
	return v4
end

New.batchedEventUpdates = batchedEventUpdates
New.batchedUpdates = batchedUpdates
New.unbatchedUpdates = unbatchedUpdates
New.deferredUpdates = deferredUpdates
New.discreteUpdates = discreteUpdates
New.flushDiscreteUpdates = flushDiscreteUpdates
New.flushControlled = flushControlled
New.flushSync = flushSync
New.flushPassiveEffects = flushPassiveEffects
New.IsThisRendererActing = isThisRendererActing
New.act = act

function New.getPublicRootInstance(p)
	local current = p.current

	if not current.child then
		return nil
	end

	if current.child.tag == hostComponent then
		return getPublicInstance(current.child.stateNode)
	end

	return current.child.stateNode
end

local fn

function New.attemptSynchronousHydration(p)
	if p.tag == hostRoot then
		local stateNode = p.stateNode

		if stateNode.hydrate then
			flushRoot(stateNode, (getHighestPriorityPendingLanes(stateNode)))
		end
	elseif p.tag == suspenseComponent then
		local v3 = requestEventTime()
		flushSync(function()
			return scheduleUpdateOnFiber(p, syncLane, v3)
		end)
		fn(p, inputDiscreteHydrationLane)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markRetryLaneImpl(p, p2)
	local memoizedState = p.memoizedState

	if memoizedState and memoizedState ~= nil and memoizedState.dehydrated ~= nil then
		memoizedState.retryLane = higherPriorityLane(memoizedState.retryLane, p2)
	end
end

fn = function(p, p2)
	markRetryLaneImpl(p, p2) -- equivalent call inferred; original call site unknown
	local alternate = p.alternate

	if alternate then
		markRetryLaneImpl(alternate, p2) -- equivalent call inferred; original call site unknown
	end
end

function New.attemptUserBlockingHydration(p)
	if p.tag ~= suspenseComponent then
		return
	end

	local inputDiscreteHydrationLane2 = inputDiscreteHydrationLane
	scheduleUpdateOnFiber(p, inputDiscreteHydrationLane2, (requestEventTime()))
	fn(p, inputDiscreteHydrationLane2)
end

function New.attemptContinuousHydration(p)
	if p.tag ~= suspenseComponent then
		return
	end

	local selectiveHydrationLane2 = selectiveHydrationLane
	scheduleUpdateOnFiber(p, selectiveHydrationLane2, (requestEventTime()))
	fn(p, selectiveHydrationLane2)
end

function New.attemptHydrationAtCurrentPriority(p)
	if p.tag ~= suspenseComponent then
		return
	end

	local v3 = requestEventTime()
	local v4 = requestUpdateLane(p)
	scheduleUpdateOnFiber(p, v4, v3)
	fn(p, v4)
end

function New.runWithPriority(p, callback)
	local currentUpdateLanePriority = getCurrentUpdateLanePriority()
	setCurrentUpdateLanePriority(p)
	local v3, v4 = xpcall(callback, describeError)
	setCurrentUpdateLanePriority(currentUpdateLanePriority)

	if not v3 then
		error(v4)
	end

	return v4
end

New.getCurrentUpdateLanePriority = getCurrentUpdateLanePriority
New.findHostInstance = findHostInstance

function New.findHostInstanceWithWarning(p, p2: string)
	if not __DEV__ then
		return (findHostInstance(p))
	end

	local v3 = get(p)

	if v3 == nil then
		if typeof(p.render) == "function" then
			invariant(false, "Unable to find node on an unmounted component.")
		else
			invariant(false, "Argument appears to not be a ReactComponent. Keys: %s", table.concat(object.keys(p)))
		end
	end

	local currentHostFiber = findCurrentHostFiber(v3)

	if currentHostFiber == nil then
		return nil
	end

	if bit32.band(currentHostFiber.mode, strictMode) == 0 then
		return currentHostFiber.stateNode
	end

	local v4 = getComponentName(v3.type) or "Component"

	if v[v4] then
		return currentHostFiber.stateNode
	end

	v[v4] = true
	local current = ReactCurrentFiber.current
	local v5, v6 = xpcall(function()
		setCurrentFiber(currentHostFiber)

		if bit32.band(v3.mode, strictMode) == 0 then
			console.error(
				"%s is deprecated in StrictMode. %s was passed an instance of %s which renders StrictMode children. Instead, add a ref directly to the element you want to reference. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-find-node",
				p2,
				p2,
				v4
			)
		else
			console.error(
				"%s is deprecated in StrictMode. %s was passed an instance of %s which is inside StrictMode. Instead, add a ref directly to the element you want to reference. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-find-node",
				p2,
				p2,
				v4
			)
		end
	end, describeError)

	if current then
		setCurrentFiber(current)
	else
		resetCurrentFiber()
	end

	if not v5 then
		error(v6)
	end

	return currentHostFiber.stateNode
end

function New.findHostInstanceWithNoPortals(p)
	local currentHostFiberWithNoPortals = findCurrentHostFiberWithNoPortals(p)

	if currentHostFiberWithNoPortals == nil then
		return nil
	end

	if currentHostFiberWithNoPortals.tag == fundamentalComponent then
		return currentHostFiberWithNoPortals.stateNode.instance
	end

	return currentHostFiberWithNoPortals.stateNode
end

local function shouldSuspendImpl(_)
	return false
end

function New.shouldSuspend(p)
	return shouldSuspendImpl(p)
end

local setSuspenseHandler, fn2, fn3, fn4, fn5, fn6, fn7, fn8

if __DEV__ then
	local copyWithDeleteImpl

	copyWithDeleteImpl = function(p, list, p2: number)
		local v3 = list[p2]
		local clone

		if array.isArray(p) then
			clone = array.slice(p)
		else
			clone = table.clone(p)
		end

		if p2 + 1 ~= #list then
			clone[v3] = copyWithDeleteImpl(p[v3], list, p2 + 1)
			return clone
		end

		if array.isArray(clone) then
			array.splice(clone, v3, 1)
			return clone
		end

		clone[v3] = nil
		return clone
	end

	local function copyWithDelete(p, p2)
		return (copyWithDeleteImpl(p, p2, 0))
	end

	local copyWithRenameImpl

	copyWithRenameImpl = function(p, list, p2, p3: number)
		local v3 = list[p3]
		local clone

		if array.isArray(p) then
			clone = array.slice(p)
		else
			clone = table.clone(p)
		end

		if p3 + 1 ~= #list then
			clone[v3] = copyWithRenameImpl(p[v3], list, p2, p3 + 1)
			return clone
		end

		clone[p2[p3]] = clone[v3]

		if array.isArray(clone) then
			array.splice(clone, v3, 1)
			return clone
		end

		clone[v3] = nil
		return clone
	end

	local function copyWithRename(p, list, list2)
		if #list ~= #list2 then
			console.warn("copyWithRename() expects paths of the same length")
			return nil
		end

		for i = 1, #list2 do
			if list[i] == list2[i] then
				continue
			end

			console.warn("copyWithRename() expects paths to be the same except for the deepest key")
			return nil
		end

		return (copyWithRenameImpl(p, list, list2, 0))
	end

	local copyWithSetImpl

	copyWithSetImpl = function(p, list, p2: number, p3)
		if #list + 1 <= p2 then
			return p3
		end

		local v3 = list[p2]
		local clone

		if array.isArray(p) then
			clone = array.slice(p)
		else
			clone = table.clone(p)
		end

		clone[v3] = copyWithSetImpl(p[v3], list, p2 + 2, p3)
		return clone
	end

	local function copyWithSet(p, p2, p3)
		return (copyWithSetImpl(p, p2, 1, p3))
	end

	local function findHook(p, p2: number)
		local memoizedState = p.memoizedState

		while memoizedState ~= nil and p2 > 1 do
			memoizedState = memoizedState.next
			p2 -= 1
		end

		return memoizedState
	end

	setSuspenseHandler = function(callback)
		shouldSuspendImpl = callback
	end

	fn2 = function(state, p: number, p2, p3)
		local memoizedState = state.memoizedState

		while memoizedState ~= nil and p > 1 do
			memoizedState = memoizedState.next
			p -= 1
		end

		if memoizedState ~= nil then
			local v3 = copyWithSetImpl(memoizedState.memoizedState, p2, 1, p3)
			memoizedState.memoizedState = v3
			memoizedState.baseState = v3
			state.memoizedProps = table.clone(state.memoizedProps)
			scheduleUpdateOnFiber(state, syncLane, noTimestamp)
		end
	end

	fn3 = function(state, p: number, p2)
		local memoizedState = state.memoizedState

		while memoizedState ~= nil and p > 1 do
			memoizedState = memoizedState.next
			p -= 1
		end

		if memoizedState ~= nil then
			local v3 = copyWithDeleteImpl(memoizedState.memoizedState, p2, 0)
			memoizedState.memoizedState = v3
			memoizedState.baseState = v3
			state.memoizedProps = table.clone(state.memoizedProps)
			scheduleUpdateOnFiber(state, syncLane, noTimestamp)
		end
	end

	fn4 = function(state, p: number, p2, p3)
		local memoizedState = state.memoizedState

		while memoizedState ~= nil and p > 1 do
			memoizedState = memoizedState.next
			p -= 1
		end

		if memoizedState ~= nil then
			local v3 = copyWithRename(memoizedState.memoizedState, p2, p3)
			memoizedState.memoizedState = v3
			memoizedState.baseState = v3
			state.memoizedProps = table.clone(state.memoizedProps)
			scheduleUpdateOnFiber(state, syncLane, noTimestamp)
		end
	end

	fn5 = function(state, p, p2)
		state.pendingProps = copyWithSetImpl(state.memoizedProps, p, 1, p2)
		local alternate = state.alternate

		if alternate then
			alternate.pendingProps = state.pendingProps
		end

		scheduleUpdateOnFiber(state, syncLane, noTimestamp)
	end

	fn6 = function(state, p)
		state.pendingProps = copyWithDeleteImpl(state.memoizedProps, p, 0)
		local alternate = state.alternate

		if alternate then
			alternate.pendingProps = state.pendingProps
		end

		scheduleUpdateOnFiber(state, syncLane, noTimestamp)
	end

	fn7 = function(state, p, p2)
		state.pendingProps = copyWithRename(state.memoizedProps, p, p2)
		local alternate = state.alternate

		if alternate then
			alternate.pendingProps = state.pendingProps
		end

		scheduleUpdateOnFiber(state, syncLane, noTimestamp)
	end

	fn8 = function(p)
		scheduleUpdateOnFiber(p, syncLane, noTimestamp)
	end
else
	fn2 = nil
	fn3 = nil
	fn4 = nil
	fn5 = nil
	fn6 = nil
	fn7 = nil
	setSuspenseHandler = nil
	fn8 = nil
end

function findHostInstanceByFiber(p)
	local currentHostFiber = findCurrentHostFiber(p)

	if currentHostFiber == nil then
		return nil
	end

	return currentHostFiber.stateNode
end

function emptyFindFiberByHostInstance(_)
	return nil
end

function getCurrentFiberForDevTools()
	return ReactCurrentFiber.current
end

function New.injectIntoDevTools(data)
	local findFiberByHostInstance = data.findFiberByHostInstance
	local reactCurrentDispatcher = reactSharedInternals.ReactCurrentDispatcher
	local getCurrentFiber

	if __DEV__ then
		getCurrentFiber = getCurrentFiberForDevTools
	end

	return injectInternals({
		bundleType = data.bundleType,
		version = data.version,
		rendererPackageName = data.rendererPackageName,
		rendererConfig = data.rendererConfig,
		overrideHookState = fn2,
		overrideHookStateDeletePath = fn3,
		overrideHookStateRenamePath = fn4,
		overrideProps = fn5,
		overridePropsDeletePath = fn6,
		overridePropsRenamePath = fn7,
		setSuspenseHandler = setSuspenseHandler,
		scheduleUpdate = fn8,
		currentDispatcherRef = reactCurrentDispatcher,
		findHostInstanceByFiber = findHostInstanceByFiber,
		findFiberByHostInstance = findFiberByHostInstance or emptyFindFiberByHostInstance,
		getCurrentFiber = getCurrentFiber
	})
end

New.robloxReactProfiling = require(script.Parent.RobloxReactProfiling)
return New