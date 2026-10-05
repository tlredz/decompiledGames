local function unimplemented(p: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. p)
	error("FIXME (roblox): " .. p .. " is unimplemented")
end

local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local error2 = LuauPolyfill.Error
local object = LuauPolyfill.Object
local __DEV__ = ReactGlobals.__DEV__
local React = require(parent.React)
local createRef = React.createRef
local React2 = require(parent.React)
local createBinding = React2.createBinding
local Shared = require(parent.Shared)
local console = Shared.console
require(parent.Shared)
require(script.Parent.ReactInternalTypes)
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local ReactHookEffectTags = require(script.Parent.ReactHookEffectTags)
local Shared2 = require(parent.Shared)
local reactSharedInternals = Shared2.ReactSharedInternals
local Shared3 = require(parent.Shared)
local reactFeatureFlags = Shared3.ReactFeatureFlags
local enableDebugTracing = reactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = reactFeatureFlags.enableSchedulingProfiler
local enableNewReconciler = reactFeatureFlags.enableNewReconciler
local enableDoubleInvokingEffects = reactFeatureFlags.enableDoubleInvokingEffects
local ReactTypeOfMode = require(script.Parent.ReactTypeOfMode)
local debugTracingMode = ReactTypeOfMode.DebugTracingMode
local noLane = ReactFiberLane.NoLane
local noLanes = ReactFiberLane.NoLanes
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local mergeLanes = ReactFiberLane.mergeLanes
local removeLanes = ReactFiberLane.removeLanes
local markRootEntangled = ReactFiberLane.markRootEntangled
local markRootMutableRead = ReactFiberLane.markRootMutableRead
local ReactFiberNewContextnew = require(script.Parent["ReactFiberNewContext.new"])
local readContext = ReactFiberNewContextnew.readContext
local ReactFiberFlags = require(script.Parent.ReactFiberFlags)
local update = ReactFiberFlags.Update
local passive = ReactFiberFlags.Passive
local passiveStatic = ReactFiberFlags.PassiveStatic
local mountLayoutDev = ReactFiberFlags.MountLayoutDev
local mountPassiveDev = ReactFiberFlags.MountPassiveDev
local hasEffect = ReactHookEffectTags.HasEffect
local layout = ReactHookEffectTags.Layout
local passive2 = ReactHookEffectTags.Passive
local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
local warnIfNotCurrentlyActingUpdatesInDEV = ReactFiberWorkLoopnew.warnIfNotCurrentlyActingUpdatesInDEV
local scheduleUpdateOnFiber = ReactFiberWorkLoopnew.scheduleUpdateOnFiber
local warnIfNotScopedWithMatchingAct = ReactFiberWorkLoopnew.warnIfNotScopedWithMatchingAct
local requestEventTime = ReactFiberWorkLoopnew.requestEventTime
local requestUpdateLane = ReactFiberWorkLoopnew.requestUpdateLane
local markSkippedUpdateLanes = ReactFiberWorkLoopnew.markSkippedUpdateLanes
local getWorkInProgressRoot = ReactFiberWorkLoopnew.getWorkInProgressRoot
local warnIfNotCurrentlyActingEffectsInDEV = ReactFiberWorkLoopnew.warnIfNotCurrentlyActingEffectsInDEV
local Shared4 = require(parent.Shared)
local invariant = Shared4.invariant
local Shared5 = require(parent.Shared)
local getComponentName = Shared5.getComponentName

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function is(p, p2)
	if p == p2 and (p ~= 0 or 1 / p == 1 / p2) then
		return true
	elseif p == p then
		return false
	else
		return p2 ~= p2
	end
end

local ReactFiberBeginWorknew = require(script.Parent["ReactFiberBeginWork.new"])
local markWorkInProgressReceivedUpdate = ReactFiberBeginWorknew.markWorkInProgressReceivedUpdate
local ReactFiberHydrationContextnew = require(script.Parent["ReactFiberHydrationContext.new"])
local getIsHydrating = ReactFiberHydrationContextnew.getIsHydrating
local ReactFiberHostConfig = require(script.Parent.ReactFiberHostConfig)
local makeClientId = ReactFiberHostConfig.makeClientId
local ReactMutableSourcenew = require(script.Parent["ReactMutableSource.new"])
local warnAboutMultipleRenderersDEV = ReactMutableSourcenew.warnAboutMultipleRenderersDEV
local getWorkInProgressVersion = ReactMutableSourcenew.getWorkInProgressVersion
local setWorkInProgressVersion = ReactMutableSourcenew.setWorkInProgressVersion
local markSourceAsDirty = ReactMutableSourcenew.markSourceAsDirty
local DebugTracing = require(script.Parent.DebugTracing)
local logStateUpdateScheduled = DebugTracing.logStateUpdateScheduled
local SchedulingProfiler = require(script.Parent.SchedulingProfiler)
local markStateUpdateScheduled = SchedulingProfiler.markStateUpdateScheduled
local reactCurrentDispatcher = reactSharedInternals.ReactCurrentDispatcher
local SafeFlags = require(parent.SafeFlags)
local v = SafeFlags.createGetFFlag("ReactCleanQueueOnUpdateBailout")()
local v2 = __DEV__ and {} or nil
local New = {}
local v3 = noLanes
local v4 = nil
local v5 = nil
local v6 = nil
local flag = false
local flag2 = false
local v7 = nil
local debugHookTypes = nil
local count = 0
local current2 = nil
local current3 = nil
local current4 = nil
local v12 = nil
local current5 = nil
local current6 = nil
local current7 = nil

