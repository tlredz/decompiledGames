local parent = script.Parent.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local depend = require(parent.Graph.depend)
local peek = require(parent.State.peek)
local castToState = require(parent.State.castToState)
require(parent.State.For.ForTypes)
local doCleanup = require(parent.Memory.doCleanup)
local deriveScope = require(parent.Memory.deriveScope)
local scopePool = require(parent.Memory.scopePool)
local nameOf = require(parent.Utility.nameOf)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "Graph",
	kind = "For.Disassembly",
	timeliness = "lazy"
}
local frozen = table.freeze({
	__index = v
})

local function Disassembly(scope, inputTable, constructor)
	local object = setmetatable({
		createdAt = os.clock(),
		dependencySet = {},
		dependentSet = {},
		scope = scope,
		validity = "invalid",
		_inputTable = inputTable,
		_constructor = constructor,
		_subObjects = {}
	}, frozen)

	local function fn()
		object.scope = nil

		for k in pairs(object.dependencySet) do
			k.dependentSet[object] = nil
		end

		for k in object._subObjects do
			if k.maybeScope == nil then
				continue
			end

			doCleanup(k.maybeScope)
			k.maybeScope = nil
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "For (internal disassembler)"
	table.insert(scope, fn)
	return object
end

function v:populate(p2, list)
	local v2 = 1e999
	local v3 = -1e999
	local v4 = false

	for k in self._subObjects do
		local v5, v6 = k:useOutputPair(p2)

		if v5 == nil or v6 == nil then
			v4 = true
		elseif list[v5] == nil then
			list[v5] = v6

			if typeof(v5) == "number" then
				v2 = math.min(v2, v5)
				v3 = math.max(v3, v5)
			end
		else
			External.logErrorNonFatal("forKeyCollision", nil, (tostring(v5)))
		end
	end

	if v4 and v2 < v3 then
		for i = v2, v3 do
			local v5 = list[i]

			if v5 == nil then
				continue
			end

			list[i] = nil
			list[v2] = v5
			v2 += 1
		end
	end
end

function v:_evaluate()
	local scope = self.scope
	local v2 = castToState(self._inputTable)

	if v2 ~= nil then
		if v2.scope == nil then
			External.logError(
				"useAfterDestroy",
				nil,
				`The input {nameOf(v2, "table")}`,
				"the For object that is watching it"
			)
		end

		depend(self, v2)
	end

	local v3 = {}

	for k, v4 in peek(self._inputTable) do
		v3[k] = v4
	end

	local subObjects = {}

	for k in self._subObjects do
		local flag = false
		local inputKey = k.inputKey
		local inputValue = k.inputValue
		local inputKey2 = nil

		if k.roamKeys or v3[inputKey] == nil then
			for k2, v7 in v3 do
				flag = true

				if k.roamValues or v7 == inputValue then
					inputKey2 = k2
					break
				else
					inputKey2 = k2
				end
			end
		else
			inputKey2 = inputKey
			flag = true
		end

		if flag then
			local inputValue2 = v3[inputKey2]
			subObjects[k] = true

			if inputKey2 ~= inputKey then
				k.inputKey = inputKey2
				k:invalidateInputKey()
			end

			if inputValue2 ~= inputValue then
				k.inputValue = inputValue2
				k:invalidateInputValue()
			end

			v3[inputKey2] = nil
		elseif k.maybeScope ~= nil then
			doCleanup(k.maybeScope)
			k.maybeScope = nil
		end
	end

	for k, v5 in v3 do
		local _constructor = self._constructor(deriveScope(scope), k, v5)

		if _constructor.maybeScope ~= nil then
			_constructor.maybeScope = scopePool.giveIfEmpty(_constructor.maybeScope)
		end

		subObjects[_constructor] = true
	end

	self._subObjects = subObjects
	return true
end

table.freeze(v)
return Disassembly