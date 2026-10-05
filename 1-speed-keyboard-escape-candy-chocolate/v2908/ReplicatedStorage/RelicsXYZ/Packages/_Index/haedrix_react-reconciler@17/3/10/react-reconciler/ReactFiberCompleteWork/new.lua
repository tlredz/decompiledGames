local function unimplemented(p: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring(p))
	error("FIXME (roblox): " .. p .. " is unimplemented", 2)
end

local parent = script.Parent.Parent
require(script.Parent.ReactInternalTypes)
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local offscreenLane = ReactFiberLane.OffscreenLane
local ReactFiberHostConfig = require(script.Parent.ReactFiberHostConfig)
require(script.Parent.ReactFiberOffscreenComponent)
local ReactMutableSourcenew = require(script.Parent["ReactMutableSource.new"])
local resetWorkInProgressVersions = ReactMutableSourcenew.resetWorkInProgressVersions
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local indeterminateComponent = ReactWorkTags.IndeterminateComponent
local functionComponent = ReactWorkTags.FunctionComponent
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local hostComponent = ReactWorkTags.HostComponent
local hostText = ReactWorkTags.HostText
local hostPortal = ReactWorkTags.HostPortal
local contextProvider = ReactWorkTags.ContextProvider
local contextConsumer = ReactWorkTags.ContextConsumer
local forwardRef = ReactWorkTags.ForwardRef
local fragment = ReactWorkTags.Fragment
local mode = ReactWorkTags.Mode
local profiler = ReactWorkTags.Profiler
local suspenseComponent = ReactWorkTags.SuspenseComponent
local suspenseListComponent = ReactWorkTags.SuspenseListComponent
local memoComponent = ReactWorkTags.MemoComponent
local simpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local lazyComponent = ReactWorkTags.LazyComponent
local incompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local fundamentalComponent = ReactWorkTags.FundamentalComponent
local scopeComponent = ReactWorkTags.ScopeComponent
local block = ReactWorkTags.Block
local offscreenComponent = ReactWorkTags.OffscreenComponent
local legacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
require(script.Parent["ReactFiberSuspenseComponent.new"])
local ReactTypeOfMode = require(script.Parent.ReactTypeOfMode)
local noMode = ReactTypeOfMode.NoMode
local concurrentMode = ReactTypeOfMode.ConcurrentMode
local blockingMode = ReactTypeOfMode.BlockingMode
local profileMode = ReactTypeOfMode.ProfileMode
local ReactFiberFlags = require(script.Parent.ReactFiberFlags)
local ref = ReactFiberFlags.Ref
local update = ReactFiberFlags.Update
local callback = ReactFiberFlags.Callback
local passive = ReactFiberFlags.Passive
local deletion = ReactFiberFlags.Deletion
local noFlags = ReactFiberFlags.NoFlags
local didCapture = ReactFiberFlags.DidCapture
local snapshot = ReactFiberFlags.Snapshot
local mutationMask = ReactFiberFlags.MutationMask
local layoutMask = ReactFiberFlags.LayoutMask
local passiveMask = ReactFiberFlags.PassiveMask
local staticMask = ReactFiberFlags.StaticMask
local performedWork = ReactFiberFlags.PerformedWork
local Shared = require(parent.Shared)
local invariant = Shared.invariant
local createInstance = ReactFiberHostConfig.createInstance
local createTextInstance = ReactFiberHostConfig.createTextInstance
local appendInitialChild = ReactFiberHostConfig.appendInitialChild
local finalizeInitialChildren = ReactFiberHostConfig.finalizeInitialChildren
local prepareUpdate = ReactFiberHostConfig.prepareUpdate
local supportsMutation = ReactFiberHostConfig.supportsMutation
local supportsPersistence = ReactFiberHostConfig.supportsPersistence
local createContainerChildSet = ReactFiberHostConfig.createContainerChildSet
local finalizeContainerChildren = ReactFiberHostConfig.finalizeContainerChildren
local preparePortalMount = ReactFiberHostConfig.preparePortalMount
local ReactFiberHostContextnew = require(script.Parent["ReactFiberHostContext.new"])
local getRootHostContainer = ReactFiberHostContextnew.getRootHostContainer
local popHostContext = ReactFiberHostContextnew.popHostContext
local getHostContext = ReactFiberHostContextnew.getHostContext
local popHostContainer = ReactFiberHostContextnew.popHostContainer
local ReactFiberSuspenseContextnew = require(script.Parent["ReactFiberSuspenseContext.new"])
local popSuspenseContext = ReactFiberSuspenseContextnew.popSuspenseContext
local suspenseStackCursor = ReactFiberSuspenseContextnew.suspenseStackCursor
local invisibleParentSuspenseContext = ReactFiberSuspenseContextnew.InvisibleParentSuspenseContext
local hasSuspenseContext = ReactFiberSuspenseContextnew.hasSuspenseContext
local ReactFiberContextnew = require(script.Parent["ReactFiberContext.new"])
local isContextProvider = ReactFiberContextnew.isContextProvider
local popContext = ReactFiberContextnew.popContext
local popTopLevelContextObject = ReactFiberContextnew.popTopLevelContextObject
local ReactFiberNewContextnew = require(script.Parent["ReactFiberNewContext.new"])
local popProvider = ReactFiberNewContextnew.popProvider
local ReactFiberHydrationContextnew = require(script.Parent["ReactFiberHydrationContext.new"])
local prepareToHydrateHostSuspenseInstance = ReactFiberHydrationContextnew.prepareToHydrateHostSuspenseInstance
local popHydrationState = ReactFiberHydrationContextnew.popHydrationState
local resetHydrationState = ReactFiberHydrationContextnew.resetHydrationState
local prepareToHydrateHostInstance = ReactFiberHydrationContextnew.prepareToHydrateHostInstance
local prepareToHydrateHostTextInstance = ReactFiberHydrationContextnew.prepareToHydrateHostTextInstance
local Shared2 = require(parent.Shared)
local reactFeatureFlags = Shared2.ReactFeatureFlags
local enableSchedulerTracing = reactFeatureFlags.enableSchedulerTracing
local enableSuspenseCallback = reactFeatureFlags.enableSuspenseCallback
local enableSuspenseServerRenderer = reactFeatureFlags.enableSuspenseServerRenderer
local enableFundamentalAPI = reactFeatureFlags.enableFundamentalAPI
local enableProfilerTimer = reactFeatureFlags.enableProfilerTimer
local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
local popRenderLanes = ReactFiberWorkLoopnew.popRenderLanes
local markSpawnedWork = ReactFiberWorkLoopnew.markSpawnedWork
local renderDidSuspend = ReactFiberWorkLoopnew.renderDidSuspend
local renderDidSuspendDelayIfPossible = ReactFiberWorkLoopnew.renderDidSuspendDelayIfPossible
local noLanes = ReactFiberLane.NoLanes
local includesSomeLane = ReactFiberLane.includesSomeLane
local mergeLanes = ReactFiberLane.mergeLanes
local ReactProfilerTimernew = require(script.Parent["ReactProfilerTimer.new"])
local transferActualDuration = ReactProfilerTimernew.transferActualDuration

