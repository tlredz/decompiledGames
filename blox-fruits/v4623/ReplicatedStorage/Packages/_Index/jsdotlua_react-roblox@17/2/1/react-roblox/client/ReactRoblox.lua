require(script.Parent.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactRobloxHostTypes.roblox"))
local ReactRobloxRoot = require(script.Parent:WaitForChild("ReactRobloxRoot"))
local createRoot = ReactRobloxRoot.createRoot
local createBlockingRoot = ReactRobloxRoot.createBlockingRoot
local createLegacyRoot = ReactRobloxRoot.createLegacyRoot
local isValidContainer = ReactRobloxRoot.isValidContainer
local ReactReconcilerroblox = require(script.Parent.Parent:WaitForChild("ReactReconciler.roblox"))
local batchedUpdates = ReactReconcilerroblox.batchedUpdates
local flushSync = ReactReconcilerroblox.flushSync
local injectIntoDevTools = ReactReconcilerroblox.injectIntoDevTools
local flushPassiveEffects = ReactReconcilerroblox.flushPassiveEffects
local isThisRendererActing = ReactReconcilerroblox.IsThisRendererActing
local createPortal = ReactReconcilerroblox.createPortal
local shared = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local reactVersion = shared.ReactVersion
local shared2 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local invariant = shared2.invariant
local shared3 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local enableNewReconciler = shared3.ReactFeatureFlags.enableNewReconciler
local ReactRobloxComponentTree = require(script.Parent:WaitForChild("ReactRobloxComponentTree"))
local getInstanceFromNode = ReactRobloxComponentTree.getInstanceFromNode
local getNodeFromInstance = ReactRobloxComponentTree.getNodeFromInstance
local getFiberCurrentPropsFromNode = ReactRobloxComponentTree.getFiberCurrentPropsFromNode
local getClosestInstanceFromNode = ReactRobloxComponentTree.getClosestInstanceFromNode
local shared4 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local event = shared4.Event
local shared5 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local change = shared5.Change
local shared6 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local ReactRoblox = {
	createPortal = function(p, p2, p3: string?)
		invariant(isValidContainer(p2), "Target container is not a Roblox Instance.")
		return createPortal(p, p2, nil, p3)
	end,
	unstable_batchedUpdates = batchedUpdates,
	flushSync = flushSync,
	__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED = {
		Events = {
			getInstanceFromNode = getInstanceFromNode,
			getNodeFromInstance = getNodeFromInstance,
			getFiberCurrentPropsFromNode = getFiberCurrentPropsFromNode,
			flushPassiveEffects = flushPassiveEffects,
			IsThisRendererActing = isThisRendererActing
		}
	},
	version = reactVersion,
	createRoot = createRoot,
	createBlockingRoot = createBlockingRoot,
	createLegacyRoot = createLegacyRoot,
	Event = event,
	Change = change,
	Tag = shared6.Tag,
	unstable_isNewReconciler = enableNewReconciler,
	act = function(_)
		error("ReactRoblox.act is only available in testing environments, not production. Enable the `__ROACT_17_MOCK_SCHEDULER__` global in your test configuration in order to use `act`.")
	end
}

if _G.__ROACT_17_MOCK_SCHEDULER__ then
	ReactRoblox.act = ReactReconcilerroblox.act
end

injectIntoDevTools({
	findFiberByHostInstance = getClosestInstanceFromNode,
	bundleType = _G.__DEV__ and 1 or 0,
	version = reactVersion,
	rendererPackageName = "ReactRoblox"
})
local _ = _G.__DEV__
ReactRoblox.robloxReactProfiling = ReactReconcilerroblox.robloxReactProfiling
return ReactRoblox