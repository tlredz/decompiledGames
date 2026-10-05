local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local error2 = LuauPolyfill.Error
local set = LuauPolyfill.Set
require(parent.Shared)
require(script.Parent.ReactInternalTypes)
require(script.Parent.ReactFiberHostConfig)
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local syncLane = ReactFiberLane.SyncLane
local noTimestamp = ReactFiberLane.NoTimestamp
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local classComponent = ReactWorkTags.ClassComponent
local functionComponent = ReactWorkTags.FunctionComponent
local forwardRef = ReactWorkTags.ForwardRef
local hostComponent = ReactWorkTags.HostComponent
local hostPortal = ReactWorkTags.HostPortal
local hostRoot = ReactWorkTags.HostRoot
local memoComponent = ReactWorkTags.MemoComponent
local simpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local Shared = require(parent.Shared)
local reactSymbols = Shared.ReactSymbols
local REACT_FORWARD_REF_TYPE = reactSymbols.REACT_FORWARD_REF_TYPE
local REACT_MEMO_TYPE = reactSymbols.REACT_MEMO_TYPE
local REACT_LAZY_TYPE = reactSymbols.REACT_LAZY_TYPE
local __DEV__ = ReactGlobals.__DEV__
local v = nil
local v2 = nil
local findChildHostInstancesForFiberShallowly
local findHostInstancesForFiberShallowly
local findHostInstancesForMatchingFibersRecursively
local scheduleFibersWithFamiliesRecursively
local New = {
	setRefreshHandler = function(callback)
		if __DEV__ then
			v = callback
		end
	end,
	resolveFunctionForHotReloading = function(p)
		if not (__DEV__ and v ~= nil) then
			return p
		end

		local v3 = v(p)

		if v3 == nil then
			return p
		end

		return v3.current
	end,
	resolveClassForHotReloading = function(p)
		if not (__DEV__ and v ~= nil) then
			return p
		end

		local v3 = v(p)

		if v3 == nil then
			return p
		end

		return v3.current
	end,
	resolveForwardRefForHotReloading = function(p)
		if not (__DEV__ and v ~= nil) then
			return p
		end

		local v3 = v(p)

		if v3 ~= nil then
			return v3.current
		end

		if p == nil or typeof(p.render) ~= "function" then
			return p
		end

		local render = p.render

		if __DEV__ and v ~= nil then
			local v4 = v(render)

			if v4 ~= nil then
				render = v4.current
			end
		end

		if p.render == render then
			return p
		end

		local v4 = {
			["$$typeof"] = REACT_FORWARD_REF_TYPE,
			render = render,
			displayName = nil
		}

		if p.displayName ~= nil then
			v4.displayName = p.displayName
		end

		return v4
	end,
	isCompatibleFamilyForHotReloading = function(p, p2)
		if not (__DEV__ and v ~= nil) then
			return false
		end

		local elementType = p.elementType
		local type = p2.type
		local typeof2

		if typeof(type) == "table" and type ~= nil then
			typeof2 = type["$$typeof"]
		end

		local tag = p.tag
		local v4

		if tag == classComponent then
			v4 = typeof(type) == "function" or false
		elseif tag == functionComponent then
			v4 = typeof(type) == "function" or (typeof2 == REACT_LAZY_TYPE or false)
		elseif tag == forwardRef then
			v4 = typeof2 == REACT_FORWARD_REF_TYPE or (typeof2 == REACT_LAZY_TYPE or false)
		elseif tag == memoComponent or tag == simpleMemoComponent then
			v4 = typeof2 == REACT_MEMO_TYPE or (typeof2 == REACT_LAZY_TYPE or false)
		else
			return false
		end

		if v4 then
			local v5 = v(elementType)

			if v5 ~= nil and v5 == v(type) then
				return true
			end
		end

		return false
	end,
	markFailedErrorBoundaryForHotReloading = function(p)
		if __DEV__ then
			if v == nil then
				return
			end

			if v2 == nil then
				v2 = set.new()
			end

			v2:add(p)
		end
	end,
	scheduleRefresh = function(p, p2)
		if __DEV__ then
			if v == nil then
				return
			end

			local staleFamilies = p2.staleFamilies
			local updatedFamilies = p2.updatedFamilies
			local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
			local flushPassiveEffects = ReactFiberWorkLoopnew.flushPassiveEffects
			local flushSync = ReactFiberWorkLoopnew.flushSync
			flushPassiveEffects()
			flushSync(function()
				scheduleFibersWithFamiliesRecursively(p.current, updatedFamilies, staleFamilies)
			end)
		end
	end,
	scheduleRoot = function(p, p2)
		if __DEV__ then
			local ReactFiberContextnew = require(script.Parent["ReactFiberContext.new"])
			local emptyContextObject = ReactFiberContextnew.emptyContextObject

			if p.context ~= emptyContextObject then
				return
			end

			local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
			local flushPassiveEffects = ReactFiberWorkLoopnew.flushPassiveEffects
			local flushSync = ReactFiberWorkLoopnew.flushSync
			flushPassiveEffects()
			flushSync(function()
				local ReactFiberReconcilernew = require(script.Parent["ReactFiberReconciler.new"])
				ReactFiberReconcilernew.updateContainer(p2, p, nil, nil)
			end)
		end
	end
}

