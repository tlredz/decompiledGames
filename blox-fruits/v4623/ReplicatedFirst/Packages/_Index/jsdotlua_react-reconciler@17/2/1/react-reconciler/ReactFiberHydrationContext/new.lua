local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console

local function unimplemented(p: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. p)
	error("FIXME (roblox): " .. p .. " is unimplemented", 2)
end

require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberHostConfig = require(script.Parent:WaitForChild("ReactFiberHostConfig"))
require(script.Parent:WaitForChild("ReactFiberSuspenseComponent.new"))
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local hostComponent = ReactWorkTags.HostComponent
local hostText = ReactWorkTags.HostText
local hostRoot = ReactWorkTags.HostRoot
local suspenseComponent = ReactWorkTags.SuspenseComponent
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local placement = ReactFiberFlags.Placement
local hydrating = ReactFiberFlags.Hydrating
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared2.invariant
local ReactFibernew = require(script.Parent:WaitForChild("ReactFiber.new"))
local createFiberFromDehydratedFragment = ReactFibernew.createFiberFromDehydratedFragment
local supportsHydration = ReactFiberHostConfig.supportsHydration
local getNextHydratableSibling = ReactFiberHostConfig.getNextHydratableSibling
local getFirstHydratableChild = ReactFiberHostConfig.getFirstHydratableChild
local canHydrateInstance = ReactFiberHostConfig.canHydrateInstance
local canHydrateTextInstance = ReactFiberHostConfig.canHydrateTextInstance
local canHydrateSuspenseInstance = ReactFiberHostConfig.canHydrateSuspenseInstance
local hydrateInstance = ReactFiberHostConfig.hydrateInstance
local hydrateTextInstance = ReactFiberHostConfig.hydrateTextInstance
local hydrateSuspenseInstance = ReactFiberHostConfig.hydrateSuspenseInstance
local getNextHydratableInstanceAfterSuspenseInstance = ReactFiberHostConfig.getNextHydratableInstanceAfterSuspenseInstance
local didNotMatchHydratedContainerTextInstance = ReactFiberHostConfig.didNotMatchHydratedContainerTextInstance
local didNotMatchHydratedTextInstance = ReactFiberHostConfig.didNotMatchHydratedTextInstance
local shouldSetTextContent = ReactFiberHostConfig.shouldSetTextContent
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local enableSuspenseServerRenderer = shared3.ReactFeatureFlags.enableSuspenseServerRenderer
local ReactFiberLane = require(script.Parent:WaitForChild("ReactFiberLane"))
local offscreenLane = ReactFiberLane.OffscreenLane
local v = nil
local v2 = nil
local flag = false

function warnIfHydrating()
	if _G.__DEV__ and flag then
		console.error("We should not be hydrating here. This is a bug in React. Please file a bug.")
	end
end

function enterHydrationState(p)
	if not supportsHydration then
		return false
	end

	v2 = getFirstHydratableChild(p.stateNode.containerInfo)
	v = p
	flag = true
	return true
end

function reenterHydrationStateFromDehydratedSuspenseInstance(p, p2)
	if not supportsHydration then
		return false
	end

	v2 = getNextHydratableSibling(p2)
	popToNextHostParent(p)
	flag = true
	return true
end

function deleteHydratableInstance(_, _)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: deleteHydratableInstance")
	error("FIXME (roblox): deleteHydratableInstance is unimplemented", 2)
end

function insertNonHydratedInstance(_, p)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: insertNonHydratedInstance")
	error("FIXME (roblox): insertNonHydratedInstance is unimplemented", 2)
	p.flags = bit32.bor(bit32.band(p.flags, (bit32.bnot(hydrating))), placement)
	local _ = _G.__DEV__
end

function tryHydrate(return_, p)
	if return_.tag == hostComponent then
		local stateNode = canHydrateInstance(p, return_.type, return_.pendingProps)

		if stateNode == nil then
			return false
		end

		return_.stateNode = stateNode
		return true
	elseif return_.tag == hostText then
		local stateNode = canHydrateTextInstance(p, return_.pendingProps)

		if stateNode == nil then
			return false
		end

		return_.stateNode = stateNode
		return true
	else
		if not (return_.tag == suspenseComponent and enableSuspenseServerRenderer) then
			return false
		end

		local dehydrated = canHydrateSuspenseInstance(p)

		if dehydrated == nil then
			return false
		end

		return_.memoizedState = {
			dehydrated = dehydrated,
			retryLane = offscreenLane
		}
		local fiberFromDehydratedFragment = createFiberFromDehydratedFragment(dehydrated)
		fiberFromDehydratedFragment.return_ = return_
		return_.child = fiberFromDehydratedFragment
		return true
	end
end

