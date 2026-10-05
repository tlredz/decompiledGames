local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local Shared = require(parent.Shared)
local console = Shared.console
require(parent.Shared)
require(parent.Shared)
local Shared2 = require(parent.Shared)
local reactCurrentDispatcher = Shared2.ReactSharedInternals.ReactCurrentDispatcher

local function resolveDispatcher()
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current
end

local ReactHooks = {}

function ReactHooks.useContext(p, value, ...)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	if not ReactGlobals.__DEV__ then
		return current.useContext(p, value)
	end

	if value ~= nil then
		console.error(
			"useContext() second argument is reserved for future use in React. Passing it is not supported. You passed: %s.%s",
			value,
			typeof(value) == "number" and array.isArray({ ... }) and [[


Did you call Array.map(useContext)? Calling Hooks inside a loop is not supported. Learn more at https://reactjs.org/link/rules-of-hooks]] or ""
		)
	end

	if p._context == nil then
		return current.useContext(p, value)
	end

	local _context = p._context

	if _context.Consumer == p then
		console.error("Calling useContext(Context.Consumer) is not supported, may cause bugs, and will be removed in a future major release. Did you mean to call useContext(Context) instead?")
	elseif _context.Provider == p then
		console.error("Calling useContext(Context.Provider) is not supported. Did you mean to call useContext(Context) instead?")
	end

	return current.useContext(p, value)
end

function ReactHooks.useState(p, ...)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useState(p, ...)
end

function ReactHooks.useReducer(callback, p, callback2)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useReducer(callback, p, callback2)
end

function ReactHooks.useRef(p)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useRef(p)
end

function ReactHooks.useBinding(p)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useBinding(p)
end

function ReactHooks.useEffect(callback, p)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useEffect(callback, p)
end

function ReactHooks.useLayoutEffect(callback, p)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useLayoutEffect(callback, p)
end

function ReactHooks.useCallback(p, p2)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useCallback(p, p2)
end

function ReactHooks.useMemo(callback, p)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useMemo(callback, p)
end

function ReactHooks.useImperativeHandle(p, callback, p2)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useImperativeHandle(p, callback, p2)
end

function ReactHooks.useDebugValue(p, callback)
	if not ReactGlobals.__DEV__ then
		return nil
	end

	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useDebugValue(p, callback)
end

ReactHooks.emptyObject = {}

function ReactHooks.useOpaqueIdentifier()
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useOpaqueIdentifier()
end

function ReactHooks.useMutableSource(p, p2, p3)
	local current = reactCurrentDispatcher.current

	if ReactGlobals.__DEV__ and current == nil then
		console.error([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end

	return current.useMutableSource(p, p2, p3)
end

return ReactHooks