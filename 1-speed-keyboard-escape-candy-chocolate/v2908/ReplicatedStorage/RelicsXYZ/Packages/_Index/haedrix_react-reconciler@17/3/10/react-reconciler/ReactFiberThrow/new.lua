local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local object = LuauPolyfill.Object
local Shared = require(parent.Shared)
local console = Shared.console
require(script.Parent.ReactInternalTypes)
local ReactFiberLane = require(script.Parent.ReactFiberLane)
require(script.Parent.ReactCapturedValue)
local ReactUpdateQueuenew = require(script.Parent["ReactUpdateQueue.new"])
require(parent.Shared)
local ReactFiberSuspenseContextnew = require(script.Parent["ReactFiberSuspenseContext.new"])
local Shared2 = require(parent.Shared)
local getComponentName = Shared2.getComponentName
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local suspenseComponent = ReactWorkTags.SuspenseComponent
local incompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local ReactFiberFlags = require(script.Parent.ReactFiberFlags)
local didCapture = ReactFiberFlags.DidCapture
local incomplete = ReactFiberFlags.Incomplete
local noFlags = ReactFiberFlags.NoFlags
local shouldCapture = ReactFiberFlags.ShouldCapture
local lifecycleEffectMask = ReactFiberFlags.LifecycleEffectMask
local forceUpdateForLegacySuspense = ReactFiberFlags.ForceUpdateForLegacySuspense
local ReactFiberSuspenseComponentnew = require(script.Parent["ReactFiberSuspenseComponent.new"])
local shouldCaptureSuspense = ReactFiberSuspenseComponentnew.shouldCaptureSuspense
local ReactTypeOfMode = require(script.Parent.ReactTypeOfMode)
local noMode = ReactTypeOfMode.NoMode
local blockingMode = ReactTypeOfMode.BlockingMode
local debugTracingMode = ReactTypeOfMode.DebugTracingMode
local Shared3 = require(parent.Shared)
local reactFeatureFlags = Shared3.ReactFeatureFlags
local enableDebugTracing = reactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = reactFeatureFlags.enableSchedulingProfiler
local ReactCapturedValue = require(script.Parent.ReactCapturedValue)
local createCapturedValue = ReactCapturedValue.createCapturedValue
local enqueueCapturedUpdate = ReactUpdateQueuenew.enqueueCapturedUpdate
local createUpdate = ReactUpdateQueuenew.createUpdate
local captureUpdate = ReactUpdateQueuenew.CaptureUpdate
local forceUpdate = ReactUpdateQueuenew.ForceUpdate
local enqueueUpdate = ReactUpdateQueuenew.enqueueUpdate
local ReactFiberHotReloadingnew = require(script.Parent["ReactFiberHotReloading.new"])
local markFailedErrorBoundaryForHotReloading = ReactFiberHotReloadingnew.markFailedErrorBoundaryForHotReloading
local hasSuspenseContext = ReactFiberSuspenseContextnew.hasSuspenseContext
local invisibleParentSuspenseContext = ReactFiberSuspenseContextnew.InvisibleParentSuspenseContext
local suspenseStackCursor = ReactFiberSuspenseContextnew.suspenseStackCursor
local v = nil
local markLegacyErrorBoundaryAsFailed = nil
local isAlreadyFailedLegacyErrorBoundary = nil
local pingSuspendedRoot = nil

local function fn(...)
	if not markLegacyErrorBoundaryAsFailed then
		local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
		v = ReactFiberWorkLoopnew
		markLegacyErrorBoundaryAsFailed = v.markLegacyErrorBoundaryAsFailed
	end

	return markLegacyErrorBoundaryAsFailed(...)
end

local function fn2(...)
	if v == nil then
		local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
		v = ReactFiberWorkLoopnew
	end

	pingSuspendedRoot = v.pingSuspendedRoot
	return pingSuspendedRoot(...)
end

local function fn3(...)
	if v == nil then
		local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
		v = ReactFiberWorkLoopnew
	end

	isAlreadyFailedLegacyErrorBoundary = v.isAlreadyFailedLegacyErrorBoundary
	return isAlreadyFailedLegacyErrorBoundary(...)
end

local ReactFiberErrorLogger = require(script.Parent.ReactFiberErrorLogger)
local logCapturedError = ReactFiberErrorLogger.logCapturedError
local DebugTracing = require(script.Parent.DebugTracing)
local logComponentSuspended = DebugTracing.logComponentSuspended
local SchedulingProfiler = require(script.Parent.SchedulingProfiler)
local markComponentSuspended = SchedulingProfiler.markComponentSuspended
local syncLane = ReactFiberLane.SyncLane
local noTimestamp = ReactFiberLane.NoTimestamp
local includesSomeLane = ReactFiberLane.includesSomeLane
local mergeLanes = ReactFiberLane.mergeLanes
local pickArbitraryLane = ReactFiberLane.pickArbitraryLane

