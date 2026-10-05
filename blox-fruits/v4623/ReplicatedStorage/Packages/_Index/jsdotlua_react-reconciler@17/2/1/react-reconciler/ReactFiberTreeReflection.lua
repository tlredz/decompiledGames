local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent:WaitForChild("ReactInternalTypes"))
require(script.Parent:WaitForChild("ReactFiberHostConfig"))
require(script.Parent:WaitForChild("ReactFiberSuspenseComponent.new"))
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared2.invariant
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local get = shared3.ReactInstanceMap.get
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSharedInternals = shared4.ReactSharedInternals
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared5.getComponentName
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local classComponent = ReactWorkTags.ClassComponent
local hostComponent = ReactWorkTags.HostComponent
local hostRoot = ReactWorkTags.HostRoot
local hostPortal = ReactWorkTags.HostPortal
local hostText = ReactWorkTags.HostText
local fundamentalComponent = ReactWorkTags.FundamentalComponent
local suspenseComponent = ReactWorkTags.SuspenseComponent
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local noFlags = ReactFiberFlags.NoFlags
local placement = ReactFiberFlags.Placement
local hydrating = ReactFiberFlags.Hydrating
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
local enableFundamentalAPI = shared6.ReactFeatureFlags.enableFundamentalAPI
local reactCurrentOwner = reactSharedInternals.ReactCurrentOwner

local function getNearestMountedFiber(return_)
	local return_2

	if return_.alternate then
		return_2 = return_

		while return_.return_ do
			return_ = return_.return_
		end
	else
		return_2 = return_

		while true do
			if bit32.band(return_.flags, (bit32.bor(placement, hydrating))) ~= noFlags then
				return_2 = return_.return_
			end

			local return_3 = return_.return_

			if not return_3 then
				break
			end

			return_ = return_3
		end
	end

	if return_.tag == hostRoot then
		return return_2
	end

	return nil
end

