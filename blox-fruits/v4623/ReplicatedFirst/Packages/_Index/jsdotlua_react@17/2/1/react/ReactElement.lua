local __DEV__ = _G.__DEV__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local error2 = luaupolyfill.Error
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactLazy"))
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared2.getComponentName
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local REACT_ELEMENT_TYPE = shared3.ReactSymbols.REACT_ELEMENT_TYPE
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local reactCurrentOwner = shared4.ReactSharedInternals.ReactCurrentOwner
local v = {
	key = true,
	ref = true,
	__self = true,
	__source = true
}
local v2 = nil
local v3 = nil
local v4 = __DEV__ and {} or nil

-- equivalent calls inferred from this helper; original call sites unknown
local function hasValidRef(data)
	if __DEV__ and data.ref ~= nil and type(data.ref) == "table" and data.ref.isReactWarning then
		return false
	end

	return data.ref ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasValidKey(data)
	if __DEV__ and data.key ~= nil and type(data.key) == "table" and data.key.isReactWarning then
		return false
	end

	return data.key ~= nil
end

local v5 = {
	isReactWarning = true
}

local function defineKeyPropWarningGetter(p, displayName: string)
	p.key = nil
	setmetatable(p, {
		__index = function(_, p2)
			if p2 ~= "key" then
				return nil
			end

			if __DEV__ and not v2 then
				v2 = true
				console.error(
					"%s: `key` is not a prop. Trying to access it will result in `nil` being returned. If you need to access the same value within the child component, you should pass it as a different prop. (https://reactjs.org/link/special-props)",
					displayName
				)
			end

			return v5
		end
	})
end

local function defineRefPropWarningGetter(p, displayName: string)
	p.ref = nil
	setmetatable(p, {
		__index = function(_, p2)
			if p2 ~= "ref" then
				return nil
			end

			if __DEV__ and not v3 then
				v3 = true
				console.error(
					"%s: `ref` is not a prop. Trying to access it will result in `nil` being returned. If you need to access the same value within the child component, you should pass it as a different prop. (https://reactjs.org/link/special-props)",
					displayName
				)
			end

			return v5
		end
	})
end

local function warnIfStringRefCannotBeAutoConverted(data)
	if __DEV__ and type(data.ref) == "string" and reactCurrentOwner.current then
		local componentName = getComponentName(reactCurrentOwner.current.type)

		if not v4[componentName] then
			error(string.format(
				"Component \"%s\" contains the string ref \"%s\". Support for string refs has been removed. We recommend using useRef() or createRef() instead. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-string-ref",
				componentName or "Unknown",
				data.ref
			))
		end
	end
end

local function ReactElement2(p, p2, ref, p3, source, owner, props)
	local v6 = {
		type = p,
		key = p2,
		ref = ref,
		props = props,
		_owner = owner,
		["$$typeof"] = REACT_ELEMENT_TYPE
	}

	if __DEV__ then
		local v7 = {
			validated = false
		}
		v6._store = setmetatable({}, {
			__index = v7,
			__newindex = function(p7, p8, validated)
				if p8 == "validated" then
					v7.validated = validated
				else
					rawset(p7, p8, validated)
				end
			end
		})
		setmetatable(v6, {
			__index = {
				_self = p3,
				_source = source
			}
		})
	end

	return v6
end

local ReactElement = {}

function ReactElement.jsx(_, _, _)
	error("JSX is currently unsupported")
end

function ReactElement.jsxDEV(_, _, _, _, _)
	error("JSX is currently unsupported")
	return nil
end

function ReactElement.createElement(value, data, ...)
	local props = data == nil and {} or table.clone(data)
	local key = nil
	local ref = nil
	local __source

	if data ~= nil then
		-- equivalent call inferred; original call site unknown
		if hasValidRef(data) then
			ref = data.ref

			if __DEV__ then
				warnIfStringRefCannotBeAutoConverted(data)
			end
		end

		-- equivalent call inferred; original call site unknown
		if hasValidKey(data) then
			key = data.key

			if type(key) ~= "number" then
				key = tostring(key)
			end
		end

		if data.__source ~= nil then
			__source = data.__source
		end

		if props.key ~= nil then
			props.key = nil
		end

		if props.ref ~= nil then
			props.ref = nil
		end

		if props.__self ~= nil then
			props.__self = nil
		end

		if props.__source ~= nil then
			props.__source = nil
		end
	end

	local v7 = select("#", ...)

	if v7 == 1 then
		props.children = select(1, ...)
	elseif v7 > 1 then
		local children = table.create(v7)

		for i = 1, v7 do
			table.insert(children, (select(i, ...)))
		end

		if __DEV__ then
			table.freeze(children)
		end

		props.children = children
	end

	if type(value) == "table" and value.defaultProps then
		local defaultProps = value.defaultProps

		for k, _ in defaultProps do
			if props[k] == nil then
				props[k] = defaultProps[k]
			end
		end
	end

	if not __DEV__ then
		return (ReactElement2(value, key, ref, nil, __source, reactCurrentOwner.current, props))
	end

	if key or ref then
		local displayName

		if type(value) == "function" then
			displayName = debug.info(value, "n") or "<function>"
		elseif type(value) == "table" then
			displayName = value.displayName or value.name or "Unknown"
		else
			displayName = value
		end

		if key then
			defineKeyPropWarningGetter(props, displayName)
		end

		if ref then
			defineRefPropWarningGetter(props, displayName)
		end
	end

	__source = __source == nil and {
		fileName = debug.info(3, "s"),
		lineNumber = debug.info(3, "l")
	} or __source
	return (ReactElement2(value, key, ref, nil, __source, reactCurrentOwner.current, props))
end

function ReactElement:cloneAndReplaceKey(p)
	return (ReactElement2(self.type, p, self.ref, self._self, self._source, self._owner, self.props))
end

function ReactElement:cloneElement(p, ...)
	if self == nil then
		error(error2.new("React.cloneElement(...): The argument must be a React element, but you passed " .. tostring(nil)))
	end

	local props = self.props
	local props2 = props == nil and {} or table.clone(props)
	local key = self.key
	local ref = self.ref
	local _source = self._source
	local _owner = self._owner

	if p ~= nil then
		local ref2 = p.ref

		if ref2 == nil then
			if not __DEV__ or p.ref == nil or type(p.ref) ~= "table" or not p.ref.isReactWarning then
				local _ = p.ref == nil
			end
		else
			_owner = reactCurrentOwner.current
			ref = ref2
		end

		local key2 = p.key

		if key2 == nil then
			if not __DEV__ or p.key == nil or type(p.key) ~= "table" or not p.key.isReactWarning then
				local _ = p.key == nil
			end
		elseif type(key2) == "number" then
			key = key2
		else
			key = key2 or "nil"
		end
	end

	local type2 = self.type
	local defaultProps

	if type(type2) == "table" then
		defaultProps = type2.defaultProps
	end

	if p ~= nil then
		for k, _ in p do
			if p[k] == nil or v[k] then
				continue
			end

			if p[k] == nil and defaultProps ~= nil then
				props2[k] = defaultProps[k]
			else
				props2[k] = p[k]
			end
		end
	end

	local v7 = select("#", ...)

	if v7 == 1 then
		props2.children = select(1, ...)
	elseif v7 > 1 then
		props2.children = { ... }
	end

	return (ReactElement2(self.type, key, ref, nil, _source, _owner, props2))
end

function ReactElement.isValidElement(p)
	return type(p) == "table" and p["$$typeof"] == REACT_ELEMENT_TYPE
end

return ReactElement