local function getHighestIndex(items)
	local v16 = 0

	for k, _ in items do
		if v16 < k then
			v16 = k
		end
	end

	return v16
end

local function isArrayOrSparseArray(items)
	if type(items) ~= "table" then
		return false
	end

	for k, _ in items do
		if type(k) ~= "number" then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mountHookTypesDev()
	if __DEV__ then
		local v16 = v7

		if debugHookTypes == nil then
			debugHookTypes = { v16 }
		else
			table.insert(debugHookTypes, v16)
		end
	end
end

function updateHookTypesDev()
	if __DEV__ then
		local v16 = v7

		if debugHookTypes ~= nil then
			count += 1

			if debugHookTypes[count] ~= v16 then
				warnOnHookMismatchInDev(v16)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkDepsAreArrayDev(items)
	if __DEV__ and items ~= nil then
		local v16

		if type(items) == "table" then
			local flag3 = true

			for k, _ in items do
				if type(k) == "number" then
					continue
				end

				v16 = false
				flag3 = false
				break
			end

			if flag3 then
				v16 = true
			end
		else
			v16 = false
		end

		if not v16 then
			console.error(
				"%s received a final argument that is not an array (instead, received `%s`). When specified, the final argument must be an array.",
				v7,
				(type(items))
			)
		end
	end
end

function warnOnHookMismatchInDev(p)
	if __DEV__ then
		local v16 = getComponentName(v4.type) or "Component"

		if not v2[v16] then
			v2[v16] = true

			if debugHookTypes ~= nil then
				local v17 = ""

				for i = 1, count do
					local v18 = debugHookTypes[i]
					local v19

					if i == count then
						v19 = p
					else
						v19 = v18
					end

					local v20 = tostring(i) .. ". " .. (v18 or "undefined")

					while string.len(v20) < 30 do
						v20 ..= " "
					end

					v17 ..= v20 .. v19 .. "\n"
				end

				console.error([[
React has detected a change in the order of Hooks called by %s. This will lead to bugs and errors if not fixed. For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

   Previous render            Next render
   ------------------------------------------------------
%s   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
]], v16, v17)
			end
		end
	end
end

local function throwInvalidHookError()
	error(error2.new([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]]))
end

local function areHookInputsEqual(list, list2)
	if list2 == nil then
		if __DEV__ then
			console.error(
				"%s received a final argument during this render, but not during the previous render. Even though the final argument is optional, its type cannot change between renders.",
				v7
			)
		end

		return false
	else
		local v16 = 0

		for k, _ in list do
			if v16 < k then
				v16 = k
			end
		end

		local v17 = 0

		for k, _ in list2 do
			if v17 < k then
				v17 = k
			end
		end

		if v16 ~= v17 then
			return false
		end

		for i = 1, math.min(v17, v16) do
			if not is(list[i], list2[i]) then
				return false
			end
		end

		return true
	end
end

function New:bailoutHooks(p, p2)
	p.updateQueue = self.updateQueue

	if __DEV__ and enableDoubleInvokingEffects then
		p.flags = bit32.band(p.flags, (bit32.bnot((bit32.bor(mountPassiveDev, passive, mountLayoutDev, update)))))
	else
		p.flags = bit32.band(p.flags, (bit32.bnot((bit32.bor(passive, update)))))
	end

	self.lanes = removeLanes(self.lanes, p2)
end

local v16 = false

function New.resetHooksAfterThrow()
	reactCurrentDispatcher.current = New.ContextOnlyDispatcher

	if flag then
		local memoizedState = v4.memoizedState

		while memoizedState ~= nil do
			local queue = memoizedState.queue

			if queue ~= nil then
				queue.pending = nil
			end

			memoizedState = memoizedState.next
		end

		flag = false
	end

	v3 = noLanes
	v4 = nil
	v5 = nil
	v6 = nil

	if __DEV__ then
		debugHookTypes = nil
		count = 0
		v7 = nil
		v16 = false
	end

	flag2 = false
end

local function mountWorkInProgressHook()
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	return v6
end

local function updateWorkInProgressHook()
	local memoizedState

	if v5 == nil then
		local alternate = v4.alternate

		if alternate ~= nil then
			memoizedState = alternate.memoizedState
		end
	else
		memoizedState = v5.next
	end

	local memoizedState2

	if v6 == nil then
		memoizedState2 = v4.memoizedState
	else
		memoizedState2 = v6.next
	end

	if memoizedState2 == nil then
		if memoizedState == nil then
			error(error2.new("Rendered more hooks than during the previous render."))
		end

		v5 = memoizedState
		local v17 = {
			memoizedState = v5.memoizedState,
			baseState = v5.baseState,
			baseQueue = v5.baseQueue,
			queue = v5.queue,
			next = nil
		}

		if v6 == nil then
			v6 = v17
			v4.memoizedState = v17
		else
			v6.next = v17
			v6 = v17
		end
	else
		v6 = memoizedState2
		local _ = v6.next
		v5 = memoizedState
	end

	return v6
end

function basicStateReducer(p, callback)
	if type(callback) == "function" then
		return callback(p)
	end

	return callback
end

function mountReducer(lastRenderedReducer, baseState, callback2)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6

	if callback2 ~= nil then
		baseState = callback2(baseState)
	end

	v18.baseState = baseState
	v18.memoizedState = v18.baseState
	local queue = {
		pending = nil,
		dispatch = nil,
		lastRenderedReducer = lastRenderedReducer,
		lastRenderedState = baseState
	}
	v18.queue = queue
	local v20 = v4

	local function fn(p, ...)
		dispatchAction(v20, queue, p, ...)
	end

	queue.dispatch = fn
	return v18.memoizedState, fn
