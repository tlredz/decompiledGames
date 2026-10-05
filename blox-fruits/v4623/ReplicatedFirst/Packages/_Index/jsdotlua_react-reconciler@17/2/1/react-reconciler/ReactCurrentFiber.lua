local __DEV__ = _G.__DEV__
require(script.Parent:WaitForChild("ReactInternalTypes"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local reactSharedInternals = shared.ReactSharedInternals
local ReactFiberComponentStack = require(script.Parent:WaitForChild("ReactFiberComponentStack"))
local getStackByFiberInDevAndProd = ReactFiberComponentStack.getStackByFiberInDevAndProd
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared2.getComponentName
local reactDebugCurrentFrame = reactSharedInternals.ReactDebugCurrentFrame
local ReactCurrentFiber = {
	current = nil,
	isRendering = false
}

function ReactCurrentFiber.getCurrentFiberOwnerNameInDevOrNull()
	if not (__DEV__ and ReactCurrentFiber.current ~= nil) then
		return nil
	end

	local _debugOwner = ReactCurrentFiber.current._debugOwner

	if _debugOwner then
		return getComponentName(_debugOwner.type)
	end

	return nil
end

local function getCurrentFiberStackInDev()
	if not (__DEV__ and ReactCurrentFiber.current ~= nil) then
		return ""
	end

	return getStackByFiberInDevAndProd(ReactCurrentFiber.current)
end

function ReactCurrentFiber.resetCurrentFiber()
	if __DEV__ then
		reactDebugCurrentFrame.getCurrentStack = nil
		ReactCurrentFiber.current = nil
		ReactCurrentFiber.isRendering = false
	end
end

function ReactCurrentFiber.setCurrentFiber(current)
	if __DEV__ then
		reactDebugCurrentFrame.getCurrentStack = getCurrentFiberStackInDev
		ReactCurrentFiber.current = current
		ReactCurrentFiber.isRendering = false
	end
end

function ReactCurrentFiber.setIsRendering(isRendering: boolean)
	if __DEV__ then
		ReactCurrentFiber.isRendering = isRendering
	end
end

function ReactCurrentFiber.getIsRendering()
	if __DEV__ then
		return ReactCurrentFiber.isRendering
	end

	return false
end

return ReactCurrentFiber