function createRootErrorUpdate(p, p2, p3, callback)
	local update = createUpdate(noTimestamp, p3)
	update.tag = captureUpdate
	update.payload = {
		element = object.None
	}
	local value = p2.value

	function update.callback()
		if callback ~= nil then
			callback(value)
		end

		logCapturedError(p, p2)
	end

	return update
end

function createClassErrorUpdate(data, p, p2)
	local update = createUpdate(noTimestamp, p2)
	update.tag = captureUpdate
	local getDerivedStateFromError = data.type.getDerivedStateFromError

	if typeof(getDerivedStateFromError) == "function" then
		local value = p.value

		function update.payload()
			logCapturedError(data, p)
			return getDerivedStateFromError(value)
		end
	end

	local stateNode = data.stateNode

	if stateNode ~= nil and typeof(stateNode.componentDidCatch) == "function" then
		function update.callback()
			if ReactGlobals.__DEV__ then
				markFailedErrorBoundaryForHotReloading(data)
			end

			if typeof(getDerivedStateFromError) ~= "function" then
				fn(stateNode)
				logCapturedError(data, p)
			end

			stateNode:componentDidCatch(p.value, {
				componentStack = p.stack or ""
			})

			if ReactGlobals.__DEV__ and typeof(getDerivedStateFromError) ~= "function" and not includesSomeLane(
				data.lanes,
				syncLane
			) then
				console.error(
					"%s: Error boundaries should implement getDerivedStateFromError(). In that method, return a state update to display an error message or fallback UI.",
					getComponentName(data.type) or "Unknown"
				)
			end
		end

		return update
	end

	if ReactGlobals.__DEV__ then
		function update.callback()
			markFailedErrorBoundaryForHotReloading(data)
		end
	end

	return update
end

local function attachPingListener(p, object2, lanes)
	local pingCache = p.pingCache
	local v2

	if pingCache == nil then
		v2 = {}
		p.pingCache = {
			[object2] = v2
		}
		local _ = p.pingCache
	else
		v2 = pingCache[object2]

		if v2 == nil then
			v2 = {}
			pingCache[object2] = v2
		end
	end

	if not v2[lanes] then
		v2[lanes] = true

		local function fn4()
			return fn2(p, object2, lanes)
		end

		object2:andThen(fn4, fn4)
	end
end

