local __DEV__ = _G.__DEV__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberLane = require(script.Parent:WaitForChild("ReactFiberLane"))
local ReactUpdateQueuenew = require(script.Parent:WaitForChild("ReactUpdateQueue.new"))
require(script.Parent.Parent:WaitForChild("shared"))
local react = require(script.Parent.Parent:WaitForChild("react"))
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local update = ReactFiberFlags.Update
local snapshot = ReactFiberFlags.Snapshot
local mountLayoutDev = ReactFiberFlags.MountLayoutDev
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local reactFeatureFlags = shared2.ReactFeatureFlags
local debugRenderPhaseSideEffectsForStrictMode = reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode
local disableLegacyContext = reactFeatureFlags.disableLegacyContext
local enableDebugTracing = reactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = reactFeatureFlags.enableSchedulingProfiler
local warnAboutDeprecatedLifecycles = reactFeatureFlags.warnAboutDeprecatedLifecycles
local enableDoubleInvokingEffects = reactFeatureFlags.enableDoubleInvokingEffects
local ReactStrictModeWarningsnew = require(script.Parent:WaitForChild("ReactStrictModeWarnings.new"))
local ReactFiberTreeReflection = require(script.Parent:WaitForChild("ReactFiberTreeReflection"))
local isMounted = ReactFiberTreeReflection.isMounted
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local reactInstanceMap = shared3.ReactInstanceMap
local get = reactInstanceMap.get
local set = reactInstanceMap.set
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local shallowEqual = shared4.shallowEqual
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared5.getComponentName
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
local uninitializedState = shared6.UninitializedState
local shared7 = require(script.Parent.Parent:WaitForChild("shared"))
local describeError = shared7.describeError
local shared8 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared8.ReactSymbols
local REACT_CONTEXT_TYPE = reactSymbols.REACT_CONTEXT_TYPE
local REACT_PROVIDER_TYPE = reactSymbols.REACT_PROVIDER_TYPE
local ReactFiberLazyComponentnew = require(script.Parent:WaitForChild("ReactFiberLazyComponent.new"))
local resolveDefaultProps = ReactFiberLazyComponentnew.resolveDefaultProps
local ReactTypeOfMode = require(script.Parent:WaitForChild("ReactTypeOfMode"))
local debugTracingMode = ReactTypeOfMode.DebugTracingMode
local strictMode = ReactTypeOfMode.StrictMode
local enqueueUpdate = ReactUpdateQueuenew.enqueueUpdate
local processUpdateQueue = ReactUpdateQueuenew.processUpdateQueue
local checkHasForceUpdateAfterProcessing = ReactUpdateQueuenew.checkHasForceUpdateAfterProcessing
local resetHasForceUpdateBeforeProcessing = ReactUpdateQueuenew.resetHasForceUpdateBeforeProcessing
local createUpdate = ReactUpdateQueuenew.createUpdate
local replaceState = ReactUpdateQueuenew.ReplaceState
local forceUpdate = ReactUpdateQueuenew.ForceUpdate
local initializeUpdateQueue = ReactUpdateQueuenew.initializeUpdateQueue
local cloneUpdateQueue = ReactUpdateQueuenew.cloneUpdateQueue
local noLanes = ReactFiberLane.NoLanes
local ReactFiberContextnew = require(script.Parent:WaitForChild("ReactFiberContext.new"))
local cacheContext = ReactFiberContextnew.cacheContext
local getMaskedContext = ReactFiberContextnew.getMaskedContext
local getUnmaskedContext = ReactFiberContextnew.getUnmaskedContext
local hasContextChanged = ReactFiberContextnew.hasContextChanged
local emptyContextObject = ReactFiberContextnew.emptyContextObject
local ReactFiberNewContextnew = require(script.Parent:WaitForChild("ReactFiberNewContext.new"))
local readContext = ReactFiberNewContextnew.readContext
local DebugTracing = require(script.Parent:WaitForChild("DebugTracing"))
local logForceUpdateScheduled = DebugTracing.logForceUpdateScheduled
local logStateUpdateScheduled = DebugTracing.logStateUpdateScheduled
local shared9 = require(script.Parent.Parent:WaitForChild("shared"))
local consolePatchingDev = shared9.ConsolePatchingDev
local disableLogs = consolePatchingDev.disableLogs
local reenableLogs = consolePatchingDev.reenableLogs
local SchedulingProfiler = require(script.Parent:WaitForChild("SchedulingProfiler"))
local markForceUpdateScheduled = SchedulingProfiler.markForceUpdateScheduled
local markStateUpdateScheduled = SchedulingProfiler.markStateUpdateScheduled
local reactInternalInstance = {}
local __refs = react.Component:extend("").__refs
local warnOnInvalidCallback, warnOnUndefinedDerivedState, v2, v3, v4, v5, v6, v7, v8

