local __DEV__ = _G.__DEV__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local array = luaupolyfill.Array
local inspect = luaupolyfill.util.inspect
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactRootTags = require(script.Parent:WaitForChild("ReactRootTags"))
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local ReactTypeOfMode = require(script.Parent:WaitForChild("ReactTypeOfMode"))
local ReactFiberLane = require(script.Parent:WaitForChild("ReactFiberLane"))
require(script.Parent:WaitForChild("ReactFiberHostConfig"))
require(script.Parent:WaitForChild("ReactFiberOffscreenComponent"))
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared2.invariant
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local enableProfilerTimer = shared3.ReactFeatureFlags.enableProfilerTimer
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local noFlags = ReactFiberFlags.NoFlags
local placement = ReactFiberFlags.Placement
local staticMask = ReactFiberFlags.StaticMask
local concurrentRoot = ReactRootTags.ConcurrentRoot
local blockingRoot = ReactRootTags.BlockingRoot
local indeterminateComponent = ReactWorkTags.IndeterminateComponent
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
local dehydratedFragment = ReactWorkTags.DehydratedFragment
local functionComponent = ReactWorkTags.FunctionComponent
local memoComponent = ReactWorkTags.MemoComponent
local simpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local lazyComponent = ReactWorkTags.LazyComponent
local fundamentalComponent = ReactWorkTags.FundamentalComponent
local scopeComponent = ReactWorkTags.ScopeComponent
local offscreenComponent = ReactWorkTags.OffscreenComponent
local legacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared4.getComponentName
local ReactFiberDevToolsHooknew = require(script.Parent:WaitForChild("ReactFiberDevToolsHook.new"))
local isDevToolsPresent = ReactFiberDevToolsHooknew.isDevToolsPresent
local ReactFiberHotReloadingnew = require(script.Parent:WaitForChild("ReactFiberHotReloading.new"))
local resolveClassForHotReloading = ReactFiberHotReloadingnew.resolveClassForHotReloading
local resolveFunctionForHotReloading = ReactFiberHotReloadingnew.resolveFunctionForHotReloading
local resolveForwardRefForHotReloading = ReactFiberHotReloadingnew.resolveForwardRefForHotReloading
local noLanes = ReactFiberLane.NoLanes
local noMode = ReactTypeOfMode.NoMode
local concurrentMode = ReactTypeOfMode.ConcurrentMode
local debugTracingMode = ReactTypeOfMode.DebugTracingMode
local profileMode = ReactTypeOfMode.ProfileMode
local strictMode = ReactTypeOfMode.StrictMode
local blockingMode = ReactTypeOfMode.BlockingMode
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared5.ReactSymbols
local REACT_FORWARD_REF_TYPE = reactSymbols.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = reactSymbols.REACT_FRAGMENT_TYPE
local REACT_ELEMENT_TYPE = reactSymbols.REACT_ELEMENT_TYPE
local REACT_DEBUG_TRACING_MODE_TYPE = reactSymbols.REACT_DEBUG_TRACING_MODE_TYPE
local REACT_STRICT_MODE_TYPE = reactSymbols.REACT_STRICT_MODE_TYPE
local REACT_PROFILER_TYPE = reactSymbols.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = reactSymbols.REACT_PROVIDER_TYPE
local REACT_CONTEXT_TYPE = reactSymbols.REACT_CONTEXT_TYPE
local REACT_SUSPENSE_TYPE = reactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = reactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_MEMO_TYPE = reactSymbols.REACT_MEMO_TYPE
local REACT_LAZY_TYPE = reactSymbols.REACT_LAZY_TYPE
local REACT_OFFSCREEN_TYPE = reactSymbols.REACT_OFFSCREEN_TYPE
local REACT_LEGACY_HIDDEN_TYPE = reactSymbols.REACT_LEGACY_HIDDEN_TYPE
local createFiberFromProfiler
local createFiberFromFragment
local createFiberFromSuspense
local createFiberFromOffscreen
local createFiberFromLegacyHidden
local debugID = 1

local function createFiber(tag, pendingProps, p3, mode2, elementType, p6, stateNode, p8)
	local v2 = {
		tag = tag,
		key = p3,
		elementType = elementType,
		type = p6,
		stateNode = stateNode,
		index = 1,
		pendingProps = pendingProps,
		mode = mode2,
		flags = noFlags,
		subtreeFlags = noFlags,
		lanes = p8 or noLanes,
		childLanes = noLanes
	}

	if enableProfilerTimer then
		v2.actualDuration = 0
		v2.actualStartTime = -1
		v2.selfBaseDuration = 0
		v2.treeBaseDuration = 0
	end

	if not __DEV__ then
		return v2
	end

	v2._debugID = debugID
	debugID += 1
	v2._debugSource = nil
	v2._debugOwner = nil
	v2._debugNeedsRemount = false
	v2._debugHookTypes = nil
	return v2