function tryToClaimNextHydratableInstance(p)
	if not flag then
		return
	end

	local v3 = v2

	if v3 then
		if not tryHydrate(p, v3) then
			local nextHydratableSibling = getNextHydratableSibling(v3)

			if nextHydratableSibling and tryHydrate(p, nextHydratableSibling) then
				deleteHydratableInstance(v, v3)
				v3 = nextHydratableSibling
			else
				insertNonHydratedInstance(v, p)
				flag = false
				v = p
				return
			end
		end

		v = p
		v2 = getFirstHydratableChild(v3)
	else
		insertNonHydratedInstance(v, p)
		flag = false
		v = p
	end
end

function prepareToHydrateHostInstance(state, p, p2)
	if not supportsHydration then
		invariant(
			false,
			"Expected prepareToHydrateHostInstance() to never be called. This error is likely caused by a bug in React. Please file an issue."
		)
	end

	local updateQueue = hydrateInstance(state.stateNode, state.type, state.memoizedProps, p, p2, state)
	state.updateQueue = updateQueue
	return updateQueue ~= nil
end

function prepareToHydrateHostTextInstance(p)
	if not supportsHydration then
		invariant(
			false,
			"Expected prepareToHydrateHostTextInstance() to never be called. This error is likely caused by a bug in React. Please file an issue."
		)
	end

	local stateNode = p.stateNode
	local memoizedProps = p.memoizedProps
	local v3 = hydrateTextInstance(stateNode, memoizedProps, p)

	if not (_G.__DEV__ and v3) then
		return v3
	end

	local v4 = v

	if v4 == nil then
		return v3
	end

	if v4.tag == hostRoot then
		didNotMatchHydratedContainerTextInstance(v4.stateNode.containerInfo, stateNode, memoizedProps)
		return v3
	else
		if v4.tag ~= hostComponent then
			return v3
		end

		didNotMatchHydratedTextInstance(v4.type, v4.memoizedProps, v4.stateNode, stateNode, memoizedProps)
		return v3
	end
end

function prepareToHydrateHostSuspenseInstance(p)
	if not supportsHydration then
		invariant(
			false,
			"Expected prepareToHydrateHostSuspenseInstance() to never be called. This error is likely caused by a bug in React. Please file an issue."
		)
	end

	local memoizedState = p.memoizedState
	local dehydrated

	if memoizedState ~= nil then
		dehydrated = memoizedState.dehydrated
	end

	invariant(
		dehydrated,
		"Expected to have a hydrated suspense instance. This error is likely caused by a bug in React. Please file an issue."
	)
	hydrateSuspenseInstance(dehydrated, p)
end

function skipPastDehydratedSuspenseInstance(p)
	if not supportsHydration then
		invariant(
			false,
			"Expected skipPastDehydratedSuspenseInstance() to never be called. This error is likely caused by a bug in React. Please file an issue."
		)
	end

	local memoizedState = p.memoizedState
	local dehydrated

	if memoizedState ~= nil then
		dehydrated = memoizedState.dehydrated
	end

	invariant(
		dehydrated,
		"Expected to have a hydrated suspense instance. This error is likely caused by a bug in React. Please file an issue."
	)
	return getNextHydratableInstanceAfterSuspenseInstance(dehydrated)
end

function popToNextHostParent(p)
	local return_ = p.return_

	while return_ ~= nil and return_.tag ~= hostComponent and return_.tag ~= hostRoot and return_.tag ~= suspenseComponent do
		return_ = return_.return_
	end

	v = return_
end

function popHydrationState(data)
	if not (supportsHydration and data == v) then
		return false
	end

	if flag then
		local type = data.type

		if data.tag ~= hostComponent or type ~= "head" and type ~= "body" and not shouldSetTextContent(
			type,
			data.memoizedProps
		) then
			local v3 = v2

			while v3 do
				deleteHydratableInstance(data, v3)
				v3 = getNextHydratableSibling(v3)
			end
		end

		popToNextHostParent(data)

		if data.tag == suspenseComponent then
			v2 = skipPastDehydratedSuspenseInstance(data)
		elseif v then
			v2 = getNextHydratableSibling(data.stateNode)
		else
			v2 = nil
		end

		return true
	else
		popToNextHostParent(data)
		flag = true
		return false
	end
end

function resetHydrationState()
	if not supportsHydration then
		return
	end

	v = nil
	v2 = nil
	flag = false
end

function getIsHydrating()
	return flag
end

return {
	warnIfHydrating = warnIfHydrating,
	enterHydrationState = enterHydrationState,
	getIsHydrating = getIsHydrating,
	reenterHydrationStateFromDehydratedSuspenseInstance = reenterHydrationStateFromDehydratedSuspenseInstance,
	resetHydrationState = resetHydrationState,
	tryToClaimNextHydratableInstance = tryToClaimNextHydratableInstance,
	prepareToHydrateHostInstance = prepareToHydrateHostInstance,
	prepareToHydrateHostTextInstance = prepareToHydrateHostTextInstance,
	prepareToHydrateHostSuspenseInstance = prepareToHydrateHostSuspenseInstance,
	popHydrationState = popHydrationState
}