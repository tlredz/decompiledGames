require(script.Parent.Types)
local Buffer = require(script.Parent.Buffer)
local BasicTypes = {}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function transformInt(number: number)
	if number % 2 == 0 then
		return number / 2
	end

	return -(number + 1) / 2
end

local function rbxF32(p: number)
	local v = bit32.rrotate(p, 1)
	return string.unpack(">f", string.pack(">I4", v))
end

function BasicTypes.String(object)
	return object:read(object:readNumber("<I4"))
end

function BasicTypes.Int32(object)
	return transformInt(object:readNumber(">I4"))
end

function BasicTypes.Int64(object)
	return transformInt(object:readNumber(">I8"))
end

function BasicTypes.Float32(object)
	return rbxF32(object:readNumber(">I4"))
end

function BasicTypes.Float64(object)
	return object:readNumber("<d")
end

function BasicTypes.InterleaveArrayWithSize(object, p: number, p2: number)
	if p < 0 then
		return Buffer("", false)
	end

	local v = object:read(p * p2)
	local values = table.create(p)

	for i = 1, p do
		local v2 = table.create(p2)

		for i2 = 0, p2 - 1 do
			local v3 = i + p * i2
			v2[i2 + 1] = string.sub(v, v3, v3)
		end

		values[i] = table.concat(v2)
	end

	return Buffer(table.concat(values), false)
end

function BasicTypes.unsignedIntArray(p, p2: number)
	if p2 < 1 then
		return {}
	end

	local result = table.create(p2)
	local interleaveArrayWithSize = BasicTypes.InterleaveArrayWithSize(p, p2, 4)

	for i = 1, p2 do
		result[i] = interleaveArrayWithSize:readNumber("<I4")
	end

	return result
end

function BasicTypes.Int32Array(p, p2: number)
	if p2 < 1 then
		return {}
	end

	local result = table.create(p2)
	local interleaveArrayWithSize = BasicTypes.InterleaveArrayWithSize(p, p2, 4)

	for i = 1, p2 do
		result[i] = BasicTypes.Int32(interleaveArrayWithSize)
	end

	return result
end

function BasicTypes.Int64Array(p, p2: number)
	if p2 < 1 then
		return {}
	end

	local result = table.create(p2)
	local interleaveArrayWithSize = BasicTypes.InterleaveArrayWithSize(p, p2, 8)

	for i = 1, p2 do
		result[i] = BasicTypes.Int64(interleaveArrayWithSize)
	end

	return result
end

function BasicTypes.RbxF32Array(p, p2: number)
	if p2 < 1 then
		return {}
	end

	local result = table.create(p2)
	local interleaveArrayWithSize = BasicTypes.InterleaveArrayWithSize(p, p2, 4)

	for i = 1, p2 do
		result[i] = BasicTypes.Float32(interleaveArrayWithSize)
	end

	return result
end

function BasicTypes.RefArray(p, p2: number)
	if p2 < 1 then
		return {}
	end

	local result = table.create(p2)
	local int32Array = BasicTypes.Int32Array(p, p2)
	local total = 0

	for i = 1, p2 do
		total += int32Array[i]
		result[i] = total
	end

	return result
end

return BasicTypes