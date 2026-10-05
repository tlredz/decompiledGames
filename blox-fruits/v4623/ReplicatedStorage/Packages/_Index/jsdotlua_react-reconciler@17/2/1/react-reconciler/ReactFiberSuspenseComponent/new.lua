require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberHostConfig = require(script.Parent:WaitForChild("ReactFiberHostConfig"))
require(script.Parent:WaitForChild("ReactFiberLane"))
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local suspenseComponent = ReactWorkTags.SuspenseComponent
local suspenseListComponent = ReactWorkTags.SuspenseListComponent
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local noFlags = ReactFiberFlags.NoFlags
local didCapture = ReactFiberFlags.DidCapture
local isSuspenseInstancePending = ReactFiberHostConfig.isSuspenseInstancePending
local isSuspenseInstanceFallback = ReactFiberHostConfig.isSuspenseInstanceFallback
local New = {}

function New.shouldCaptureSuspense(p, flag: boolean)
	local memoizedState = p.memoizedState

	if memoizedState then
		return memoizedState.dehydrated ~= nil
	end

	local memoizedProps = p.memoizedProps
	return memoizedProps.fallback ~= nil and (memoizedProps.unstable_avoidThisFallback ~= true or not flag)
end

function New.findFirstSuspended(p)
	local return_ = p

	while return_ ~= nil do
		if return_.tag == suspenseComponent then
			local memoizedState = return_.memoizedState

			if memoizedState then
				local dehydrated = memoizedState.dehydrated

				if dehydrated == nil or isSuspenseInstancePending(dehydrated) or isSuspenseInstanceFallback(dehydrated) then
					return return_
				end
			end

			if return_ == p then
				return nil
			end

			while return_.sibling == nil do
				if return_.return_ == nil or return_.return_ == p then
					return nil
				else
					return_ = return_.return_
				end
			end

			return_.sibling.return_ = return_.return_
			return_ = return_.sibling
		elseif return_.tag == suspenseListComponent and return_.memoizedProps.revealOrder ~= nil then
			if bit32.band(return_.flags, didCapture) ~= noFlags then
				return return_
			end

			if return_ == p then
				return nil
			end

			while return_.sibling == nil do
				if return_.return_ == nil or return_.return_ == p then
					return nil
				else
					return_ = return_.return_
				end
			end

			return_.sibling.return_ = return_.return_
			return_ = return_.sibling
		elseif return_.child == nil then
			if return_ == p then
				return nil
			end

			while return_.sibling == nil do
				if return_.return_ == nil or return_.return_ == p then
					return nil
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

	return nil
end

return New