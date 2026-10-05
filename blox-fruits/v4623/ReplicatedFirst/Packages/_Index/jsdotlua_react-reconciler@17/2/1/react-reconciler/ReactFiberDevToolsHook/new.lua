local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local New = {}

local function isCallable(value)
	if typeof(value) == "function" then
		return true
	end

	if typeof(value) ~= "table" then
		return false
	end

	local metatable = getmetatable(value)

	if metatable and rawget(metatable, "__call") or value._isMockFunction then
		return true
	end

	return false
end

local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local enableProfilerTimer = shared2.ReactFeatureFlags.enableProfilerTimer
require(script.Parent:WaitForChild("ReactInternalTypes"))
require(script.Parent.Parent:WaitForChild("shared"))
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local didCapture = ReactFiberFlags.DidCapture
local v = nil
local v2 = nil
local v3 = false

function New.isDevToolsPresent()
	return _G.__REACT_DEVTOOLS_GLOBAL_HOOK__ ~= nil
end

function New.injectInternals(p)
	if _G.__REACT_DEVTOOLS_GLOBAL_HOOK__ == nil then
		return false
	end

	local __REACT_DEVTOOLS_GLOBAL_HOOK__ = _G.__REACT_DEVTOOLS_GLOBAL_HOOK__

	if __REACT_DEVTOOLS_GLOBAL_HOOK__.isDisabled then
		return true
	end

	if __REACT_DEVTOOLS_GLOBAL_HOOK__.supportsFiber then
		local success, result = pcall(function()
			v = __REACT_DEVTOOLS_GLOBAL_HOOK__.inject(p)
			v2 = __REACT_DEVTOOLS_GLOBAL_HOOK__
		end)

		if not success and _G.__DEV__ then
			console.error("React instrumentation encountered an error: %s.", result)
		end

		return true
	else
		if _G.__DEV__ then
			console.error("The installed version of React DevTools is too old and will not work with the current version of React. Please update React DevTools. https://reactjs.org/link/react-devtools")
		end

		return true
	end
end

function New.onScheduleRoot(p, p2)
	if _G.__DEV__ and v2 then
		local onScheduleFiberRoot = v2.onScheduleFiberRoot
		local v4

		if typeof(onScheduleFiberRoot) == "function" then
			v4 = true
		elseif typeof(onScheduleFiberRoot) == "table" then
			local metatable = getmetatable(onScheduleFiberRoot)
			v4 = metatable and rawget(metatable, "__call") and true or onScheduleFiberRoot._isMockFunction and true or false
		else
			v4 = false
		end

		if v4 then
			local success, result = pcall(v2.onScheduleFiberRoot, v, p, p2)

			if not success and _G.__DEV__ and not v3 then
				v3 = true
				console.error("React instrumentation encountered an error: %s", result)
			end
		end
	end
end

function New.onCommitRoot(p, p2)
	if v2 then
		local onCommitFiberRoot = v2.onCommitFiberRoot
		local v4

		if typeof(onCommitFiberRoot) == "function" then
			v4 = true
		elseif typeof(onCommitFiberRoot) == "table" then
			local metatable = getmetatable(onCommitFiberRoot)
			v4 = metatable and rawget(metatable, "__call") and true or onCommitFiberRoot._isMockFunction and true or false
		else
			v4 = false
		end

		if v4 then
			local success, result = pcall(function()
				local v5 = bit32.band(p.current.flags, didCapture) == didCapture

				if enableProfilerTimer then
					v2.onCommitFiberRoot(v, p, p2, v5)
				else
					v2.onCommitFiberRoot(v, p, nil, v5)
				end
			end)

			if not success and _G.__DEV__ and not v3 then
				v3 = true
				console.error("React instrumentation encountered an error: %s", result)
			end
		end
	end
end

function New.onCommitUnmount(p)
	if v2 then
		local onCommitFiberUnmount = v2.onCommitFiberUnmount
		local v4

		if typeof(onCommitFiberUnmount) == "function" then
			v4 = true
		elseif typeof(onCommitFiberUnmount) == "table" then
			local metatable = getmetatable(onCommitFiberUnmount)
			v4 = metatable and rawget(metatable, "__call") and true or onCommitFiberUnmount._isMockFunction and true or false
		else
			v4 = false
		end

		if v4 then
			local success, result = pcall(v2.onCommitFiberUnmount, v, p)

			if not success and _G.__DEV__ and not v3 then
				v3 = true
				console.error("React instrumentation encountered an error: %s", result)
			end
		end
	end
end

return New