end

function updateReducer(lastRenderedReducer, _, _)
	local v17 = updateWorkInProgressHook()
	local queue = v17.queue
	assert(queue ~= nil, "Should have a queue. This is likely a bug in React. Please file an issue.")
	queue.lastRenderedReducer = lastRenderedReducer
	local v18 = v5
	local baseQueue = v18.baseQueue
	local pending = queue.pending

	if pending ~= nil then
		if baseQueue ~= nil then
			local next = baseQueue.next
			baseQueue.next = pending.next
			pending.next = next
		end

		v18.baseQueue = pending
		queue.pending = nil
		baseQueue = pending
	end

	if baseQueue ~= nil then
		local next = baseQueue.next
		local baseState = v18.baseState
		local next2 = next
		local next3 = nil
		local next4 = nil
		local baseState2 = nil

		while true do
			local lane = next2.lane

			if bit32.band(v3, lane) == lane then
				if next3 ~= nil then
					next3.next = {
						lane = noLane,
						action = next2.action,
						eagerReducer = next2.eagerReducer,
						eagerState = next2.eagerState,
						next = nil
					}
					next3 = next3.next
				end

				if next2.eagerReducer == lastRenderedReducer then
					baseState = next2.eagerState
				else
					baseState = lastRenderedReducer(baseState, next2.action)
				end
			else
				local next5 = {
					lane = lane,
					action = next2.action,
					eagerReducer = next2.eagerReducer,
					eagerState = next2.eagerState,
					next = nil
				}

				if next3 == nil then
					baseState2 = baseState
					next4 = next5
					next3 = next4
					next4 = next3
				else
					next3.next = next5
					next3 = next3.next
				end

				v4.lanes = mergeLanes(v4.lanes, lane)
				markSkippedUpdateLanes(lane)
			end

			next2 = next2.next

			if not (next2 == nil or next2 == next) then
				continue
			end

			if next3 == nil then
				baseState2 = baseState
			else
				next3.next = next4
			end

			if not is(baseState, v17.memoizedState) then
				markWorkInProgressReceivedUpdate()
			end

			v17.memoizedState = baseState
			v17.baseState = baseState2
			v17.baseQueue = next3
			queue.lastRenderedState = baseState
			break
		end
	end

	local dispatch = queue.dispatch
	return v17.memoizedState, dispatch
end

function rerenderReducer(lastRenderedReducer, _, _)
	local v17 = updateWorkInProgressHook()
	local queue = v17.queue
	assert(queue ~= nil, "Should have a queue. This is likely a bug in React. Please file an issue.")
	queue.lastRenderedReducer = lastRenderedReducer
	local dispatch = queue.dispatch
	local pending = queue.pending
	local memoizedState = v17.memoizedState

	if pending == nil then
		return memoizedState, dispatch
	end

	queue.pending = nil
	local next = pending.next
	local next2 = next

	repeat
		memoizedState = lastRenderedReducer(memoizedState, next2.action)
		next2 = next2.next
	until next2 == next

	if not is(memoizedState, v17.memoizedState) then
		markWorkInProgressReceivedUpdate()
	end

	v17.memoizedState = memoizedState

	if v17.baseQueue == nil then
		v17.baseState = memoizedState
	end

	queue.lastRenderedState = memoizedState
	return memoizedState, dispatch
end

function readFromUnsubcribedMutableSource(p, p2, callback)
	if __DEV__ then
		warnAboutMultipleRenderersDEV(p2)
	end

	local _getVersion = p2._getVersion(p2._source)
	local workInProgressVersion = getWorkInProgressVersion(p2)
	local v17

	if workInProgressVersion == nil then
		v17 = isSubsetOfLanes(v3, p.mutableReadLanes)

		if v17 then
			setWorkInProgressVersion(p2, _getVersion)
		end
	else
		v17 = workInProgressVersion == _getVersion
	end

	if v17 then
		local v18 = callback(p2._source)

		if __DEV__ and type(v18) == "function" then
			console.error("Mutable source should not return a function as the snapshot value. Functions may close over mutable values and cause tearing.")
		end

		return v18
	else
		markSourceAsDirty(p2)
		error(error2.new("Cannot read from mutable source during the current render without tearing. This is a bug in React. Please file an issue."))
	end
end

