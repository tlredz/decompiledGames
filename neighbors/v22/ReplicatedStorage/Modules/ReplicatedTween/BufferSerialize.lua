game:GetService("HttpService")
local Serialize = require(script.Serialize)
local Deserialize = require(script.Deserialize)
local Utils = require(script.Utils)
local TYPE_SIGNATURES = Utils.TYPE_SIGNATURES

local function serialize(p, p2)
	local fillwriteopt = Utils.fillwriteopt(p2)
	local typeName = typeof(p)
	local dataInfo, v = Utils.getDataInfo(p, fillwriteopt)
	local buf = buffer.create(v + 2)
	buffer.writeu8(buf, 0, dataInfo)
	Serialize[typeName](buf, p, 1, fillwriteopt)
	return buf
end

local function deserialize(buf, p)
	local fillreadopt = Utils.fillreadopt(p)
	return Deserialize[TYPE_SIGNATURES[buffer.readu8(buf, 0)]](buf, 1, fillreadopt)
end

return {
	Serialize = serialize,
	Deserialize = deserialize
}