local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local array = luaupolyfill.Array
local boolean = luaupolyfill.Boolean
local object = luaupolyfill.Object
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local inspect = luaupolyfill.util.inspect
require(script.Parent.Parent:WaitForChild("shared"))
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local isValidElementType = shared2.isValidElementType
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared3.getComponentName
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared4.ReactSymbols
local getIteratorFn = reactSymbols.getIteratorFn
local _ = reactSymbols.REACT_FORWARD_REF_TYPE
local _ = reactSymbols.REACT_MEMO_TYPE
local REACT_FRAGMENT_TYPE = reactSymbols.REACT_FRAGMENT_TYPE
local REACT_ELEMENT_TYPE = reactSymbols.REACT_ELEMENT_TYPE
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local warnAboutSpreadingKeyToJSX = shared5.ReactFeatureFlags.warnAboutSpreadingKeyToJSX
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
local checkPropTypes = shared6.checkPropTypes
local shared7 = require(script.Parent.Parent:WaitForChild("shared"))
local reactCurrentOwner = shared7.ReactSharedInternals.ReactCurrentOwner
local ReactElement = require(script.Parent:WaitForChild("ReactElement"))
local isValidElement = ReactElement.isValidElement
local createElement = ReactElement.createElement
local cloneElement = ReactElement.cloneElement
local jsxDEV = ReactElement.jsxDEV
local shared8 = require(script.Parent.Parent:WaitForChild("shared"))
local setExtraStackFrame = shared8.ReactSharedInternals.ReactDebugCurrentFrame.setExtraStackFrame
local shared9 = require(script.Parent.Parent:WaitForChild("shared"))
local describeUnknownElementTypeFrameInDEV = shared9.ReactComponentStackFrame.describeUnknownElementTypeFrameInDEV

-- equivalent calls inferred from this helper; original call sites unknown
local function setCurrentlyValidatingElement(data)
	if _G.__DEV__ then
		if data then
			local _owner = data._owner
			local v

			if _owner then
				v = _owner.type
			end

			setExtraStackFrame((describeUnknownElementTypeFrameInDEV(data.type, data._source, v)))
		else
			setExtraStackFrame(nil)
		end
	end
end

local v

if _G.__DEV__ then
	v = false
else
	v = nil
end