-- equivalent calls inferred from this helper; original call sites unknown
local function markUpdate(p)
	p.flags = bit32.bor(p.flags, update)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markRef(state)
	state.flags = bit32.bor(state.flags, ref)
end

local function hadNoMutationsEffects(p, p2)
	local v

	if p == nil then
		v = false
	else
		v = p.child == p2.child
	end

	if v then
		return true
	end

	local child = p2.child

	while child ~= nil do
		if not (bit32.band(child.flags, mutationMask) == noFlags and bit32.band(child.subtreeFlags, mutationMask) == noFlags) then
			return false
		end

		child = child.sibling
	end

	return true
end

local fn
local updateHostComponent
local updateHostText
local updateHostContainer

if supportsMutation then
	updateHostComponent = function(data, state, type, pendingProps, rootHostContainer)
		local memoizedProps = data.memoizedProps

		if memoizedProps == pendingProps then
			return
		end

		local updateQueue = prepareUpdate(
			state.stateNode,
			type,
			memoizedProps,
			pendingProps,
			rootHostContainer,
			(getHostContext())
		)
		state.updateQueue = updateQueue

		if updateQueue then
			markUpdate(state) -- equivalent call inferred; original call site unknown
		end
	end

	updateHostText = function(_, state, memoizedProps: string, pendingProps: string)
		if memoizedProps ~= pendingProps then
			markUpdate(state) -- equivalent call inferred; original call site unknown
		end
	end

	updateHostContainer = function(_, _) end

	fn = function(p, p2, _: boolean, _: boolean)
		local child = p2.child

		while child ~= nil do
			if child.tag == hostComponent or child.tag == hostText then
				appendInitialChild(p, child.stateNode)

				if child == p2 then
					break
				end

				while child.sibling == nil do
					if child.return_ == nil or child.return_ == p2 then
						return
					else
						child = child.return_
					end
				end

				child.sibling.return_ = child.return_
				child = child.sibling
			elseif enableFundamentalAPI and child.tag == fundamentalComponent then
				appendInitialChild(p, child.stateNode.instance)

				if child == p2 then
					break
				end

				while child.sibling == nil do
					if child.return_ == nil or child.return_ == p2 then
						return
					else
						child = child.return_
					end
				end

				child.sibling.return_ = child.return_
				child = child.sibling
			elseif child.tag == hostPortal or child.child == nil then
				if child == p2 then
					break
				end

				while child.sibling == nil do
					if child.return_ == nil or child.return_ == p2 then
						return
					else
						child = child.return_
					end
				end

				child.sibling.return_ = child.return_
				child = child.sibling
			else
				child.child.return_ = child
				child = child.child
			end
		end
	end
