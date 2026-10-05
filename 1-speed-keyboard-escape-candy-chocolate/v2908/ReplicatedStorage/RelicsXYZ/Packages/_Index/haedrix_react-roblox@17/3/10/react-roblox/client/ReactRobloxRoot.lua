local parent = script.Parent.Parent.Parent
require(script.Parent["ReactRobloxHostTypes.roblox"])
local ReactGlobals = require(parent.ReactGlobals)
require(parent.ReactReconciler)
require(parent.Shared)
require(parent.ReactReconciler)
local ReactRobloxComponentTree = require(script.Parent.ReactRobloxComponentTree)
local markContainerAsRoot = ReactRobloxComponentTree.markContainerAsRoot
local unmarkContainerAsRoot = ReactRobloxComponentTree.unmarkContainerAsRoot
local ReactReconcilerroblox = require(script.Parent.Parent["ReactReconciler.roblox"])
local createContainer = ReactReconcilerroblox.createContainer
local updateContainer = ReactReconcilerroblox.updateContainer
local Shared = require(parent.Shared)
local invariant = Shared.invariant
local Shared2 = require(parent.Shared)
local enableEagerRootListeners = Shared2.ReactFeatureFlags.enableEagerRootListeners
local flushSync = ReactReconcilerroblox.flushSync
local flushPassiveEffects = ReactReconcilerroblox.flushPassiveEffects
local blockingRoot = ReactReconcilerroblox.ReactRootTags.BlockingRoot
local concurrentRoot = ReactReconcilerroblox.ReactRootTags.ConcurrentRoot
local legacyRoot = ReactReconcilerroblox.ReactRootTags.LegacyRoot
local fn
local class = {}
class.__index = class

function class.new(p, p2)
	local self = setmetatable({}, class)
	self._internalRoot = fn(p, concurrentRoot, p2)
	return self
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createBlockingRoot(p, p2, p3)
	local self = setmetatable({}, class)
	self._internalRoot = fn(p, p2, p3)
	return self
end

function class:render(p2)
	updateContainer(p2, self._internalRoot, nil)
end

function class:unmount()
	local _internalRoot = self._internalRoot
	local containerInfo = _internalRoot.containerInfo
	flushSync(function()
		updateContainer(nil, _internalRoot, nil, function()
			unmarkContainerAsRoot(containerInfo)
		end)
	end)
	flushPassiveEffects()
end

fn = function(p, p2, p3)
	local v

	if p3 == nil then
		v = false
	else
		v = p3.hydrate == true
	end

	local hydrationOptions

	if p3 ~= nil then
		hydrationOptions = p3.hydrationOptions
	end

	local mutableSources

	if not (p3 == nil or p3.hydrationOptions == nil) then
		mutableSources = p3.hydrationOptions.mutableSources or nil
	end

	local container = createContainer(p, p2, v, hydrationOptions)
	markContainerAsRoot(container.current, p)
	return container
end

local ReactRobloxRoot = {
	isValidContainer = function(instance)
		return typeof(instance) == "Instance"
	end,
	createRoot = function(instance, p)
		invariant(typeof(instance) == "Instance", "createRoot(...): Target container is not a Roblox Instance.")
		warnIfReactDOMContainerInDEV(instance)
		return class.new(instance, p)
	end,
	createBlockingRoot = function(instance, p)
		invariant(typeof(instance) == "Instance", "createRoot(...): Target container is not a Roblox Instance.")
		warnIfReactDOMContainerInDEV(instance)
		return createBlockingRoot(instance, blockingRoot, p)
	end,
	createLegacyRoot = function(p, p2)
		return createBlockingRoot(p, legacyRoot, p2)
	end
}

function warnIfReactDOMContainerInDEV(_)
	local _ = ReactGlobals.__DEV__
end

return ReactRobloxRoot