function useMutableSource(p, source2, getSnapshot, subscribe2)
	local workInProgressRoot = getWorkInProgressRoot()
	invariant(
		workInProgressRoot ~= nil,
		"Expected a work-in-progress root. This is a bug in React. Please file an issue."
	)
	local _getVersion = source2._getVersion
	local v17 = _getVersion(source2._source)
	local current = reactCurrentDispatcher.current
	assert(current ~= nil, "dispatcher was nil, this is a bug in React")
	local state, setState = current.useState(function()
		return readFromUnsubcribedMutableSource(workInProgressRoot, source2, getSnapshot)
	end)
	local v18 = state
	local v19 = v6
	local memoizedState = p.memoizedState

	if memoizedState.refs == nil then
		error((tostring(debug.traceback())))
	end

	local refs = memoizedState.refs
	local getSnapshot2 = refs.getSnapshot
	local source = memoizedState.source
	local subscribe = memoizedState.subscribe
	local v20 = v4
	p.memoizedState = {
		refs = refs,
		source = source2,
		subscribe = subscribe2
	}
	current.useEffect(function()
		refs.getSnapshot = getSnapshot
		refs.setSnapshot = setState

		if not is(v17, _getVersion(source2._source)) then
			local snapshot = getSnapshot(source2._source)

			if __DEV__ and type(snapshot) == "function" then
				console.error("Mutable source should not return a function as the snapshot value. Functions may close over mutable values and cause tearing.")
			end

			if not is(v18, snapshot) then
				setState(snapshot)
				markRootMutableRead(workInProgressRoot, (requestUpdateLane(v20)))
			end

			markRootEntangled(workInProgressRoot, workInProgressRoot.mutableReadLanes)
		end
	end, { getSnapshot, source2, subscribe2 })
	current.useEffect(function()
		local function fn()
			local getSnapshot3 = refs.getSnapshot
			local setSnapshot = refs.setSnapshot
			local success, result = pcall(function()
				setSnapshot(getSnapshot3(source2._source))
				markRootMutableRead(workInProgressRoot, (requestUpdateLane(v20)))
			end)

			if not success then
				setSnapshot(function()
					error(result)
				end)
			end
		end

		local v21 = subscribe2(source2._source, fn)

		if __DEV__ and type(v21) ~= "function" then
			console.error("Mutable source subscribe function must return an unsubscribe function.")
		end

		return v21
	end, { source2, subscribe2 })
	local queue, v23

	if is(getSnapshot2, getSnapshot) then
		if is(source, source2) then
			if not is(subscribe, subscribe2) then
				queue = {
					pending = nil,
					dispatch = nil,
					lastRenderedReducer = basicStateReducer,
					lastRenderedState = v18
				}
				v23 = v4

				setState = function(...)
					dispatchAction(v23, queue, ...)
				end

				queue.dispatch = setState
				v19.queue = queue
				v19.baseQueue = nil
				v18 = readFromUnsubcribedMutableSource(workInProgressRoot, source2, getSnapshot)
				v19.baseState = v18
				v19.memoizedState = v19.baseState
			end
		else
			queue = {
				pending = nil,
				dispatch = nil,
				lastRenderedReducer = basicStateReducer,
				lastRenderedState = v18
			}
			v23 = v4

			setState = function(...)
				dispatchAction(v23, queue, ...)
			end

			queue.dispatch = setState
			v19.queue = queue
			v19.baseQueue = nil
			v18 = readFromUnsubcribedMutableSource(workInProgressRoot, source2, getSnapshot)
			v19.baseState = v18
			v19.memoizedState = v19.baseState
		end
	else
		queue = {
			pending = nil,
			dispatch = nil,
			lastRenderedReducer = basicStateReducer,
			lastRenderedState = v18
		}
		v23 = v4

		setState = function(...)
			dispatchAction(v23, queue, ...)
		end

		queue.dispatch = setState
		v19.queue = queue
		v19.baseQueue = nil
		v18 = readFromUnsubcribedMutableSource(workInProgressRoot, source2, getSnapshot)
		v19.baseState = v18
		v19.memoizedState = v19.baseState
	end

	return v18
end

function mountMutableSource(source, getSnapshot, subscribe)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6
	v18.memoizedState = {
		refs = {
			getSnapshot = getSnapshot,
			setSnapshot = nil
		},
		source = source,
		subscribe = subscribe
	}
	return useMutableSource(v18, source, getSnapshot, subscribe)
end

function updateMutableSource(p, p2, p3)
	local v17 = updateWorkInProgressHook()
	return useMutableSource(v17, p, p2, p3)
end

function mountState(baseState)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6

	if type(baseState) == "function" then
		baseState = baseState()
	end

	v18.baseState = baseState
	v18.memoizedState = v18.baseState
	local queue = {
		pending = nil,
		dispatch = nil,
		lastRenderedReducer = basicStateReducer,
		lastRenderedState = baseState
	}
	v18.queue = queue
	local v20 = v4

	local function fn(p, ...)
		dispatchAction(v20, queue, p, ...)
	end

	queue.dispatch = fn
	return v18.memoizedState, fn
end

function updateState(p)
	return updateReducer(basicStateReducer, p)
end

function rerenderState(p)
	return rerenderReducer(basicStateReducer, p)
end

local function pushEffect(tag, create, destroy, deps)
	local v17 = {
		tag = tag,
		create = create,
		destroy = destroy,
		deps = deps,
		next = nil
	}
	local updateQueue = v4.updateQueue

	if updateQueue == nil then
		local updateQueue2 = {
			lastEffect = nil
		}
		v4.updateQueue = updateQueue2
		v17.next = v17
		updateQueue2.lastEffect = v17
		return v17
	else
		local lastEffect = updateQueue.lastEffect

		if lastEffect == nil then
			updateQueue.lastEffect = v17
			v17.next = v17
			return v17
		else
			local next = lastEffect.next
			lastEffect.next = v17
			v17.next = next
			updateQueue.lastEffect = v17
			return v17
		end
	end
end

function mountBinding(p)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6
	local binding, v19 = createBinding(p)
	v18.memoizedState = { binding, v19 }
	return binding, v19
end

function updateBinding(_)
	return unpack(updateWorkInProgressHook().memoizedState)
end

function mountRef(current)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6
	local ref = createRef()
	ref.current = current
	v18.memoizedState = ref
	return ref
end

function updateRef(_)
	return updateWorkInProgressHook().memoizedState
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mountEffectImpl(p, layout2, fn, joined)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6
	v4.flags = bit32.bor(v4.flags, p)
	v18.memoizedState = pushEffect(bit32.bor(hasEffect, layout2), fn, nil, joined)
end

