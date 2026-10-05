local console = require(script.Parent:WaitForChild("console"))
local ReactSymbols = require(script.Parent:WaitForChild("ReactSymbols"))
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_PORTAL_TYPE = ReactSymbols.REACT_PORTAL_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_PROFILER_TYPE = ReactSymbols.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local REACT_STRICT_MODE_TYPE = ReactSymbols.REACT_STRICT_MODE_TYPE
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = ReactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local REACT_BLOCK_TYPE = ReactSymbols.REACT_BLOCK_TYPE
require(script.Parent:WaitForChild("ReactTypes"))
local ErrorHandlingroblox = require(script.Parent:WaitForChild("ErrorHandling.roblox"))
local describeError = ErrorHandlingroblox.describeError

local function getWrappedName(p, p2, p3: string)
	local v = typeof(p2) ~= "table" and "<function>" or p2.displayName or p2.name or ""
	local displayName = p.displayName

	if not displayName then
		if v == "" then
			displayName = p3
		else
			displayName = string.format("%s(%s)", p3, v) or p3
		end
	end

	return displayName
end

local function getContextName(p)
	return p.displayName or "Context"
end

local getComponentName

getComponentName = function(data)
	if data == nil then
		return nil
	end

	local typeName = typeof(data)

	if _G.__DEV__ and typeName == "table" and typeof(data.tag) == "number" then
		console.warn("Received an unexpected object in getComponentName(). This is likely a bug in React. Please file an issue.")
	end

	if typeName == "function" then
		local v = debug.info(data, "n")

		if v and string.len(v) > 0 then
			return v
		end

		return nil
	else
		if typeName == "string" then
			return data
		end

		if data == REACT_FRAGMENT_TYPE then
			return "Fragment"
		end

		if data == REACT_PORTAL_TYPE then
			return "Portal"
		end

		if data == REACT_PROFILER_TYPE then
			return "Profiler"
		end

		if data == REACT_STRICT_MODE_TYPE then
			return "StrictMode"
		end

		if data == REACT_SUSPENSE_TYPE then
			return "Suspense"
		end

		if data == REACT_SUSPENSE_LIST_TYPE then
			return "SuspenseList"
		end

		if typeName ~= "table" then
			return nil
		end

		local typeof2 = data["$$typeof"]

		if typeof2 == REACT_CONTEXT_TYPE then
			return (data.displayName or "Context") .. ".Consumer"
		end

		if typeof2 == REACT_PROVIDER_TYPE then
			return (data._context.displayName or "Context") .. ".Provider"
		end

		if typeof2 == REACT_FORWARD_REF_TYPE then
			local render = data.render
			local v = typeof(render) ~= "table" and "<function>" or render.displayName or render.name or ""
			return data.displayName or v ~= "" and string.format("%s(%s)", "ForwardRef", v) or "ForwardRef"
		else
			if typeof2 == REACT_MEMO_TYPE then
				return getComponentName(data.type)
			end

			if typeof2 == REACT_BLOCK_TYPE then
				return getComponentName(data._render)
			end

			if typeof2 == REACT_LAZY_TYPE then
				local _payload = data._payload
				local _init = data._init
				local v, v2 = xpcall(_init, describeError, _payload)

				if v then
					return getComponentName(v2)
				end

				return nil
			else
				if data.displayName then
					return data.displayName
				end

				if data.name then
					return data.name
				end

				local metatable = getmetatable(data)

				if metatable and rawget(metatable, "__tostring") then
					return (tostring(data))
				end
			end
		end

		return nil
	end
end

return getComponentName