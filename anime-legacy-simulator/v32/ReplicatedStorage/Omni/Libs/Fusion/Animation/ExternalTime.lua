local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local change = require(parent.Graph.change)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "State",
	kind = "ExternalTime",
	timeliness = "lazy",
	dependencySet = table.freeze({}),
	_EXTREMELY_DANGEROUS_usedAsValue = External.lastUpdateStep()
}
local frozen = table.freeze({
	__index = v
})
local v2 = {}

local function ExternalTime(scope)
	local object = setmetatable({
		createdAt = os.clock(),
		dependentSet = {},
		lastChange = nil,
		scope = scope,
		validity = "invalid"
	}, frozen)

	local function fn()
		object.scope = nil
		local index = table.find(v2, object)

		if index ~= nil then
			table.remove(v2, index)
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "ExternalTime"
	table.insert(scope, fn)
	table.insert(v2, object)
	return object
end

function v._evaluate(_)
	return true
end

External.bindToUpdateStep(function(_: number)
	v._EXTREMELY_DANGEROUS_usedAsValue = External.lastUpdateStep()

	for _, v3 in v2 do
		if next(v3.dependentSet) ~= nil then
			change(v3)
		end
	end
end)
return ExternalTime