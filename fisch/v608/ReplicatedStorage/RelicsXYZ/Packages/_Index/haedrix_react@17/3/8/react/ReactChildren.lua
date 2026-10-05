local parent = script.Parent.Parent
require(parent.Shared)
local Shared = require(parent.Shared)
local invariant = Shared.invariant
local Shared2 = require(parent.Shared)
local reactSymbols = Shared2.ReactSymbols
local getIteratorFn = reactSymbols.getIteratorFn
local REACT_ELEMENT_TYPE = reactSymbols.REACT_ELEMENT_TYPE
local REACT_PORTAL_TYPE = reactSymbols.REACT_PORTAL_TYPE
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local ReactElement = require(script.Parent.ReactElement)
local isValidElement = ReactElement.isValidElement
local cloneAndReplaceKey = ReactElement.cloneAndReplaceKey

-- equivalent calls inferred from this helper; original call sites unknown
local function escape(key: string)
	local v = string.gsub(key, "=", "=0")
	return "$" .. string.gsub(v, ":", "=2")
end

local function escapeUserProvidedKey(p: string)
	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getElementKey(p, p2: number)
	if typeof(p) ~= "table" or p == nil or p.key == nil then
		return (tostring(p2))
	end

	return escape(tostring(p.key))
end

local mapIntoArray

mapIntoArray = function(p, list, p2: string, p3: string, callback)
	local typeName = typeof(p)

	if typeName == "nil" or typeName == "boolean" or typeName == "userdata" then
		p = nil
	end

	local v = false

	if p == nil or typeName == "string" or typeName == "number" then
		v = true
	elseif typeName == "table" then
		local typeof2 = p["$$typeof"]
		v = typeof2 == REACT_ELEMENT_TYPE or typeof2 == REACT_PORTAL_TYPE or false
	end

	if v then
		local v2 = callback(p)

		if p3 == "" then
			local elementKey = getElementKey(p, 1) -- equivalent call inferred; original call site unknown
			p3 = "." .. elementKey
		end

		if array.isArray(v2) then
			mapIntoArray(v2, list, p3 == nil and "" or p3 .. "/", "", function(p4)
				return p4
			end)
		elseif v2 ~= nil then
			if isValidElement(v2) then
				local key = v2.key
				v2 = cloneAndReplaceKey(
					v2,
					p2 .. ((not key or p and p.key == key) and "" or tostring(key) .. "/") .. p3
				)
			end

			table.insert(list, v2)
		end

		return 1
	else
		local total = 0
		local v2 = p3 == "" and "." or p3 .. ":"

		if array.isArray(p) then
			for i = 1, #p do
				local v3 = p[i]
				local elementKey = getElementKey(v3, i) -- equivalent call inferred; original call site unknown
				total += mapIntoArray(v3, list, p2, v2 .. elementKey, callback)
			end

			return total
		else
			local iteratorFn = getIteratorFn(p)

			if typeof(iteratorFn) ~= "function" then
				return total
			end

			local v3 = iteratorFn(p)
			local next = v3.next()
			local v4 = 1

			while not next.done do
				local value = next.value
				local elementKey = getElementKey(value, v4) -- equivalent call inferred; original call site unknown
				local v5 = v2 .. elementKey
				v4 += 1
				total += mapIntoArray(value, list, p2, v5, callback)
				next = v3.next()
			end

			return total
		end
	end
end

local function mapChildren(p, fn, _)
	if p == nil then
		return nil
	end

	local v = {}
	local v2 = 1
	mapIntoArray(p, v, "", "", function(p2)
		local v3 = fn(p2, v2)
		v2 += 1
		return v3
	end)
	return v
end

local function countChildren(p)
	local count = 0
	mapChildren(p, function()
		count += 1
	end)
	return count
end

local function forEachChildren(p, callback, p2)
	mapChildren(p, function(...)
		callback(...)
	end, p2)
end

local function onlyChild(p)
	invariant(isValidElement(p), "React.Children.only expected to receive a single React element child.")
	return p
end

return {
	forEach = forEachChildren,
	map = mapChildren,
	count = countChildren,
	only = onlyChild,
	toArray = function(p)
		return mapChildren(p, function(p2)
			return p2
		end) or {}
	end
}