local ReactFiberTreeReflection = {
	getNearestMountedFiber = getNearestMountedFiber,
	getSuspenseInstanceFromFiber = function(data)
		if data.tag ~= suspenseComponent then
			return nil
		end

		local memoizedState = data.memoizedState

		if memoizedState == nil then
			local alternate = data.alternate

			if alternate ~= nil then
				memoizedState = alternate.memoizedState
			end
		end

		if memoizedState then
			return memoizedState.dehydrated
		end

		return nil
	end,
	getContainerFromFiber = function(p)
		if p.tag == hostRoot then
			return p.stateNode.containerInfo
		end

		return nil
	end,
	isFiberMounted = function(p)
		return getNearestMountedFiber(p) == p
	end,
	isMounted = function(p)
		if _G.__DEV__ then
			local current = reactCurrentOwner.current

			if current ~= nil and current.tag == classComponent then
				local stateNode = current.stateNode

				if not stateNode._warnedAboutRefsInRender then
					console.error(
						"%s is accessing isMounted inside its render() function. render() should be a pure function of props and state. It should never access something that requires stale data from the previous render, such as refs. Move this logic to componentDidMount and componentDidUpdate instead.",
						getComponentName(current.type) or "A component"
					)
				end

				stateNode._warnedAboutRefsInRender = true
			end
		end

		local v = get(p)

		if v then
			return getNearestMountedFiber(v) == v
		end

		return false
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function assertIsMounted(return_)
	invariant(getNearestMountedFiber(return_) == return_, "Unable to find node on an unmounted component.")
end

local function findCurrentFiberUsingSlowPath(p)
	local alternate = p.alternate

	if alternate then
		local return_ = alternate
		local v = p

		while true do
			local return_2 = v.return_

			if return_2 == nil then
				break
			end

			local alternate2 = return_2.alternate

			if alternate2 == nil then
				return_ = return_2.return_

				if return_ == nil then
					break
				else
					v = return_
				end
			else
				if return_2.child == alternate2.child then
					local child = return_2.child

					while child do
						if child == v then
							assertIsMounted(return_2) -- equivalent call inferred; original call site unknown
							return p
						end

						if child == return_ then
							assertIsMounted(return_2) -- equivalent call inferred; original call site unknown
							return alternate
						else
							child = child.sibling
						end
					end

					invariant(false, "Unable to find node on an unmounted component.")
				end

				if v.return_ == return_.return_ then
					local child = return_2.child
					local v2 = false

					while child do
						if child == v then
							return_ = alternate2
							v = return_2
							v2 = true
							break
						elseif child == return_ then
							return_ = return_2
							v = alternate2
							v2 = true
							break
						else
							child = child.sibling
						end
					end

					if not v2 then
						local child2 = alternate2.child

						while child2 do
							if child2 == v then
								return_ = return_2
								v = alternate2
								v2 = true
								break
							elseif child2 == return_ then
								return_ = alternate2
								v = return_2
								v2 = true
								break
							else
								child2 = child2.sibling
							end
						end

						invariant(
							v2,
							"Child was not found in either parent set. This indicates a bug in React related to the return pointer. Please file an issue."
						)
					end
				else
					return_ = alternate2
					v = return_2
				end

				invariant(
					v.alternate == return_,
					"Return fibers should always be each others' alternates. This error is likely caused by a bug in React. Please file an issue."
				)
			end
		end

		invariant(v.tag == hostRoot, "Unable to find node on an unmounted component.")

		if v.stateNode.current == v then
			return p
		end

		return alternate
	else
		local nearestMountedFiber = getNearestMountedFiber(p)
		invariant(nearestMountedFiber ~= nil, "Unable to find node on an unmounted component.")

		if nearestMountedFiber == p then
			return p
		end

		return nil
	end
end

ReactFiberTreeReflection.findCurrentFiberUsingSlowPath = findCurrentFiberUsingSlowPath

function ReactFiberTreeReflection.findCurrentHostFiber(p)
	local currentFiberUsingSlowPath = findCurrentFiberUsingSlowPath(p)

	if not currentFiberUsingSlowPath then
		return nil
	end

	local sibling = currentFiberUsingSlowPath

	while true do
		local child = sibling.child

		if sibling.tag == hostComponent or sibling.tag == hostText then
			break
		end

		if child then
			child.return_ = sibling
			sibling = child
		else
			if sibling == currentFiberUsingSlowPath then
				return nil
			end

			local return_ = sibling.return_
			sibling = sibling.sibling

			while not sibling do
				if not return_ or return_ == currentFiberUsingSlowPath then
					return nil
				end
			end

			sibling.return_ = return_
		end
	end

	return sibling
end

function ReactFiberTreeReflection.findCurrentHostFiberWithNoPortals(p)
	local currentFiberUsingSlowPath = findCurrentFiberUsingSlowPath(p)

	if not currentFiberUsingSlowPath then
		return nil
	end

	local sibling = currentFiberUsingSlowPath

	while true do
		local child = sibling.child

		if sibling.tag == hostComponent or sibling.tag == hostText or enableFundamentalAPI and sibling.tag == fundamentalComponent then
			break
		end

		if child and sibling.tag ~= hostPortal then
			child.return_ = sibling
			sibling = child
		else
			if sibling == currentFiberUsingSlowPath then
				return nil
			end

			local return_ = sibling.return_
			sibling = sibling.sibling

			while not sibling do
				if not return_ or return_ == currentFiberUsingSlowPath then
					return nil
				end
			end

			sibling.return_ = return_
		end
	end

	return sibling
end

function ReactFiberTreeReflection.isFiberSuspenseAndTimedOut(p)
	local memoizedState = p.memoizedState
	return p.tag == suspenseComponent and memoizedState ~= nil and memoizedState.dehydrated == nil
end

function ReactFiberTreeReflection.doesFiberContain(p, return_)
	local alternate = p.alternate

	while return_ ~= nil do
		if return_ == p or return_ == alternate then
			return true
		else
			return_ = return_.return_
		end
	end

	return false
end

return ReactFiberTreeReflection