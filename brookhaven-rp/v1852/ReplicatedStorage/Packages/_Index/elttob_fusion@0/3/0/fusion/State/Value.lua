local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local change = require(parent.Graph.change)
local isSimilar = require(parent.Utility.isSimilar)
local never = require(parent.Utility.never)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "State",
	kind = "Value",
	timeliness = "lazy",
	dependencySet = table.freeze({})
}
local frozen = table.freeze({
	__index = v
})

local function Value(scope, p)
	local now = os.clock()

	if p == nil and (typeof(scope) ~= "table" or scope[1] == nil and next(scope) ~= nil) then
		External.logError("scopeMissing", nil, "Value", "myScope:Value(initialValue)")
	end

	local object = setmetatable({
		createdAt = now,
		dependentSet = {},
		lastChange = os.clock(),
		scope = scope,
		validity = "valid",
		_EXTREMELY_DANGEROUS_usedAsValue = p
	}, frozen)

	local function fn()
		object.scope = nil
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "Value"
	table.insert(scope, fn)
	return object
end

function v.get(_, _)
	External.logError("stateGetWasRemoved")
	return never()
end

function v:set(eXTREMELY_DANGEROUS_usedAsValue)
	if not isSimilar(self._EXTREMELY_DANGEROUS_usedAsValue, eXTREMELY_DANGEROUS_usedAsValue) then
		self._EXTREMELY_DANGEROUS_usedAsValue = eXTREMELY_DANGEROUS_usedAsValue
		change(self)
	end

	return eXTREMELY_DANGEROUS_usedAsValue
end

function v._evaluate(_)
	return true
end

table.freeze(v)
return Value