local __DEV__ = _G.__DEV__
local __COMPAT_WARNINGS__ = _G.__COMPAT_WARNINGS__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent.Parent:WaitForChild("shared"))
local ReactNoopUpdateQueue = require(script.Parent:WaitForChild("ReactNoopUpdateQueue"))
local refs = {}

if __DEV__ then
	object.freeze(refs)
end

local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local uninitializedState = shared2.UninitializedState

local function trimPath(value: string)
	local v2 = string.match(value, "%.%u[%.%w]-$")

	if v2 then
		return string.gsub(v2, "^%.", "")
	end

	return value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function warnAboutExistingLifecycle(__componentName, p, p2)
	console.warn(
		"%s already defined '%s', but it also defining the deprecated Roact method '%s'. %s should only implement one of these methods, preferably using the non-deprecated name.",
		__componentName,
		p2,
		p,
		__componentName
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function warnAboutDeprecatedLifecycleName(__componentName, p, p2)
	if __DEV__ and __COMPAT_WARNINGS__ then
		local v2, v3 = debug.info(3, "sln")
		local warn = console.warn
		local v5 = string.match(v2, "%.%u[%.%w]-$")

		if v5 then
			v2 = string.gsub(v5, "^%.", "")
		end

		warn([[
%s is using method '%s', which is no longer supported and should be updated to '%s'
File: %s:%s]], __componentName, p, p2, v2, (tostring(v3)))
	end
end

local v2 = {
	didMount = "componentDidMount",
	shouldUpdate = "shouldComponentUpdate",
	willUpdate = "UNSAFE_componentWillUpdate",
	didUpdate = "componentDidUpdate",
	willUnmount = "componentWillUnmount"
}

local function handleNewLifecycle(p, p2, p3)
	if v2[p2] ~= nil then
		if p[v2[p2]] == nil then
			if p2 == "willUpdate" and p.componentWillUpdate then
				warnAboutExistingLifecycle(p.__componentName, "willUpdate", "UNSAFE_componentWillUpdate") -- equivalent call inferred; original call site unknown
			else
				warnAboutDeprecatedLifecycleName(p.__componentName, p2, v2[p2]) -- equivalent call inferred; original call site unknown
			end
		else
			warnAboutExistingLifecycle(p.__componentName, p2, v2[p2]) -- equivalent call inferred; original call site unknown
		end

		p2 = v2[p2]
	end

	rawset(p, p2, p3)
end

local object2 = setmetatable({
	__componentName = "Component"
}, {
	__newindex = handleNewLifecycle,
	__index = {
		isReactComponent = true
	},
	__tostring = function(p)
		return p.__componentName
	end
})
local v3 = _G.__TESTEZ_RUNNING_TEST__ and 0 or 900
local v4 = table.create(v3)
local v5 = 1

for _ = 1, v3 do
	table.insert(v4, {
		props = nil,
		context = nil,
		state = uninitializedState,
		__refs = refs,
		__updater = ReactNoopUpdateQueue
	})
end

local function setStateInInit(state, callback, p: nil)
	if __DEV__ and p ~= nil then
		console.warn([[
Received a `callback` argument to `setState` during initialization of "%s". The callback behavior is not supported when using `setState` in `init`.

Consider defining similar behavior in a `compontentDidMount` method instead.]], state.__componentName)
	end

	local typeName = callback and type(callback)

	if callback == nil or typeName ~= "table" and typeName ~= "function" then
		error("setState(...): takes an object of state variables to update or a function which returns an object of state variables.")
	end

	local state2 = state.state

	if typeName == "function" then
		callback = callback(state2, state.props)
	end

	state.state = object.assign({}, state2, callback)
end

function object2:extend(componentName)
	if componentName == nil then
		if __COMPAT_WARNINGS__ then
			console.warn("Component:extend() accepting no arguments is deprecated, and will not be supported in a future version of Roact. Please provide an explicit name.")
		end

		componentName = ""
	elseif type(componentName) ~= "string" then
		error("Component class name must be a string")
	end

	local v6 = {
		__componentName = componentName,
		setState = self.setState,
		forceUpdate = self.forceUpdate,
		init = nil
	}
	v6.__index = v6

	function v6.__ctor(props, context, p2)
		local v7

		if v5 <= v3 then
			v7 = v4[v5]
			v7.props = props
			v7.context = context
			v4[v5] = nil
			v5 += 1
		else
			v7 = {
				props = props,
				context = context,
				state = uninitializedState,
				__refs = refs,
				__updater = p2 or ReactNoopUpdateQueue
			}
		end

		local object3 = setmetatable(v7, v6)

		if v6.init and type(v6.init) == "function" then
			object3.setState = setStateInInit
			v6.init(object3, props, context)
			object3.setState = nil
		end

		return object3
	end

	setmetatable(v6, (getmetatable(self)))
	return v6
end

function object2:setState(value, p2)
	if value ~= nil and type(value) ~= "table" and type(value) ~= "function" then
		error("setState(...): takes an object of state variables to update or a function which returns an object of state variables.")
	end

	self.__updater.enqueueSetState(self, value, p2, "setState")
end

function object2:forceUpdate(p2)
	self.__updater.enqueueForceUpdate(self, p2, "forceUpdate")
end

if __DEV__ then
	local v6 = {
		isMounted = {
			"isMounted",
			"Instead, make sure to clean up subscriptions and pending requests in componentWillUnmount to prevent memory leaks."
		},
		replaceState = {
			"replaceState",
			"Refactor your code to use setState instead (see https://github.com/facebook/react/issues/3236)."
		}
	}

	for k, _ in v6 do
		if v6[k] == nil then
			continue
		end

		local v8 = v6[k]

		object2[k] = function()
			console.warn("%s(...) is deprecated in plain JavaScript React classes. %s", v8[1], v8[2])
			return nil
		end
	end
end

local extended = object2:extend("PureComponent")
extended.extend = object2.extend
setmetatable(extended, {
	__newindex = handleNewLifecycle,
	__index = {
		isReactComponent = true,
		isPureReactComponent = true
	},
	__tostring = function(p)
		return p.__componentName
	end
})
return {
	Component = object2,
	PureComponent = extended
}