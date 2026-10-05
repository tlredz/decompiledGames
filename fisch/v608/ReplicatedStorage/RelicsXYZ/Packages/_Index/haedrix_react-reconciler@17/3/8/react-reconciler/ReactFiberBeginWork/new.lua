local function unimplemented(p: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring(p))
	error("FIXME (roblox): " .. p .. " is unimplemented", 2)
end

local parent = script.Parent.Parent
local Shared = require(parent.Shared)
local console = Shared.console
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local object = LuauPolyfill.Object
local inspect = LuauPolyfill.util.inspect
local ReactGlobals = require(parent.ReactGlobals)
local __DEV__ = ReactGlobals.__DEV__
local ReactGlobals2 = require(parent.ReactGlobals)
local __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ = ReactGlobals2.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
local ReactGlobals3 = require(parent.ReactGlobals)
local __COMPAT_WARNINGS__ = ReactGlobals3.__COMPAT_WARNINGS__
require(parent.Shared)
require(parent.React)
require(script.Parent.ReactInternalTypes)
local ReactFiberLane = require(script.Parent.ReactFiberLane)
require(script.Parent["ReactFiberSuspenseComponent.new"])
LuauPolyfill = require(script.Parent["ReactFiberSuspenseContext.new"])
require(script.Parent.ReactFiberOffscreenComponent)
local Shared2 = require(parent.Shared)
local checkPropTypes = Shared2.checkPropTypes
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local functionComponent = ReactWorkTags.FunctionComponent
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local hostComponent = ReactWorkTags.HostComponent
local hostText = ReactWorkTags.HostText
local hostPortal = ReactWorkTags.HostPortal
local forwardRef = ReactWorkTags.ForwardRef
local fragment = ReactWorkTags.Fragment
local mode = ReactWorkTags.Mode
local contextProvider = ReactWorkTags.ContextProvider
local contextConsumer = ReactWorkTags.ContextConsumer
local profiler = ReactWorkTags.Profiler
local suspenseComponent = ReactWorkTags.SuspenseComponent
local suspenseListComponent = ReactWorkTags.SuspenseListComponent
local memoComponent = ReactWorkTags.MemoComponent
local simpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local lazyComponent = ReactWorkTags.LazyComponent
local incompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local offscreenComponent = ReactWorkTags.OffscreenComponent
local legacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local ReactFiberFlags = require(script.Parent.ReactFiberFlags)
local noFlags = ReactFiberFlags.NoFlags
local staticMask = ReactFiberFlags.StaticMask
local performedWork = ReactFiberFlags.PerformedWork
local placement = ReactFiberFlags.Placement
local hydrating = ReactFiberFlags.Hydrating
local contentReset = ReactFiberFlags.ContentReset
local didCapture = ReactFiberFlags.DidCapture
local ref = ReactFiberFlags.Ref
local deletion = ReactFiberFlags.Deletion
local forceUpdateForLegacySuspense = ReactFiberFlags.ForceUpdateForLegacySuspense
local Shared3 = require(parent.Shared)
ReactFiberFlags = Shared3.ReactSharedInternals
local Shared4 = require(parent.Shared)
local reactFeatureFlags = Shared4.ReactFeatureFlags
local debugRenderPhaseSideEffectsForStrictMode = reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode
local disableLegacyContext = reactFeatureFlags.disableLegacyContext
local disableModulePatternComponents = reactFeatureFlags.disableModulePatternComponents
local enableProfilerTimer = reactFeatureFlags.enableProfilerTimer
local enableSchedulerTracing = reactFeatureFlags.enableSchedulerTracing
local enableSuspenseServerRenderer = reactFeatureFlags.enableSuspenseServerRenderer
local warnAboutDefaultPropsOnFunctionComponents = reactFeatureFlags.warnAboutDefaultPropsOnFunctionComponents
local Shared5 = require(parent.Shared)
local invariant = Shared5.invariant
local Shared6 = require(parent.Shared)
local describeError = Shared6.describeError
local Shared7 = require(parent.Shared)
local shallowEqual = Shared7.shallowEqual
local Shared8 = require(parent.Shared)
local getComponentName = Shared8.getComponentName
local Shared9 = require(parent.Shared)
reactFeatureFlags = Shared9.ReactSymbols
local REACT_LAZY_TYPE = reactFeatureFlags.REACT_LAZY_TYPE
local _ = reactFeatureFlags.getIteratorFn
local ReactStrictModeWarningsnew = require(script.Parent["ReactStrictModeWarnings.new"])
reactFeatureFlags = require(script.Parent.ReactCurrentFiber)
local getCurrentFiberOwnerNameInDevOrNull = reactFeatureFlags.getCurrentFiberOwnerNameInDevOrNull
local setIsRendering = reactFeatureFlags.setIsRendering
reactFeatureFlags = require(script.Parent["ReactFiberHotReloading.new"])
local resolveFunctionForHotReloading = reactFeatureFlags.resolveFunctionForHotReloading
local resolveForwardRefForHotReloading = reactFeatureFlags.resolveForwardRefForHotReloading
local resolveClassForHotReloading = reactFeatureFlags.resolveClassForHotReloading
reactFeatureFlags = require(script.Parent["ReactChildFiber.new"])
local mountChildFibers = reactFeatureFlags.mountChildFibers
local reconcileChildFibers = reactFeatureFlags.reconcileChildFibers
local cloneChildFibers = reactFeatureFlags.cloneChildFibers
reactFeatureFlags = require(script.Parent["ReactUpdateQueue.new"])
local processUpdateQueue = reactFeatureFlags.processUpdateQueue
local cloneUpdateQueue = reactFeatureFlags.cloneUpdateQueue
local initializeUpdateQueue = reactFeatureFlags.initializeUpdateQueue
reactFeatureFlags = require(script.Parent.ReactTypeOfMode)
local concurrentMode = reactFeatureFlags.ConcurrentMode
local noMode = reactFeatureFlags.NoMode
local profileMode = reactFeatureFlags.ProfileMode
local strictMode = reactFeatureFlags.StrictMode
local blockingMode = reactFeatureFlags.BlockingMode
reactFeatureFlags = require(script.Parent.ReactFiberHostConfig)
local shouldSetTextContent = reactFeatureFlags.shouldSetTextContent
local isSuspenseInstancePending = reactFeatureFlags.isSuspenseInstancePending
local isSuspenseInstanceFallback = reactFeatureFlags.isSuspenseInstanceFallback
local registerSuspenseInstanceRetry = reactFeatureFlags.registerSuspenseInstanceRetry
local supportsHydration = reactFeatureFlags.supportsHydration
reactFeatureFlags = require(script.Parent["ReactFiberHostContext.new"])
local pushHostContext = reactFeatureFlags.pushHostContext
local pushHostContainer = reactFeatureFlags.pushHostContainer
local suspenseStackCursor = LuauPolyfill.suspenseStackCursor
local hasSuspenseContext = LuauPolyfill.hasSuspenseContext
local forceSuspenseFallback = LuauPolyfill.ForceSuspenseFallback
local addSubtreeSuspenseContext = LuauPolyfill.addSubtreeSuspenseContext
local invisibleParentSuspenseContext = LuauPolyfill.InvisibleParentSuspenseContext
local pushSuspenseContext = LuauPolyfill.pushSuspenseContext
local setDefaultShallowSuspenseContext = LuauPolyfill.setDefaultShallowSuspenseContext
LuauPolyfill = require(script.Parent["ReactFiberNewContext.new"])
local propagateContextChange = LuauPolyfill.propagateContextChange
local readContext = LuauPolyfill.readContext
local calculateChangedBits = LuauPolyfill.calculateChangedBits
local prepareToReadContext = LuauPolyfill.prepareToReadContext
local pushProvider = LuauPolyfill.pushProvider
local v = {
	renderWithHooksRef = nil,
	bailoutHooksRef = nil,
	shouldSuspendRef = nil
}