function updateEffectImpl(p, tag, create, deps)
	local v17 = updateWorkInProgressHook()
	local destroy

	if v5 ~= nil then
		local memoizedState = v5.memoizedState
		destroy = memoizedState.destroy

		if deps ~= nil and areHookInputsEqual(deps, memoizedState.deps) then
			v17.memoizedState = pushEffect(tag, create, destroy, deps)
			return
		end
	end

	v4.flags = bit32.bor(v4.flags, p)
	v17.memoizedState = pushEffect(bit32.bor(hasEffect, tag), create, destroy, deps)
end

local function mountEffect(create, deps)
	if __DEV__ and (type(_G.jest) ~= "nil" or ReactGlobals.__TESTEZ_RUNNING_TEST__) then
		warnIfNotCurrentlyActingEffectsInDEV(v4)
	end

	if __DEV__ and enableDoubleInvokingEffects then
		mountEffectImpl(bit32.bor(mountPassiveDev, passive, passiveStatic), passive2, create, deps) -- equivalent call inferred; original call site unknown
	else
		mountEffectImpl(bit32.bor(passive, passiveStatic), passive2, create, deps) -- equivalent call inferred; original call site unknown
	end
end

local function updateEffect(callback, p)
	if __DEV__ and (type(_G.jest) ~= "nil" or ReactGlobals.__TESTEZ_RUNNING_TEST__) then
		warnIfNotCurrentlyActingEffectsInDEV(v4)
	end

	updateEffectImpl(passive, passive2, callback, p)
end

local function mountLayoutEffect(create, deps)
	if __DEV__ and enableDoubleInvokingEffects then
		mountEffectImpl(bit32.bor(mountLayoutDev, update), layout, create, deps) -- equivalent call inferred; original call site unknown
	else
		mountEffectImpl(update, layout, create, deps) -- equivalent call inferred; original call site unknown
	end
end

local function updateLayoutEffect(callback, p)
	updateEffectImpl(update, layout, callback, p)
end

function imperativeHandleEffect(callback, callback2)
	if callback2 ~= nil and type(callback2) == "function" then
		callback2((callback()))
		return function()
			return callback2(nil)
		end
	end

	if callback2 == nil then
		return nil
	end

	if __DEV__ then
		local v17

		if getmetatable(callback2) == nil then
			v17 = false
		else
			v17 = #object.keys(callback2) == 0
		end

		if not v17 then
			console.error(
				"Expected useImperativeHandle() first argument to either be a ref callback or React.createRef() object. Instead received: %s.",
				"an object with keys {" .. array.join(object.keys(callback2), ", ") .. "}"
			)
		end
	end

	callback2.current = callback()
	return function()
		callback2.current = nil
	end
end

function mountImperativeHandle(p, callback, p2)
	if __DEV__ and type(callback) ~= "function" then
		console.error(
			"Expected useImperativeHandle() second argument to be a function that creates a handle. Instead received: %s.",
			callback == nil and "nil" or type(callback)
		)
	end

	local joined

	if p2 ~= nil then
		joined = array.concat(p2, { p })
	end

	if __DEV__ and enableDoubleInvokingEffects then
		return mountEffectImpl(bit32.bor(mountLayoutDev, update), layout, function()
			return imperativeHandleEffect(callback, p)
		end, joined)
	end

	return mountEffectImpl(update, layout, function()
		return imperativeHandleEffect(callback, p)
	end, joined)
end

function updateImperativeHandle(p, callback, p2)
	if __DEV__ and type(callback) ~= "function" then
		local v17 = not callback and "nil" or type(callback)
		console.error(
			"Expected useImperativeHandle() second argument to be a function that creates a handle. Instead received: %s.",
			v17
		)
	end

	local clone

	if p2 ~= nil then
		clone = table.clone(p2)
		table.insert(clone, p)
	end

	return updateEffectImpl(update, layout, function()
		return imperativeHandleEffect(callback, p)
	end, clone)
end

function mountDebugValue(_, _) end

local mountDebugValue2 = mountDebugValue

function mountCallback(p, p2)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	v6.memoizedState = { p, p2 }
	return p
end

function updateCallback(p, p2)
	local v17 = updateWorkInProgressHook()
	local memoizedState = v17.memoizedState

	if memoizedState ~= nil and p2 ~= nil and areHookInputsEqual(p2, memoizedState[2]) then
		return memoizedState[1]
	end

	v17.memoizedState = { p, p2 }
	return p
end

function mountMemo(callback, p)
	local v17 = {
		memoizedState = nil,
		baseState = nil,
		baseQueue = nil,
		queue = nil,
		next = nil
	}

	if v6 == nil then
		v4.memoizedState = v17
	else
		v6.next = v17
	end

	v6 = v17
	local v18 = v6
	local v19 = { callback() }
	v18.memoizedState = { v19, p }
	return unpack(v19)
end

function updateMemo(callback, p)
	local v17 = updateWorkInProgressHook()
	local memoizedState = v17.memoizedState

	if memoizedState ~= nil and p ~= nil and areHookInputsEqual(p, memoizedState[2]) then
		return unpack(memoizedState[1])
	end

	local v18 = { callback() }
	v17.memoizedState = { v18, p }
	return unpack(v18)
end

function New.getIsUpdatingOpaqueValueInRenderPhaseInDEV()
	if __DEV__ then
		return false
	end

	return nil
end

