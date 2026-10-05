require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local ReactMutableSource = require(script.Parent:WaitForChild("ReactMutableSource"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local reactSharedInternals = shared.ReactSharedInternals
local ReactBaseClasses = require(script.Parent:WaitForChild("ReactBaseClasses"))
local ReactChildren = require(script.Parent:WaitForChild("ReactChildren"))
local ReactElementValidator = require(script.Parent:WaitForChild("ReactElementValidator"))
local ReactElement = require(script.Parent:WaitForChild("ReactElement"))
local ReactCreateRef = require(script.Parent:WaitForChild("ReactCreateRef"))
local ReactForwardRef = require(script.Parent:WaitForChild("ReactForwardRef"))
local ReactHooks = require(script.Parent:WaitForChild("ReactHooks"))
local ReactMemo = require(script.Parent:WaitForChild("ReactMemo"))
local ReactContext = require(script.Parent:WaitForChild("ReactContext"))
local ReactLazy = require(script.Parent:WaitForChild("ReactLazy"))
local ReactBindingroblox = require(script.Parent:WaitForChild("ReactBinding.roblox"))
local Noneroblox = require(script.Parent:WaitForChild("None.roblox"))
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared2.ReactSymbols
local __DEV__ = _G.__DEV__ or _G.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
require(script.Parent.Parent:WaitForChild("shared"))
local createElementWithValidation

if __DEV__ then
	createElementWithValidation = ReactElementValidator.createElementWithValidation
else
	createElementWithValidation = ReactElement.createElement
end

local cloneElement

if __DEV__ then
	cloneElement = ReactElementValidator.cloneElementWithValidation
else
	cloneElement = ReactElement.cloneElement
end

local React = {
	Children = ReactChildren,
	createMutableSource = ReactMutableSource,
	createRef = ReactCreateRef.createRef,
	Component = ReactBaseClasses.Component,
	PureComponent = ReactBaseClasses.PureComponent,
	createContext = ReactContext.createContext,
	forwardRef = ReactForwardRef.forwardRef,
	lazy = ReactLazy.lazy,
	memo = ReactMemo.memo,
	useCallback = ReactHooks.useCallback,
	useContext = ReactHooks.useContext,
	useEffect = ReactHooks.useEffect,
	useImperativeHandle = ReactHooks.useImperativeHandle,
	useDebugValue = ReactHooks.useDebugValue,
	useLayoutEffect = ReactHooks.useLayoutEffect,
	useMemo = ReactHooks.useMemo,
	useMutableSource = ReactHooks.useMutableSource,
	useReducer = ReactHooks.useReducer,
	useRef = ReactHooks.useRef,
	useBinding = ReactHooks.useBinding,
	useState = ReactHooks.useState,
	Fragment = reactSymbols.REACT_FRAGMENT_TYPE,
	Profiler = reactSymbols.REACT_PROFILER_TYPE,
	StrictMode = reactSymbols.REACT_STRICT_MODE_TYPE,
	unstable_DebugTracingMode = reactSymbols.REACT_DEBUG_TRACING_MODE_TYPE,
	Suspense = reactSymbols.REACT_SUSPENSE_TYPE,
	createElement = createElementWithValidation,
	cloneElement = cloneElement,
	isValidElement = ReactElement.isValidElement,
	__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED = reactSharedInternals,
	unstable_LegacyHidden = reactSymbols.REACT_LEGACY_HIDDEN_TYPE,
	createBinding = ReactBindingroblox.create,
	joinBindings = ReactBindingroblox.join,
	None = Noneroblox,
	__subscribeToBinding = ReactBindingroblox.subscribe
}
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
React.Event = shared3.Event
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
React.Change = shared4.Change
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
React.Tag = shared5.Tag
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
React.unstable_parseReactError = shared6.parseReactError
return React