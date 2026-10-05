local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local v = {}

local function warnNoop(p, p2: string)
	if _G.__DEV__ then
		local __componentName = p.__componentName or "ReactClass"
		local v2 = __componentName .. "." .. p2

		if v[v2] then
			return
		end

		console.error(
			"Can't call %s on a component that is not yet mounted. This is a no-op, but it might indicate a bug in your application. Instead, assign to `self.state` directly with the desired state in the %s component's `init` method.",
			p2,
			__componentName
		)
		v[v2] = true
	end
end

local ReactNoopUpdateQueue = {}

function ReactNoopUpdateQueue.isMounted(_)
	return false
end

function ReactNoopUpdateQueue.enqueueForceUpdate(p, _, _)
	if _G.__DEV__ then
		local __componentName = p.__componentName or "ReactClass"
		local v2 = __componentName .. ".forceUpdate"

		if v[v2] then
			return
		end

		console.error(
			"Can't call %s on a component that is not yet mounted. This is a no-op, but it might indicate a bug in your application. Instead, assign to `self.state` directly with the desired state in the %s component's `init` method.",
			"forceUpdate",
			__componentName
		)
		v[v2] = true
	end
end

function ReactNoopUpdateQueue.enqueueReplaceState(p, _, _, _)
	if _G.__DEV__ then
		local __componentName = p.__componentName or "ReactClass"
		local v2 = __componentName .. ".replaceState"

		if v[v2] then
			return
		end

		console.error(
			"Can't call %s on a component that is not yet mounted. This is a no-op, but it might indicate a bug in your application. Instead, assign to `self.state` directly with the desired state in the %s component's `init` method.",
			"replaceState",
			__componentName
		)
		v[v2] = true
	end
end

function ReactNoopUpdateQueue.enqueueSetState(p, _, _, _)
	if _G.__DEV__ then
		local __componentName = p.__componentName or "ReactClass"
		local v2 = __componentName .. ".setState"

		if v[v2] then
			return
		end

		console.error(
			"Can't call %s on a component that is not yet mounted. This is a no-op, but it might indicate a bug in your application. Instead, assign to `self.state` directly with the desired state in the %s component's `init` method.",
			"setState",
			__componentName
		)
		v[v2] = true
	end
end

return ReactNoopUpdateQueue