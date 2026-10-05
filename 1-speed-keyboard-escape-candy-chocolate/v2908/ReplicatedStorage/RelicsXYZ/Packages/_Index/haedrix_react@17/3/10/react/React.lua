local parent = script.Parent
local parent2 = parent.Parent
local ReactGlobals = require(parent2.ReactGlobals)
require(parent2.LuauPolyfill)
local ReactMutableSource = require(parent.ReactMutableSource)
local Shared = require(parent2.Shared)
local reactSharedInternals = Shared.ReactSharedInternals
local ReactBaseClasses = require(parent.ReactBaseClasses)
local ReactChildren = require(parent.ReactChildren)
local ReactElementValidator = require(parent.ReactElementValidator)
local ReactElement = require(parent.ReactElement)
local ReactCreateRef = require(parent.ReactCreateRef)
local ReactForwardRef = require(parent.ReactForwardRef)
local ReactHooks = require(parent.ReactHooks)
local ReactMemo = require(parent.ReactMemo)
local ReactContext = require(parent.ReactContext)
local ReactLazy = require(parent.ReactLazy)
local ReactBindingroblox = require(parent["ReactBinding.roblox"])
local Noneroblox = require(parent["None.roblox"])
local Shared2 = require(parent2.Shared)
local reactSymbols = Shared2.ReactSymbols
local __DEV__ = ReactGlobals.__DEV__ or ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
require(parent2.Shared)
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
local Shared3 = require(parent2.Shared)
React.Event = Shared3.Event
local Shared4 = require(parent2.Shared)
React.Change = Shared4.Change
local Shared5 = require(parent2.Shared)
React.Tag = Shared5.Tag
local Shared6 = require(parent2.Shared)
React.unstable_parseReactError = Shared6.parseReactError
return React