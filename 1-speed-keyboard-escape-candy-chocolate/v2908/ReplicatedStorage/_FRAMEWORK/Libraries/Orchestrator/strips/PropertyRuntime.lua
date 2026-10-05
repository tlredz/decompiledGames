require(script.Parent.Parent.types.Property)
require(script.Parent.Parent.types.Save)
require(script.Parent.Parent.types.Strip)
local ResourceClaims = require(script.Parent.Parent.runtime.ResourceClaims)
local areEqual

areEqual = function(value, items)
	if type(value) ~= type(items) then
		return false
	end

	if type(value) == "number" then
		return math.abs(value - items) <= 1e-6
	end

	if type(value) ~= "table" then
		return value == items
	end

	for k, item in value do
		if not areEqual(item, items[k]) then
			return false
		end
	end

	for k in items do
		if value[k] == nil then
			return false
		end
	end

	return true
end

local function findDataAtTime(data, keyframes, timeSeconds: number)
	local v = nil
	local v2 = nil

	for _, item in keyframes do
		if item.timeSeconds <= timeSeconds then
			v = item
		else
			v2 = item
			break
		end
	end

	if v == nil then
		if v2 == nil then
			return nil
		end

		return v2.data
	else
		if v2 == nil then
			return v.data
		end

		local v4 = v2.timeSeconds - v.timeSeconds
		local v5 = math.clamp((timeSeconds - v.timeSeconds) / v4, 0, 1)
		return data.interpolate(v.data, v2.data, v5)
	end
end

local function createContinuousRuntime(data, p, callback)
	local v = {}
	local formatted = `property:{data.propertyName}`
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = false

	local function release(flag: boolean)
		if v2 ~= nil and v6 then
			if flag and v4 ~= nil and v3 ~= nil and v5 ~= nil then
				local v7

				if data.isApplied == nil then
					v7 = areEqual(data.capture(v2, v5.root), v4)
				else
					v7 = data.isApplied(v2, v4, v5)
				end

				if v7 then
					data.apply(v2, v3, v5)
				end
			end

			ResourceClaims.release(v, v2, formatted)
		end

		v2 = nil
		v3 = nil
		v4 = nil
		v5 = nil
		v6 = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply(p2)
		if v2 ~= nil and v6 then
			v5 = p2
			local dataAtTime = findDataAtTime(data, p.keyframes, p2.timeSeconds)

			if dataAtTime ~= nil then
				data.apply(v2, dataAtTime, p2)
				v4 = dataAtTime
			end
		end
	end

	return {
		attach = function(_, p2, p3)
			local v7

			if p.actorId == "__sequence" then
				v7 = data.supportsGlobal
			else
				v7 = data.supports(p2)
			end

			if not v7 then
				callback(string.format("%s does not support this actor.", data.propertyName))
				return false
			end

			release(true)

			if not ResourceClaims.claim(v, p2, formatted) then
				callback(string.format("%s is already controlled by another Sequence.", data.propertyName))
				return false
			end

			v2 = p2
			v3 = data.capture(p2, p3.root)
			v6 = true
			apply(p3) -- equivalent call inferred; original call site unknown
			return true
		end,
		update = function(_, p2)
			apply(p2) -- equivalent call inferred; original call site unknown
		end,
		detach = function(_, _: string, flag: boolean)
			release(flag)
		end,
		destroy = function(_, _: string, flag: boolean)
			release(flag)
			ResourceClaims.releaseOwner(v)
		end
	}
end

local function createActionRuntime(data, p, callback)
	local v = nil
	return {
		attach = function(_, p2, _)
			local v2

			if p.actorId == "__sequence" then
				v2 = data.supportsGlobal
			else
				v2 = data.supports(p2)
			end

			if v2 then
				v = p2
				return true
			end

			callback(string.format("%s does not support this actor.", data.propertyName))
			return false
		end,
		update = function(_, data2)
			local v2 = v

			if v2 ~= nil and not data2.isCatchUp and not data2.isSeeking and data2.timeSeconds > data2.previousTimeSeconds then
				for _, keyframe in p.keyframes do
					if keyframe.timeSeconds > data2.previousTimeSeconds and keyframe.timeSeconds <= data2.timeSeconds then
						data.trigger(v2, keyframe.data, data2)
					end
				end
			end
		end,
		detach = function(_, _: string, _: boolean)
			v = nil
		end,
		destroy = function(_, _: string, _: boolean)
			v = nil
		end
	}
end

return {
	create = function(p, p2, callback)
		if p.playbackMode == "action" then
			return (createActionRuntime(p, p2, callback))
		end

		if p.playbackMode == "custom" then
			return p.createRuntime(p2, callback)
		end

		return (createContinuousRuntime(p, p2, callback))
	end
}