function throwException(p, return_, state, p2, lanes, p3, callback)
	local v2, alternate, v3, updateQueue, return_2
	local controlFlowState = 33

	while true do
		if controlFlowState == 0 then
			controlFlowState = 1
			continue
		end

		if controlFlowState == 1 then
			callback()
			v2 = createCapturedValue(p2, state)
			controlFlowState = 32
			continue
		else
			if controlFlowState == 2 then
				controlFlowState = 25
				continue
			end

			if controlFlowState == 3 then
				if ReactGlobals.__DEV__ and enableDebugTracing and bit32.band(state.mode, debugTracingMode) ~= 0 then
					controlFlowState = 6
				else
					controlFlowState = 5
				end

				continue
			else
				if controlFlowState == 4 then
					controlFlowState = 32
					continue
				end

				if controlFlowState == 5 then
					if enableSchedulingProfiler then
						controlFlowState = 7
					else
						controlFlowState = 8
					end

					continue
				elseif controlFlowState == 6 then
					logComponentSuspended(getComponentName(state.type) or "Unknown", p2)
					controlFlowState = 5
					continue
				elseif controlFlowState == 7 then
					markComponentSuspended(state, p2)
					controlFlowState = 8
					continue
				elseif controlFlowState == 8 then
					if bit32.band(state.mode, blockingMode) == noMode then
						controlFlowState = 9
					else
						controlFlowState = 10
					end

					continue
				elseif controlFlowState == 9 then
					alternate = state.alternate

					if alternate then
						controlFlowState = 11
					else
						controlFlowState = 12
					end

					continue
				elseif controlFlowState == 10 then
					v3 = hasSuspenseContext(suspenseStackCursor.current, invisibleParentSuspenseContext)
					return_2 = return_
					controlFlowState = 25
					continue
				elseif controlFlowState == 11 then
					state.updateQueue = alternate.updateQueue
					state.memoizedState = alternate.memoizedState
					state.lanes = alternate.lanes
					controlFlowState = 10
					continue
				elseif controlFlowState == 12 then
					state.updateQueue = nil
					state.memoizedState = nil
					controlFlowState = 10
					continue
				elseif controlFlowState == 13 then
					return_2 = return_2.return_

					if return_2 == nil then
						controlFlowState = 24
					else
						controlFlowState = 2
					end

					continue
				elseif controlFlowState == 14 then
					updateQueue = return_2.updateQueue

					if updateQueue == nil then
						controlFlowState = 15
					else
						controlFlowState = 16
					end

					continue
				elseif controlFlowState == 15 then
					return_2.updateQueue = {
						[p2] = true
					}
					controlFlowState = 17
					continue
				elseif controlFlowState == 16 then
					updateQueue[p2] = true
					controlFlowState = 17
					continue
				elseif controlFlowState == 17 then
					if bit32.band(return_2.mode, blockingMode) == noMode then
						controlFlowState = 18
					else
						controlFlowState = 19
					end

					continue
				elseif controlFlowState == 18 then
					return_2.flags = bit32.bor(return_2.flags, didCapture)
					state.flags = bit32.bor(state.flags, forceUpdateForLegacySuspense)
					state.flags = bit32.band(state.flags, (bit32.bnot((bit32.bor(lifecycleEffectMask, incomplete)))))

					if state.tag == classComponent then
						controlFlowState = 20
					else
						controlFlowState = 21
					end

					continue
				elseif controlFlowState == 19 then
					attachPingListener(p, p2, lanes)
					return_2.flags = bit32.bor(return_2.flags, shouldCapture)
					return_2.lanes = lanes
					break
				elseif controlFlowState == 20 then
					if state.alternate == nil then
						controlFlowState = 22
					else
						controlFlowState = 23
					end

					continue
				else
					if controlFlowState == 21 then
						state.lanes = mergeLanes(state.lanes, syncLane)
						break
					end

					if controlFlowState == 22 then
						state.tag = incompleteClassComponent
						controlFlowState = 21
						continue
					elseif controlFlowState == 23 then
						local update = createUpdate(noTimestamp, syncLane)
						update.tag = forceUpdate
						enqueueUpdate(state, update)
						controlFlowState = 21
						continue
					elseif controlFlowState == 24 then
						p2 = (getComponentName(state.type) or "A React component") .. [[
 suspended while rendering, but no fallback UI was specified.

Add a <Suspense fallback=...> component higher in the tree to provide a loading indicator or placeholder to display.]]
						controlFlowState = 1
						continue
					elseif controlFlowState == 25 then
						if return_2.tag == suspenseComponent and shouldCaptureSuspense(return_2, v3) then
							controlFlowState = 14
						else
							controlFlowState = 13
						end

						continue
					elseif controlFlowState == 26 then
						return_.flags = bit32.bor(return_.flags, shouldCapture)
						local v4 = pickArbitraryLane(lanes)
						return_.lanes = mergeLanes(return_.lanes, v4)
						enqueueCapturedUpdate(return_, (createRootErrorUpdate(return_, v2, v4, p3)))
						break
					elseif controlFlowState == 27 then
						if return_.tag == classComponent then
							controlFlowState = 28
						else
							controlFlowState = 29
						end

						continue
					elseif controlFlowState == 28 then
						local type = return_.type
						local stateNode = return_.stateNode

						if bit32.band(return_.flags, didCapture) == noFlags and (typeof(type.getDerivedStateFromError) == "function" or stateNode ~= nil and typeof(stateNode.componentDidCatch) == "function" and not fn3(stateNode)) then
							controlFlowState = 30
						else
							controlFlowState = 29
						end

						continue
					elseif controlFlowState == 29 then
						return_ = return_.return_

						if return_ == nil then
							controlFlowState = 31
						else
							controlFlowState = 4
						end

						continue
					elseif controlFlowState == 30 then
						return_.flags = bit32.bor(return_.flags, shouldCapture)
						local v4 = pickArbitraryLane(lanes)
						return_.lanes = mergeLanes(return_.lanes, v4)
						enqueueCapturedUpdate(return_, (createClassErrorUpdate(return_, v2, v4)))
						break
					else
						if controlFlowState == 31 then
							break
						end

						if controlFlowState == 32 then
							if return_.tag == hostRoot then
								controlFlowState = 26
							else
								controlFlowState = 27
							end
						else
							if controlFlowState ~= 33 then
								break
							end

							state.flags = bit32.bor(state.flags, incomplete)

							if p2 == nil or typeof(p2) ~= "table" or typeof(p2.andThen) ~= "function" then
								controlFlowState = 0
							else
								controlFlowState = 3
							end
						end

						continue
					end
				end
			end
		end
	end
end

return {
	throwException = throwException,
	createRootErrorUpdate = createRootErrorUpdate,
	createClassErrorUpdate = createClassErrorUpdate
}