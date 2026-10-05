local function unimplemented(p: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring(p))
	error("FIXME (roblox): " .. p .. " is unimplemented", 2)
end

local __DEV__ = _G.__DEV__
local __YOLO__ = _G.__YOLO__
local v = 0

local function isCallable(value)
	if typeof(value) == "function" then
		return true
	end

	if typeof(value) ~= "table" then
		return false
	end

	local metatable = getmetatable(value)

	if metatable and rawget(metatable, "__call") or value._isMockFunction then
		return true
	end

	return false
end

local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local error2 = luaupolyfill.Error
local set = luaupolyfill.Set
local ReactFiberHostConfig = require(script.Parent:WaitForChild("ReactFiberHostConfig"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
require(script.Parent:WaitForChild("ReactFiberSuspenseComponent.new"))
local ReactUpdateQueuenew = require(script.Parent:WaitForChild("ReactUpdateQueue.new"))
require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactFiberOffscreenComponent"))
local ReactHookEffectTags = require(script.Parent:WaitForChild("ReactHookEffectTags"))
local scheduler = require(script.Parent.Parent:WaitForChild("scheduler"))
local unstable_wrap = scheduler.tracing.unstable_wrap
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local reactFeatureFlags = shared2.ReactFeatureFlags
local enableSchedulerTracing = reactFeatureFlags.enableSchedulerTracing
local enableProfilerTimer = reactFeatureFlags.enableProfilerTimer
local enableProfilerCommitHooks = reactFeatureFlags.enableProfilerCommitHooks
local enableSuspenseCallback = reactFeatureFlags.enableSuspenseCallback
local enableDoubleInvokingEffects = reactFeatureFlags.enableDoubleInvokingEffects
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local functionComponent = ReactWorkTags.FunctionComponent
local forwardRef = ReactWorkTags.ForwardRef
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local hostComponent = ReactWorkTags.HostComponent
local hostText = ReactWorkTags.HostText
local hostPortal = ReactWorkTags.HostPortal
local profiler = ReactWorkTags.Profiler
local suspenseComponent = ReactWorkTags.SuspenseComponent
local dehydratedFragment = ReactWorkTags.DehydratedFragment
local incompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local memoComponent = ReactWorkTags.MemoComponent
local simpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local suspenseListComponent = ReactWorkTags.SuspenseListComponent
local fundamentalComponent = ReactWorkTags.FundamentalComponent
local scopeComponent = ReactWorkTags.ScopeComponent
local block = ReactWorkTags.Block
local offscreenComponent = ReactWorkTags.OffscreenComponent
local legacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local reactErrorUtils = shared3.ReactErrorUtils
local invokeGuardedCallback = reactErrorUtils.invokeGuardedCallback
local hasCaughtError = reactErrorUtils.hasCaughtError
local clearCaughtError = reactErrorUtils.clearCaughtError
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local noFlags = ReactFiberFlags.NoFlags
local contentReset = ReactFiberFlags.ContentReset
local placement = ReactFiberFlags.Placement
local snapshot = ReactFiberFlags.Snapshot
local update = ReactFiberFlags.Update
local callback = ReactFiberFlags.Callback
local layoutMask = ReactFiberFlags.LayoutMask
local passiveMask = ReactFiberFlags.PassiveMask
local ref = ReactFiberFlags.Ref
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared4.getComponentName
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared5.invariant
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
local describeError = shared6.describeError
local ReactCurrentFiber = require(script.Parent:WaitForChild("ReactCurrentFiber"))
local current = ReactCurrentFiber.current
local resetCurrentFiber = ReactCurrentFiber.resetCurrentFiber
local setCurrentFiber = ReactCurrentFiber.setCurrentFiber
local ReactFiberDevToolsHooknew = require(script.Parent:WaitForChild("ReactFiberDevToolsHook.new"))
local onCommitUnmount = ReactFiberDevToolsHooknew.onCommitUnmount
local ReactFiberLazyComponentnew = require(script.Parent:WaitForChild("ReactFiberLazyComponent.new"))
local resolveDefaultProps = ReactFiberLazyComponentnew.resolveDefaultProps
local ReactProfilerTimernew = require(script.Parent:WaitForChild("ReactProfilerTimer.new"))
local startLayoutEffectTimer = ReactProfilerTimernew.startLayoutEffectTimer
local recordPassiveEffectDuration = ReactProfilerTimernew.recordPassiveEffectDuration
local recordLayoutEffectDuration = ReactProfilerTimernew.recordLayoutEffectDuration
local startPassiveEffectTimer = ReactProfilerTimernew.startPassiveEffectTimer
local getCommitTime = ReactProfilerTimernew.getCommitTime
local ReactTypeOfMode = require(script.Parent:WaitForChild("ReactTypeOfMode"))
local profileMode = ReactTypeOfMode.ProfileMode
local commitUpdateQueue = ReactUpdateQueuenew.commitUpdateQueue
local getPublicInstance = ReactFiberHostConfig.getPublicInstance
local supportsMutation = ReactFiberHostConfig.supportsMutation
local supportsPersistence = ReactFiberHostConfig.supportsPersistence
local supportsHydration = ReactFiberHostConfig.supportsHydration
local commitMount = ReactFiberHostConfig.commitMount
local commitUpdate = ReactFiberHostConfig.commitUpdate
local resetTextContent = ReactFiberHostConfig.resetTextContent
local commitTextUpdate = ReactFiberHostConfig.commitTextUpdate
local appendChild = ReactFiberHostConfig.appendChild
local appendChildToContainer = ReactFiberHostConfig.appendChildToContainer
local insertBefore = ReactFiberHostConfig.insertBefore
local insertInContainerBefore = ReactFiberHostConfig.insertInContainerBefore
local removeChild = ReactFiberHostConfig.removeChild
local removeChildFromContainer = ReactFiberHostConfig.removeChildFromContainer
local hideInstance = ReactFiberHostConfig.hideInstance
local hideTextInstance = ReactFiberHostConfig.hideTextInstance
local unhideInstance = ReactFiberHostConfig.unhideInstance
local unhideTextInstance = ReactFiberHostConfig.unhideTextInstance
local commitHydratedSuspenseInstance = ReactFiberHostConfig.commitHydratedSuspenseInstance
local clearContainer = ReactFiberHostConfig.clearContainer
local v2 = nil

local function resolveRetryWakeable(state, p)
	if not v2 then
		local ReactFiberWorkLoopnew = require(script.Parent:WaitForChild("ReactFiberWorkLoop.new"))
		v2 = ReactFiberWorkLoopnew
	end

	v2.resolveRetryWakeable(state, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markCommitTimeOfFallback()
	if not v2 then
		local ReactFiberWorkLoopnew = require(script.Parent:WaitForChild("ReactFiberWorkLoop.new"))
		v2 = ReactFiberWorkLoopnew
	end

	v2.markCommitTimeOfFallback()
end

local function schedulePassiveEffectCallback()
	console.warn("ReactFiberCommitWork: schedulePassiveEffectCallback causes a dependency cycle\n" .. debug.traceback())
end

local function captureCommitPhaseError(_, _, message)
	console.warn("ReactFiberCommitWork: captureCommitPhaseError causes a dependency cycle")
	error(message)
end

local noFlags2 = ReactHookEffectTags.NoFlags
local hasEffect = ReactHookEffectTags.HasEffect
local layout = ReactHookEffectTags.Layout
local passive = ReactHookEffectTags.Passive
local didWarnAboutReassigningProps = nil

local function fn()
	if not didWarnAboutReassigningProps then
		local ReactFiberBeginWorknew = require(script.Parent:WaitForChild("ReactFiberBeginWork.new"))
		didWarnAboutReassigningProps = ReactFiberBeginWorknew.didWarnAboutReassigningProps
	end

	return didWarnAboutReassigningProps
end

local isHostParent
local insertOrAppendPlacementNode
local insertOrAppendPlacementNodeIntoContainer
local commitLayoutEffectsForHostRoot
local commitLayoutEffectsForHostComponent
local commitLayoutEffectsForClassComponent
local unmountHostComponents
local v3 = nil

local function callComponentWillUnmountWithTimer(data, object)
	object.props = data.memoizedProps
	object.state = data.memoizedState

	if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(data.mode, profileMode) ~= 0 then
		local v4, v5 = xpcall(function()
			startLayoutEffectTimer()
			object:componentWillUnmount()
		end, describeError)
		recordLayoutEffectDuration(data)

		if not v4 then
			error(v5)
		end
	else
		object:componentWillUnmount()
	end
end

function safelyCallComponentWillUnmount(p, p2, p3)
	local v4, v5 = xpcall(callComponentWillUnmountWithTimer, describeError, p, p2)

	if not v4 then
		captureCommitPhaseError(p, p3, v5)
	end
end

local function safelyDetachRef(p, p2)
	local ref2 = p.ref

	if ref2 ~= nil then
		if typeof(ref2) == "function" then
			local v4, v5 = xpcall(ref2, describeError)

			if not v4 then
				captureCommitPhaseError(p, p2, v5)
			end
		else
			ref2.current = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function safelyCallDestroy(p, p2, callback2)
	local v4, v5 = xpcall(callback2, describeError)

	if not v4 then
		captureCommitPhaseError(p, p2, v5)
	end
end

local function commitHookEffectListUnmount(p, p2, p3)
	local updateQueue = p2.updateQueue
	local lastEffect

	if updateQueue ~= nil then
		lastEffect = updateQueue.lastEffect
	end

	if lastEffect ~= nil then
		local next = lastEffect.next
		local next2 = next

		repeat
			if bit32.band(next2.tag, p) == p then
				local destroy = next2.destroy
				next2.destroy = nil

				if destroy ~= nil then
					safelyCallDestroy(p2, p3, destroy) -- equivalent call inferred; original call site unknown
				end
			end

			next2 = next2.next
		until next2 == next
	end
end

local function commitHookEffectListMount(p, p2)
	local updateQueue = p2.updateQueue
	local lastEffect

	if updateQueue ~= nil then
		lastEffect = updateQueue.lastEffect
	end

	if lastEffect ~= nil then
		local next = lastEffect.next
		local next2 = next

		repeat
			if bit32.band(next2.tag, p) == p then
				next2.destroy = next2.create()

				if __DEV__ then
					local destroy = next2.destroy

					if destroy ~= nil and typeof(destroy) ~= "function" then
						local v4 = destroy == nil and " You returned nil. If your effect does not require clean up, return nil (or nothing)." or typeof(destroy.andThen) == "function" and [=[


It looks like you wrote useEffect(Promise.new(function() --[[...]] end) or returned a Promise. Instead, write the async function inside your effect and call it immediately:

useEffect(function()
  function fetchData()
    -- You can await here
    local response = MyAPI.getData(someId):await()
    -- ...
  end
  fetchData()
end, {someId}) -- Or {} if effect doesn't need props or state

Learn more about data fetching with Hooks: https://reactjs.org/link/hooks-data-fetching]=] or " You returned: " .. destroy
						console.error(
							"An effect function must not return anything besides a function, which is used for clean-up.%s",
							v4
						)
					end
				end
			end

			next2 = next2.next
		until next2 == next
	end
end

function commitProfilerPassiveEffect(p, data)
	if enableProfilerTimer and enableProfilerCommitHooks and data.tag == profiler then
		local passiveEffectDuration = data.stateNode.passiveEffectDuration
		local id = data.memoizedProps.id
		local onPostCommit = data.memoizedProps.onPostCommit
		local commitTime = getCommitTime()

		if typeof(onPostCommit) == "function" then
			if enableSchedulerTracing then
				onPostCommit(
					id,
					data.alternate == nil and "mount" or "update",
					passiveEffectDuration,
					commitTime,
					p.memoizedInteractions
				)
			else
				onPostCommit(id, data.alternate == nil and "mount" or "update", passiveEffectDuration, commitTime)
			end
		end
	end
end

local recursivelyCommitLayoutEffects

recursivelyCommitLayoutEffects = function(child, p, captureCommitPhaseError2, schedulePassiveEffectCallback2)
	if captureCommitPhaseError2 ~= nil then
		captureCommitPhaseError = captureCommitPhaseError2
	end

	if schedulePassiveEffectCallback2 ~= nil then
		schedulePassiveEffectCallback = schedulePassiveEffectCallback2
	end

	local flags = child.flags
	local tag = child.tag

	if tag == profiler then
		local v4

		if enableProfilerTimer and enableProfilerCommitHooks then
			v4 = v3
			v3 = child
		end

		local child2 = child.child

		while child2 ~= nil do
			if bit32.band(child.subtreeFlags, layoutMask) ~= noFlags then
				if __DEV__ then
					local current2 = current
					setCurrentFiber(child2)
					invokeGuardedCallback(
						nil,
						recursivelyCommitLayoutEffects,
						nil,
						child2,
						p,
						captureCommitPhaseError,
						schedulePassiveEffectCallback
					)

					if hasCaughtError() then
						local v6 = clearCaughtError()
						captureCommitPhaseError(child2, child, v6)
					end

					if current2 == nil then
						resetCurrentFiber()
					else
						setCurrentFiber(current2)
					end
				else
					local v5, v6 = xpcall(
						recursivelyCommitLayoutEffects,
						describeError,
						child2,
						p,
						captureCommitPhaseError,
						schedulePassiveEffectCallback
					)

					if not v5 then
						captureCommitPhaseError(child2, child, v6)
					end
				end
			end

			child2 = child2.sibling
		end

		if bit32.band(flags, (bit32.bor(update, callback))) ~= noFlags and enableProfilerTimer then
			if __DEV__ then
				local current2 = current
				setCurrentFiber(child)
				invokeGuardedCallback(nil, commitLayoutEffectsForProfiler, nil, child, p)

				if hasCaughtError() then
					local v6 = clearCaughtError()
					captureCommitPhaseError(child, child.return_, v6)
				end

				if current2 == nil then
					resetCurrentFiber()
				else
					setCurrentFiber(current2)
				end
			else
				local v5, v6 = xpcall(commitLayoutEffectsForProfiler, describeError, child, p)

				if not v5 then
					captureCommitPhaseError(child, child.return_, v6)
				end
			end
		end

		if enableProfilerTimer and enableProfilerCommitHooks then
			if v4 ~= nil then
				v4.stateNode.effectDuration += child.stateNode.effectDuration
			end

			v3 = v4
		end
	else
		local child2 = child.child

		while child2 ~= nil do
			if bit32.band(child.subtreeFlags, layoutMask) ~= noFlags then
				if __DEV__ then
					local current2 = ReactCurrentFiber.current
					setCurrentFiber(child2)

					if v < 20 then
						v += 1
						invokeGuardedCallback(
							nil,
							recursivelyCommitLayoutEffects,
							nil,
							child2,
							p,
							captureCommitPhaseError,
							schedulePassiveEffectCallback
						)
						v -= 1

						if hasCaughtError() then
							local v4 = clearCaughtError()
							captureCommitPhaseError(child2, child, v4)
						end
					else
						recursivelyCommitLayoutEffects(
							child2,
							p,
							captureCommitPhaseError,
							schedulePassiveEffectCallback
						)
					end

					if current2 == nil then
						resetCurrentFiber()
					else
						setCurrentFiber(current2)
					end
				else
					local v4 = nil
					local v5

					if __YOLO__ or not (v < 20) then
						recursivelyCommitLayoutEffects(
							child2,
							p,
							captureCommitPhaseError,
							schedulePassiveEffectCallback
						)
						v5 = true
					else
						v += 1
						v5, v4 = xpcall(
							recursivelyCommitLayoutEffects,
							describeError,
							child2,
							p,
							captureCommitPhaseError,
							schedulePassiveEffectCallback
						)
						v -= 1
					end

					if not v5 then
						captureCommitPhaseError(child2, child, v4)
					end
				end
			end

			child2 = child2.sibling
		end

		if bit32.band(flags, (bit32.bor(update, callback))) ~= noFlags then
			if tag == functionComponent or tag == forwardRef or tag == simpleMemoComponent or tag == block then
				if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(child.mode, profileMode) ~= 0 then
					local v4, v5 = xpcall(function()
						startLayoutEffectTimer()
						commitHookEffectListMount(bit32.bor(layout, hasEffect), child)
					end, describeError)
					recordLayoutEffectDuration(child)

					if not v4 then
						error(v5)
					end
				else
					commitHookEffectListMount(bit32.bor(layout, hasEffect), child)
				end

				if bit32.band(child.subtreeFlags, passiveMask) ~= noFlags then
					schedulePassiveEffectCallback()
				end
			elseif tag == classComponent then
				commitLayoutEffectsForClassComponent(child)
			elseif tag == hostRoot then
				commitLayoutEffectsForHostRoot(child)
			elseif tag == hostComponent then
				commitLayoutEffectsForHostComponent(child)
			elseif tag == suspenseComponent then
				commitSuspenseHydrationCallbacks(p, child)
			elseif tag ~= fundamentalComponent and tag ~= hostPortal and tag ~= hostText and tag ~= incompleteClassComponent and tag ~= legacyHiddenComponent and tag ~= offscreenComponent and tag ~= scopeComponent and tag ~= suspenseListComponent then
				invariant(
					false,
					"This unit of work tag should not have side-effects. This error is likely caused by a bug in React. Please file an issue."
				)
			end
		end

		if bit32.band(flags, ref) ~= 0 then
			commitAttachRef(child)
		end
	end
end

function commitLayoutEffectsForProfiler(data, p)
	if enableProfilerTimer then
		local flags = data.flags
		local alternate = data.alternate
		local onCommit = data.memoizedProps.onCommit
		local onRender = data.memoizedProps.onRender
		local effectDuration = data.stateNode.effectDuration
		local commitTime = getCommitTime()

		if bit32.band(flags, update) ~= noFlags then
			local v5

			if typeof(onRender) == "function" then
				v5 = true
			elseif typeof(onRender) == "table" then
				local metatable = getmetatable(onRender)
				v5 = metatable and rawget(metatable, "__call") and true or onRender._isMockFunction and true or false
			else
				v5 = false
			end

			if v5 then
				if enableSchedulerTracing then
					onRender(
						data.memoizedProps.id,
						alternate == nil and "mount" or "update",
						data.actualDuration,
						data.treeBaseDuration,
						data.actualStartTime,
						commitTime,
						p.memoizedInteractions
					)
				else
					onRender(
						data.memoizedProps.id,
						alternate == nil and "mount" or "update",
						data.actualDuration,
						data.treeBaseDuration,
						data.actualStartTime,
						commitTime
					)
				end
			end
		end

		if enableProfilerCommitHooks and bit32.band(flags, callback) ~= noFlags then
			local v5

			if typeof(onCommit) == "function" then
				v5 = true
			elseif typeof(onCommit) == "table" then
				local metatable = getmetatable(onCommit)
				v5 = metatable and rawget(metatable, "__call") and true or onCommit._isMockFunction and true or false
			else
				v5 = false
			end

			if v5 then
				if enableSchedulerTracing then
					onCommit(
						data.memoizedProps.id,
						alternate == nil and "mount" or "update",
						effectDuration,
						commitTime,
						p.memoizedInteractions
					)
				else
					onCommit(
						data.memoizedProps.id,
						alternate == nil and "mount" or "update",
						effectDuration,
						commitTime
					)
				end
			end
		end
	end
end

commitLayoutEffectsForClassComponent = function(data)
	local stateNode = data.stateNode
	local alternate = data.alternate

	if bit32.band(data.flags, update) ~= 0 then
		if alternate == nil then
			if __DEV__ and data.type == data.elementType and not fn then
				if stateNode.props ~= data.memoizedProps then
					console.error(
						"Expected %s props to match memoized props before componentDidMount. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.",
						getComponentName(data.type) or "instance"
					)
				end

				if stateNode.state ~= data.memoizedState then
					console.error(
						"Expected %s state to match memoized state before componentDidMount. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.",
						getComponentName(data.type) or "instance"
					)
				end
			end

			if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(data.mode, profileMode) ~= 0 then
				local v4, v5 = xpcall(function()
					startLayoutEffectTimer()
					stateNode:componentDidMount()
				end, describeError)
				recordLayoutEffectDuration(data)

				if not v4 then
					error(v5)
				end
			else
				stateNode:componentDidMount()
			end
		else
			local memoizedProps = data.elementType == data.type and alternate.memoizedProps or resolveDefaultProps(
				data.type,
				alternate.memoizedProps
			)
			local memoizedState = alternate.memoizedState

			if __DEV__ and data.type == data.elementType and not fn then
				if stateNode.props ~= data.memoizedProps then
					console.error(
						"Expected %s props to match memoized props before componentDidUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.",
						getComponentName(data.type) or "instance"
					)
				end

				if stateNode.state ~= data.memoizedState then
					console.error(
						"Expected %s state to match memoized state before componentDidUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.",
						getComponentName(data.type) or "instance"
					)
				end
			end

			if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(data.mode, profileMode) ~= 0 then
				local v4, v5 = xpcall(function()
					startLayoutEffectTimer()
					stateNode:componentDidUpdate(
						memoizedProps,
						memoizedState,
						stateNode.__reactInternalSnapshotBeforeUpdate
					)
				end, describeError)
				recordLayoutEffectDuration(data)

				if not v4 then
					error(v5)
				end
			else
				stateNode:componentDidUpdate(
					memoizedProps,
					memoizedState,
					stateNode.__reactInternalSnapshotBeforeUpdate
				)
			end
		end
	end

	local updateQueue = data.updateQueue

	if updateQueue ~= nil then
		if __DEV__ and data.type == data.elementType and not fn then
			if stateNode.props ~= data.memoizedProps then
				console.error(
					"Expected %s props to match memoized props before processing the update queue. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.",
					getComponentName(data.type) or "instance"
				)
			end

			if stateNode.state ~= data.memoizedState then
				console.error(
					"Expected %s state to match memoized state before processing the update queue. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.",
					getComponentName(data.type) or "instance"
				)
			end
		end

		commitUpdateQueue(data, updateQueue, stateNode)
	end
end

commitLayoutEffectsForHostRoot = function(data)
	local updateQueue = data.updateQueue

	if updateQueue ~= nil then
		local stateNode = nil

		if data.child ~= nil then
			local child = data.child

			if child.tag == hostComponent then
				stateNode = getPublicInstance(child.stateNode)
			elseif child.tag == classComponent then
				stateNode = child.stateNode
			end
		end

		commitUpdateQueue(data, updateQueue, stateNode)
	end
end

commitLayoutEffectsForHostComponent = function(data)
	local stateNode = data.stateNode

	if data.alternate == nil and bit32.band(data.flags, update) ~= 0 then
		commitMount(stateNode, data.type, data.memoizedProps, data)
	end
end

local function hideOrUnhideAllChildren(p, p2)
	local stateNode, stateNode2, child
	local controlFlowState = 21

	while true do
		if controlFlowState == 0 then
			break
		end

		if controlFlowState == 1 then
			stateNode = child.stateNode

			if p2 then
				controlFlowState = 3
			else
				controlFlowState = 4
			end
		elseif controlFlowState == 2 then
			if child.tag == hostText then
				controlFlowState = 6
			else
				controlFlowState = 7
			end
		elseif controlFlowState == 3 then
			hideInstance(stateNode)
			controlFlowState = 5
		elseif controlFlowState == 4 then
			unhideInstance(child.stateNode, child.memoizedProps)
			controlFlowState = 5
		elseif controlFlowState == 5 then
			if child == p then
				controlFlowState = 14
			else
				controlFlowState = 11
			end
		elseif controlFlowState == 6 then
			stateNode2 = child.stateNode

			if p2 then
				controlFlowState = 8
			else
				controlFlowState = 9
			end
		elseif controlFlowState == 7 then
			if (child.tag == offscreenComponent or child.tag == legacyHiddenComponent) and child.memoizedState ~= nil and child ~= p or child.child == nil then
				controlFlowState = 5
			else
				controlFlowState = 12
			end
		elseif controlFlowState == 8 then
			hideTextInstance(stateNode2)
			controlFlowState = 5
		elseif controlFlowState == 9 then
			unhideTextInstance(stateNode2, child.memoizedProps)
			controlFlowState = 5
		elseif controlFlowState == 10 then
			child = p
			controlFlowState = 20
		else
			if controlFlowState == 11 then
				controlFlowState = 15
				continue
			end

			if controlFlowState == 12 then
				child.child.return_ = child
				child = child.child
				controlFlowState = 13
			else
				if controlFlowState == 13 then
					controlFlowState = 20
					continue
				end

				if controlFlowState == 14 then
					break
				end

				if controlFlowState == 15 then
					if child.sibling == nil then
						controlFlowState = 16
					else
						controlFlowState = 17
					end
				elseif controlFlowState == 16 then
					if child.return_ == nil or child.return_ == p then
						controlFlowState = 18
					else
						controlFlowState = 19
					end
				elseif controlFlowState == 17 then
					child.sibling.return_ = child.return_
					child = child.sibling
					controlFlowState = 13
				else
					if controlFlowState == 18 then
						break
					end

					if controlFlowState == 19 then
						child = child.return_
						controlFlowState = 15
					elseif controlFlowState == 20 then
						if child.tag == hostComponent then
							controlFlowState = 1
						else
							controlFlowState = 2
						end
					else
						if controlFlowState ~= 21 then
							break
						end

						if supportsMutation then
							controlFlowState = 10
						else
							controlFlowState = 0
						end
					end
				end
			end
		end

		continue
	end
end

function commitAttachRef(data)
	local ref2 = data.ref

	if ref2 ~= nil then
		local stateNode = data.stateNode

		if data.tag == hostComponent then
			stateNode = getPublicInstance(stateNode)
		end

		if typeof(ref2) == "function" then
			ref2(stateNode)
		elseif __DEV__ and typeof(ref2) ~= "table" then
			console.error(
				"Unexpected ref object provided for %s. Use either a ref-setter function or React.createRef().",
				getComponentName(data.type) or "instance"
			)
		else
			ref2.current = stateNode
		end
	end
end

function commitDetachRef(p)
	local ref2 = p.ref

	if ref2 ~= nil then
		if typeof(ref2) == "function" then
			ref2(nil)
		else
			ref2.current = nil
		end
	end
end

local function commitUnmount(p, data, p2, p3)
	onCommitUnmount(data)

	if data.tag == functionComponent or data.tag == forwardRef or data.tag == memoComponent or data.tag == simpleMemoComponent or data.tag == block then
		local updateQueue = data.updateQueue

		if updateQueue ~= nil then
			local lastEffect = updateQueue.lastEffect

			if lastEffect ~= nil then
				local next = lastEffect.next
				local next2 = next

				repeat
					if next2.destroy ~= nil and bit32.band(next2.tag, layout) ~= noFlags2 then
						if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(data.mode, profileMode) ~= 0 then
							startLayoutEffectTimer()
							safelyCallDestroy(data, p2, next2.destroy) -- equivalent call inferred; original call site unknown
							recordLayoutEffectDuration(data)
						else
							safelyCallDestroy(data, p2, next2.destroy) -- equivalent call inferred; original call site unknown
						end
					end

					next2 = next2.next
				until next2 == next
			end
		end
	elseif data.tag == classComponent then
		local ref2 = data.ref

		if ref2 ~= nil then
			if typeof(ref2) == "function" then
				safelyCallDestroy(data, p2, ref2) -- equivalent call inferred; original call site unknown
			else
				ref2.current = nil
			end
		end

		local stateNode = data.stateNode

		if typeof(stateNode.componentWillUnmount) == "function" then
			safelyCallComponentWillUnmount(data, stateNode, p2)
		end
	elseif data.tag == hostComponent then
		local ref2 = data.ref

		if ref2 ~= nil then
			if typeof(ref2) == "function" then
				safelyCallDestroy(data, p2, ref2) -- equivalent call inferred; original call site unknown
			else
				ref2.current = nil
			end
		end
	else
		if data.tag ~= hostPortal then
			return
		end

		if supportsMutation then
			unmountHostComponents(p, data, p2, p3)
		elseif supportsPersistence then
			unimplemented("emptyPortalContainer")
		end
	end
end

local function commitNestedUnmounts(p, child, p2, p3)
	local return_ = child

	while true do
		commitUnmount(p, return_, p2, p3)

		if return_.child == nil or supportsMutation and return_.tag == hostPortal then
			if return_ == child then
				break
			end

			while return_.sibling == nil do
				if return_.return_ == nil or return_.return_ == child then
					return
				else
					return_ = return_.return_
				end
			end

			return_.sibling.return_ = return_.return_
			return_ = return_.sibling
		else
			return_.child.return_ = return_
			return_ = return_.child
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function detachFiberMutation(p)
	local alternate = p.alternate

	if alternate ~= nil then
		alternate.return_ = nil
		p.alternate = nil
	end

	p.return_ = nil
end

local function getHostParentFiber(p)
	local return_ = p.return_

	while return_ ~= nil do
		if isHostParent(return_) then
			return return_
		else
			return_ = return_.return_
		end
	end

	error(error2.new("Expected to find a host parent. This error is likely caused by a bug in React. Please file an issue."))
end

isHostParent = function(return_)
	return return_.tag == hostComponent or return_.tag == hostRoot or return_.tag == hostPortal
end

local function getHostSibling(return_)
	while true do
		local v4 = false

		while return_.sibling == nil do
			if return_.return_ == nil or isHostParent(return_.return_) then
				return nil
			else
				return_ = return_.return_
			end
		end

		return_.sibling.return_ = return_.return_
		return_ = return_.sibling

		while return_.tag ~= hostComponent and return_.tag ~= hostText and return_.tag ~= dehydratedFragment do
			if bit32.band(return_.flags, placement) == 0 and return_.child ~= nil and return_.tag ~= hostPortal then
				return_.child.return_ = return_
				return_ = return_.child
			else
				v4 = true
				break
			end
		end

		if not v4 and bit32.band(return_.flags, placement) == 0 then
			return return_.stateNode
		end
	end
end

local function commitPlacement(p)
	if not supportsMutation then
		return
	end

	local hostParentFiber = getHostParentFiber(p)
	local containerInfo = nil
	local flag = nil
	local stateNode = hostParentFiber.stateNode

	if hostParentFiber.tag == hostComponent then
		containerInfo = stateNode
		flag = false
	elseif hostParentFiber.tag == hostRoot then
		containerInfo = stateNode.containerInfo
		flag = true
	elseif hostParentFiber.tag == hostPortal then
		containerInfo = stateNode.containerInfo
		flag = true
	else
		invariant(
			false,
			"Invalid host parent fiber. This error is likely caused by a bug in React. Please file an issue."
		)
	end

	if bit32.band(hostParentFiber.flags, contentReset) ~= 0 then
		resetTextContent(containerInfo)
		hostParentFiber.flags = bit32.band(hostParentFiber.flags, (bit32.bnot(contentReset)))
	end

	local hostSibling = getHostSibling(p)

	if flag then
		insertOrAppendPlacementNodeIntoContainer(p, hostSibling, containerInfo)
	else
		insertOrAppendPlacementNode(p, hostSibling, containerInfo)
	end
end

insertOrAppendPlacementNodeIntoContainer = function(data, p, p2)
	local tag = data.tag

	if tag == hostComponent or tag == hostText then
		local stateNode = data.stateNode

		if p then
			insertInContainerBefore(p2, stateNode, p)
		else
			appendChildToContainer(p2, stateNode)
		end
	else
		if tag == hostPortal then
			return
		end

		local child = data.child

		if child ~= nil then
			insertOrAppendPlacementNodeIntoContainer(child, p, p2)
			local sibling = child.sibling

			while sibling ~= nil do
				insertOrAppendPlacementNodeIntoContainer(sibling, p, p2)
				sibling = sibling.sibling
			end
		end
	end
end

insertOrAppendPlacementNode = function(data, p, p2)
	local tag = data.tag

	if tag == hostComponent or tag == hostText then
		local stateNode = data.stateNode

		if p then
			insertBefore(p2, stateNode, p)
		else
			appendChild(p2, stateNode)
		end
	else
		if tag == hostPortal then
			return
		end

		local child = data.child

		if child ~= nil then
			insertOrAppendPlacementNode(child, p, p2)
			local sibling = child.sibling

			while sibling ~= nil do
				insertOrAppendPlacementNode(sibling, p, p2)
				sibling = sibling.sibling
			end
		end
	end
end

unmountHostComponents = function(p, p2, p3, p4)
	local return_, flag, child, flag2, stateNode
	local controlFlowState = 34

	while true do
		if controlFlowState == 0 then
			controlFlowState = 32
			continue
		end

		if controlFlowState == 1 then
			return_ = child.return_
			controlFlowState = 12
		elseif controlFlowState == 2 then
			if child.tag == hostComponent or child.tag == hostText then
				controlFlowState = 14
			else
				controlFlowState = 15
			end
		elseif controlFlowState == 3 then
			error(error2.new("Expected to find a host parent. This error is likely caused by a bug in React. Please file an issue."))
			controlFlowState = 4
		elseif controlFlowState == 4 then
			stateNode = return_.stateNode

			if return_.tag == hostComponent then
				controlFlowState = 5
			else
				controlFlowState = 6
			end
		elseif controlFlowState == 5 then
			flag2 = false
			controlFlowState = 7
		elseif controlFlowState == 6 then
			if return_.tag == hostRoot then
				controlFlowState = 8
			else
				controlFlowState = 9
			end
		elseif controlFlowState == 7 then
			flag = true
			controlFlowState = 2
		elseif controlFlowState == 8 then
			stateNode = stateNode.containerInfo
			flag2 = true
			controlFlowState = 7
		elseif controlFlowState == 9 then
			if return_.tag == hostPortal then
				controlFlowState = 10
			else
				controlFlowState = 11
			end
		elseif controlFlowState == 10 then
			stateNode = stateNode.containerInfo
			flag2 = true
			controlFlowState = 7
		elseif controlFlowState == 11 then
			return_ = return_.return_
			controlFlowState = 12
		elseif controlFlowState == 12 then
			if return_ == nil then
				controlFlowState = 3
			else
				controlFlowState = 4
			end
		else
			if controlFlowState == 13 then
				controlFlowState = 25
				continue
			end

			if controlFlowState == 14 then
				commitNestedUnmounts(p, child, p3, p4)

				if flag2 then
					controlFlowState = 16
				else
					controlFlowState = 17
				end
			elseif controlFlowState == 15 then
				if child.tag == hostPortal then
					controlFlowState = 19
				else
					controlFlowState = 20
				end
			elseif controlFlowState == 16 then
				removeChildFromContainer(stateNode, child.stateNode)
				controlFlowState = 18
			elseif controlFlowState == 17 then
				removeChild(stateNode, child.stateNode)
				controlFlowState = 18
			elseif controlFlowState == 18 then
				if child == p2 then
					controlFlowState = 24
				else
					controlFlowState = 13
				end
			elseif controlFlowState == 19 then
				if child.child == nil then
					controlFlowState = 18
				else
					controlFlowState = 21
				end
			elseif controlFlowState == 20 then
				commitUnmount(p, child, p3, p4)

				if child.child == nil then
					controlFlowState = 18
				else
					controlFlowState = 23
				end
			elseif controlFlowState == 21 then
				stateNode = child.stateNode.containerInfo
				child.child.return_ = child
				child = child.child
				flag2 = true
				controlFlowState = 22
			else
				if controlFlowState == 22 then
					controlFlowState = 33
					continue
				end

				if controlFlowState == 23 then
					child.child.return_ = child
					child = child.child
					controlFlowState = 22
				else
					if controlFlowState == 24 then
						break
					end

					if controlFlowState == 25 then
						if child.sibling == nil then
							controlFlowState = 26
						else
							controlFlowState = 27
						end
					elseif controlFlowState == 26 then
						if child.return_ == nil or child.return_ == p2 then
							controlFlowState = 29
						else
							controlFlowState = 30
						end
					elseif controlFlowState == 27 then
						child.sibling.return_ = child.return_
						child = child.sibling
						controlFlowState = 22
					elseif controlFlowState == 28 then
						flag = false
						controlFlowState = 32
					else
						if controlFlowState == 29 then
							break
						end

						if controlFlowState == 30 then
							child = child.return_

							if child.tag == hostPortal then
								controlFlowState = 28
							else
								controlFlowState = 0
							end
						else
							if controlFlowState == 31 then
								controlFlowState = 2
								continue
							end

							if controlFlowState == 32 then
								controlFlowState = 25
								continue
							end

							if controlFlowState == 33 then
								if flag then
									controlFlowState = 31
								else
									controlFlowState = 1
								end
							else
								if controlFlowState ~= 34 then
									break
								end

								child = p2
								flag = false
								flag2 = nil
								stateNode = nil
								controlFlowState = 33
							end
						end
					end
				end
			end
		end

		continue
	end
end

local function commitDeletion(p, p2, p3, p4)
	unmountHostComponents(p, p2, p3, p4)
	local alternate = p2.alternate
	detachFiberMutation(p2) -- equivalent call inferred; original call site unknown

	if alternate ~= nil then
		detachFiberMutation(alternate) -- equivalent call inferred; original call site unknown
	end
end

function commitSuspenseComponent(data)
	local memoizedState = data.memoizedState

	if memoizedState ~= nil then
		markCommitTimeOfFallback() -- equivalent call inferred; original call site unknown

		if supportsMutation then
			hideOrUnhideAllChildren(data.child, true)
		end
	end

	if enableSuspenseCallback and memoizedState ~= nil then
		local suspenseCallback = data.memoizedProps.suspenseCallback

		if typeof(suspenseCallback) == "function" then
			local updateQueue = data.updateQueue

			if updateQueue ~= nil then
				suspenseCallback(table.clone(updateQueue))
			end
		elseif __DEV__ and suspenseCallback ~= nil then
			console.error("Unexpected type for suspenseCallback: %s", (tostring(suspenseCallback)))
		end
	end
end

function commitSuspenseHydrationCallbacks(p, p2)
	if not supportsHydration then
		return
	end

	if p2.memoizedState == nil then
		local alternate = p2.alternate

		if alternate ~= nil then
			local memoizedState = alternate.memoizedState

			if memoizedState ~= nil then
				local dehydrated = memoizedState.dehydrated

				if dehydrated ~= nil then
					commitHydratedSuspenseInstance(dehydrated)

					if enableSuspenseCallback then
						local hydrationCallbacks = p.hydrationCallbacks
						local onHydrated = hydrationCallbacks ~= nil and hydrationCallbacks.onHydrated

						if onHydrated then
							onHydrated(dehydrated)
						end
					end
				end
			end
		end
	end
end

function attachSuspenseRetryListeners(state)
	local updateQueue = state.updateQueue

	if updateQueue ~= nil then
		state.updateQueue = nil
		local stateNode = state.stateNode

		if stateNode == nil then
			state.stateNode = set.new()
			stateNode = state.stateNode
		end

		for k, _ in updateQueue do
			local v4 = k

			local function fn2()
				return resolveRetryWakeable(state, v4)
			end

			if stateNode:has(k) then
				continue
			end

			if enableSchedulerTracing and k.__reactDoNotTraceInteractions ~= true then
				fn2 = unstable_wrap(fn2)
			end

			stateNode:add(k)
			k:andThen(function()
				return fn2()
			end, function()
				return fn2()
			end)
		end
	end
end

function isSuspenseBoundaryBeingHidden(p, p2)
	if p == nil then
		return false
	end

	local memoizedState = p.memoizedState

	if memoizedState == nil or memoizedState.dehydrated ~= nil then
		local memoizedState2 = p2.memoizedState
		return memoizedState2 ~= nil and memoizedState2.dehydrated == nil
	end

	return false
end

function commitResetTextContent(p)
	if not supportsMutation then
		return
	end

	resetTextContent(p.stateNode)
end

function invokeLayoutEffectMountInDEV(data)
	if __DEV__ and enableDoubleInvokingEffects then
		if data.tag == functionComponent or data.tag == forwardRef or data.tag == simpleMemoComponent or data.tag == block then
			invokeGuardedCallback(nil, commitHookEffectListMount, nil, bit32.bor(layout, hasEffect), data)

			if hasCaughtError() then
				local v4 = clearCaughtError()
				captureCommitPhaseError(data, data.return_, v4)
			end
		end
	elseif data.tag == classComponent then
		local stateNode = data.stateNode
		invokeGuardedCallback(nil, stateNode.componentDidMount, stateNode)

		if hasCaughtError() then
			local v4 = clearCaughtError()
			captureCommitPhaseError(data, data.return_, v4)
		end
	end
end

function invokePassiveEffectMountInDEV(p)
	if not __DEV__ or not enableDoubleInvokingEffects or p.tag ~= functionComponent and p.tag ~= forwardRef and p.tag ~= simpleMemoComponent and p.tag ~= block then
		return
	end

	invokeGuardedCallback(nil, commitHookEffectListMount, nil, bit32.bor(passive, hasEffect), p)

	if hasCaughtError() then
		local v4 = clearCaughtError()
		captureCommitPhaseError(p, p.return_, v4)
	end
end

function invokeLayoutEffectUnmountInDEV(data)
	if __DEV__ and enableDoubleInvokingEffects then
		if data.tag == functionComponent or data.tag == forwardRef or data.tag == simpleMemoComponent or data.tag == block then
			invokeGuardedCallback(
				nil,
				commitHookEffectListUnmount,
				nil,
				bit32.bor(layout, hasEffect),
				data,
				data.return_
			)

			if hasCaughtError() then
				local v4 = clearCaughtError()
				captureCommitPhaseError(data, data.return_, v4)
			end
		end
	elseif data.tag == classComponent then
		local stateNode = data.stateNode

		if typeof(stateNode.componentWillUnmount) == "function" then
			safelyCallComponentWillUnmount(data, stateNode, data.return_)
		end
	end
end

function invokePassiveEffectUnmountInDEV(p)
	if not __DEV__ or not enableDoubleInvokingEffects or p.tag ~= functionComponent and p.tag ~= forwardRef and p.tag ~= simpleMemoComponent and p.tag ~= block then
		return
	end

	invokeGuardedCallback(nil, commitHookEffectListUnmount, nil, bit32.bor(passive, hasEffect), p, p.return_)

	if hasCaughtError() then
		local v4 = clearCaughtError()
		captureCommitPhaseError(p, p.return_, v4)
	end
end

local New = {}
New.safelyCallDestroy = safelyCallDestroy

function New.commitBeforeMutationLifeCycles(p, data)
	if data.tag == functionComponent or data.tag == forwardRef or data.tag == simpleMemoComponent or data.tag == block then
		return
	end

	if data.tag == classComponent then
		if bit32.band(data.flags, snapshot) ~= 0 and p ~= nil then
			local memoizedProps = p.memoizedProps
			local memoizedState = p.memoizedState
			local stateNode = data.stateNode

			if __DEV__ and data.type == data.elementType and not fn then
				if stateNode.props ~= data.memoizedProps then
					console.error(
						"Expected %s props to match memoized props before getSnapshotBeforeUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.",
						getComponentName(data.type) or "instance"
					)
				end

				if stateNode.state ~= data.memoizedState then
					console.error(
						"Expected %s state to match memoized state before getSnapshotBeforeUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.",
						getComponentName(data.type) or "instance"
					)
				end
			end

			stateNode.__reactInternalSnapshotBeforeUpdate = stateNode:getSnapshotBeforeUpdate(
				data.elementType == data.type and memoizedProps or resolveDefaultProps(data.type, memoizedProps),
				memoizedState
			)
		end
	elseif data.tag == hostRoot then
		if supportsMutation and bit32.band(data.flags, snapshot) ~= 0 then
			clearContainer(data.stateNode.containerInfo)
		end
	else
		if data.tag == hostComponent or data.tag == hostText or data.tag == hostPortal or data.tag == incompleteClassComponent then
			return
		end

		invariant(
			false,
			"This unit of work tag should not have side-effects. This error is likely caused by a bug in React. Please file an issue."
		)
	end
end

New.commitResetTextContent = commitResetTextContent
New.commitPlacement = commitPlacement
New.commitDeletion = commitDeletion

function New.commitWork(p, state)
	if state.tag == functionComponent or state.tag == forwardRef or state.tag == memoComponent or state.tag == simpleMemoComponent or state.tag == block then
		if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(state.mode, profileMode) ~= 0 then
			local v4, v5 = xpcall(function()
				startLayoutEffectTimer()
				commitHookEffectListUnmount(bit32.bor(layout, hasEffect), state, state.return_)
			end, describeError)
			recordLayoutEffectDuration(state)

			if not v4 then
				error(v5)
			end
		else
			commitHookEffectListUnmount(bit32.bor(layout, hasEffect), state, state.return_)
		end
	else
		if state.tag == classComponent then
			return
		end

		if state.tag == hostComponent then
			local stateNode = state.stateNode

			if stateNode ~= nil then
				local memoizedProps = state.memoizedProps
				local memoizedProps2

				if p then
					memoizedProps2 = p.memoizedProps
				else
					memoizedProps2 = memoizedProps
				end

				local type = state.type
				local updateQueue = state.updateQueue
				state.updateQueue = nil

				if updateQueue ~= nil then
					commitUpdate(stateNode, updateQueue, type, memoizedProps2, memoizedProps, state)
				end
			end
		elseif state.tag == hostText then
			invariant(
				state.stateNode ~= nil,
				"This should have a text node initialized. This error is likely caused by a bug in React. Please file an issue."
			)
			local stateNode = state.stateNode
			local memoizedProps = state.memoizedProps
			local v4

			if p ~= nil then
				local _ = p.memoizedProps
				v4 = memoizedProps
			end

			commitTextUpdate(stateNode, v4, memoizedProps)
		elseif state.tag == hostRoot then
			if supportsHydration then
				local stateNode = state.stateNode

				if stateNode.hydrate then
					stateNode.hydrate = false
					unimplemented("commitWork: HostRoot: commitHydratedContainer")
				end
			end
		else
			if state.tag == profiler then
				return
			end

			if state.tag == suspenseComponent then
				commitSuspenseComponent(state)
				attachSuspenseRetryListeners(state)
			else
				if state.tag == suspenseListComponent then
					unimplemented("commitWork: SuspenseListComponent")
				else
					if state.tag == incompleteClassComponent then
						return
					end

					if state.tag == offscreenComponent or state.tag == legacyHiddenComponent then
						hideOrUnhideAllChildren(state, state.memoizedState ~= nil)
						return
					end
				end

				invariant(
					false,
					"This unit of work tag should not have side-effects. This error is likely caused by a bug in React. Please file an issue."
				)
			end
		end
	end
end

New.commitAttachRef = commitAttachRef
New.commitDetachRef = commitDetachRef

function New.commitPassiveUnmount(data)
	if data.tag == functionComponent or data.tag == forwardRef or data.tag == simpleMemoComponent or data.tag == block then
		if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(data.mode, profileMode) ~= 0 then
			startPassiveEffectTimer()
			commitHookEffectListUnmount(bit32.bor(passive, hasEffect), data, data.return_)
			recordPassiveEffectDuration(data)
		else
			commitHookEffectListUnmount(bit32.bor(passive, hasEffect), data, data.return_)
		end
	end
end

function New.commitPassiveUnmountInsideDeletedTree(p, p2)
	if p.tag == functionComponent or p.tag == forwardRef or p.tag == simpleMemoComponent or p.tag == block then
		if enableProfilerTimer and enableProfilerCommitHooks and bit32.band(p.mode, profileMode) ~= 0 then
			startPassiveEffectTimer()
			commitHookEffectListUnmount(passive, p, p2)
			recordPassiveEffectDuration(p)
		else
			commitHookEffectListUnmount(passive, p, p2)
		end
	end
end

function New.commitPassiveMount(p, p2)
	if p2.tag == functionComponent or p2.tag == forwardRef or p2.tag == simpleMemoComponent or p2.tag == block then
		if not enableProfilerTimer or not enableProfilerCommitHooks or bit32.band(p2.mode, profileMode) == 0 then
			commitHookEffectListMount(bit32.bor(passive, hasEffect), p2)
			return
		end

		startPassiveEffectTimer()
		local v4, v5 = xpcall(commitHookEffectListMount, describeError, bit32.bor(passive, hasEffect), p2)
		recordPassiveEffectDuration(p2)

		if not v4 then
			error(v5)
		end
	elseif p2.tag == profiler then
		commitProfilerPassiveEffect(p, p2)
	end
end

New.invokeLayoutEffectMountInDEV = invokeLayoutEffectMountInDEV
New.invokeLayoutEffectUnmountInDEV = invokeLayoutEffectUnmountInDEV
New.invokePassiveEffectMountInDEV = invokePassiveEffectMountInDEV
New.invokePassiveEffectUnmountInDEV = invokePassiveEffectUnmountInDEV
New.isSuspenseBoundaryBeingHidden = isSuspenseBoundaryBeingHidden
New.recursivelyCommitLayoutEffects = recursivelyCommitLayoutEffects
return New