if __DEV__ then
	local v9 = {}

	warnOnInvalidCallback = function(callback, p: string)
		if callback == nil or type(callback) == "function" then
			return
		end

		local v10 = p .. "_" .. tostring(callback)

		if not v9[v10] then
			v9[v10] = true
			console.error(
				"%s(...): Expected the last optional `callback` argument to be a function. Instead received: %s.",
				p,
				(tostring(callback))
			)
		end
	end

	warnOnUndefinedDerivedState = function(_, _) end

	v2 = {}
	v3 = {}
	v4 = {}
	v5 = {}
	v6 = {}
	v7 = {}
	v8 = {}
else
	warnOnUndefinedDerivedState = nil
	warnOnInvalidCallback = nil
	v2 = nil
	v3 = nil
	v4 = nil
	v5 = nil
	v6 = nil
	v7 = nil
	v8 = nil
end

local function applyDerivedStateFromProps(state, p, getDerivedStateFromProps, p2)
	local memoizedState = state.memoizedState

	if __DEV__ and debugRenderPhaseSideEffectsForStrictMode and bit32.band(state.mode, strictMode) ~= 0 then
		disableLogs()
		local v9, v10 = xpcall(getDerivedStateFromProps, describeError, p2, memoizedState)
		reenableLogs()

		if not v9 then
			error(v10)
		end
	end

	local v9 = getDerivedStateFromProps(p2, memoizedState)

	if __DEV__ then
		warnOnUndefinedDerivedState(p, v9)
	end

	if v9 ~= nil then
		memoizedState = object.assign({}, memoizedState, v9)
	end

	state.memoizedState = memoizedState

	if state.lanes == noLanes then
		state.updateQueue.baseState = memoizedState
	end
end

local updater = nil

local function initializeClassComponentUpdater()
	local ReactFiberWorkLoopnew = require(script.Parent:WaitForChild("ReactFiberWorkLoop.new"))
	local requestEventTime = ReactFiberWorkLoopnew.requestEventTime
	local requestUpdateLane = ReactFiberWorkLoopnew.requestUpdateLane
	local scheduleUpdateOnFiber = ReactFiberWorkLoopnew.scheduleUpdateOnFiber
	updater = {
		isMounted = isMounted,
		enqueueSetState = function(p, p2, callback)
			local v10 = get(p)
			local v11 = requestEventTime()
			local v12 = requestUpdateLane(v10)
			local update2 = createUpdate(v11, v12, p2, callback)

			if callback ~= nil and __DEV__ then
				warnOnInvalidCallback(callback, "setState")
			end

			enqueueUpdate(v10, update2)
			scheduleUpdateOnFiber(v10, v12, v11)

			if __DEV__ and enableDebugTracing and bit32.band(v10.mode, debugTracingMode) ~= 0 then
				logStateUpdateScheduled(getComponentName(v10.type) or "Unknown", v12, p2)
			end

			if enableSchedulingProfiler then
				markStateUpdateScheduled(v10, v12)
			end
		end,
		enqueueReplaceState = function(p, p2, p3)
			local v10 = get(p)
			local v11 = requestEventTime()
			local v12 = requestUpdateLane(v10)
			local update2 = createUpdate(v11, v12, p2, p3)
			update2.tag = replaceState

			if p3 ~= nil and __DEV__ then
				warnOnInvalidCallback(p3, "replaceState")
			end

			enqueueUpdate(v10, update2)
			scheduleUpdateOnFiber(v10, v12, v11)

			if __DEV__ and enableDebugTracing and bit32.band(v10.mode, debugTracingMode) ~= 0 then
				logStateUpdateScheduled(getComponentName(v10.type) or "Unknown", v12, p2)
			end

			if enableSchedulingProfiler then
				markStateUpdateScheduled(v10, v12)
			end
		end,
		enqueueForceUpdate = function(p, p2)
			local v10 = get(p)
			local v11 = requestEventTime()
			local v12 = requestUpdateLane(v10)
			local update2 = createUpdate(v11, v12, nil, p2)
			update2.tag = forceUpdate

			if p2 ~= nil and __DEV__ then
				warnOnInvalidCallback(p2, "forceUpdate")
			end

			enqueueUpdate(v10, update2)
			scheduleUpdateOnFiber(v10, v12, v11)

			if __DEV__ and enableDebugTracing and bit32.band(v10.mode, debugTracingMode) ~= 0 then
				logForceUpdateScheduled(getComponentName(v10.type) or "Unknown", v12)
			end

			if enableSchedulingProfiler then
				markForceUpdateScheduled(v10, v12)
			end
		end
	}