elseif supportsPersistence then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function appendAllChildrenToContainer(_, _, _: boolean, _: boolean)
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("UNIMPLEMENTED ERROR: " .. tostring("appendAllChildrenToContainer"))
		error("FIXME (roblox): appendAllChildrenToContainer is unimplemented", 2)
	end

	updateHostContainer = function(p, p2)
		local stateNode = p2.stateNode

		if hadNoMutationsEffects(p, p2) then
			return
		end

		local containerInfo = stateNode.containerInfo
		local containerChildSet = createContainerChildSet(containerInfo)
		appendAllChildrenToContainer() -- equivalent call inferred; original call site unknown
		stateNode.pendingChildren = containerChildSet
		markUpdate(p2) -- equivalent call inferred; original call site unknown
		finalizeContainerChildren(containerInfo, containerChildSet)
	end

	fn = function(_, _, _: boolean, _: boolean)
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("UNIMPLEMENTED ERROR: " .. tostring("appendAllChildren"))
		error("FIXME (roblox): appendAllChildren is unimplemented", 2)
	end
else
	updateHostContainer = function(_, _) end
end

local function bubbleProperties(return_)
	local v

	if return_.alternate == nil then
		v = false
	else
		v = return_.alternate.child == return_.child
	end

	local childLanes = noLanes
	local v3 = noFlags

	if v then
		if enableProfilerTimer and bit32.band(return_.mode, profileMode) ~= noMode then
			local selfBaseDuration = return_.selfBaseDuration
			local child = return_.child

			while child ~= nil do
				childLanes = mergeLanes(childLanes, mergeLanes(child.lanes, child.childLanes))
				v3 = bit32.bor(
					bit32.bor(v3, (bit32.band(child.subtreeFlags, staticMask))),
					(bit32.band(child.flags, staticMask))
				)
				selfBaseDuration += child.treeBaseDuration
				child = child.sibling
			end

			return_.treeBaseDuration = selfBaseDuration
		else
			local child = return_.child

			while child ~= nil do
				childLanes = bit32.bor(childLanes, (bit32.bor(child.lanes, child.childLanes)))
				v3 = bit32.bor(
					bit32.bor(v3, (bit32.band(child.subtreeFlags, staticMask))),
					(bit32.band(child.flags, staticMask))
				)
				child.return_ = return_
				child = child.sibling
			end
		end
	elseif enableProfilerTimer and bit32.band(return_.mode, profileMode) ~= noMode then
		local actualDuration = return_.actualDuration
		local selfBaseDuration = return_.selfBaseDuration
		local child = return_.child

		while child ~= nil do
			childLanes = mergeLanes(childLanes, mergeLanes(child.lanes, child.childLanes))
			v3 = bit32.bor(bit32.bor(v3, child.subtreeFlags), child.flags)
			actualDuration += child.actualDuration
			selfBaseDuration += child.treeBaseDuration
			child = child.sibling
		end

		return_.actualDuration = actualDuration
		return_.treeBaseDuration = selfBaseDuration
	else
		local child = return_.child

		while child ~= nil do
			childLanes = bit32.bor(childLanes, (bit32.bor(child.lanes, child.childLanes)))
			v3 = bit32.bor(bit32.bor(v3, child.subtreeFlags), child.flags)
			child.return_ = return_
			child = child.sibling
		end
	end

	return_.subtreeFlags = bit32.bor(return_.subtreeFlags, v3)
	return_.childLanes = childLanes
	return v
end