function mountOpaqueIdentifier()
	local v17 = nil

	if __DEV__ then
		console.warn("!!! unimplemented: warnOnOpaqueIdentifierAccessInDEV")
	else
		v17 = makeClientId
	end

	if getIsHydrating() then
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("UNIMPLEMENTED ERROR: ReactFiberHooks: getIsHydrating() true")
		error("FIXME (roblox): ReactFiberHooks: getIsHydrating() true is unimplemented")
		return nil
	else
		local v18 = v17()
		mountState(v18)
		return v18
	end
end

function updateOpaqueIdentifier()
	local v17, _ = updateState(nil)
	return v17
end

function rerenderOpaqueIdentifier()
	local v17, _ = rerenderState(nil)
	return v17
end

function dispatchAction(data, state, action, ...)
	if __DEV__ then
		local v17

		if select("#", ...) == 1 then
			v17 = select(1, ...)
		end

		if type(v17) == "function" then
			console.error("State updates from the useState() and useReducer() Hooks don't support the second callback argument. To execute a side effect after rendering, declare it in the component body with useEffect().")
		end
	end

	local v17 = requestEventTime()
	local lane = requestUpdateLane(data)
	local v19 = {
		lane = lane,
		action = action,
		eagerReducer = nil,
		eagerState = nil,
		next = nil
	}
	local pending = state.pending

	if pending == nil then
		v19.next = v19
	else
		v19.next = pending.next
		pending.next = v19
	end

	state.pending = v19
	local alternate = data.alternate

	if data == v4 or alternate ~= nil and alternate == v4 then
		flag = true
		flag2 = true
	else
		if data.lanes == noLanes and (alternate == nil or alternate.lanes == noLanes) then
			local lastRenderedReducer = state.lastRenderedReducer

			if lastRenderedReducer ~= nil then
				local current

				if __DEV__ then
					current = reactCurrentDispatcher.current
					reactCurrentDispatcher.current = current6
				end

				local lastRenderedState = state.lastRenderedState
				local success, result = pcall(lastRenderedReducer, lastRenderedState, action)

				if success then
					v19.eagerReducer = lastRenderedReducer
					v19.eagerState = result
				end

				if __DEV__ then
					reactCurrentDispatcher.current = current
				end

				if is(result, lastRenderedState) then
					if not v then
						return
					end

					if pending == nil then
						state.pending = nil
						return
					else
						pending.next = v19.next
						state.pending = pending
					end

					return
				end
			end
		end

		if __DEV__ and (type(_G.jest) ~= "nil" or ReactGlobals.__TESTEZ_RUNNING_TEST__) then
			warnIfNotScopedWithMatchingAct(data)
			warnIfNotCurrentlyActingUpdatesInDEV(data)
		end

		scheduleUpdateOnFiber(data, lane, v17)
	end

	if __DEV__ and enableDebugTracing and bit32.band(data.mode, debugTracingMode) ~= 0 then
		logStateUpdateScheduled(getComponentName(data.type) or "Unknown", lane, action)
	end

	if enableSchedulingProfiler then
		markStateUpdateScheduled(data, lane)
	end
end

local v17 = {
	readContext = readContext,
	useCallback = throwInvalidHookError,
	useContext = throwInvalidHookError,
	useEffect = throwInvalidHookError,
	useImperativeHandle = throwInvalidHookError,
	useLayoutEffect = throwInvalidHookError,
	useMemo = throwInvalidHookError,
	useReducer = throwInvalidHookError,
	useRef = throwInvalidHookError,
	useBinding = throwInvalidHookError,
	useState = throwInvalidHookError,
	useDebugValue = throwInvalidHookError,
	useMutableSource = throwInvalidHookError,
	useOpaqueIdentifier = throwInvalidHookError,
	unstable_isNewReconciler = enableNewReconciler
}
New.ContextOnlyDispatcher = v17
local v18 = {
	readContext = readContext,
	useCallback = mountCallback,
	useContext = readContext,
	useEffect = mountEffect,
	useImperativeHandle = mountImperativeHandle,
	useLayoutEffect = mountLayoutEffect,
	useMemo = mountMemo,
	useReducer = mountReducer,
	useRef = mountRef,
	useBinding = mountBinding,
	useState = mountState,
	useDebugValue = mountDebugValue,
	useMutableSource = mountMutableSource,
	useOpaqueIdentifier = mountOpaqueIdentifier,
	unstable_isNewReconciler = enableNewReconciler
}
local v19 = {
	readContext = readContext,
	useCallback = updateCallback,
	useContext = readContext,
	useEffect = updateEffect,
	useImperativeHandle = updateImperativeHandle,
	useLayoutEffect = updateLayoutEffect,
	useMemo = updateMemo,
	useReducer = updateReducer,
	useRef = updateRef,
	useBinding = updateBinding,
	useState = updateState,
	useDebugValue = mountDebugValue2,
	useMutableSource = updateMutableSource,
	useOpaqueIdentifier = updateOpaqueIdentifier,
	unstable_isNewReconciler = enableNewReconciler
}
local v20 = {
	readContext = readContext,
	useCallback = updateCallback,
	useContext = readContext,
	useEffect = updateEffect,
	useImperativeHandle = updateImperativeHandle,
	useLayoutEffect = updateLayoutEffect,
	useMemo = updateMemo,
	useReducer = rerenderReducer,
	useRef = updateRef,
	useBinding = updateBinding,
	useState = rerenderState,
	useDebugValue = mountDebugValue2,
	useMutableSource = updateMutableSource,
	useOpaqueIdentifier = rerenderOpaqueIdentifier,
	unstable_isNewReconciler = enableNewReconciler
}