end

local function getClassComponentUpdater()
	if updater == nil then
		initializeClassComponentUpdater()
	end

	return updater
end

function checkShouldComponentUpdate(p, p2, p3, p4, p5, p6, p7)
	local stateNode = p.stateNode

	if stateNode.shouldComponentUpdate == nil or type(stateNode.shouldComponentUpdate) ~= "function" then
		if type(p2) == "table" and p2.isPureReactComponent then
			return not (shallowEqual(p3, p4) and shallowEqual(p5, p6))
		end

		return true
	else
		if __DEV__ and debugRenderPhaseSideEffectsForStrictMode and bit32.band(p.mode, strictMode) ~= 0 then
			disableLogs()
			local v10, v11 = xpcall(stateNode.shouldComponentUpdate, describeError, stateNode, p4, p6, p7)
			reenableLogs()

			if not v10 then
				error(v11)
			end
		end

		local shouldComponentUpdate = stateNode:shouldComponentUpdate(p4, p6, p7)

		if __DEV__ and shouldComponentUpdate == nil then
			console.error(
				"%s.shouldComponentUpdate(): Returned nil instead of a boolean value. Make sure to return true or false.",
				getComponentName(p2) or "Component"
			)
		end

		return shouldComponentUpdate
	end
end

local function checkClassInstance(state, data, props)
	local stateNode = state.stateNode

	if __DEV__ then
		local v10 = getComponentName(data) or "Component"

		if not stateNode.render then
			if type(data.render) == "function" then
				console.error(
					"%s(...): No `render` method found on the returned component instance: did you accidentally return an object from the constructor?",
					v10
				)
			else
				console.error(
					"%s(...): No `render` method found on the returned component instance: you may have forgotten to define `render`.",
					v10
				)
			end
		end

		if stateNode.getInitialState and not (stateNode.getInitialState.isReactClassApproved or stateNode.state) then
			console.error(
				"getInitialState was defined on %s, a plain JavaScript class. This is only supported for classes created using React.createClass. Did you mean to define a state property instead?",
				v10
			)
		end

		if stateNode.getDefaultProps and not stateNode.getDefaultProps.isReactClassApproved then
			console.error(
				"getDefaultProps was defined on %s, a plain JavaScript class. This is only supported for classes created using React.createClass. Use a static property to define defaultProps instead.",
				v10
			)
		end

		if stateNode.propTypes and not data.propTypes then
			console.error(
				"propTypes was defined as an instance property on %s. Use a static property to define propTypes instead.",
				v10
			)
		end

		if stateNode.contextType and not data.contextType then
			console.error(
				"contextType was defined as an instance property on %s. Use a static property to define contextType instead.",
				v10
			)
		end

		if disableLegacyContext then
			if data.childContextTypes then
				console.error(
					"%s uses the legacy childContextTypes API which is no longer supported. Use React.createContext() instead.",
					v10
				)
			end

			if data.contextTypes then
				console.error(
					"%s uses the legacy contextTypes API which is no longer supported. Use React.createContext() with static contextType instead.",
					v10
				)
			end
		else
			if stateNode.contextTypes and not data.contextTypes then
				console.error(
					"contextTypes was defined as an instance property on %s. Use a static property to define contextTypes instead.",
					v10
				)
			end

			if type(data) == "table" and data.contextType and data.contextTypes and not v2[data] then
				v2[data] = true
				console.error(
					"%s declares both contextTypes and contextType static properties. The legacy contextTypes property will be ignored.",
					v10
				)
			end
		end

		if type(stateNode.componentShouldUpdate) == "function" then
			console.error(
				"%s has a method called componentShouldUpdate(). Did you mean shouldComponentUpdate()? The name is phrased as a question because the function is expected to return a value.",
				v10
			)
		end

		if type(data) == "table" and data.isPureReactComponent and stateNode.shouldComponentUpdate ~= nil then
			console.error(
				"%s has a method called shouldComponentUpdate(). shouldComponentUpdate should not be used when extending React.PureComponent. Please extend React.Component if shouldComponentUpdate is used.",
				getComponentName(data) or "A pure component"
			)
		end

		if type(stateNode.componentDidUnmount) == "function" then
			console.error(
				"%s has a method called componentDidUnmount(). But there is no such lifecycle method. Did you mean componentWillUnmount()?",
				v10
			)
		end

		if type(stateNode.componentDidReceiveProps) == "function" then
			console.error(
				"%s has a method called componentDidReceiveProps(). But there is no such lifecycle method. If you meant to update the state in response to changing props, use componentWillReceiveProps(). If you meant to fetch data or run side-effects or mutations after React has updated the UI, use componentDidUpdate().",
				v10
			)
		end

		if type(stateNode.componentWillRecieveProps) == "function" then
			console.error(
				"%s has a method called componentWillRecieveProps(). Did you mean componentWillReceiveProps()?",
				v10
			)
		end

		if type(stateNode.UNSAFE_componentWillRecieveProps) == "function" then
			console.error(
				"%s has a method called UNSAFE_componentWillRecieveProps(). Did you mean UNSAFE_componentWillReceiveProps()?",
				v10
			)
		end

		local v11 = stateNode.props ~= props

		if stateNode.props ~= nil and v11 then
			console.error(
				"%s(...): When calling super() in `%s`, make sure to pass up the same props that your component's constructor was passed.",
				v10,
				v10
			)
		end

		if rawget(stateNode, "defaultProps") then
			console.error(
				"Setting defaultProps as an instance property on %s is not supported and will be ignored. Instead, define defaultProps as a static property on %s.",
				v10,
				v10
			)
		end

		if type(stateNode.getSnapshotBeforeUpdate) == "function" and type(stateNode.componentDidUpdate) ~= "function" and not v3[data] then
			v3[data] = true
			console.error(
				"%s: getSnapshotBeforeUpdate() should be used with componentDidUpdate(). This component defines getSnapshotBeforeUpdate() only.",
				getComponentName(data)
			)
		end

		local state2 = stateNode.state

		if state2 ~= nil and type(state2) ~= "table" then
			console.error("%s.state: must be set to an object or nil", v10)
		end

		if type(data) == "table" and type(stateNode.getChildContext) == "function" and type(data.childContextTypes) ~= "table" then
			console.error(
				"%s.getChildContext(): childContextTypes must be defined in order to use getChildContext().",
				v10
			)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adoptClassInstance(state, stateNode)
	if updater == nil then
		initializeClassComponentUpdater()
	end

	stateNode.__updater = updater
	state.stateNode = stateNode
	set(stateNode, state)

	if __DEV__ then
		stateNode._reactInternalInstance = reactInternalInstance
	end
