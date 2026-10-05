require(script.Parent:WaitForChild("ReactRobloxHostTypes.roblox"))
require(script.Parent.Parent.Parent:WaitForChild("react-reconciler"))
local shared = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local reactWorkTags = nil
local hostComponent = nil
local hostComponent2 = nil
local hostComponent3 = nil
local hostComponent4 = nil
local getParentSuspenseInstance = nil
local invariant = shared.invariant
local v = {}
local v2 = {}
local v3 = {}
local v4 = string.sub(tostring(math.random()), 3)
local v5 = "__reactFiber$" .. v4
local v6 = "__reactContainer$" .. v4
local ReactRobloxComponentTree = {}

function ReactRobloxComponentTree.precacheFiberNode(p, p2)
	v2[p2] = p
end

function ReactRobloxComponentTree.uncacheFiberNode(p)
	v2[p] = nil
	v3[p] = nil
end

function ReactRobloxComponentTree.markContainerAsRoot(p, p2)
	v[p2] = p
end

function ReactRobloxComponentTree.unmarkContainerAsRoot(p)
	v[p] = nil
end

function ReactRobloxComponentTree.isContainerMarkedAsRoot(p)
	return v[p] and true or false
end

function ReactRobloxComponentTree.getClosestInstanceFromNode(p)
	local v7 = v2[p]

	if v7 then
		return v7
	end

	local parent = p.Parent

	while parent do
		local v8 = v2[parent]

		if v8 then
			local alternate = v8.alternate

			if v8.child == nil and (alternate == nil or alternate.child == nil) then
				return v8
			end

			if getParentSuspenseInstance == nil then
				local ReactRobloxHostConfig = require(script.Parent.ReactRobloxHostConfig)
				getParentSuspenseInstance = ReactRobloxHostConfig.getParentSuspenseInstance
			end

			local parentSuspenseInstance = getParentSuspenseInstance(p)

			while parentSuspenseInstance ~= nil do
				local v9 = v2[parentSuspenseInstance]

				if v9 then
					return v9
				else
					parentSuspenseInstance = getParentSuspenseInstance(parentSuspenseInstance)
				end
			end

			return v8
		else
			p = parent
			parent = parent.Parent
		end
	end

	return nil
end

function ReactRobloxComponentTree.getInstanceFromNode(p)
	if reactWorkTags == nil then
		local ReactReconcilerroblox = require(script.Parent.Parent:WaitForChild("ReactReconciler.roblox"))
		reactWorkTags = ReactReconcilerroblox.ReactWorkTags
		hostComponent = reactWorkTags.HostComponent
		hostComponent2 = reactWorkTags.HostComponent
		hostComponent3 = reactWorkTags.HostComponent
		hostComponent4 = reactWorkTags.HostComponent
	end

	local v7 = p[v5] or p[v6]

	if not v7 then
		return nil
	end

	if v7.tag == hostComponent or v7.tag == hostComponent2 or v7.tag == hostComponent4 or v7.tag == hostComponent3 then
		return v7
	end

	return nil
end

function ReactRobloxComponentTree.getNodeFromInstance(p)
	if p.tag == hostComponent or p.tag == hostComponent2 then
		return p.stateNode
	end

	invariant(false, "getNodeFromInstance: Invalid argument.")
	error("getNodeFromInstance: Invalid argument.")
end

function ReactRobloxComponentTree.getFiberCurrentPropsFromNode(p)
	return v3[p]
end

function ReactRobloxComponentTree.updateFiberProps(p, p2)
	v3[p] = p2
end

return ReactRobloxComponentTree