local function shouldSuspend(p)
	if not v.shouldSuspendRef then
		local v2 = v
		local ReactFiberReconciler = require(script.Parent.ReactFiberReconciler)
		v2.shouldSuspendRef = ReactFiberReconciler.shouldSuspend
	end

	return v.shouldSuspendRef(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initReactFiberHooks()
	local ReactFiberHooksnew = require(script.Parent["ReactFiberHooks.new"])
	v.renderWithHooksRef = ReactFiberHooksnew.renderWithHooks
	v.bailoutHooksRef = ReactFiberHooksnew.bailoutHooks
end

local function renderWithHooks(...)
	if not v.renderWithHooksRef then
		initReactFiberHooks() -- equivalent call inferred; original call site unknown
	end

	return v.renderWithHooksRef(...)
end

local function bailoutHooks(...)
	if not v.bailoutHooksRef then
		initReactFiberHooks() -- equivalent call inferred; original call site unknown
	end

	return v.bailoutHooksRef(...)
end

local ReactProfilerTimernew = require(script.Parent["ReactProfilerTimer.new"])
local stopProfilerTimerIfRunning = ReactProfilerTimernew.stopProfilerTimerIfRunning
LuauPolyfill = require(script.Parent["ReactFiberContext.new"])
local getMaskedContext = LuauPolyfill.getMaskedContext
local getUnmaskedContext = LuauPolyfill.getUnmaskedContext
local hasContextChanged = LuauPolyfill.hasContextChanged
local pushContextProvider = LuauPolyfill.pushContextProvider
local isContextProvider = LuauPolyfill.isContextProvider
local pushTopLevelContextObject = LuauPolyfill.pushTopLevelContextObject
local invalidateContextProvider = LuauPolyfill.invalidateContextProvider
LuauPolyfill = require(script.Parent["ReactFiberHydrationContext.new"])
local resetHydrationState = LuauPolyfill.resetHydrationState
local enterHydrationState = LuauPolyfill.enterHydrationState
local reenterHydrationStateFromDehydratedSuspenseInstance = LuauPolyfill.reenterHydrationStateFromDehydratedSuspenseInstance
local tryToClaimNextHydratableInstance = LuauPolyfill.tryToClaimNextHydratableInstance
local warnIfHydrating = LuauPolyfill.warnIfHydrating
LuauPolyfill = require(script.Parent["ReactFiberClassComponent.new"])
local adoptClassInstance = LuauPolyfill.adoptClassInstance
local applyDerivedStateFromProps = LuauPolyfill.applyDerivedStateFromProps
local constructClassInstance = LuauPolyfill.constructClassInstance
local mountClassInstance = LuauPolyfill.mountClassInstance
local resumeMountClassInstance = LuauPolyfill.resumeMountClassInstance
local updateClassInstance = LuauPolyfill.updateClassInstance
local ReactFiberLazyComponentnew = require(script.Parent["ReactFiberLazyComponent.new"])
local resolveDefaultProps = ReactFiberLazyComponentnew.resolveDefaultProps
LuauPolyfill = require(script.Parent["ReactFiber.new"])
local resolveLazyComponentTag = LuauPolyfill.resolveLazyComponentTag
local createFiberFromFragment = LuauPolyfill.createFiberFromFragment
local createFiberFromOffscreen = LuauPolyfill.createFiberFromOffscreen
local createFiberFromTypeAndProps = LuauPolyfill.createFiberFromTypeAndProps
local isSimpleFunctionComponent = LuauPolyfill.isSimpleFunctionComponent
local createWorkInProgress = LuauPolyfill.createWorkInProgress
LuauPolyfill = require(script.Parent["ReactFiberWorkLoop.new"])
local pushRenderLanes = LuauPolyfill.pushRenderLanes
local markSpawnedWork = LuauPolyfill.markSpawnedWork
local retryDehydratedSuspenseBoundary = LuauPolyfill.retryDehydratedSuspenseBoundary
local scheduleUpdateOnFiber = LuauPolyfill.scheduleUpdateOnFiber
local renderDidSuspendDelayIfPossible = LuauPolyfill.renderDidSuspendDelayIfPossible
local getWorkInProgressRoot = LuauPolyfill.getWorkInProgressRoot
local getExecutionContext = LuauPolyfill.getExecutionContext
local retryAfterError = LuauPolyfill.RetryAfterError
local noContext = LuauPolyfill.NoContext
local unstable_wrap = nil
local ReactMutableSourcenew = require(script.Parent["ReactMutableSource.new"])
local setWorkInProgressVersion = ReactMutableSourcenew.setWorkInProgressVersion
local ReactFiberWorkInProgress = require(script.Parent.ReactFiberWorkInProgress)
local markSkippedUpdateLanes = ReactFiberWorkInProgress.markSkippedUpdateLanes
local Shared10 = require(parent.Shared)
LuauPolyfill = Shared10.ConsolePatchingDev
local disableLogs = LuauPolyfill.disableLogs
local reenableLogs = LuauPolyfill.reenableLogs
local reactCurrentOwner = ReactFiberFlags.ReactCurrentOwner
local New = {}
local bailoutOnAlreadyFinishedWork
local updateFunctionComponent
local v2 = false
local v3 = {
	didWarnAboutBadClass = {},
	didWarnAboutModulePatternComponent = {},
	didWarnAboutContextTypeOnFunctionComponent = {},
	didWarnAboutGetDerivedStateOnFunctionComponent = {},
	didWarnAboutFunctionRefs = {},
	didWarnAboutDefaultPropsOnFunctionComponent = {}
}
local updateSimpleMemoComponent

if __DEV__ then
	v3.didWarnAboutBadClass = {}
	v3.didWarnAboutModulePatternComponent = {}
	v3.didWarnAboutContextTypeOnFunctionComponent = {}
	v3.didWarnAboutGetDerivedStateOnFunctionComponent = {}
	v3.didWarnAboutFunctionRefs = {}
	New.didWarnAboutReassigningProps = false
	v3.didWarnAboutDefaultPropsOnFunctionComponent = {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reconcileChildren(p, p2, p3, p4)
	if p == nil then
		p2.child = mountChildFibers(p2, nil, p3, p4)
	else
		p2.child = reconcileChildFibers(p2, p.child, p3, p4)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forceUnmountCurrentAndReconcile(p, current, p2, p3)
	current.child = reconcileChildFibers(current, p.child, nil, p3)
	current.child = reconcileChildFibers(current, nil, p2, p3)
end

local function updateForwardRef(p, current, data, p2, p3)
	if (__DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__) and current.type ~= current.elementType then
		local propTypes = data.propTypes
		local validateProps = data.validateProps

		if propTypes or validateProps then
			checkPropTypes(propTypes, validateProps, p2, "prop", getComponentName(data))
		end
	end

	local render = data.render
	local ref2 = current.ref
	prepareToReadContext(current, p3, New.markWorkInProgressReceivedUpdate)
	local v4

	if __DEV__ then
		reactCurrentOwner.current = current
		setIsRendering(true)
		v4 = renderWithHooks(p, current, render, p2, ref2, p3)

		if debugRenderPhaseSideEffectsForStrictMode and bit32.band(current.mode, strictMode) ~= 0 then
			disableLogs()
			local v5, v6 = xpcall(renderWithHooks, describeError, p, current, render, p2, ref2, p3)

			if v5 then
				v4 = v6
			end

			reenableLogs()

			if not v5 then
				error(v6)
			end
		end

		setIsRendering(false)
	else
		v4 = renderWithHooks(p, current, render, p2, ref2, p3)
	end

	if p ~= nil and not v2 then
		bailoutHooks(p, current, p3)
		return bailoutOnAlreadyFinishedWork(p, current, p3)
	end

	current.flags = bit32.bor(current.flags, performedWork)
	reconcileChildren(p, current, v4, p3) -- equivalent call inferred; original call site unknown
	return current.child
end

local function updateMemoComponent(p, return_, data, p2, p3, p4)
	if p == nil then
		local type2 = data.type

		if isSimpleFunctionComponent(type2) and data.compare == nil and data.defaultProps == nil then
			local v4

			if __DEV__ then
				v4 = resolveFunctionForHotReloading(type2)
			else
				v4 = type2
			end

			return_.tag = simpleMemoComponent
			return_.type = v4

			if __DEV__ then
				validateFunctionComponentInDev(return_, type2)
			end

			return updateSimpleMemoComponent(nil, return_, v4, p2, p3, p4)
		else
			if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
				local propTypes, validateProps

				if type(type2) == "table" then
					propTypes = type2.propTypes
					validateProps = type2.validateProps
				end

				if propTypes or validateProps then
					checkPropTypes(propTypes, validateProps, p2, "prop", getComponentName(type2))
				end
			end

			local fiberFromTypeAndProps = createFiberFromTypeAndProps(data.type, nil, p2, return_, return_.mode, p4)
			fiberFromTypeAndProps.ref = return_.ref
			fiberFromTypeAndProps.return_ = return_
			return_.child = fiberFromTypeAndProps
			return fiberFromTypeAndProps
		end
	else
		if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
			local type2 = data.type
			local propTypes, validateProps

			if type(type2) == "table" then
				propTypes = type2.propTypes
				validateProps = type2.validateProps
			end

			if propTypes or validateProps then
				checkPropTypes(propTypes, validateProps, p2, "prop", getComponentName(type2))
			end
		end

		local child = p.child

		if not ReactFiberLane.includesSomeLane(p3, p4) then
			local memoizedProps = child.memoizedProps
			local compare = data.compare

			if compare == nil then
				compare = shallowEqual
			end

			if compare(memoizedProps, p2) and p.ref == return_.ref then
				return bailoutOnAlreadyFinishedWork(p, return_, p4)
			end
		end

		return_.flags = bit32.bor(return_.flags, performedWork)
		local workInProgress = createWorkInProgress(child, p2)
		workInProgress.ref = return_.ref
		workInProgress.return_ = return_
		return_.child = workInProgress
		return workInProgress
	end
end

updateSimpleMemoComponent = function(data, state, p, p2, p3, p4)
	if (__DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__) and state.type ~= state.elementType then
		local elementType = state.elementType

		if elementType["$$typeof"] == REACT_LAZY_TYPE then
			local _payload = elementType._payload
			local _init = elementType._init
			local v4, v5 = xpcall(_init, describeError, _payload)

			if not v4 then
				v5 = nil
			end

			local propTypes, validateProps

			if not (v5 == nil or type(v5) ~= "table") then
				propTypes = v5.propTypes
				validateProps = v5.validateProps
			end

			if propTypes or validateProps then
				checkPropTypes(propTypes, validateProps, p2, "prop", getComponentName(v5))
			end
		end
	end

	if data == nil then
		return updateFunctionComponent(nil, state, p, p2, p4)
	end

	local memoizedProps = data.memoizedProps
	local v4 = not __DEV__ or state.type == data.type

	if not (shallowEqual(memoizedProps, p2) and data.ref == state.ref and v4) then
		return updateFunctionComponent(data, state, p, p2, p4)
	end

	v2 = false

	if ReactFiberLane.includesSomeLane(p4, p3) then
		if bit32.band(data.flags, forceUpdateForLegacySuspense) ~= noFlags then
			v2 = true
		end
	else
		state.lanes = data.lanes
		return bailoutOnAlreadyFinishedWork(data, state, p4)
	end

	return updateFunctionComponent(data, state, p, p2, p4)
end

local function updateOffscreenComponent(data, state, baseLanes2)
	local pendingProps = state.pendingProps
	local children = pendingProps.children
	local memoizedState

	if data ~= nil then
		memoizedState = data.memoizedState
	end

	if pendingProps.mode == "hidden" or pendingProps.mode == "unstable-defer-without-hiding" then
		if bit32.band(state.mode, concurrentMode) == noMode then
			state.memoizedState = {
				baseLanes = ReactFiberLane.NoLanes
			}
			pushRenderLanes(state, baseLanes2)
		elseif ReactFiberLane.includesSomeLane(baseLanes2, ReactFiberLane.OffscreenLane) then
			state.memoizedState = {
				baseLanes = ReactFiberLane.NoLanes
			}
			local v4

			if memoizedState == nil then
				v4 = baseLanes2
			else
				v4 = memoizedState.baseLanes
			end

			pushRenderLanes(state, v4)
		else
			if memoizedState ~= nil then
				local baseLanes = memoizedState.baseLanes
				baseLanes2 = ReactFiberLane.mergeLanes(baseLanes, baseLanes2)
			end

			if enableSchedulerTracing then
				markSpawnedWork(ReactFiberLane.OffscreenLane)
			end

			state.childLanes = ReactFiberLane.laneToLanes(ReactFiberLane.OffscreenLane)
			state.lanes = state.childLanes
			state.memoizedState = {
				baseLanes = baseLanes2
			}
			pushRenderLanes(state, baseLanes2)
			return nil
		end
	else
		local v4

		if memoizedState == nil then
			v4 = baseLanes2
		else
			v4 = ReactFiberLane.mergeLanes(memoizedState.baseLanes, baseLanes2)
			state.memoizedState = nil
		end

		pushRenderLanes(state, v4)
	end

	reconcileChildren(data, state, children, baseLanes2) -- equivalent call inferred; original call site unknown
	return state.child
end

function updateFragment(p, p2, p3)
	reconcileChildren(p, p2, p2.pendingProps, p3) -- equivalent call inferred; original call site unknown
	return p2.child
end

function updateMode(p, p2, p3)
	reconcileChildren(p, p2, p2.pendingProps.children, p3) -- equivalent call inferred; original call site unknown
	return p2.child
end

function updateProfiler(p, data, p2)
	if enableProfilerTimer then
		local stateNode = data.stateNode
		stateNode.effectDuration = 0
		stateNode.passiveEffectDuration = 0
	end

	reconcileChildren(p, data, data.pendingProps.children, p2) -- equivalent call inferred; original call site unknown
	return data.child
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markRef(p, state)
	local ref2 = state.ref

	if p == nil and ref2 ~= nil or p ~= nil and p.ref ~= ref2 then
		state.flags = bit32.bor(state.flags, ref)
	end
end

updateFunctionComponent = function(p, current, value, p2, p3)
	if (__DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__) and type(value) ~= "function" and current.type ~= current.elementType then
		local propTypes, validateProps

		if type(value) == "table" then
			propTypes = value.propTypes
			validateProps = value.validateProps
		end

		if propTypes or validateProps then
			checkPropTypes(propTypes, validateProps, p2, "prop", getComponentName(value))
		end
	end

	local v4

	if not disableLegacyContext then
		v4 = getMaskedContext(current, (getUnmaskedContext(current, value, true)))
	end

	prepareToReadContext(current, p3, New.markWorkInProgressReceivedUpdate)
	local v5

	if __DEV__ then
		reactCurrentOwner.current = current
		setIsRendering(true)
		v5 = renderWithHooks(p, current, value, p2, v4, p3)

		if debugRenderPhaseSideEffectsForStrictMode and bit32.band(current.mode, strictMode) ~= 0 then
			disableLogs()
			local v6, v7 = xpcall(renderWithHooks, describeError, p, current, value, p2, v4, p3)
			reenableLogs()

			if v6 then
				v5 = v7
			else
				error(v7)
			end
		end

		setIsRendering(false)
	else
		v5 = renderWithHooks(p, current, value, p2, v4, p3)
	end

	if p ~= nil and not v2 then
		bailoutHooks(p, current, p3)
		return bailoutOnAlreadyFinishedWork(p, current, p3)
	end

	current.flags = bit32.bor(current.flags, performedWork)
	reconcileChildren(p, current, v5, p3) -- equivalent call inferred; original call site unknown
	return current.child
end

local function updateClassComponent(p, state, p2, p3, p4)
	if (__DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__) and state.type ~= state.elementType then
		local propTypes = p2.propTypes
		local validateProps = p2.validateProps

		if propTypes or validateProps then
			checkPropTypes(propTypes, validateProps, p3, "prop", getComponentName(p2))
		end
	end

	local v4

	if isContextProvider(p2) then
		pushContextProvider(state)
		v4 = true
	else
		v4 = false
	end

	prepareToReadContext(state, p4, New.markWorkInProgressReceivedUpdate)
	local v5

	if state.stateNode == nil then
		if p ~= nil then
			p.alternate = nil
			state.alternate = nil
			state.flags = bit32.bor(state.flags, placement)
		end

		constructClassInstance(state, p2, p3)
		mountClassInstance(state, p2, p3, p4)
		v5 = true
	elseif p == nil then
		v5 = resumeMountClassInstance(state, p2, p3, p4)
	else
		v5 = updateClassInstance(p, state, p2, p3, p4)
	end

	local v6 = finishClassComponent(p, state, p2, v5, v4, p4)

	if not __DEV__ then
		return v6
	end

	local stateNode = state.stateNode

	if v5 and stateNode.props ~= p3 then
		if not New.didWarnAboutReassigningProps then
			console.error(
				"It looks like %s is reassigning its own `this.props` while rendering. This is not supported and can lead to confusing bugs.",
				getComponentName(state.type) or "a component"
			)
		end

		New.didWarnAboutReassigningProps = true
	end

	return v6
end

function finishClassComponent(p, current, p2, flag: boolean, flag2: boolean, p3)
	markRef(p, current) -- equivalent call inferred; original call site unknown
	local v4 = bit32.band(current.flags, didCapture) ~= noFlags

	if flag or v4 then
		local stateNode = current.stateNode
		reactCurrentOwner.current = current
		local v5

		if v4 and (p2.getDerivedStateFromError == nil or type(p2.getDerivedStateFromError) ~= "function") then
			if enableProfilerTimer then
				stopProfilerTimerIfRunning(current)
			end
		elseif __DEV__ then
			setIsRendering(true)
			v5 = stateNode:render()

			if debugRenderPhaseSideEffectsForStrictMode and bit32.band(current.mode, strictMode) ~= 0 then
				disableLogs()
				local v6, v7 = xpcall(stateNode.render, describeError, stateNode)
				reenableLogs()

				if not v6 then
					error(v7)
				end
			end

			setIsRendering(false)
		else
			v5 = stateNode:render()
		end

		current.flags = bit32.bor(current.flags, performedWork)

		if p == nil or not v4 then
			reconcileChildren(p, current, v5, p3) -- equivalent call inferred; original call site unknown
		else
			forceUnmountCurrentAndReconcile(p, current, v5, p3) -- equivalent call inferred; original call site unknown
		end

		current.memoizedState = stateNode.state

		if flag2 then
			invalidateContextProvider(current, p2, true)
		end

		return current.child
	else
		if flag2 then
			invalidateContextProvider(current, p2, false)
		end

		return bailoutOnAlreadyFinishedWork(p, current, p3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushHostRootContext(state)
	local stateNode = state.stateNode

	if stateNode.pendingContext then
		pushTopLevelContextObject(state, stateNode.pendingContext, stateNode.pendingContext ~= stateNode.context)
	elseif stateNode.context then
		pushTopLevelContextObject(state, stateNode.context, false)
	end

	pushHostContainer(state, stateNode.containerInfo)
end

local function updateHostRoot(data, state, p)
	pushHostRootContext(state) -- equivalent call inferred; original call site unknown
	local updateQueue = state.updateQueue
	invariant(
		data ~= nil and updateQueue ~= nil,
		"If the root does not have an updateQueue, we should have already bailed out. This error is likely caused by a bug in React. Please file an issue."
	)
	local pendingProps = state.pendingProps
	local memoizedState = state.memoizedState
	local element

	if memoizedState ~= nil then
		element = memoizedState.element
	end

	cloneUpdateQueue(data, state)
	processUpdateQueue(state, pendingProps, nil, p)
	local element2 = state.memoizedState.element

	if element2 == element then
		resetHydrationState()
		return bailoutOnAlreadyFinishedWork(data, state, p)
	end

	local stateNode = state.stateNode

	if stateNode.hydrate and enterHydrationState(state) then
		if supportsHydration then
			local mutableSourceEagerHydrationData = stateNode.mutableSourceEagerHydrationData

			if mutableSourceEagerHydrationData ~= nil then
				for i = 1, #mutableSourceEagerHydrationData, 2 do
					setWorkInProgressVersion(mutableSourceEagerHydrationData[i], mutableSourceEagerHydrationData[i + 1])
				end
			end
		end

		local sibling = mountChildFibers(state, nil, element2, p)
		state.child = sibling

		while sibling do
			sibling.flags = bit32.bor(bit32.band(sibling.flags, (bit32.bnot(placement))), hydrating)
			sibling = sibling.sibling
		end
	else
		reconcileChildren(data, state, element2, p) -- equivalent call inferred; original call site unknown
		resetHydrationState()
	end

	return state.child
end

local function updateHostComponent(data, state, p)
	pushHostContext(state)

	if data == nil then
		tryToClaimNextHydratableInstance(state)
	end

	local type2 = state.type
	local pendingProps = state.pendingProps
	local memoizedProps

	if data ~= nil then
		memoizedProps = data.memoizedProps
	end

	local children = pendingProps.children

	if shouldSetTextContent(type2, pendingProps) then
		children = nil
	elseif memoizedProps ~= nil and shouldSetTextContent(type2, memoizedProps) then
		state.flags = bit32.bor(state.flags, contentReset)
	end

	state.flags = bit32.bor(state.flags, performedWork)
	markRef(data, state) -- equivalent call inferred; original call site unknown
	reconcileChildren(data, state, children, p) -- equivalent call inferred; original call site unknown
	return state.child
end

local function updateHostText(p, p2)
	if p == nil then
		tryToClaimNextHydratableInstance(p2)
	end

	return nil
end

local function mountLazyComponent(data, state, elementType, lanes, p)
	if data ~= nil then
		data.alternate = nil
		state.alternate = nil
		state.flags = bit32.bor(state.flags, placement)
	end

	local pendingProps = state.pendingProps
	local _payload = elementType._payload
	local _init = elementType._init(_payload)
	state.type = _init
	state.tag = resolveLazyComponentTag(_init)
	local tag = state.tag
	local defaultProps = resolveDefaultProps(_init, pendingProps)

	if tag == functionComponent then
		if __DEV__ then
			validateFunctionComponentInDev(state, _init)
			_init = resolveFunctionForHotReloading(_init)
			state.type = _init
		end

		return (updateFunctionComponent(nil, state, _init, defaultProps, p))
	elseif tag == classComponent then
		if __DEV__ then
			_init = resolveClassForHotReloading(_init)
			state.type = _init
		end

		return (updateClassComponent(nil, state, _init, defaultProps, p))
	elseif tag == forwardRef then
		if __DEV__ then
			_init = resolveForwardRefForHotReloading(_init)
			state.type = _init
		end

		return (updateForwardRef(nil, state, _init, defaultProps, p))
	elseif tag == memoComponent then
		if (__DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__) and state.type ~= state.elementType then
			local propTypes = _init.propTypes
			local validateProps = _init.validateProps

			if propTypes or validateProps then
				checkPropTypes(propTypes, validateProps, defaultProps, "prop", getComponentName(_init))
			end
		end

		return (updateMemoComponent(nil, state, _init, resolveDefaultProps(_init.type, defaultProps), lanes, p))
	else
		local v4 = ""

		if __DEV__ then
			if _init == nil or type(_init) ~= "table" or _init["$$typeof"] ~= REACT_LAZY_TYPE then
				if type(_init) == "table" and _init["$$typeof"] == nil then
					v4 = "\n" .. inspect(_init)
				end
			else
				v4 = " Did you wrap a component in React.lazy() more than once?"
			end
		end

		invariant(
			false,
			"Element type is invalid. Received a promise that resolves to: %s. Lazy element type must resolve to a class or function.%s",
			tostring(_init),
			v4
		)
		return nil
	end
end

function mountIncompleteClassComponent(p, p2, p3, p4, p5)
	if p ~= nil then
		p.alternate = nil
		p2.alternate = nil
		p2.flags = bit32.bor(p2.flags, placement)
	end

	p2.tag = classComponent
	local v4

	if isContextProvider(p3) then
		pushContextProvider(p2)
		v4 = true
	else
		v4 = false
	end

	prepareToReadContext(p2, p5, New.markWorkInProgressReceivedUpdate)
	constructClassInstance(p2, p3, p4)
	mountClassInstance(p2, p3, p4, p5)
	return finishClassComponent(nil, p2, p3, true, v4, p5)
end

local function mountIndeterminateComponent(data, current, type2, p)
	if data ~= nil then
		data.alternate = nil
		current.alternate = nil
		current.flags = bit32.bor(current.flags, placement)
	end

	local pendingProps = current.pendingProps
	local v4

	if not disableLegacyContext then
		v4 = getMaskedContext(current, (getUnmaskedContext(current, type2, false)))
	end

	prepareToReadContext(current, p, New.markWorkInProgressReceivedUpdate)
	local v5

	if __DEV__ then
		if type(type2) == "table" and type(type2.render) == "function" then
			local v6 = getComponentName(type2) or "Unknown"

			if not v3.didWarnAboutBadClass[v6] then
				console.error(
					"The <%s /> component appears to have a render method, but doesn't extend React.Component. This is likely to cause errors. Change %s to extend React.Component instead.",
					v6,
					v6
				)
				v3.didWarnAboutBadClass[v6] = true
			end
		end

		if bit32.band(current.mode, strictMode) ~= 0 then
			ReactStrictModeWarningsnew.recordLegacyContextWarning(current)
		end

		setIsRendering(true)
		reactCurrentOwner.current = current
		v5 = renderWithHooks(nil, current, type2, pendingProps, v4, p)
		setIsRendering(false)
	else
		v5 = renderWithHooks(nil, current, type2, pendingProps, v4, p)
	end

	current.flags = bit32.bor(current.flags, performedWork)
	local typeName = type(v5)

	if __DEV__ and v5 ~= nil and typeName == "table" and type(v5.render) == "function" and v5["$$typeof"] == nil then
		local v6 = getComponentName(type2) or "Unknown"

		if not v3.didWarnAboutModulePatternComponent[v6] then
			console.error(
				"The <%s /> component appears to be a function component that returns a class instance. Change %s to a class that extends React.Component instead. ",
				v6,
				v6
			)
			v3.didWarnAboutModulePatternComponent[v6] = true
		end
	end

	if disableModulePatternComponents or v5 == nil or typeName ~= "table" or type(v5.render) ~= "function" or v5["$$typeof"] ~= nil then
		current.tag = functionComponent

		if __DEV__ then
			if disableLegacyContext and type2.contextTypes then
				console.error(
					"%s uses the legacy contextTypes API which is no longer supported. Use React.createContext() with React.useContext() instead.",
					getComponentName(type2) or "Unknown"
				)
			end

			if debugRenderPhaseSideEffectsForStrictMode and bit32.band(current.mode, strictMode) ~= 0 then
				disableLogs()
				local v6, v7 = xpcall(renderWithHooks, describeError, nil, current, type2, pendingProps, v4, p)
				reenableLogs()

				if v6 then
					v5 = v7
				else
					error(v7)
				end
			end
		end

		current.child = mountChildFibers(current, nil, v5, p)

		if __DEV__ then
			validateFunctionComponentInDev(current, type2)
		end

		return current.child
	else
		if __DEV__ then
			local v6 = getComponentName(type2) or "Unknown"

			if not v3.didWarnAboutModulePatternComponent[v6] then
				console.error(
					"The <%s /> component appears to be a function component that returns a class instance. " .. "Change %s to a class that extends React.Component instead. " .. v6,
					v6
				)
				v3.didWarnAboutModulePatternComponent[v6] = true
			end
		end

		current.tag = classComponent
		current.memoizedState = nil
		current.updateQueue = nil
		local v6

		if isContextProvider(type2) then
			pushContextProvider(current)
			v6 = true
		else
			v6 = false
		end

		current.memoizedState = v5.state
		initializeUpdateQueue(current)
		local getDerivedStateFromProps

		if type(type2) ~= "function" then
			getDerivedStateFromProps = type2.getDerivedStateFromProps
		end

		if getDerivedStateFromProps ~= nil and type(getDerivedStateFromProps) == "function" then
			applyDerivedStateFromProps(current, type2, getDerivedStateFromProps, pendingProps)
		end

		adoptClassInstance(current, v5)
		mountClassInstance(current, type2, pendingProps, p)
		return finishClassComponent(nil, current, type2, true, v6, p)
	end
end

function validateFunctionComponentInDev(data, callback)
	if __DEV__ then
		if data.ref ~= nil then
			local v4 = ""
			local currentFiberOwnerNameInDevOrNull = getCurrentFiberOwnerNameInDevOrNull()

			if currentFiberOwnerNameInDevOrNull then
				v4 ..= [[


Check the render method of `]] .. currentFiberOwnerNameInDevOrNull .. "`."
			end

			local v5 = currentFiberOwnerNameInDevOrNull or data._debugID or ""
			local _debugSource = data._debugSource

			if _debugSource then
				v5 = _debugSource.fileName .. ":" .. _debugSource.lineNumber
			end

			if not v3.didWarnAboutFunctionRefs[v5] then
				v3.didWarnAboutFunctionRefs[v5] = true
				console.error(
					"Function components cannot be given refs. Attempts to access this ref will fail. Did you mean to use React.forwardRef()?%s",
					v4
				)
			end
		end

		if warnAboutDefaultPropsOnFunctionComponents and type(callback) ~= "function" and callback.defaultProps ~= nil then
			local v4 = getComponentName(callback) or "Unknown"

			if not v3.didWarnAboutDefaultPropsOnFunctionComponent[v4] then
				console.error(
					"%s: Support for defaultProps will be removed from function components in a future major release.",
					v4
				)
				v3.didWarnAboutDefaultPropsOnFunctionComponent[v4] = true
			end
		end

		if type(callback) ~= "function" and callback.getDerivedStateFromProps ~= nil and type(callback.getDerivedStateFromProps) == "function" then
			local v4 = getComponentName(callback) or "Unknown"

			if not v3.didWarnAboutGetDerivedStateOnFunctionComponent[v4] then
				console.error("%s: Function components do not support getDerivedStateFromProps.", v4)
				v3.didWarnAboutGetDerivedStateOnFunctionComponent[v4] = true
			end
		end

		if type(callback) ~= "function" and callback.contextType ~= nil and type(callback.contextType) == "table" then
			local v4 = getComponentName(callback) or "Unknown"

			if not v3.didWarnAboutContextTypeOnFunctionComponent[v4] then
				console.error("%s: Function components do not support contextType.", v4)
				v3.didWarnAboutContextTypeOnFunctionComponent[v4] = true
			end
		end
	end
end

local memoizedState3 = {
	dehydrated = nil,
	retryLane = ReactFiberLane.NoLane
}

local function mountSuspenseOffscreenState(baseLanes)
	return {
		baseLanes = baseLanes
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSuspenseOffscreenState(p, p2)
	return {
		baseLanes = ReactFiberLane.mergeLanes(p.baseLanes, p2)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldRemainOnFallback(current, data, _, _)
	if data == nil or data.memoizedState ~= nil then
		return hasSuspenseContext(current, forceSuspenseFallback)
	end

	return false
end

local function getRemainingWorkInPrimaryTree(p, p2)
	return ReactFiberLane.removeLanes(p.childLanes, p2)
end

local updateSuspensePrimaryChildren
local mountDehydratedSuspenseComponent
local mountSuspensePrimaryChildren
local updateSuspenseFallbackChildren
local updateDehydratedSuspenseComponent

local function updateSuspenseComponent(data, state, baseLanes)
	local pendingProps = state.pendingProps

	if __DEV__ then
		if not v.shouldSuspendRef then
			local v5 = v
			local ReactFiberReconciler = require(script.Parent.ReactFiberReconciler)
			v5.shouldSuspendRef = ReactFiberReconciler.shouldSuspend
		end

		if v.shouldSuspendRef(state) then
			state.flags = bit32.bor(state.flags, didCapture)
		end
	end

	local current = suspenseStackCursor.current
	local flag = false
	local v5 = bit32.band(state.flags, didCapture) ~= noFlags

	if v5 then
		state.flags = bit32.band(state.flags, (bit32.bnot(didCapture)))
		flag = true
	else
		-- equivalent call inferred; original call site unknown
		if shouldRemainOnFallback(current, data) then
			state.flags = bit32.band(state.flags, (bit32.bnot(didCapture)))
			flag = true
		elseif (data == nil or data.memoizedState ~= nil) and pendingProps.fallback ~= nil and pendingProps.unstable_avoidThisFallback ~= true then
			current = addSubtreeSuspenseContext(current, invisibleParentSuspenseContext)
		end
	end

	pushSuspenseContext(state, (setDefaultShallowSuspenseContext(current)))

	if data == nil then
		if pendingProps.fallback ~= nil then
			tryToClaimNextHydratableInstance(state)

			if enableSuspenseServerRenderer then
				local memoizedState = state.memoizedState

				if memoizedState ~= nil then
					local dehydrated = memoizedState.dehydrated

					if dehydrated ~= nil then
						return mountDehydratedSuspenseComponent(state, dehydrated, baseLanes)
					end
				end
			end
		end

		local children = pendingProps.children
		local fallback = pendingProps.fallback

		if flag then
			local v7 = mountSuspenseFallbackChildren(state, children, fallback, baseLanes)
			state.child.memoizedState = {
				baseLanes = baseLanes
			}
			state.memoizedState = memoizedState3
			return v7
		else
			if pendingProps.unstable_expectedLoadTime == nil or type(pendingProps.unstable_expectedLoadTime) ~= "number" then
				return mountSuspensePrimaryChildren(state, children, baseLanes)
			end

			local v7 = mountSuspenseFallbackChildren(state, children, fallback, baseLanes)
			state.child.memoizedState = {
				baseLanes = baseLanes
			}
			state.memoizedState = memoizedState3
			state.lanes = ReactFiberLane.SomeRetryLane

			if enableSchedulerTracing then
				markSpawnedWork(ReactFiberLane.SomeRetryLane)
			end

			return v7
		end
	else
		local memoizedState = data.memoizedState

		if memoizedState ~= nil and enableSuspenseServerRenderer then
			local dehydrated = memoizedState.dehydrated

			if dehydrated ~= nil then
				if not v5 then
					return updateDehydratedSuspenseComponent(data, state, dehydrated, memoizedState, baseLanes)
				end

				if state.memoizedState == nil then
					local children = pendingProps.children
					local fallback = pendingProps.fallback
					local v7 = mountSuspenseFallbackAfterRetryWithoutHydrating(
						data,
						state,
						children,
						fallback,
						baseLanes
					)
					state.child.memoizedState = {
						baseLanes = baseLanes
					}
					state.memoizedState = memoizedState3
					return v7
				else
					state.child = data.child
					state.flags = bit32.bor(state.flags, didCapture)
					return nil
				end
			end
		end

		if flag then
			local fallback = pendingProps.fallback
			local children = pendingProps.children
			local v7 = updateSuspenseFallbackChildren(data, state, children, fallback, baseLanes)
			local child = state.child
			local memoizedState2 = data.child.memoizedState

			if memoizedState2 == nil then
				child.memoizedState = {
					baseLanes = baseLanes
				}
			else
				child.memoizedState = updateSuspenseOffscreenState(memoizedState2, baseLanes)
			end

			child.childLanes = ReactFiberLane.removeLanes(data.childLanes, baseLanes)
			state.memoizedState = memoizedState3
			return v7
		else
			local children = pendingProps.children
			local v7 = updateSuspensePrimaryChildren(data, state, children, baseLanes)
			state.memoizedState = nil
			return v7
		end
	end
end

mountSuspensePrimaryChildren = function(return_, children, p)
	local fiberFromOffscreen = createFiberFromOffscreen({
		mode = "visible",
		children = children
	}, return_.mode, p, nil)
	fiberFromOffscreen.return_ = return_
	return_.child = fiberFromOffscreen
	return fiberFromOffscreen
end

function mountSuspenseFallbackChildren(return_, children, p2, p3)
	local mode2 = return_.mode
	local child = return_.child
	local pendingProps = {
		mode = "hidden",
		children = children
	}

	if bit32.band(mode2, blockingMode) == noMode and child ~= nil then
		child.childLanes = ReactFiberLane.NoLanes
		child.pendingProps = pendingProps

		if enableProfilerTimer and bit32.band(return_.mode, profileMode) ~= 0 then
			child.actualDuration = 0
			child.actualStartTime = -1
			child.selfBaseDuration = 0
			child.treeBaseDuration = 0
		end
	else
		child = createFiberFromOffscreen(pendingProps, mode2, ReactFiberLane.NoLanes, nil)
	end

	local fiberFromFragment = createFiberFromFragment(p2, mode2, p3, nil)
	child.return_ = return_
	fiberFromFragment.return_ = return_
	child.sibling = fiberFromFragment
	return_.child = child
	return fiberFromFragment
end

local function createWorkInProgressOffscreenFiber(p, p2)
	return createWorkInProgress(p, p2)
end

updateSuspensePrimaryChildren = function(data, return_, children, lanes)
	local child = data.child
	local sibling = child.sibling
	local workInProgress = createWorkInProgress(child, {
		mode = "visible",
		children = children
	})

	if bit32.band(return_.mode, blockingMode) == noMode then
		workInProgress.lanes = lanes
	end

	workInProgress.return_ = return_
	workInProgress.sibling = nil

	if sibling ~= nil then
		local deletions = return_.deletions

		if deletions == nil then
			return_.deletions = { sibling }
			return_.flags = bit32.bor(return_.flags, deletion)
		else
			table.insert(deletions, sibling)
		end
	end

	return_.child = workInProgress
	return workInProgress
end

updateSuspenseFallbackChildren = function(data, return_, children, fallback, p)
	local mode2 = return_.mode
	local child = data.child
	local sibling = child.sibling
	local pendingProps = {
		mode = "hidden",
		children = children
	}
	local child2

	if bit32.band(mode2, blockingMode) == noMode and return_.child ~= child then
		child2 = return_.child
		child2.childLanes = ReactFiberLane.NoLanes
		child2.pendingProps = pendingProps

		if enableProfilerTimer and bit32.band(return_.mode, profileMode) ~= 0 then
			child2.actualDuration = 0
			child2.actualStartTime = -1
			child2.selfBaseDuration = child.selfBaseDuration
			child2.treeBaseDuration = child.treeBaseDuration
		end

		return_.deletions = nil
	else
		child2 = createWorkInProgress(child, pendingProps)
		child2.subtreeFlags = bit32.band(child.subtreeFlags, staticMask)
	end

	local sibling2

	if sibling == nil then
		sibling2 = createFiberFromFragment(fallback, mode2, p, nil)
		sibling2.flags = bit32.bor(sibling2.flags, placement)
	else
		sibling2 = createWorkInProgress(sibling, fallback)
	end

	sibling2.return_ = return_
	child2.return_ = return_
	child2.sibling = sibling2
	return_.child = child2
	return sibling2
end

local function retrySuspenseComponentWithoutHydrating(p, p2, p3)
	reconcileChildFibers(p2, p.child, nil, p3)
	local children = p2.pendingProps.children
	local v5 = mountSuspensePrimaryChildren(p2, children, p3)
	v5.flags = bit32.bor(v5.flags, placement)
	p2.memoizedState = nil
	return v5
end

function mountSuspenseFallbackAfterRetryWithoutHydrating(p, return_, p2, p3, p4)
	local mode2 = return_.mode
	local fiberFromOffscreen = createFiberFromOffscreen(p2, mode2, ReactFiberLane.NoLanes, nil)
	local fiberFromFragment = createFiberFromFragment(p3, mode2, p4, nil)
	fiberFromFragment.flags = bit32.bor(fiberFromFragment.flags, placement)
	fiberFromOffscreen.return_ = return_
	fiberFromFragment.return_ = return_
	fiberFromOffscreen.sibling = fiberFromFragment
	return_.child = fiberFromOffscreen

	if bit32.band(return_.mode, blockingMode) ~= noMode then
		reconcileChildFibers(return_, p.child, nil, p4)
	end

	return fiberFromFragment
end

mountDehydratedSuspenseComponent = function(state, dehydrated, _)
	if bit32.band(state.mode, blockingMode) == noMode then
		if __DEV__ then
			console.error("Cannot hydrate Suspense in legacy mode. Switch fromReactDOM.hydrate(element, container) to ReactDOM.createBlockingRoot(container, { hydrate: true }).render(element) or remove the Suspense componentsthe server rendered components.")
		end

		state.lanes = ReactFiberLane.laneToLanes(ReactFiberLane.SyncLane)
	elseif isSuspenseInstanceFallback(dehydrated) then
		if enableSchedulerTracing then
			markSpawnedWork(ReactFiberLane.DefaultHydrationLane)
		end

		state.lanes = ReactFiberLane.laneToLanes(ReactFiberLane.DefaultHydrationLane)
	else
		state.lanes = ReactFiberLane.laneToLanes(ReactFiberLane.OffscreenLane)

		if enableSchedulerTracing then
			markSpawnedWork(ReactFiberLane.OffscreenLane)
		end
	end

	return nil
end

updateDehydratedSuspenseComponent = function(data, state, dehydrated, memoizedState, p)
	warnIfHydrating()

	if bit32.band(getExecutionContext(), retryAfterError) == noContext and bit32.band(state.mode, blockingMode) ~= noMode and not isSuspenseInstanceFallback(dehydrated) then
		local includesSomeLane = ReactFiberLane.includesSomeLane(p, data.childLanes)

		if v2 or includesSomeLane then
			local workInProgressRoot = getWorkInProgressRoot()

			if workInProgressRoot ~= nil then
				local bumpedLaneForHydration = ReactFiberLane.getBumpedLaneForHydration(workInProgressRoot, p)

				if bumpedLaneForHydration ~= ReactFiberLane.NoLane and bumpedLaneForHydration ~= memoizedState.retryLane then
					memoizedState.retryLane = bumpedLaneForHydration
					scheduleUpdateOnFiber(data, bumpedLaneForHydration, ReactFiberLane.NoTimestamp)
				end
			end

			renderDidSuspendDelayIfPossible()
			reconcileChildFibers(state, data.child, nil, p)
			local children = state.pendingProps.children
			local v5 = mountSuspensePrimaryChildren(state, children, p)
			v5.flags = bit32.bor(v5.flags, placement)
			state.memoizedState = nil
			return v5
		elseif isSuspenseInstancePending(dehydrated) then
			state.flags = bit32.bor(state.flags, didCapture)
			state.child = data.child

			local function fn()
				return retryDehydratedSuspenseBoundary(data)
			end

			if enableSchedulerTracing then
				if unstable_wrap == nil then
					local Scheduler = require(parent.Scheduler)
					unstable_wrap = Scheduler.tracing.unstable_wrap
				end

				fn = unstable_wrap(fn)
			end

			registerSuspenseInstanceRetry(dehydrated, fn)
			return nil
		else
			reenterHydrationStateFromDehydratedSuspenseInstance(state, dehydrated)
			local children = state.pendingProps.children
			local v5 = mountSuspensePrimaryChildren(state, children, p)
			v5.flags = bit32.bor(v5.flags, hydrating)
			return v5
		end
	end

	reconcileChildFibers(state, data.child, nil, p)
	local children = state.pendingProps.children
	local v5 = mountSuspensePrimaryChildren(state, children, p)
	v5.flags = bit32.bor(v5.flags, placement)
	state.memoizedState = nil
	return v5
end

function updatePortalComponent(p, state, p2)
	pushHostContainer(state, state.stateNode.containerInfo)
	local pendingProps = state.pendingProps

	if p == nil then
		state.child = reconcileChildFibers(state, nil, pendingProps, p2)
	else
		reconcileChildren(p, state, pendingProps, p2) -- equivalent call inferred; original call site unknown
	end

	return state.child
end

local v5 = false

local function updateContextProvider(data, data2, p)
	local _context = data2.type._context
	local pendingProps = data2.pendingProps
	local memoizedProps = data2.memoizedProps
	local value = pendingProps.value

	if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
		if array.indexOf(object.keys(pendingProps), "value") < 1 and not v5 then
			v5 = true
			console.error("The `value` prop is required for the `<Context.Provider>`. Did you misspell it or forget to pass it?")
		end

		local propTypes = data2.type.propTypes
		local validateProps = data2.type.validateProps

		if propTypes or validateProps then
			checkPropTypes(propTypes, validateProps, pendingProps, "prop", "Context.Provider")
		end
	end

	pushProvider(data2, value)

	if memoizedProps ~= nil then
		local v6 = calculateChangedBits(_context, value, memoizedProps.value)

		if v6 == 0 then
			if memoizedProps.children == pendingProps.children and not hasContextChanged() then
				return bailoutOnAlreadyFinishedWork(data, data2, p)
			end
		else
			propagateContextChange(data2, _context, v6, p)
		end
	end

	reconcileChildren(data, data2, pendingProps.children, p) -- equivalent call inferred; original call site unknown
	return data2.child
end

local v6 = {
	usingContextAsConsumer = false,
	usingLegacyConsumer = false
}

function updateContextConsumer(p, current, p2)
	local type2 = current.type

	if __DEV__ then
		if type2._context == nil then
			if type2 ~= type2.Consumer and not v6.usingContextAsConsumer then
				v6.usingContextAsConsumer = true
				console.error("Rendering <Context> directly is not supported and will be removed in a future major release. Did you mean to render <Context.Consumer> instead?")
			end
		else
			type2 = type2._context
		end
	end

	local pendingProps = current.pendingProps
	local render

	if pendingProps.render then
		if __DEV__ and __COMPAT_WARNINGS__ and not v6.usingLegacyConsumer then
			v6.usingLegacyConsumer = true
			console.warn([[
Your Context.Consumer component is using legacy Roact syntax, which won't be supported in future versions of Roact. 
Please provide no props and supply the 'render' function as a child (the 3rd argument of createElement). For example: 
       createElement(ContextConsumer, {render = function(...) end})
becomes:
       createElement(ContextConsumer, nil, function(...) end)
For more info, reference the React documentation here: 
https://reactjs.org/docs/context.html#contextconsumer]])
		end

		render = pendingProps.render
	else
		render = pendingProps.children
	end

	if __DEV__ and type(render) ~= "function" then
		console.error("A context consumer was rendered with multiple children, or a child that isn't a function. A context consumer expects a single child that is a function. If you did pass a function, make sure there is no trailing or leading whitespace around it.")
	end

	prepareToReadContext(current, p2, New.markWorkInProgressReceivedUpdate)
	local v7 = readContext(type2, pendingProps.unstable_observedBits)
	local v8

	if __DEV__ then
		reactCurrentOwner.current = current
		setIsRendering(true)
		v8 = render(v7)
		setIsRendering(false)
	else
		v8 = render(v7)
	end

	current.flags = bit32.bor(current.flags, performedWork)
	reconcileChildren(p, current, v8, p2) -- equivalent call inferred; original call site unknown
	return current.child
end

function New.markWorkInProgressReceivedUpdate()
	v2 = true
end

bailoutOnAlreadyFinishedWork = function(p, state, p2)
	if p then
		state.dependencies = p.dependencies
	end

	if enableProfilerTimer then
		stopProfilerTimerIfRunning(state)
	end

	markSkippedUpdateLanes(state.lanes)

	if not ReactFiberLane.includesSomeLane(p2, state.childLanes) then
		return nil
	end

	cloneChildFibers(p, state)
	return state.child
end

function remountFiber(p, state, p2)
	if not __DEV__ then
		error("Did not expect this call in production. This is a bug in React. Please file an issue.")
		return
	end

	local return_ = state.return_

	if return_ == nil then
		error("Cannot swap the root fiber.")
	end

	assert(return_ ~= nil, "returnFiber was nil in remountFiber")
	p.alternate = nil
	state.alternate = nil
	p2.index = state.index
	p2.sibling = state.sibling
	p2.return_ = state.return_
	p2.ref = state.ref

	if state == return_.child then
		return_.child = p2
	else
		local child = return_.child

		if child == nil then
			error("Expected parent to have a child.")
		end

		assert(child ~= nil, "prevSibling was nil in remountFiber")

		while child.sibling ~= state do
			child = child.sibling

			if child == nil then
				error("Expected to find the previous sibling.")
			end
		end

		child.sibling = p2
	end

	local deletions = return_.deletions

	if deletions == nil then
		return_.deletions = { p }
		return_.flags = bit32.bor(return_.flags, deletion)
	else
		table.insert(deletions, p)
	end

	p2.flags = bit32.bor(p2.flags, placement)
	return p2
end

function New.beginWork(data, state, p)
	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail2()
		if not (state.tag ~= offscreenComponent and state.tag ~= legacyHiddenComponent) then
			return (updateOffscreenComponent(data, state, p))
		end

		invariant(
			false,
			"Unknown unit of work tag (%s). This error is likely caused by a bug in React. Please file an issue.",
			(tostring(state.tag))
		)
		return nil
	end

	local lanes = state.lanes

	if __DEV__ and state._debugNeedsRemount and data ~= nil then
		return remountFiber(
			data,
			state,
			createFiberFromTypeAndProps(
				state.type,
				state.key,
				state.pendingProps,
				state._debugOwner or nil,
				state.mode,
				state.lanes
			)
		)
	end

	local elementType, type2, pendingProps, type3, pendingProps2, v7, type4, pendingProps3, type5, pendingProps4, v8, _, _, _, type6, pendingProps5, v9

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		local v10, propTypes, validateProps

		if (__DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__) and state.type ~= state.elementType then
			if type(type5) == "table" then
				propTypes = type5.propTypes
				validateProps = type5.validateProps
			end

			if propTypes or validateProps then
				checkPropTypes(propTypes, validateProps, v8, "prop", getComponentName(type5))
			end
		end

		v10 = resolveDefaultProps(type5.type, v8)
		return updateMemoComponent(data, state, type5, v10, lanes, p)
	end

	if data == nil then
		v2 = false
	else
		if data.memoizedProps == state.pendingProps and not hasContextChanged() then
			local v10

			if __DEV__ then
				v10 = state.type ~= data.type
			else
				v10 = false
			end

			if not v10 then
				if ReactFiberLane.includesSomeLane(p, lanes) then
					if bit32.band(data.flags, forceUpdateForLegacySuspense) == noFlags then
						v2 = false
					else
						v2 = true
					end

					state.lanes = ReactFiberLane.NoLanes

					if state.tag == ReactWorkTags.IndeterminateComponent then
						return mountIndeterminateComponent(data, state, state.type, p)
					end

					if state.tag == lazyComponent then
						elementType = state.elementType
						return (mountLazyComponent(data, state, elementType, lanes, p))
					end

					if state.tag == functionComponent then
						type2 = state.type
						pendingProps = state.pendingProps

						if state.elementType ~= type2 then
							pendingProps = resolveDefaultProps(type2, pendingProps)
						end

						return updateFunctionComponent(data, state, type2, pendingProps, p)
					elseif state.tag == classComponent then
						type3 = state.type
						pendingProps2 = state.pendingProps
						v7 = state.elementType == type3 and pendingProps2 or resolveDefaultProps(type3, pendingProps2)
						return (updateClassComponent(data, state, type3, v7, p))
					else
						if state.tag == hostRoot then
							return updateHostRoot(data, state, p)
						end

						if state.tag == hostComponent then
							return (updateHostComponent(data, state, p))
						end

						if state.tag == hostText then
							if data == nil then
								tryToClaimNextHydratableInstance(state)
							end

							return nil
						else
							if state.tag == suspenseComponent then
								return updateSuspenseComponent(data, state, p)
							end

							if state.tag == hostPortal then
								return updatePortalComponent(data, state, p)
							end

							if state.tag == forwardRef then
								type4 = state.type
								pendingProps3 = state.pendingProps

								if state.elementType ~= type4 then
									pendingProps3 = resolveDefaultProps(type4, pendingProps3)
								end

								return updateForwardRef(data, state, type4, pendingProps3, p)
							else
								if state.tag == fragment then
									return updateFragment(data, state, p)
								end

								if state.tag == mode then
									return updateMode(data, state, p)
								end

								if state.tag == profiler then
									return updateProfiler(data, state, p)
								end

								if state.tag == contextProvider then
									return updateContextProvider(data, state, p)
								end

								if state.tag == contextConsumer then
									return updateContextConsumer(data, state, p)
								end

								if state.tag == memoComponent then
									type5 = state.type
									pendingProps4 = state.pendingProps
									v8 = resolveDefaultProps(type5, pendingProps4)
									return deduplicatedTail()
								else
									if state.tag == simpleMemoComponent then
										return updateSimpleMemoComponent(
											data,
											state,
											state.type,
											state.pendingProps,
											lanes,
											p
										)
									end

									if state.tag == incompleteClassComponent then
										type6 = state.type
										pendingProps5 = state.pendingProps
										v9 = state.elementType == type6 and pendingProps5 or resolveDefaultProps(
											type6,
											pendingProps5
										)
										return mountIncompleteClassComponent(data, state, type6, v9, p)
									else
										return deduplicatedTail2()
									end
								end
							end
						end
					end
				else
					v2 = false

					if state.tag == hostRoot then
						pushHostRootContext(state) -- equivalent call inferred; original call site unknown
						resetHydrationState()
						return bailoutOnAlreadyFinishedWork(data, state, p)
					else
						if state.tag == hostComponent then
							pushHostContext(state)
							return bailoutOnAlreadyFinishedWork(data, state, p)
						end

						if state.tag == classComponent then
							if isContextProvider(state.type) then
								pushContextProvider(state)
							end

							return bailoutOnAlreadyFinishedWork(data, state, p)
						else
							if state.tag == hostPortal then
								pushHostContainer(state, state.stateNode.containerInfo)
								return bailoutOnAlreadyFinishedWork(data, state, p)
							end

							if state.tag == contextProvider then
								pushProvider(state, state.memoizedProps.value)
								return bailoutOnAlreadyFinishedWork(data, state, p)
							elseif state.tag == profiler then
								if enableProfilerTimer then
									local stateNode = state.stateNode
									stateNode.effectDuration = 0
									stateNode.passiveEffectDuration = 0
								end

								return bailoutOnAlreadyFinishedWork(data, state, p)
							elseif state.tag == suspenseComponent then
								local memoizedState = state.memoizedState

								if memoizedState == nil then
									pushSuspenseContext(
										state,
										setDefaultShallowSuspenseContext(suspenseStackCursor.current)
									)
									return bailoutOnAlreadyFinishedWork(data, state, p)
								end

								if enableSuspenseServerRenderer and memoizedState.dehydrated ~= nil then
									pushSuspenseContext(
										state,
										setDefaultShallowSuspenseContext(suspenseStackCursor.current)
									)
									state.flags = bit32.bor(state.flags, didCapture)
									return nil
								else
									local childLanes = state.child.childLanes

									if ReactFiberLane.includesSomeLane(p, childLanes) then
										return updateSuspenseComponent(data, state, p)
									end

									pushSuspenseContext(
										state,
										setDefaultShallowSuspenseContext(suspenseStackCursor.current)
									)
									local v11 = bailoutOnAlreadyFinishedWork(data, state, p)

									if v11 == nil then
										return nil
									end

									return v11.sibling
								end
							elseif state.tag == suspenseListComponent then
								print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
								print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
								print("UNIMPLEMENTED ERROR: " .. tostring("beginWork: SuspenseListComponent"))
								error("FIXME (roblox): beginWork: SuspenseListComponent is unimplemented", 2)
								return bailoutOnAlreadyFinishedWork(data, state, p)
							else
								if state.tag ~= offscreenComponent and state.tag ~= legacyHiddenComponent then
									return bailoutOnAlreadyFinishedWork(data, state, p)
								end

								state.lanes = ReactFiberLane.NoLanes
								return (updateOffscreenComponent(data, state, p))
							end
						end
					end
				end
			end
		end

		v2 = true
	end

	state.lanes = ReactFiberLane.NoLanes

	if state.tag == ReactWorkTags.IndeterminateComponent then
		return mountIndeterminateComponent(data, state, state.type, p)
	end

	if state.tag == lazyComponent then
		elementType = state.elementType
		return (mountLazyComponent(data, state, elementType, lanes, p))
	end

	if state.tag == functionComponent then
		type2 = state.type
		pendingProps = state.pendingProps

		if state.elementType ~= type2 then
			pendingProps = resolveDefaultProps(type2, pendingProps)
		end

		return updateFunctionComponent(data, state, type2, pendingProps, p)
	elseif state.tag == classComponent then
		type3 = state.type
		pendingProps2 = state.pendingProps
		v7 = state.elementType == type3 and pendingProps2 or resolveDefaultProps(type3, pendingProps2)
		return (updateClassComponent(data, state, type3, v7, p))
	else
		if state.tag == hostRoot then
			return updateHostRoot(data, state, p)
		end

		if state.tag == hostComponent then
			return (updateHostComponent(data, state, p))
		end

		if state.tag == hostText then
			if data == nil then
				tryToClaimNextHydratableInstance(state)
			end

			return nil
		else
			if state.tag == suspenseComponent then
				return updateSuspenseComponent(data, state, p)
			end

			if state.tag == hostPortal then
				return updatePortalComponent(data, state, p)
			end

			if state.tag == forwardRef then
				type4 = state.type
				pendingProps3 = state.pendingProps

				if state.elementType ~= type4 then
					pendingProps3 = resolveDefaultProps(type4, pendingProps3)
				end

				return updateForwardRef(data, state, type4, pendingProps3, p)
			else
				if state.tag == fragment then
					return updateFragment(data, state, p)
				end

				if state.tag == mode then
					return updateMode(data, state, p)
				end

				if state.tag == profiler then
					return updateProfiler(data, state, p)
				end

				if state.tag == contextProvider then
					return updateContextProvider(data, state, p)
				end

				if state.tag == contextConsumer then
					return updateContextConsumer(data, state, p)
				end

				if state.tag == memoComponent then
					type5 = state.type
					pendingProps4 = state.pendingProps
					v8 = resolveDefaultProps(type5, pendingProps4)
					return deduplicatedTail()
				else
					if state.tag == simpleMemoComponent then
						return updateSimpleMemoComponent(data, state, state.type, state.pendingProps, lanes, p)
					end

					if state.tag == incompleteClassComponent then
						type6 = state.type
						pendingProps5 = state.pendingProps
						v9 = state.elementType == type6 and pendingProps5 or resolveDefaultProps(type6, pendingProps5)
						return mountIncompleteClassComponent(data, state, type6, v9, p)
					else
						return deduplicatedTail2()
					end
				end
			end
		end
	end
end

return New