end

function _shouldConstruct(callback)
	return type(callback) ~= "function" and (callback.isReactComponent and true or false)
end

local function createFiberFromTypeAndProps(type2, key: string?, props, _owner, p, p2)
	local v2 = indeterminateComponent
	local typeName = type(type2)
	local v3

	if typeName == "function" then
		if __DEV__ then
			v3 = resolveFunctionForHotReloading(type2)
		else
			v3 = type2
		end
	elseif typeName == "table" and type2.isReactComponent then
		v2 = classComponent

		if __DEV__ then
			v3 = resolveClassForHotReloading(type2)
		else
			v3 = type2
		end
	elseif typeName == "string" then
		v2 = hostComponent
		v3 = type2
	else
		if type2 == REACT_FRAGMENT_TYPE then
			return createFiberFromFragment(props.children, p, p2, key)
		end

		if type2 == REACT_DEBUG_TRACING_MODE_TYPE then
			v2 = mode
			p = bit32.bor(p, debugTracingMode)
			v3 = type2
		elseif type2 == REACT_STRICT_MODE_TYPE then
			v2 = mode
			p = bit32.bor(p, strictMode)
			v3 = type2
		else
			if type2 == REACT_PROFILER_TYPE then
				return createFiberFromProfiler(props, p, p2, key)
			end

			if type2 == REACT_SUSPENSE_TYPE then
				return createFiberFromSuspense(props, p, p2, key)
			end

			if type2 == REACT_OFFSCREEN_TYPE then
				return createFiberFromOffscreen(props, p, p2, key)
			end

			if type2 == REACT_LEGACY_HIDDEN_TYPE then
				return createFiberFromLegacyHidden(props, p, p2, key)
			end

			local v4 = false
			local typeof2

			if typeName == "table" then
				typeof2 = type2["$$typeof"]

				if typeof2 == REACT_PROVIDER_TYPE then
					v2 = contextProvider
					v3 = type2
					v4 = true
				elseif typeof2 == REACT_CONTEXT_TYPE then
					v2 = contextConsumer
					v3 = type2
					v4 = true
				elseif typeof2 == REACT_FORWARD_REF_TYPE then
					v2 = forwardRef

					if __DEV__ then
						v3 = resolveForwardRefForHotReloading(type2)
					else
						v3 = type2
					end

					v4 = true
				elseif typeof2 == REACT_MEMO_TYPE then
					v2 = memoComponent
					v3 = type2
					v4 = true
				elseif typeof2 == REACT_LAZY_TYPE then
					v2 = lazyComponent
					v4 = true
				else
					v3 = type2
				end
			else
				v3 = type2
			end

			if not v4 then
				local v5 = ""

				if __DEV__ then
					if type2 == nil or typeName == "table" and #object.keys(type2) == 0 then
						v5 ..= " You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports."
					elseif type2 ~= nil and typeName == "table" then
						v5 ..= "\n" .. inspect(type2)
					end

					local v6

					if _owner then
						v6 = getComponentName(_owner.type)
					end

					if v6 == nil or v6 == "" then
						if _owner then
							v5 ..= "\n" .. inspect(_owner)
						end
					else
						v5 ..= [[


Check the render method of `]] .. v6 .. "`."
					end
				end

				if type2 == nil then
					typeName = "nil"
				elseif array.isArray(type2) then
					typeName = "array"
				elseif typeName == "table" and typeof2 == REACT_ELEMENT_TYPE then
					typeName = string.format("<%s />", getComponentName(type2.type) or "Unknown")
					v5 = " Did you accidentally export a JSX literal or Element instead of a component?"
				end

				invariant(
					false,
					"Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s",
					typeName,
					v5
				)
			end
		end
	end

	local fiber = createFiber(v2, props, key, p, type2, v3, nil, p2)

	if __DEV__ then
		fiber._debugOwner = _owner
	end

	return fiber
end

createFiberFromFragment = function(children, mode2, p2, p3: string?)
	return (createFiber(fragment, children, p3, mode2, nil, nil, nil, p2))
end

local function createFiberFromScope(elementType, pendingProps, mode2, p4, p5: string?)
	return (createFiber(scopeComponent, pendingProps, p5, mode2, elementType, elementType, nil, p4))
end

createFiberFromProfiler = function(pendingProps, p2, p3, p4: string?)
	if __DEV__ and typeof(pendingProps.id) ~= "string" then
		console.error("Profiler must specify an \"id\" as a prop")
	end

	return (createFiber(
		profiler,
		pendingProps,
		p4,
		bit32.bor(p2, profileMode),
		REACT_PROFILER_TYPE,
		REACT_PROFILER_TYPE,
		enableProfilerTimer and {
			effectDuration = 0,
			passiveEffectDuration = 0
		} or nil,
		p3
	))
end

createFiberFromSuspense = function(pendingProps, mode2, p3, p4: string?)
	return (createFiber(suspenseComponent, pendingProps, p4, mode2, REACT_SUSPENSE_TYPE, REACT_SUSPENSE_TYPE, nil, p3))
end

createFiberFromOffscreen = function(pendingProps, mode2, p3, p4: string?)
	local v5

	if __DEV__ then
		v5 = REACT_OFFSCREEN_TYPE
	end

	return (createFiber(offscreenComponent, pendingProps, p4, mode2, REACT_OFFSCREEN_TYPE, v5, nil, p3))
end

createFiberFromLegacyHidden = function(pendingProps, mode2, p3, p4: string?)
	local v5

	if __DEV__ then
		v5 = REACT_LEGACY_HIDDEN_TYPE
	end

	return (createFiber(legacyHiddenComponent, pendingProps, p4, mode2, REACT_LEGACY_HIDDEN_TYPE, v5, nil, p3))
end

local New = {}

function New.isSimpleFunctionComponent(callback)
	return type(callback) == "function"
end

function New.resolveLazyComponentTag(p)
	local typeName = typeof(p)

	if typeName == "function" then
		return functionComponent
	end

	if typeName ~= "table" then
		return indeterminateComponent
	end

	if p.isReactComponent then
		return classComponent
	end

	local typeof2 = p["$$typeof"]

	if typeof2 == REACT_FORWARD_REF_TYPE then
		return forwardRef
	end

	if typeof2 == REACT_MEMO_TYPE then
		return memoComponent
	end

	return indeterminateComponent
end

function New.createWorkInProgress(alternate, pendingProps)
	local alternate2 = alternate.alternate

	if alternate2 == nil then
		alternate2 = createFiber(
			alternate.tag,
			pendingProps,
			alternate.key,
			alternate.mode,
			alternate.elementType,
			alternate.type,
			alternate.stateNode
		)

		if __DEV__ then
			alternate2._debugID = alternate._debugID
			alternate2._debugSource = alternate._debugSource
			alternate2._debugOwner = alternate._debugOwner
			alternate2._debugHookTypes = alternate._debugHookTypes
		end

		alternate2.alternate = alternate
		alternate.alternate = alternate2
	else
		alternate2.pendingProps = pendingProps
		alternate2.type = alternate.type
		alternate2.flags = noFlags
		alternate2.subtreeFlags = noFlags
		alternate2.deletions = nil

		if enableProfilerTimer then
			alternate2.actualDuration = 0
			alternate2.actualStartTime = -1
		end
	end

	alternate2.flags = bit32.band(alternate.flags, staticMask)
	alternate2.childLanes = alternate.childLanes
	alternate2.lanes = alternate.lanes
	alternate2.child = alternate.child
	alternate2.memoizedProps = alternate.memoizedProps
	alternate2.memoizedState = alternate.memoizedState
	alternate2.updateQueue = alternate.updateQueue
	local dependencies = alternate.dependencies

	if dependencies == nil then
		alternate2.dependencies = nil
	else
		alternate2.dependencies = {
			lanes = dependencies.lanes,
			firstContext = dependencies.firstContext
		}
	end

	alternate2.sibling = alternate.sibling
	alternate2.index = alternate.index
	alternate2.ref = alternate.ref

	if enableProfilerTimer then
		alternate2.selfBaseDuration = alternate.selfBaseDuration
		alternate2.treeBaseDuration = alternate.treeBaseDuration
	end

	if not __DEV__ then
		return alternate2
	end

	alternate2._debugNeedsRemount = alternate._debugNeedsRemount

	if alternate2.tag == indeterminateComponent or alternate2.tag == functionComponent or alternate2.tag == simpleMemoComponent then
		alternate2.type = resolveFunctionForHotReloading(alternate.type)
		return alternate2
	end

	if alternate2.tag == classComponent then
		alternate2.type = resolveClassForHotReloading(alternate.type)
		return alternate2
	elseif alternate2.tag == forwardRef then
		alternate2.type = resolveForwardRefForHotReloading(alternate.type)
	end

	return alternate2
end

function New.resetWorkInProgress(state, lanes)
	state.flags = bit32.band(state.flags, (bit32.bor(staticMask, placement)))
	local alternate = state.alternate

	if alternate == nil then
		state.childLanes = noLanes
		state.lanes = lanes
		state.child = nil
		state.subtreeFlags = noFlags
		state.memoizedProps = nil
		state.memoizedState = nil
		state.updateQueue = nil
		state.dependencies = nil
		state.stateNode = nil

		if enableProfilerTimer then
			state.selfBaseDuration = 0
			state.treeBaseDuration = 0
			return state
		end
	else
		state.childLanes = alternate.childLanes
		state.lanes = alternate.lanes
		state.child = alternate.child
		state.subtreeFlags = alternate.subtreeFlags
		state.deletions = nil
		state.memoizedProps = alternate.memoizedProps
		state.memoizedState = alternate.memoizedState
		state.updateQueue = alternate.updateQueue
		state.type = alternate.type
		local dependencies = alternate.dependencies

		if dependencies == nil then
			state.dependencies = nil
		else
			state.dependencies = {
				lanes = dependencies.lanes,
				firstContext = dependencies.firstContext
			}
		end

		if enableProfilerTimer then
			state.selfBaseDuration = alternate.selfBaseDuration
			state.treeBaseDuration = alternate.treeBaseDuration
		end
	end

	return state
end

function New.createHostRootFiber(p)
	local v2

	if p == concurrentRoot then
		v2 = bit32.bor(concurrentMode, blockingMode, strictMode)
	elseif p == blockingRoot then
		v2 = bit32.bor(blockingMode, strictMode)
	else
		v2 = noMode
	end

	if enableProfilerTimer and isDevToolsPresent() then
		v2 = bit32.bor(v2, profileMode)
	end

	return (createFiber(hostRoot, nil, nil, v2))
end

New.createFiberFromTypeAndProps = createFiberFromTypeAndProps

function New.createFiberFromElement(data, p, p2)
	local _owner

	if __DEV__ then
		_owner = data._owner
	end

	local fiberFromTypeAndProps = createFiberFromTypeAndProps(data.type, data.key, data.props, _owner, p, p2)

	if __DEV__ then
		fiberFromTypeAndProps._debugSource = data._source
		fiberFromTypeAndProps._debugOwner = data._owner
	end

	return fiberFromTypeAndProps
end

New.createFiberFromFragment = createFiberFromFragment

function New.createFiberFromFundamental(elementType, pendingProps, mode2, p4, p5: string?)
	return (createFiber(fundamentalComponent, pendingProps, p5, mode2, elementType, elementType, nil, p4))
end

New.createFiberFromSuspense = createFiberFromSuspense

function New.createFiberFromSuspenseList(pendingProps, mode2, p3, p4: string?)
	local v5

	if __DEV__ then
		v5 = REACT_SUSPENSE_LIST_TYPE
	end

	return (createFiber(suspenseListComponent, pendingProps, p4, mode2, REACT_SUSPENSE_LIST_TYPE, v5, nil, p3))
end

New.createFiberFromOffscreen = createFiberFromOffscreen
New.createFiberFromLegacyHidden = createFiberFromLegacyHidden

function New.createFiberFromText(pendingProps: string, mode2, p3)
	return (createFiber(hostText, pendingProps, nil, mode2, nil, nil, nil, p3))
end

function New.createFiberFromHostInstanceForDeletion()
	return (createFiber(hostComponent, nil, nil, noMode, "DELETED", "DELETED"))
end

function New.createFiberFromDehydratedFragment(p)
	return (createFiber(dehydratedFragment, nil, nil, noMode, nil, nil, p))
end

function New.createFiberFromPortal(data, mode2, p2)
	return (createFiber(hostPortal, data.children == nil and {} or data.children, data.key, mode2, nil, nil, {
		containerInfo = data.containerInfo,
		pendingChildren = nil,
		implementation = data.implementation
	}, p2))
end

function New.assignFiberPropertiesInDEV(p, data)
	if p == nil then
		p = createFiber(indeterminateComponent, nil, nil, noMode)
	end

	p.tag = data.tag
	p.key = data.key
	p.elementType = data.elementType
	p.type = data.type
	p.stateNode = data.stateNode
	p.return_ = data.return_
	p.child = data.child
	p.sibling = data.sibling
	p.index = data.index
	p.ref = data.ref
	p.pendingProps = data.pendingProps
	p.memoizedProps = data.memoizedProps
	p.updateQueue = data.updateQueue
	p.memoizedState = data.memoizedState
	p.dependencies = data.dependencies
	p.mode = data.mode
	p.flags = data.flags
	p.subtreeFlags = data.subtreeFlags
	p.deletions = data.deletions
	p.lanes = data.lanes
	p.childLanes = data.childLanes
	p.alternate = data.alternate

	if enableProfilerTimer then
		p.actualDuration = data.actualDuration
		p.actualStartTime = data.actualStartTime
		p.selfBaseDuration = data.selfBaseDuration
		p.treeBaseDuration = data.treeBaseDuration
	end

	p._debugID = data._debugID
	p._debugSource = data._debugSource
	p._debugOwner = data._debugOwner
	p._debugNeedsRemount = data._debugNeedsRemount
	p._debugHookTypes = data._debugHookTypes
	return p
end

return New