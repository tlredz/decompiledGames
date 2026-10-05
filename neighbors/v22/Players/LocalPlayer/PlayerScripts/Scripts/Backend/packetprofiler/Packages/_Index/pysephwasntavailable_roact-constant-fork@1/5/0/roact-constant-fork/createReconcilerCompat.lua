local Logging = require(script.Parent.Logging)

local function createReconcilerCompat(data)
	return {
		reify = function(...)
			Logging.warnOnce([[
Roact.reify has been renamed to Roact.mount and will be removed in a future release.
Check the call to Roact.reify at:
]])
			return data.mountVirtualTree(...)
		end,
		teardown = function(...)
			Logging.warnOnce([[
Roact.teardown has been renamed to Roact.unmount and will be removed in a future release.
Check the call to Roact.teardown at:
]])
			return data.unmountVirtualTree(...)
		end,
		reconcile = function(...)
			Logging.warnOnce([[
Roact.reconcile has been renamed to Roact.update and will be removed in a future release.
Check the call to Roact.reconcile at:
]])
			return data.updateVirtualTree(...)
		end
	}
end

return createReconcilerCompat