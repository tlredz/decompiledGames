local __DEV__ = _G.__DEV__
local __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ = _G.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local error2 = luaupolyfill.Error
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberStacknew = require(script.Parent:WaitForChild("ReactFiberStack.new"))
local ReactFiberTreeReflection = require(script.Parent:WaitForChild("ReactFiberTreeReflection"))
local isFiberMounted = ReactFiberTreeReflection.isFiberMounted
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local disableLegacyContext = shared2.ReactFeatureFlags.disableLegacyContext
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local classComponent = ReactWorkTags.ClassComponent
local hostRoot = ReactWorkTags.HostRoot
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared3.getComponentName
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local checkPropTypes = shared4.checkPropTypes
local createCursor = ReactFiberStacknew.createCursor
local push = ReactFiberStacknew.push
local pop = ReactFiberStacknew.pop
local v = __DEV__ and {} or nil
local emptyContextObject = {}

if __DEV__ then
	object.freeze(emptyContextObject)
end

local cursor = createCursor(emptyContextObject)
local cursor2 = createCursor(false)
local current = emptyContextObject
local isContextProvider

local function getUnmaskedContext(_, p, flag: boolean)
	if flag and isContextProvider(p) then
		return current
	end

	return cursor.current
end

isContextProvider = function(callback)
	return type(callback) ~= "function" and callback.childContextTypes ~= nil
end

local function processChildContext(p, p2, current2)
	local stateNode = p.stateNode
	local childContextTypes = p2.childContextTypes

	if stateNode.getChildContext == nil or type(stateNode.getChildContext) ~= "function" then
		if not __DEV__ then
			return current2
		end

		local v3 = getComponentName(p2) or "Unknown"

		if not v[v3] then
			v[v3] = true
			console.error(
				"%s.childContextTypes is specified but there is no getChildContext() method on the instance. You can either define getChildContext() on %s or remove childContextTypes from it.",
				v3,
				v3
			)
		end

		return current2
	else
		local childContext = stateNode:getChildContext()

		for k, _ in childContext do
			if childContextTypes[k] ~= nil then
				continue
			end

			local v3 = getComponentName(p2) or "Unknown"
			error(error2.new(string.format(
				"%s.getChildContext(): key \"%s\" is not defined in childContextTypes.",
				v3,
				k
			)))
		end

		if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
			checkPropTypes(childContextTypes, nil, childContext, "child context", getComponentName(p2) or "Unknown")
		end

		return object.assign({}, current2, childContext)
	end
end

local New = {}
New.emptyContextObject = emptyContextObject
New.getUnmaskedContext = getUnmaskedContext

function New.cacheContext(p, reactInternalMemoizedUnmaskedChildContext, reactInternalMemoizedMaskedChildContext)
	local stateNode = p.stateNode
	stateNode.__reactInternalMemoizedUnmaskedChildContext = reactInternalMemoizedUnmaskedChildContext
	stateNode.__reactInternalMemoizedMaskedChildContext = reactInternalMemoizedMaskedChildContext
end

function New.getMaskedContext(p, reactInternalMemoizedUnmaskedChildContext)
	local type2 = p.type

	if type(type2) == "function" then
		return reactInternalMemoizedUnmaskedChildContext
	end

	local contextTypes = type2.contextTypes

	if not contextTypes then
		return emptyContextObject
	end

	local stateNode = p.stateNode

	if stateNode and stateNode.__reactInternalMemoizedUnmaskedChildContext == reactInternalMemoizedUnmaskedChildContext then
		return stateNode.__reactInternalMemoizedMaskedChildContext
	end

	local result = {}

	for k, _ in contextTypes do
		result[k] = reactInternalMemoizedUnmaskedChildContext[k]
	end

	if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
		checkPropTypes(contextTypes, nil, result, "context", getComponentName(type2) or "Unknown")
	end

	if stateNode then
		local stateNode2 = p.stateNode
		stateNode2.__reactInternalMemoizedUnmaskedChildContext = reactInternalMemoizedUnmaskedChildContext
		stateNode2.__reactInternalMemoizedMaskedChildContext = result
	end

	return result
end

function New.hasContextChanged()
	return not disableLegacyContext and cursor2.current
end

function New.popContext(p)
	pop(cursor2, p)
	pop(cursor, p)
end

function New.popTopLevelContextObject(p)
	pop(cursor2, p)
	pop(cursor, p)
end

function New.pushTopLevelContextObject(p, p2, flag: boolean)
	if cursor.current ~= emptyContextObject then
		error(error2.new("Unexpected context found on stack. This error is likely caused by a bug in React. Please file an issue."))
	end

	push(cursor, p2, p)
	push(cursor2, flag, p)
end

New.processChildContext = processChildContext
New.isContextProvider = isContextProvider

function New.pushContextProvider(p)
	local stateNode = p.stateNode
	local __reactInternalMemoizedMergedChildContext = stateNode and stateNode.__reactInternalMemoizedMergedChildContext or emptyContextObject
	current = cursor.current
	push(cursor, __reactInternalMemoizedMergedChildContext, p)
	push(cursor2, cursor2.current, p)
	return true
end

function New.invalidateContextProvider(p, p2, flag: boolean)
	local stateNode = p.stateNode

	if not stateNode then
		error(error2.new("Expected to have an instance by this point. This error is likely caused by a bug in React. Please file an issue."))
	end

	if flag then
		local reactInternalMemoizedMergedChildContext = processChildContext(p, p2, current)
		stateNode.__reactInternalMemoizedMergedChildContext = reactInternalMemoizedMergedChildContext
		pop(cursor2, p)
		pop(cursor, p)
		push(cursor, reactInternalMemoizedMergedChildContext, p)
		push(cursor2, flag, p)
	else
		pop(cursor2, p)
		push(cursor2, flag, p)
	end
end

function New.findCurrentUnmaskedContext(return_)
	if return_.tag ~= classComponent or not isFiberMounted(return_) then
		error(error2.new("Expected subtree parent to be a mounted class component. This error is likely caused by a bug in React. Please file an issue."))
	end

	while return_.tag ~= hostRoot do
		if return_.tag == classComponent and return_.type.childContextTypes ~= nil then
			return return_.stateNode.__reactInternalMemoizedMergedChildContext
		end

		return_ = return_.return_

		if return_ ~= nil then
			continue
		end

		error(error2.new("Found unexpected detached subtree parent. This error is likely caused by a bug in React. Please file an issue."))
		return
	end

	return return_.stateNode.context
end

return New