if __DEV__ then
	current2 = {
		readContext = function(p, p2)
			return readContext(p, p2)
		end,
		useCallback = function(p, items)
			v7 = "useCallback"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			checkDepsAreArrayDev(items) -- equivalent call inferred; original call site unknown
			return mountCallback(p, items)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return readContext(p, p2)
		end,
		useEffect = function(create, deps)
			v7 = "useEffect"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			checkDepsAreArrayDev(deps) -- equivalent call inferred; original call site unknown
			return mountEffect(create, deps)
		end,
		useImperativeHandle = function(p, callback, items)
			v7 = "useImperativeHandle"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			checkDepsAreArrayDev(items) -- equivalent call inferred; original call site unknown
			return mountImperativeHandle(p, callback, items)
		end,
		useLayoutEffect = function(create, deps)
			v7 = "useLayoutEffect"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			checkDepsAreArrayDev(deps) -- equivalent call inferred; original call site unknown
			return mountLayoutEffect(create, deps)
		end,
		useMemo = function(callback, items)
			v7 = "useMemo"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			checkDepsAreArrayDev(items) -- equivalent call inferred; original call site unknown
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local v21 = { pcall(mountMemo, callback, items) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local success, result, v21 = pcall(mountReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local success, result, v21 = pcall(mountState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountDebugValue(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
	current3 = {
		readContext = function(p, p2)
			return readContext(p, p2)
		end,
		useCallback = function(p, items)
			v7 = "useCallback"
			updateHookTypesDev()
			checkDepsAreArrayDev(items) -- equivalent call inferred; original call site unknown
			return mountCallback(p, items)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			updateHookTypesDev()
			return readContext(p, p2)
		end,
		useEffect = function(create, deps)
			v7 = "useEffect"
			updateHookTypesDev()
			return mountEffect(create, deps)
		end,
		useImperativeHandle = function(p, callback, p2)
			v7 = "useImperativeHandle"
			updateHookTypesDev()
			return mountImperativeHandle(p, callback, p2)
		end,
		useLayoutEffect = function(create, deps)
			v7 = "useLayoutEffect"
			updateHookTypesDev()
			return mountLayoutEffect(create, deps)
		end,
		useMemo = function(callback, p)
			v7 = "useMemo"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local v21 = { pcall(mountMemo, callback, p) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local success, result, v21 = pcall(mountReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			updateHookTypesDev()
			return mountRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			updateHookTypesDev()
			return mountBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local success, result, v21 = pcall(mountState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			updateHookTypesDev()
			return mountDebugValue(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			updateHookTypesDev()
			return mountMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			updateHookTypesDev()
			return mountOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
	current4 = {
		readContext = function(p, p2)
			return readContext(p, p2)
		end,
		useCallback = function(p, p2)
			v7 = "useCallback"
			updateHookTypesDev()
			return updateCallback(p, p2)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			updateHookTypesDev()
			return readContext(p, p2)
		end,
		useEffect = function(callback, p)
			v7 = "useEffect"
			updateHookTypesDev()
			return updateEffect(callback, p)
		end,
		useImperativeHandle = function(p, callback, p2)
			v7 = "useImperativeHandle"
			updateHookTypesDev()
			return updateImperativeHandle(p, callback, p2)
		end,
		useLayoutEffect = function(callback, p)
			v7 = "useLayoutEffect"
			updateHookTypesDev()
			return updateLayoutEffect(callback, p)
		end,
		useMemo = function(callback, p)
			v7 = "useMemo"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local v21 = { pcall(updateMemo, callback, p) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local success, result, v21 = pcall(updateReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			updateHookTypesDev()
			return updateRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			updateHookTypesDev()
			return updateBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local success, result, v21 = pcall(updateState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			updateHookTypesDev()
			return mountDebugValue2(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			updateHookTypesDev()
			return updateMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			updateHookTypesDev()
			return updateOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
	v12 = {
		readContext = function(p, p2)
			return readContext(p, p2)
		end,
		useCallback = function(p, p2)
			v7 = "useCallback"
			updateHookTypesDev()
			return updateCallback(p, p2)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			updateHookTypesDev()
			return readContext(p, p2)
		end,
		useEffect = function(callback, p)
			v7 = "useEffect"
			updateHookTypesDev()
			return updateEffect(callback, p)
		end,
		useImperativeHandle = function(p, callback, p2)
			v7 = "useImperativeHandle"
			updateHookTypesDev()
			return updateImperativeHandle(p, callback, p2)
		end,
		useLayoutEffect = function(callback, p)
			v7 = "useLayoutEffect"
			updateHookTypesDev()
			return updateLayoutEffect(callback, p)
		end,
		useMemo = function(callback, p)
			v7 = "useMemo"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current7
			local v21 = { pcall(updateMemo, callback, p) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current7
			local success, result, v21 = pcall(rerenderReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			updateHookTypesDev()
			return updateRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			updateHookTypesDev()
			return updateBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current7
			local success, result, v21 = pcall(rerenderState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			updateHookTypesDev()
			return mountDebugValue2(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			updateHookTypesDev()
			return updateMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			updateHookTypesDev()
			return rerenderOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
	current5 = {
		readContext = function(p, p2)
			console.error("Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().")
			return readContext(p, p2)
		end,
		useCallback = function(p, p2)
			v7 = "useCallback"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountCallback(p, p2)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return readContext(p, p2)
		end,
		useEffect = function(create, deps)
			v7 = "useEffect"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountEffect(create, deps)
		end,
		useImperativeHandle = function(p, callback, p2)
			v7 = "useImperativeHandle"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountImperativeHandle(p, callback, p2)
		end,
		useLayoutEffect = function(create, deps)
			v7 = "useLayoutEffect"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountLayoutEffect(create, deps)
		end,
		useMemo = function(callback, p)
			v7 = "useMemo"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local v21 = { pcall(mountMemo, callback, p) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local success, result, v21 = pcall(mountReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current5
			local success, result, v21 = pcall(mountState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountDebugValue(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			mountHookTypesDev() -- equivalent call inferred; original call site unknown
			return mountOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
	current6 = {
		readContext = function(p, p2)
			console.error("Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().")
			return readContext(p, p2)
		end,
		useCallback = function(p, p2)
			v7 = "useCallback"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return mountCallback(p, p2)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return readContext(p, p2)
		end,
		useEffect = function(callback, p)
			v7 = "useEffect"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateEffect(callback, p)
		end,
		useImperativeHandle = function(p, callback, p2)
			v7 = "useImperativeHandle"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateImperativeHandle(p, callback, p2)
		end,
		useLayoutEffect = function(callback, p)
			v7 = "useLayoutEffect"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateLayoutEffect(callback, p)
		end,
		useMemo = function(callback, p)
			v7 = "useMemo"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local v21 = { pcall(updateMemo, callback, p) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local success, result, v21 = pcall(updateReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local success, result, v21 = pcall(updateState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return mountDebugValue2(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
	current7 = {
		readContext = function(p, p2)
			console.error("Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().")
			return readContext(p, p2)
		end,
		useCallback = function(p, p2)
			v7 = "useCallback"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateCallback(p, p2)
		end,
		useContext = function(p, p2)
			v7 = "useContext"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return readContext(p, p2)
		end,
		useEffect = function(callback, p)
			v7 = "useEffect"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateEffect(callback, p)
		end,
		useImperativeHandle = function(p, callback, p2)
			v7 = "useImperativeHandle"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateImperativeHandle(p, callback, p2)
		end,
		useLayoutEffect = function(callback, p)
			v7 = "useLayoutEffect"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateLayoutEffect(callback, p)
		end,
		useMemo = function(callback, p)
			v7 = "useMemo"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local v21 = { pcall(updateMemo, callback, p) }
			reactCurrentDispatcher.current = current

			if not v21[1] then
				error(v21[2])
			end

			return unpack(v21, 2)
		end,
		useReducer = function(callback, p, callback2)
			v7 = "useReducer"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local success, result, v21 = pcall(rerenderReducer, callback, p, callback2)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useRef = function(p)
			v7 = "useRef"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateRef(p)
		end,
		useBinding = function(p)
			v7 = "useBinding"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateBinding(p)
		end,
		useState = function(p)
			v7 = "useState"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			local current = reactCurrentDispatcher.current
			reactCurrentDispatcher.current = current6
			local success, result, v21 = pcall(rerenderState, p)
			reactCurrentDispatcher.current = current

			if not success then
				error(result)
			end

			return result, v21
		end,
		useDebugValue = function(p, callback)
			v7 = "useDebugValue"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return mountDebugValue2(p, callback)
		end,
		useMutableSource = function(p, p2, p3)
			v7 = "useMutableSource"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return updateMutableSource(p, p2, p3)
		end,
		useOpaqueIdentifier = function()
			v7 = "useOpaqueIdentifier"
			console.error("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks")
			updateHookTypesDev()
			return rerenderOpaqueIdentifier()
		end,
		unstable_isNewReconciler = enableNewReconciler
	}
end

function New:renderWithHooks(p2, callback, p3, p4, p5)
	v3 = p5
	v4 = p2

	if __DEV__ then
		local v21

		if self ~= nil then
			v21 = self._debugHookTypes
		end

		debugHookTypes = v21
		count = 0
	end

	p2.memoizedState = nil
	p2.updateQueue = nil
	p2.lanes = noLanes

	if __DEV__ then
		if self == nil or self.memoizedState == nil then
			if debugHookTypes == nil then
				reactCurrentDispatcher.current = current2
			else
				reactCurrentDispatcher.current = current3
			end
		else
			reactCurrentDispatcher.current = current4
		end
	else
		reactCurrentDispatcher.current = (self == nil or self.memoizedState == nil) and v18 or v19
	end

	local v21 = callback(p3, p4)

	if flag2 then
		local count2 = 0

		repeat
			flag2 = false

			if count2 >= 25 then
				error(error2.new("Too many re-renders. React limits the number of renders to prevent an infinite loop."))
			end

			count2 += 1
			v5 = nil
			v6 = nil
			p2.updateQueue = nil

			if __DEV__ then
				count = 0
			end

			reactCurrentDispatcher.current = __DEV__ and v12 or v20
			v21 = callback(p3, p4)
		until not flag2
	end

	reactCurrentDispatcher.current = v17

	if __DEV__ then
		p2._debugHookTypes = debugHookTypes
	end

	local v22

	if v5 == nil then
		v22 = false
	else
		v22 = v5.next ~= nil
	end

	v3 = noLanes
	v4 = nil
	v5 = nil
	v6 = nil

	if __DEV__ then
		v7 = nil
		debugHookTypes = nil
		count = 0
	end

	flag = false

	if not v22 then
		return v21
	end

	local v23 = "unknown"

	if v21 and v21.type then
		v23 = getComponentName(v21.type) or v23
	end

	error(error2.new("Rendered fewer hooks than expected. This may be caused by an accidental " .. "early return statement. Inside '" .. v23 .. "'"))
	return v21
end

return New