local function hasOwnProperty(p, p2)
	return p[p2] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDeclarationErrorAddendum()
	local v2 = reactCurrentOwner.current and getComponentName(reactCurrentOwner.current.type)

	if v2 then
		return [[


Check the render method of `]] .. v2 .. "`."
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSourceInfoErrorAddendum(p)
	if p == nil then
		return ""
	end

	return [[


Check your code at ]] .. string.gsub(p.fileName, "^.*[\\/]", "") .. ":" .. p.lineNumber .. "."
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSourceInfoErrorAddendumForProps(p)
	if p == nil then
		return ""
	end

	local __source = p.__source

	if __source == nil then
		return ""
	end

	return [[


Check your code at ]] .. string.gsub(__source.fileName, "^.*[\\/]", "") .. ":" .. __source.lineNumber .. "."
end

local v2 = {}

local function getCurrentComponentErrorInfo(value)
	local declarationErrorAddendum = getDeclarationErrorAddendum() -- equivalent call inferred; original call site unknown

	if boolean.toJSBoolean(declarationErrorAddendum) then
		return declarationErrorAddendum
	end

	local displayName

	if typeof(value) == "string" then
		displayName = value
	elseif typeof(value) == "table" then
		displayName = value.displayName or value.name
	end

	if not displayName and typeof(value) == "function" then
		displayName = debug.info(value, "n")

		if displayName == "" then
			displayName = nil
		end
	end

	if displayName then
		declarationErrorAddendum = string.format([[


Check the top-level render call using <%s>.]], displayName)
	end

	return declarationErrorAddendum
end

local function validateExplicitKey(data, p, p2)
	if data._store == nil or data._store.validated then
		return
	end

	data._store.validated = true

	if data.key ~= nil ~= (p2 ~= nil) then
		return
	end

	local currentComponentErrorInfo = getCurrentComponentErrorInfo(p)

	if v2[currentComponentErrorInfo] then
		return
	end

	v2[currentComponentErrorInfo] = true
	local v3 = (not data or not data._owner or data._owner == reactCurrentOwner.current) and "" or string.format(
		" It was passed a child from %s.",
		(tostring(getComponentName(data._owner.type)))
	)

	if _G.__DEV__ then
		setCurrentlyValidatingElement(data) -- equivalent call inferred; original call site unknown

		if data.key == nil or p2 == nil then
			console.error(
				"Each child in a list should have a unique \"key\" prop.%s%s See https://reactjs.org/link/warning-keys for more information.",
				currentComponentErrorInfo,
				v3
			)
		else
			console.error(
				"Child element received a \"key\" prop (\"%s\") in addition to a key in the \"children\" table of its parent (\"%s\"). Please provide only one key definition. When both are present, the \"key\" prop will take precedence.%s%s See https://reactjs.org/link/warning-keys for more information.",
				tostring(data.key),
				tostring(p2),
				currentComponentErrorInfo,
				v3
			)
		end

		setCurrentlyValidatingElement() -- equivalent call inferred; original call site unknown
	end
end

local function validateChildKeys(p, p2)
	if typeof(p) ~= "table" then
		return
	end

	if array.isArray(p) then
		for i = 1, #p do
			local v3 = p[i]

			if isValidElement(v3) then
				validateExplicitKey(v3, p2)
			end
		end
	elseif isValidElement(p) then
		if p._store then
			p._store.validated = true
		end
	elseif p then
		local iteratorFn = getIteratorFn(p)

		if typeof(iteratorFn) == "function" and iteratorFn ~= p.entries then
			local v3 = iteratorFn(p)
			local next = v3.next()

			while not next.done do
				if isValidElement(next.value) then
					validateExplicitKey(next.value, p2, next.key)
				end

				next = v3.next()
			end
		end
	end
end

local function validatePropTypes(p)
	if _G.__DEV__ or _G.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
		local type = p.type

		if type == nil or typeof(type) == "string" or typeof(type) == "function" or typeof(type) ~= "table" then
			return
		end

		local propTypes = type.propTypes
		local validateProps = type.validateProps

		if propTypes or validateProps then
			local componentName = getComponentName(type)
			checkPropTypes(propTypes, validateProps, p.props, "prop", componentName, p)
		elseif type.PropTypes ~= nil and not v then
			v = true
			local componentName = getComponentName(type)
			console.error(
				"Component %s declared `PropTypes` instead of `propTypes`. Did you misspell the property assignment?",
				componentName or "Unknown"
			)
		end

		if type.getDefaultProps ~= nil then
			console.error("getDefaultProps is only used on classic React.createClass definitions. Use a static property named `defaultProps` instead.")
		end
	end
end

local function validateFragmentProps(data)
	if _G.__DEV__ then
		local keys = object.keys(data.props)

		for i = 1, #keys do
			local key = keys[i]

			if not (key ~= "children" and key ~= "key") then
				continue
			end

			setCurrentlyValidatingElement(data) -- equivalent call inferred; original call site unknown
			console.error(
				"Invalid prop `%s` supplied to `React.Fragment`. React.Fragment can only have `key` and `children` props.",
				key
			)

			if not _G.__DEV__ then
				break
			end

			setExtraStackFrame(nil)
			break
		end

		if data.ref ~= nil then
			setCurrentlyValidatingElement(data) -- equivalent call inferred; original call site unknown
			console.error("Invalid attribute `ref` supplied to `React.Fragment`.")
			setCurrentlyValidatingElement() -- equivalent call inferred; original call site unknown
		end
	end
end

local function jsxWithValidation(p, p2, p3, p4, p5, p6)
	local validElementType = isValidElementType(p)

	if not validElementType then
		local v3 = ""

		if p == nil or typeof(p) == "table" and #object.keys(p) == 0 then
			v3 ..= " You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports."
		end

		local sourceInfoErrorAddendum = getSourceInfoErrorAddendum(p5) -- equivalent call inferred; original call site unknown
		local v4

		if sourceInfoErrorAddendum then
			v4 = v3 .. sourceInfoErrorAddendum
		else
			v4 = v3 .. getDeclarationErrorAddendum()
		end

		local typeName

		if p == nil then
			typeName = "nil"
		elseif array.isArray(p) then
			typeName = "array"
		elseif typeof(p) == "table" and p["$$typeof"] == REACT_ELEMENT_TYPE then
			typeName = string.format("<%s />", getComponentName(p.type) or "Unknown")
			v4 ..= " Did you accidentally export a JSX literal or Element instead of a component?"
		else
			typeName = typeof(p)
			v4 ..= "\n" .. inspect(p)
		end

		if _G.__DEV__ then
			console.error(
				"React.jsx: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s",
				typeName,
				v4
			)
		end
	end

	local v3 = jsxDEV(p, p2, p3, p5, p6)

	if v3 == nil then
		return nil
	end

	if validElementType then
		local children = p2.children

		if children ~= nil then
			if p4 then
				if array.isArray(children) then
					for i = 1, #children do
						validateChildKeys(children[i], p)
					end

					object.freeze(children)
				elseif _G.__DEV__ then
					console.error("React.jsx: Static children should always be an array. You are likely explicitly calling React.jsxs or React.jsxDEV. Use the Babel transform instead.")
				end
			else
				validateChildKeys(children, p)
			end
		end
	end

	if _G.__DEV__ and warnAboutSpreadingKeyToJSX and p2.key ~= nil then
		console.error(
			"React.jsx: Spreading a key to JSX is a deprecated pattern. Explicitly pass a key after spreading props in your JSX call. E.g. <%s {...props} key={key} />",
			getComponentName(p) or "ComponentName"
		)
	end

	if p == REACT_FRAGMENT_TYPE then
		validateFragmentProps(v3)
		return v3
	end

	validatePropTypes(v3)
	return v3
end

local ReactElementValidator = {}
ReactElementValidator.jsxWithValidation = jsxWithValidation

function ReactElementValidator.jsxWithValidationStatic(p, p2, p3)
	return (jsxWithValidation(p, p2, p3, true))
end

function ReactElementValidator.jsxWithValidationDynamic(p, p2, p3)
	return (jsxWithValidation(p, p2, p3, false))
end

function ReactElementValidator.createElementWithValidation(p, p2, ...)
	local validElementType = isValidElementType(p)

	if not validElementType then
		local v3 = ""

		if p == nil or typeof(p) == "table" and #object.keys(p) == 0 then
			v3 ..= " You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports."
		end

		local sourceInfoErrorAddendumForProps = getSourceInfoErrorAddendumForProps(p2) -- equivalent call inferred; original call site unknown
		local v4

		if sourceInfoErrorAddendumForProps then
			v4 = v3 .. sourceInfoErrorAddendumForProps
		else
			v4 = v3 .. getDeclarationErrorAddendum()
		end

		local typeName

		if p == nil then
			typeName = "nil"
		elseif array.isArray(p) then
			typeName = "array"
		elseif p == nil or typeof(p) ~= "table" or p["$$typeof"] ~= REACT_ELEMENT_TYPE then
			typeName = typeof(p)

			if p ~= nil then
				v4 ..= "\n" .. inspect(p)
			end
		else
			typeName = string.format("<%s />", getComponentName(p.type) or "Unknown")
			v4 ..= " Did you accidentally export a JSX literal or Element instead of a component?"
		end

		if _G.__DEV__ then
			console.error(
				"React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s",
				typeName,
				v4
			)
		end
	end

	local element = createElement(p, p2, ...)

	if element == nil then
		return nil
	end

	if validElementType then
		for i = 1, select("#", ...) do
			validateChildKeys(select(i, ...), p)
		end
	end

	if p == REACT_FRAGMENT_TYPE then
		validateFragmentProps(element)
		return element
	end

	validatePropTypes(element)
	return element
end

function ReactElementValidator.cloneElementWithValidation(p, p2, ...)
	local v3 = { p, p2, ... }
	local element = cloneElement(p, p2, ...)

	for i = 3, #v3 do
		validateChildKeys(v3[i], element.type)
	end

	validatePropTypes(element)
	return element
end

return ReactElementValidator