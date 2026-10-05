local TypeId = require(script.Parent.Parent.TypeId)
require(script.Parent.Parent.Buffer.Reader)
local Vlq = require(script.Parent.Parent.Vlq)
local Deserialization = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function deserialize(p)
	local readu8 = p.readu8()
	return Deserialization[TypeId.toType(readu8)](p)
end

function Deserialization.array(p)
	local result = {}

	for _ = 1, Vlq.decode(p) do
		table.insert(result, deserialize(p))
	end

	return result
end

function Deserialization.dictionary(p)
	local result = {}

	for _ = 1, Vlq.decode(p) do
		local v = deserialize(p) -- equivalent call inferred; original call site unknown
		result[v] = deserialize(p)
	end

	return result
end

Deserialization["nil"] = function()
	return nil
end

function Deserialization.string(p)
	local decoded = Vlq.decode(p)
	return (p.readstring(decoded))
end

function Deserialization.number(p)
	return p.readf64()
end

function Deserialization.boolean(p)
	return p.readu8() == 1
end

function Deserialization.Vector2(p)
	local readf32 = p.readf32()
	local readf322 = p.readf32()
	return Vector2.new(readf32, readf322)
end

function Deserialization.Vector3(p)
	return (Vector3.new(p.readf32(), p.readf32(), (p.readf32())))
end

function Deserialization.Vector2int16(p)
	local readi16 = p.readi16()
	local readi162 = p.readi16()
	return Vector2int16.new(readi16, readi162)
end

function Deserialization.Vector3int16(p)
	local readi16 = p.readi16()
	local readi162 = p.readi16()
	local readi163 = p.readi16()
	return Vector3int16.new(readi16, readi162, readi163)
end

function Deserialization.CFrame(p)
	local vector = Vector3.new(p.readf32(), p.readf32(), p.readf32())
	local vector2 = Vector3.new(p.readf32(), p.readf32(), p.readf32())
	local magnitude = vector2.Magnitude

	if magnitude == 0 then
		return CFrame.new(vector)
	end

	return CFrame.fromAxisAngle(vector2, magnitude) + vector
end

return Deserialization