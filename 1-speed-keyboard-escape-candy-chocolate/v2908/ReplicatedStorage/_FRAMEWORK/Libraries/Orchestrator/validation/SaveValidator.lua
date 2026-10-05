local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local TableUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.TableUtils)
require(script.Parent.Parent.types.Save)
local PropertyRegistry = require(script.Parent.Parent.strips.PropertyRegistry)
local StripRegistry = require(script.Parent.Parent.strips.StripRegistry)
local strictInterface = t.strictInterface
local literalList = t.literalList
local intersection = t.intersection(t.number, function(p)
	if math.abs(p) < 1e999 then
		return true, nil
	end

	return false, "finite number expected"
end)
local intersection2 = t.intersection(t.string, function(p)
	if p == "" then
		return false, "non-empty string expected"
	end

	return true, nil
end)
local v = literalList({
	"skip",
	"apply",
	"latest",
	"seek"
})
local v2 = strictInterface({
	time = t.intersection(intersection, t.numberMin(0)),
	name = intersection2,
	value = t.string
})
local v3 = strictInterface({
	id = intersection2,
	path = t.array(intersection2)
})
local v4 = strictInterface({
	timeSeconds = t.intersection(intersection, t.numberMin(0)),
	data = t.table
})
local v5 = strictInterface({
	id = intersection2,
	type = literalList({ "property" }),
	actorId = intersection2,
	propertyName = intersection2,
	catchUpPolicy = t.optional(v),
	keyframes = t.array(v4)
})
local v6 = strictInterface({
	schema = literalList({ "frameworkOrchestrator" }),
	schemaVersion = literalList({ 2 }),
	name = intersection2,
	durationSeconds = t.intersection(intersection, t.numberMinExclusive(0)),
	markers = t.array(v2),
	actors = t.array(v3),
	strips = t.array(v5)
})

local function validateCrossFields(data)
	local v7 = {}

	for k, actor in data.actors do
		if v7[actor.id] then
			return false, string.format("Data.actors[%d] duplicates actor id '%s'.", k, actor.id)
		else
			v7[actor.id] = true
		end
	end

	for k, marker in data.markers do
		if marker.time > data.durationSeconds then
			return false, string.format("Data.markers[%d].time must not exceed durationSeconds.", k)
		end
	end

	local v8 = {}
	local v9 = {}

	for k, strip in data.strips do
		if v8[strip.id] then
			return false, string.format("Data.strips[%d] duplicates strip id '%s'.", k, strip.id)
		end

		if not v7[strip.actorId] then
			return false, string.format("Data.strips[%d] references unknown actor '%s'.", k, strip.actorId)
		end

		if StripRegistry.get(strip.type) == nil then
			return false, string.format("Data.strips[%d] uses unsupported strip type '%s'.", k, strip.type)
		end

		v8[strip.id] = true
		local formatted = ("%*\0%*"):format(strip.actorId, strip.propertyName)

		if v9[formatted] then
			return
				false,
				string.format(
					"Data.strips[%d] duplicates property '%s' for actor '%s'.",
					k,
					strip.propertyName,
					strip.actorId
				)
		end

		v9[formatted] = true
		local timeSeconds = -1e999

		for k2, keyframe in strip.keyframes do
			if keyframe.timeSeconds > data.durationSeconds then
				return
					false,
					string.format("Data.strips[%d].keyframes[%d].timeSeconds must not exceed durationSeconds.", k, k2)
			end

			if keyframe.timeSeconds <= timeSeconds then
				return false, string.format("Data.strips[%d].keyframes must be strictly ordered by timeSeconds.", k)
			else
				timeSeconds = keyframe.timeSeconds
			end
		end

		local v10, v11 = PropertyRegistry.validate(strip.propertyName, strip.catchUpPolicy)

		if not v10 then
			return false, string.format("Data.strips[%d]: %s", k, v11 or "invalid property")
		end
	end

	return true, nil
end

local freezeDeep

freezeDeep = function(list)
	if type(list) == "table" and not table.isfrozen(list) then
		for _, v7 in list do
			freezeDeep(v7)
		end

		table.freeze(list)
	end
end

local SaveValidator = {
	validate = function(p)
		local v7, v8 = v6(p)

		if v7 then
			return validateCrossFields(p)
		end

		return false, v8
	end
}

function SaveValidator.prepare(p)
	local v7, v8 = SaveValidator.validate(p)

	if not v7 then
		return nil, v8
	end

	local copy = TableUtils.Copy(p, true)

	for _, strip in copy.strips do
		if strip.catchUpPolicy == nil then
			strip.catchUpPolicy = PropertyRegistry.getDefaultCatchUpPolicy(strip.propertyName) or "latest"
		end

		for _, keyframe in strip.keyframes do
			local v9 = PropertyRegistry.reconcileData(strip.propertyName, keyframe.data)

			if v9 ~= nil then
				keyframe.data = v9
			end
		end
	end

	freezeDeep(copy)
	return copy, nil
end

return SaveValidator