scheduleFibersWithFamiliesRecursively = function(state, object, object2)
	if __DEV__ then
		local alternate = state.alternate
		local child = state.child
		local sibling = state.sibling
		local tag = state.tag
		local type = state.type
		local render = nil

		if tag == functionComponent or tag == simpleMemoComponent or tag == classComponent then
			render = type
		elseif tag == forwardRef then
			render = type.render
		end

		if v == nil then
			error(error2.new("Expected resolveFamily to be set during hot reload."))
		end

		local v3 = false
		local v4 = false

		if render ~= nil then
			local v5 = v(render)

			if v5 ~= nil then
				if object2:has(v5) then
					v4 = true
				elseif object:has(v5) then
					if tag == classComponent then
						v4 = true
					else
						v3 = true
					end
				end
			end
		end

		local v5 = v2 ~= nil and (v2:has(state) or alternate ~= nil and v2:has(alternate)) and true or v4

		if v5 then
			state._debugNeedsRemount = true
		end

		if v5 or v3 then
			local ReactFiberWorkLoopnew = require(script.Parent["ReactFiberWorkLoop.new"])
			ReactFiberWorkLoopnew.scheduleUpdateOnFiber(state, syncLane, noTimestamp)
		end

		if child ~= nil and not v5 then
			scheduleFibersWithFamiliesRecursively(child, object, object2)
		end

		if sibling ~= nil then
			scheduleFibersWithFamiliesRecursively(sibling, object, object2)
		end
	end
end

function New.findHostInstancesForRefresh(p, p2)
	if not __DEV__ then
		error(error2.new("Did not expect findHostInstancesForRefresh to be called in production."))
		return
	end

	local v3 = set.new()
	local v4 = set.new(array.map(p2, function(p3)
		return p3.current
	end))
	findHostInstancesForMatchingFibersRecursively(p.current, v4, v3)
	return v3
end

findHostInstancesForMatchingFibersRecursively = function(data, object, p)
	if __DEV__ then
		local child = data.child
		local sibling = data.sibling
		local tag = data.tag
		local type = data.type
		local render = nil

		if tag == functionComponent or tag == simpleMemoComponent or tag == classComponent then
			render = type
		elseif tag == forwardRef then
			render = type.render
		end

		if render ~= nil and object:has(render) then
			findHostInstancesForFiberShallowly(data, p)
		elseif child ~= nil then
			findHostInstancesForMatchingFibersRecursively(child, object, p)
		end

		if sibling ~= nil then
			findHostInstancesForMatchingFibersRecursively(sibling, object, p)
		end
	end
end

findHostInstancesForFiberShallowly = function(return_, object)
	if not __DEV__ or findChildHostInstancesForFiberShallowly(return_, object) then
		return
	end

	while true do
		local tag = return_.tag

		if tag == hostComponent then
			break
		end

		if tag == hostPortal then
			object:add(return_.stateNode.containerInfo)
			return
		end

		if tag == hostRoot then
			object:add(return_.stateNode.containerInfo)
			return
		end

		if return_.return_ == nil then
			error(error2.new("Expected to reach root first."))
		end

		return_ = return_.return_
	end

	object:add(return_.stateNode)
end

findChildHostInstancesForFiberShallowly = function(return_, object)
	local child, v3
	local controlFlowState = 16

	while true do
		if controlFlowState == 0 then
			return false
		end

		if controlFlowState == 1 then
			object:add(child.stateNode)
			v3 = true
			controlFlowState = 3
		elseif controlFlowState == 2 then
			if child.child == nil then
				controlFlowState = 14
			else
				controlFlowState = 4
			end
		elseif controlFlowState == 3 then
			if child == return_ then
				controlFlowState = 6
			else
				controlFlowState = 13
			end
		elseif controlFlowState == 4 then
			child.child.return_ = child
			child = child.child
			controlFlowState = 5
		else
			if controlFlowState == 5 then
				controlFlowState = 15
				continue
			end

			if controlFlowState == 6 then
				return v3
			end

			if controlFlowState == 7 then
				if child.sibling == nil then
					controlFlowState = 8
				else
					controlFlowState = 9
				end
			elseif controlFlowState == 8 then
				if child.return_ == nil or child.return_ == return_ then
					controlFlowState = 10
				else
					controlFlowState = 11
				end
			elseif controlFlowState == 9 then
				assert(child.sibling ~= nil, "should be non-nil")
				child.sibling.return_ = child.return_
				child = child.sibling
				controlFlowState = 5
			else
				if controlFlowState == 10 then
					return v3
				end

				if controlFlowState == 11 then
					child = child.return_
					controlFlowState = 7
				elseif controlFlowState == 12 then
					child = return_
					v3 = false
					controlFlowState = 15
				else
					if controlFlowState == 13 then
						controlFlowState = 7
						continue
					end

					if controlFlowState == 14 then
						controlFlowState = 3
						continue
					end

					if controlFlowState == 15 then
						if child.tag == hostComponent then
							controlFlowState = 1
						else
							controlFlowState = 2
						end
					else
						if controlFlowState ~= 16 then
							break
						end

						if __DEV__ then
							controlFlowState = 12
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

return New