end

local function constructClassInstance(state, data, p)
	local v10 = false
	local v11 = emptyContextObject
	local v12 = emptyContextObject
	local contextType = data.contextType

	if __DEV__ and data.contextType ~= nil then
		local v13

		if contextType == nil then
			v13 = true
		elseif contextType["$$typeof"] == REACT_CONTEXT_TYPE then
			v13 = contextType._context == nil
		else
			v13 = false
		end

		if not (v13 or v4[data]) then
			v4[data] = true
			local v14 = ""
			local v15

			if contextType == nil then
				v15 = " However, it is set to nil. This can be caused by a typo or by mixing up named and default imports. This can also happen due to a circular dependency, so try moving the createContext() call to a separate file."
			elseif type(contextType) == "table" then
				if contextType["$$typeof"] == REACT_PROVIDER_TYPE then
					v15 = " Did you accidentally pass the Context.Provider instead?"
				elseif contextType._context == nil then
					local v16 = v14 .. " However, it is set to an object with keys {"

					for k, _ in contextType do
						v16 ..= k .. ", "
					end

					v15 = v16 .. "}."
				else
					v15 = " Did you accidentally pass the Context.Consumer instead?"
				end
			else
				v15 = " However, it is set to a " .. type(contextType) .. "."
			end

			console.error(
				"%s defines an invalid contextType. contextType should point to the Context object returned by React.createContext().%s",
				getComponentName(data) or "Component",
				v15
			)
		end
	end

	if contextType == nil or type(contextType) ~= "table" then
		if not disableLegacyContext then
			v11 = getUnmaskedContext(state, data, true)
			v10 = data.contextTypes ~= nil
			v12 = v10 and getMaskedContext(state, v11) or emptyContextObject
		end
	else
		v12 = readContext(contextType)
	end

	if __DEV__ and debugRenderPhaseSideEffectsForStrictMode and bit32.band(state.mode, strictMode) ~= 0 then
		disableLogs()
		local v13, v14 = xpcall(data.__ctor, describeError, p, v12)
		reenableLogs()

		if not v13 then
			error(v14)
		end
	end

	local __ctor = data.__ctor(p, v12)
	state.memoizedState = __ctor.state
	local memoizedState = state.memoizedState
	adoptClassInstance(state, __ctor) -- equivalent call inferred; original call site unknown

	if __DEV__ then
		if type(data.getDerivedStateFromProps) == "function" and memoizedState == uninitializedState then
			local v13 = getComponentName(data) or "Component"

			if not v5[v13] then
				v5[v13] = true
				console.error(
					"`%s` uses `getDerivedStateFromProps` but its initial state has not been initialized. This is not recommended. Instead, define the initial state by passing an object to `self:setState` in the `init` method of `%s`. This ensures that `getDerivedStateFromProps` arguments have a consistent shape.",
					v13,
					v13
				)
			end
		end

		if type(data.getDerivedStateFromProps) == "function" or type(__ctor.getSnapshotBeforeUpdate) == "function" then
			local v13 = type(__ctor.componentWillMount) == "function" and "componentWillMount" or type(__ctor.UNSAFE_componentWillMount) == "function" and "UNSAFE_componentWillMount" or nil
			local v14 = type(__ctor.componentWillReceiveProps) == "function" and "componentWillReceiveProps" or type(__ctor.UNSAFE_componentWillReceiveProps) == "function" and "UNSAFE_componentWillReceiveProps" or nil
			local v15 = type(__ctor.componentWillUpdate) == "function" and "componentWillUpdate" or type(__ctor.UNSAFE_componentWillUpdate) == "function" and "UNSAFE_componentWillUpdate" or nil

			if v13 ~= nil or v14 ~= nil or v15 ~= nil then
				local v16 = getComponentName(data) or "Component"
				local v17 = type(data.getDerivedStateFromProps) == "function" and "getDerivedStateFromProps()" or "getSnapshotBeforeUpdate()"
				local v18 = v13 == nil and "" or "\n  " .. tostring(v13)
				local v19 = v14 == nil and "" or "\n  " .. tostring(v14)
				local v20 = v15 == nil and "" or "\n  " .. tostring(v15)

				if not v6[v16] then
					v6[v16] = true
					console.error([[
Unsafe legacy lifecycles will not be called for components using new component APIs.

%s uses %s but also contains the following legacy lifecycles:%s%s%s

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], v16, v17, v18, v19, v20)
				end
			end
		end
	end

	if v10 then
		cacheContext(state, v11, v12)
	end

	return __ctor
end

local function callComponentWillMount(state, stateNode)
	local state2 = stateNode.state

	if stateNode.componentWillMount ~= nil and type(stateNode.componentWillMount) == "function" then
		stateNode:componentWillMount()
	end

	if stateNode.UNSAFE_componentWillMount ~= nil and type(stateNode.UNSAFE_componentWillMount) == "function" then
		stateNode:UNSAFE_componentWillMount()
	end

	if state2 ~= stateNode.state then
		if __DEV__ then
			console.error(
				"%s.componentWillMount(): Assigning directly to this.state is deprecated (except inside a component's constructor). Use setState instead.",
				getComponentName(state.type) or "Component"
			)
		end

		if updater == nil then
			initializeClassComponentUpdater()
		end

		updater.enqueueReplaceState(stateNode, stateNode.state)
	end
end

function callComponentWillReceiveProps(p, object2, p2, p3)
	local state = object2.state

	if object2.componentWillReceiveProps ~= nil and type(object2.componentWillReceiveProps) == "function" then
		object2:componentWillReceiveProps(p2, p3)
	end

	if object2.UNSAFE_componentWillReceiveProps ~= nil and type(object2.UNSAFE_componentWillReceiveProps) == "function" then
		object2:UNSAFE_componentWillReceiveProps(p2, p3)
	end

	if object2.state ~= state then
		if __DEV__ then
			local v10 = getComponentName(p.type) or "Component"

			if not v7[v10] then
				v7[v10] = true
				console.error(
					"%s.componentWillReceiveProps(): Assigning directly to this.state is deprecated (except inside a component's constructor). Use setState instead.",
					v10
				)
			end
		end

		if updater == nil then
			initializeClassComponentUpdater()
		end

		updater.enqueueReplaceState(object2, object2.state)
	end
end

function resumeMountClassInstance(state, p, p2, p3)
	local stateNode = state.stateNode
	local memoizedProps = state.memoizedProps
	stateNode.props = memoizedProps
	local context = stateNode.context
	local contextType = p.contextType
	local context2 = emptyContextObject

	if contextType == nil or type(contextType) ~= "table" then
		if not disableLegacyContext then
			context2 = getMaskedContext(state, (getUnmaskedContext(state, p, true)))
		end
	else
		context2 = readContext(contextType)
	end

	local getDerivedStateFromProps = p.getDerivedStateFromProps
	local v11 = type(getDerivedStateFromProps) == "function" or type(stateNode.getSnapshotBeforeUpdate) == "function"

	if not v11 and (type(stateNode.UNSAFE_componentWillReceiveProps) == "function" or type(stateNode.componentWillReceiveProps) == "function") and (memoizedProps ~= p2 or context ~= context2) then
		callComponentWillReceiveProps(state, stateNode, p2, context2)
	end

	resetHasForceUpdateBeforeProcessing()
	local memoizedState = state.memoizedState
	stateNode.state = memoizedState
	processUpdateQueue(state, p2, stateNode, p3)
	local memoizedState2 = state.memoizedState

	if memoizedProps == p2 and memoizedState == memoizedState2 and not (hasContextChanged() or checkHasForceUpdateAfterProcessing()) then
		if type(stateNode.componentDidMount) == "function" then
			if __DEV__ and enableDoubleInvokingEffects then
				state.flags = bit32.bor(state.flags, mountLayoutDev, update)
			else
				state.flags = bit32.bor(state.flags, update)
			end
		end

		return false
	else
		if getDerivedStateFromProps ~= nil and type(getDerivedStateFromProps) == "function" then
			applyDerivedStateFromProps(state, p, getDerivedStateFromProps, p2)
			memoizedState2 = state.memoizedState
		end

		local v12 = checkHasForceUpdateAfterProcessing() or checkShouldComponentUpdate(
			state,
			p,
			memoizedProps,
			p2,
			memoizedState,
			memoizedState2,
			context2
		)

		if v12 then
			if not v11 and (type(stateNode.UNSAFE_componentWillMount) == "function" or type(stateNode.componentWillMount) == "function") then
				if type(stateNode.componentWillMount) == "function" then
					stateNode:componentWillMount()
				end

				if type(stateNode.UNSAFE_componentWillMount) == "function" then
					stateNode:UNSAFE_componentWillMount()
				end
			end

			if type(stateNode.componentDidMount) == "function" then
				if __DEV__ and enableDoubleInvokingEffects then
					state.flags = bit32.bor(state.flags, mountLayoutDev, update)
				else
					state.flags = bit32.bor(state.flags, update)
				end
			end
		else
			if type(stateNode.componentDidMount) == "function" then
				if __DEV__ and enableDoubleInvokingEffects then
					state.flags = bit32.bor(state.flags, mountLayoutDev, update)
				else
					state.flags = bit32.bor(state.flags, update)
				end
			end

			state.memoizedProps = p2
			state.memoizedState = memoizedState2
		end

		stateNode.props = p2
		stateNode.state = memoizedState2
		stateNode.context = context2
		return v12
	end
end

local New = {}
New.adoptClassInstance = adoptClassInstance
New.constructClassInstance = constructClassInstance

function New.mountClassInstance(state, p, props, p2)
	if __DEV__ then
		checkClassInstance(state, p, props)
	end

	local stateNode = state.stateNode
	stateNode.props = props
	stateNode.state = state.memoizedState
	stateNode.__refs = __refs
	initializeUpdateQueue(state)
	local contextType

	if type(p) == "table" then
		contextType = p.contextType
	end

	if contextType == nil or type(contextType) ~= "table" then
		if disableLegacyContext then
			stateNode.context = emptyContextObject
		else
			stateNode.context = getMaskedContext(state, (getUnmaskedContext(state, p, true)))
		end
	else
		stateNode.context = readContext(contextType)
	end

	if __DEV__ then
		if stateNode.state == props then
			local v10 = getComponentName(p) or "Component"

			if not v8[v10] then
				v8[v10] = true
				console.error(
					"%s: It is not recommended to assign props directly to state because updates to props won't be reflected in state. In most cases, it is better to use props directly.",
					v10
				)
			end
		end

		if bit32.band(state.mode, strictMode) ~= 0 then
			ReactStrictModeWarningsnew.recordLegacyContextWarning(state, stateNode)
		end

		if warnAboutDeprecatedLifecycles then
			ReactStrictModeWarningsnew.recordUnsafeLifecycleWarnings(state, stateNode)
		end
	end

	processUpdateQueue(state, props, stateNode, p2)
	stateNode.state = state.memoizedState
	local typeName = type(p)
	local getDerivedStateFromProps

	if type(p) == "table" then
		getDerivedStateFromProps = p.getDerivedStateFromProps
	end

	if getDerivedStateFromProps ~= nil and type(getDerivedStateFromProps) == "function" then
		applyDerivedStateFromProps(state, p, getDerivedStateFromProps, props)
		stateNode.state = state.memoizedState
	end

	if typeName == "table" and type(p.getDerivedStateFromProps) ~= "function" and type(stateNode.getSnapshotBeforeUpdate) ~= "function" and (type(stateNode.UNSAFE_componentWillMount) == "function" or type(stateNode.componentWillMount) == "function") then
		callComponentWillMount(state, stateNode)
		processUpdateQueue(state, props, stateNode, p2)
		stateNode.state = state.memoizedState
	end

	if type(stateNode.componentDidMount) == "function" then
		if __DEV__ and enableDoubleInvokingEffects then
			state.flags = bit32.bor(state.flags, (bit32.bor(mountLayoutDev, update)))
		else
			state.flags = bit32.bor(state.flags, update)
		end
	end
end

New.resumeMountClassInstance = resumeMountClassInstance

function New.updateClassInstance(p, state, p2, p3, p4)
	local stateNode = state.stateNode
	cloneUpdateQueue(p, state)
	local memoizedProps = state.memoizedProps
	local props

	if state.type == state.elementType then
		props = memoizedProps
	else
		props = resolveDefaultProps(state.type, memoizedProps)
	end

	stateNode.props = props
	local pendingProps = state.pendingProps
	local context = stateNode.context
	local contextType, getDerivedStateFromProps

	if type(p2) == "table" then
		contextType = p2.contextType
		getDerivedStateFromProps = p2.getDerivedStateFromProps
	end

	local context2 = emptyContextObject

	if type(contextType) == "table" then
		context2 = readContext(contextType)
	elseif not disableLegacyContext then
		context2 = getMaskedContext(state, (getUnmaskedContext(state, p2, true)))
	end

	local v12

	if getDerivedStateFromProps == nil or type(getDerivedStateFromProps) ~= "function" then
		if stateNode.getSnapshotBeforeUpdate == nil then
			v12 = false
		else
			v12 = type(stateNode.getSnapshotBeforeUpdate) == "function"
		end
	else
		v12 = true
	end

	if not v12 and (stateNode.UNSAFE_componentWillReceiveProps ~= nil and type(stateNode.UNSAFE_componentWillReceiveProps) == "function" or stateNode.componentWillReceiveProps ~= nil and type(stateNode.componentWillReceiveProps) == "function") and (memoizedProps ~= pendingProps or context ~= context2) then
		callComponentWillReceiveProps(state, stateNode, p3, context2)
	end

	resetHasForceUpdateBeforeProcessing()
	local memoizedState = state.memoizedState
	stateNode.state = memoizedState
	local _ = stateNode.state
	processUpdateQueue(state, p3, stateNode, p4)
	local memoizedState2 = state.memoizedState

	if memoizedProps == pendingProps and memoizedState == memoizedState2 and not (hasContextChanged() or checkHasForceUpdateAfterProcessing()) then
		if stateNode.componentDidUpdate ~= nil and type(stateNode.componentDidUpdate) == "function" and (memoizedProps ~= p.memoizedProps or memoizedState ~= p.memoizedState) then
			state.flags = bit32.bor(state.flags, update)
		end

		if stateNode.getSnapshotBeforeUpdate ~= nil and type(stateNode.getSnapshotBeforeUpdate) == "function" and (memoizedProps ~= p.memoizedProps or memoizedState ~= p.memoizedState) then
			state.flags = bit32.bor(state.flags, snapshot)
		end

		return false
	else
		if getDerivedStateFromProps ~= nil and type(getDerivedStateFromProps) == "function" then
			applyDerivedStateFromProps(state, p2, getDerivedStateFromProps, p3)
			memoizedState2 = state.memoizedState
		end

		local v13 = checkHasForceUpdateAfterProcessing() or checkShouldComponentUpdate(
			state,
			p2,
			props,
			p3,
			memoizedState,
			memoizedState2,
			context2
		)

		if v13 then
			if not v12 and (stateNode.UNSAFE_componentWillUpdate ~= nil and type(stateNode.UNSAFE_componentWillUpdate) == "function" or stateNode.componentWillUpdate ~= nil and type(stateNode.componentWillUpdate) == "function") then
				if stateNode.componentWillUpdate ~= nil and type(stateNode.componentWillUpdate) == "function" then
					stateNode:componentWillUpdate(p3, memoizedState2, context2)
				end

				if stateNode.UNSAFE_componentWillUpdate ~= nil and type(stateNode.UNSAFE_componentWillUpdate) == "function" then
					stateNode:UNSAFE_componentWillUpdate(p3, memoizedState2, context2)
				end
			end

			if stateNode.componentDidUpdate ~= nil and type(stateNode.componentDidUpdate) == "function" then
				state.flags = bit32.bor(state.flags, update)
			end

			if stateNode.getSnapshotBeforeUpdate ~= nil and type(stateNode.getSnapshotBeforeUpdate) == "function" then
				state.flags = bit32.bor(state.flags, snapshot)
			end
		else
			if stateNode.componentDidUpdate ~= nil and type(stateNode.componentDidUpdate) == "function" and (memoizedProps ~= p.memoizedProps or memoizedState ~= p.memoizedState) then
				state.flags = bit32.bor(state.flags, update)
			end

			if stateNode.getSnapshotBeforeUpdate ~= nil and type(stateNode.getSnapshotBeforeUpdate) == "function" and (memoizedProps ~= p.memoizedProps or memoizedState ~= p.memoizedState) then
				state.flags = bit32.bor(state.flags, snapshot)
			end

			state.memoizedProps = p3
			state.memoizedState = memoizedState2
		end

		stateNode.props = p3
		stateNode.state = memoizedState2
		stateNode.context = context2
		return v13
	end
end

New.applyDerivedStateFromProps = applyDerivedStateFromProps
New.emptyRefsObject = __refs
return New