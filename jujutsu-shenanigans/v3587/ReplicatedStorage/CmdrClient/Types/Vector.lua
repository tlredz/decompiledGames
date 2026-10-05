local Util = require(script.Parent.Parent.Shared.Util)

local function validateVector(p, p2)
	if p == nil then
		return false, ("Invalid or missing number at position %d in Vector type."):format(p2)
	end

	return true
end

local sequenceType = Util.MakeSequenceType({
	ValidateEach = validateVector,
	TransformEach = tonumber,
	Constructor = Vector3.new,
	Length = 3
})
local sequenceType2 = Util.MakeSequenceType({
	ValidateEach = validateVector,
	TransformEach = tonumber,
	Constructor = Vector2.new,
	Length = 2
})
return function(registry)
	registry:RegisterType("vector3", sequenceType)
	registry:RegisterType("vector3s", Util.MakeListableType(sequenceType))
	registry:RegisterType("vector2", sequenceType2)
	registry:RegisterType("vector2s", Util.MakeListableType(sequenceType2))
end