return {
	completeWork = function(data, state, lanes)
		local pendingProps = state.pendingProps

		if state.tag == indeterminateComponent or state.tag == lazyComponent or state.tag == simpleMemoComponent or state.tag == functionComponent or state.tag == forwardRef or state.tag == fragment or state.tag == mode or state.tag == contextConsumer or state.tag == memoComponent then
			bubbleProperties(state)
			return nil
		end

		if state.tag == classComponent then
			if isContextProvider(state.type) then
				popContext(state)
			end

			bubbleProperties(state)
			return nil
		elseif state.tag == hostRoot then
			popHostContainer(state)
			popTopLevelContextObject(state)
			resetWorkInProgressVersions()
			local stateNode = state.stateNode

			if stateNode.pendingContext then
				stateNode.context = stateNode.pendingContext
				stateNode.pendingContext = nil
			end

			if data == nil or data.child == nil then
				if popHydrationState(state) then
					markUpdate(state) -- equivalent call inferred; original call site unknown
				elseif not stateNode.hydrate then
					state.flags = bit32.bor(state.flags, snapshot)
				end
			end

			updateHostContainer(data, state)
			bubbleProperties(state)
			return nil
		elseif state.tag == hostComponent then
			popHostContext(state)
			local rootHostContainer = getRootHostContainer()
			local type = state.type

			if data == nil or state.stateNode == nil then
				if pendingProps then
					local hostContext = getHostContext()

					if popHydrationState(state) then
						if prepareToHydrateHostInstance(state, rootHostContainer, hostContext) then
							markUpdate(state) -- equivalent call inferred; original call site unknown
						end
					else
						local instance = createInstance(type, pendingProps, rootHostContainer, hostContext, state)
						fn(instance, state, false, false)
						state.stateNode = instance

						if finalizeInitialChildren(instance, type, pendingProps, rootHostContainer, hostContext) then
							markUpdate(state) -- equivalent call inferred; original call site unknown
						end
					end

					if state.ref ~= nil then
						markRef(state) -- equivalent call inferred; original call site unknown
					end
				else
					invariant(
						state.stateNode ~= nil,
						"We must have new props for new mounts. This error is likely caused by a bug in React. Please file an issue."
					)
					bubbleProperties(state)
					return nil
				end
			else
				updateHostComponent(data, state, type, pendingProps, rootHostContainer)

				if data.ref ~= state.ref then
					markRef(state) -- equivalent call inferred; original call site unknown
				end
			end

			bubbleProperties(state)
			return nil
		elseif state.tag == hostText then
			if data and state.stateNode ~= nil then
				updateHostText(data, state, data.memoizedProps, pendingProps)
			else
				if typeof(pendingProps) ~= "string" then
					invariant(
						state.stateNode ~= nil,
						"We must have new props for new mounts. This error is likely caused by a bug in React. Please file an issue."
					)
				end

				local rootHostContainer = getRootHostContainer()
				local hostContext = getHostContext()

				if popHydrationState(state) then
					if prepareToHydrateHostTextInstance(state) then
						markUpdate(state) -- equivalent call inferred; original call site unknown
					end
				else
					state.stateNode = createTextInstance(pendingProps, rootHostContainer, hostContext, state)
				end
			end

			bubbleProperties(state)
			return nil
		elseif state.tag == profiler then
			if bubbleProperties(state) then
				return nil
			end

			local update2 = update
			local callback2 = callback
			local passive2 = passive
			local subtreeFlags = state.subtreeFlags
			local flags = state.flags
			local flags2

			if bit32.band(flags, performedWork) == noFlags and bit32.band(subtreeFlags, performedWork) == noFlags then
				flags2 = flags
			else
				flags2 = bit32.bor(flags, update2)
			end

			if bit32.band(flags, (bit32.bor(layoutMask, deletion))) ~= noFlags or bit32.band(
				subtreeFlags,
				(bit32.bor(layoutMask, deletion))
			) ~= noFlags then
				flags2 = bit32.bor(flags2, callback2)
			end

			if bit32.band(flags, passiveMask) ~= noFlags or bit32.band(subtreeFlags, passiveMask) ~= noFlags then
				flags2 = bit32.bor(flags2, passive2)
			end

			state.flags = flags2
			return nil
		elseif state.tag == suspenseComponent then
			popSuspenseContext(state)
			local memoizedState = state.memoizedState

			if enableSuspenseServerRenderer and memoizedState ~= nil and memoizedState.dehydrated ~= nil then
				if data == nil then
					invariant(
						popHydrationState(state),
						"A dehydrated suspense component was completed without a hydrated node. This is probably a bug in React."
					)
					prepareToHydrateHostSuspenseInstance(state)

					if enableSchedulerTracing then
						markSpawnedWork(offscreenLane)
					end

					bubbleProperties(state)

					if enableProfilerTimer and bit32.band(state.mode, profileMode) ~= noMode and memoizedState ~= nil then
						local child = state.child

						if child ~= nil then
							state.treeBaseDuration = child.treeBaseDuration
						end
					end

					return nil
				else
					resetHydrationState()

					if bit32.band(state.flags, didCapture) == noFlags then
						state.memoizedState = nil
					end

					markUpdate(state) -- equivalent call inferred; original call site unknown
					bubbleProperties(state)

					if enableProfilerTimer and bit32.band(state.mode, profileMode) ~= noMode and memoizedState ~= nil then
						local child = state.child

						if child ~= nil then
							state.treeBaseDuration -= child.treeBaseDuration
						end
					end

					return nil
				end
			elseif bit32.band(state.flags, didCapture) == noFlags then
				local v = memoizedState ~= nil
				local v2 = false

				if data == nil then
					if state.memoizedProps.fallback ~= nil then
						popHydrationState(state)
					end
				else
					v2 = data.memoizedState ~= nil
				end

				if v and not v2 and bit32.band(state.mode, blockingMode) ~= noMode then
					local v3

					if data == nil then
						v3 = state.memoizedProps.unstable_avoidThisFallback ~= true
					else
						v3 = false
					end

					if v3 or hasSuspenseContext(suspenseStackCursor.current, invisibleParentSuspenseContext) then
						renderDidSuspend()
					else
						renderDidSuspendDelayIfPossible()
					end
				end

				if supportsPersistence and v then
					markUpdate(state) -- equivalent call inferred; original call site unknown
				end

				if supportsMutation and (v or v2) then
					markUpdate(state) -- equivalent call inferred; original call site unknown
				end

				if enableSuspenseCallback and state.updateQueue ~= nil and state.memoizedProps.suspenseCallback ~= nil then
					markUpdate(state) -- equivalent call inferred; original call site unknown
				end

				bubbleProperties(state)

				if enableProfilerTimer and bit32.band(state.mode, profileMode) ~= noMode and v then
					local child = state.child

					if child ~= nil then
						state.treeBaseDuration -= child.treeBaseDuration
					end
				end

				return nil
			else
				state.lanes = lanes

				if enableProfilerTimer and bit32.band(state.mode, profileMode) ~= noMode then
					transferActualDuration(state)
				end

				return state
			end
		elseif state.tag == hostPortal then
			popHostContainer(state)
			updateHostContainer(data, state)

			if data == nil then
				preparePortalMount(state.stateNode.containerInfo)
			end

			bubbleProperties(state)
			return nil
		elseif state.tag == contextProvider then
			popProvider(state)
			bubbleProperties(state)
			return nil
		elseif state.tag == incompleteClassComponent then
			if isContextProvider(state.type) then
				popContext(state)
			end

			bubbleProperties(state)
			return nil
		else
			if state.tag == suspenseListComponent then
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("UNIMPLEMENTED ERROR: " .. tostring("SuspenseListComponent"))
				error("FIXME (roblox): SuspenseListComponent is unimplemented", 2)
			elseif state.tag == fundamentalComponent then
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("UNIMPLEMENTED ERROR: " .. tostring("FundamentalComponent"))
				error("FIXME (roblox): FundamentalComponent is unimplemented", 2)
			elseif state.tag == scopeComponent then
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("UNIMPLEMENTED ERROR: " .. tostring("ScopeComponent"))
				error("FIXME (roblox): ScopeComponent is unimplemented", 2)
			elseif state.tag == block then
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				print("UNIMPLEMENTED ERROR: " .. tostring("Block"))
				error("FIXME (roblox): Block is unimplemented", 2)
			elseif state.tag == offscreenComponent or state.tag == legacyHiddenComponent then
				popRenderLanes(state)
				local v = state.memoizedState ~= nil

				if data ~= nil and data.memoizedState ~= nil ~= v and pendingProps.mode ~= "unstable-defer-without-hiding" then
					markUpdate(state) -- equivalent call inferred; original call site unknown
				end

				if not v or includesSomeLane(ReactFiberWorkLoopnew.subtreeRenderLanes, offscreenLane) or bit32.band(
					state.mode,
					concurrentMode
				) == noMode then
					bubbleProperties(state)
				end

				return nil
			end

			invariant(
				false,
				"Unknown unit of work tag (%s). This error is likely caused by a bug in React. Please file an issue.",
				(tostring(state.tag))
			)
			return nil
		end
	end
}