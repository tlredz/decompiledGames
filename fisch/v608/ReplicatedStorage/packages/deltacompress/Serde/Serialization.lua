local TypeId = require(script.Parent.Parent.TypeId)
local isArray = require(script.Parent.Parent.isArray)
require(script.Parent.Parent.Buffer.Writer)
local Vlq = require(script.Parent.Parent.Vlq)
local serializers = {}

local function serialize(p, p2)
	local typeName = typeof(p2)
	local v2, array

	if typeName == "table" then
		if isArray(p2) then
			v2 = TypeId.fromType("array")
			array = serializers.array
		else
			v2 = TypeId.fromType("dictionary")
			array = serializers.dictionary
		end
	else
		v2 = TypeId.fromType(typeName)
		array = serializers[typeName]
	end

	if array == nil then
		error((`invalid type '{typeName}'`))
		return
	end

	p.writeu8(v2)
	array(p, p2)
end

function serializers.array(p, list)
	Vlq.encode(p, #list)

	for _, v2 in list do
		serialize(p, v2)
	end
end

function serializers.dictionary(p, items)
	local count = 0

	for _ in items do
		count += 1
	end

	Vlq.encode(p, count)

	for k, item in items do
		serialize(p, k)
		serialize(p, item)
	end
end

serializers["nil"] = function() end

function serializers.string(p, list: string)
	Vlq.encode(p, #list)
	p.writestring(list)
end

function serializers.number(p, p2: number)
	p.writef64(p2)
end

function serializers.boolean(p, flag: boolean)
	p.writeu8(flag and 1 or 0)
end

function serializers.Vector2(p, point: Vector2)
	p.writef32(point.X)
	p.writef32(point.Y)
end

function serializers.Vector3(p, vector: Vector3)
	p.writef32(vector.X)
	p.writef32(vector.Y)
	p.writef32(vector.Z)
end

function serializers.Vector2int16(p, p2)
	p.writei16(p2.X)
	p.writei16(p2.Y)
end

function serializers.Vector3int16(p, data)
	p.writei16(data.X)
	p.writei16(data.Y)
	p.writei16(data.Z)
end

function serializers.CFrame(p, cframe: CFrame)
	local axisAngle, v2 = cframe:ToAxisAngle()
	local v3 = axisAngle * v2
	p.writef32(cframe.Position.X)
	p.writef32(cframe.Position.Y)
	p.writef32(cframe.Position.Z)
	p.writef32(v3.X)
	p.writef32(v3.Y)
	p.writef32(v3.Z)
end

return {
	serializers = serializers,
	serialize = serialize
}