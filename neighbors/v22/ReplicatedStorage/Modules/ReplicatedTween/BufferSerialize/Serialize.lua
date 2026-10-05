game:GetService("HttpService")
local Mappings = require(script.Parent.Mappings)
local Utils = require(script.Parent.Utils)
local Serialize = {
	CFrame = function(buf, cframe: CFrame, offset, _)
		local components, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = cframe:GetComponents()
		buffer.writei32(buf, offset, (math.floor(components * 100)))
		buffer.writei32(buf, offset + 4, (math.floor(v * 100)))
		buffer.writei32(buf, offset + 8, (math.floor(v2 * 100)))
		buffer.writei8(buf, offset + 13, (math.floor(v3 * 127)))
		buffer.writei8(buf, offset + 14, (math.floor(v4 * 127)))
		buffer.writei8(buf, offset + 15, (math.floor(v5 * 127)))
		buffer.writei8(buf, offset + 16, (math.floor(v6 * 127)))
		buffer.writei8(buf, offset + 17, (math.floor(v7 * 127)))
		buffer.writei8(buf, offset + 18, (math.floor(v8 * 127)))
		buffer.writei8(buf, offset + 19, (math.floor(v9 * 127)))
		buffer.writei8(buf, offset + 20, (math.floor(v10 * 127)))
		buffer.writei8(buf, offset + 21, (math.floor(v11 * 127)))
	end,
	Vector3 = function(buf, vector: Vector3, offset, _)
		local X = vector.X
		local Y = vector.Y
		local Z = vector.Z
		buffer.writei32(buf, offset, (math.floor(X * 100)))
		buffer.writei32(buf, offset + 4, (math.floor(Y * 100)))
		buffer.writei32(buf, offset + 8, (math.floor(Z * 100)))
	end,
	Vector3int16 = function(buf, data, offset, _)
		local X = data.X
		local Y = data.Y
		local Z = data.Z
		buffer.writei16(buf, offset, X)
		buffer.writei16(buf, offset + 2, Y)
		buffer.writei16(buf, offset + 4, Z)
	end,
	Vector2 = function(buf, point: Vector2, offset, _)
		local X = point.X
		local Y = point.Y
		buffer.writei32(buf, offset, (math.floor(X * 100)))
		buffer.writei32(buf, offset + 4, (math.floor(Y * 100)))
	end,
	Vector2int16 = function(buf, p, offset, _)
		local X = p.X
		local Y = p.Y
		buffer.writei16(buf, offset, X)
		buffer.writei16(buf, offset + 2, Y)
	end,
	Color3 = function(buf, color: Color3, offset, _)
		local R = color.R
		local G = color.G
		local B = color.B
		buffer.writeu8(buf, offset, (math.floor(R * 255)))
		buffer.writeu8(buf, offset + 1, (math.floor(G * 255)))
		buffer.writeu8(buf, offset + 2, (math.floor(B * 255)))
	end,
	EnumItem = function(buf, p, offset, _)
		local enumType = tostring(p.EnumType)
		local value = p.Value
		buffer.writeu8(buf, offset, (table.find(Mappings.enumMapping, enumType)))
		buffer.writeu16(buf, offset + 1, value)
	end,
	number = function(p, p2: number, p3, p4)
		buffer[`write{p4.numbersAs}`](p, p3, (math.floor(p2 * 100)))
	end,
	boolean = function(buf, flag: boolean, offset, _)
		buffer.writeu8(buf, offset, (table.find(Mappings.bools, flag)))
	end,
	string = function(buf, value: string, p, _)
		local count = 0

		for _, value2 in { value:byte(1, value:len()) } do
			buffer.writeu8(buf, p + count, value2)
			count += 1
		end

		buffer.writeu8(buf, p + count, 0)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function type_error(p, typeName)
	local v = "Unrecognized datatype: " .. typeName

	if p.errorOnException then
		error(v)
	else
		warn(v)
	end
end

local function writeMember(buf, offset, p, p2)
	local v = Serialize[typeof(p)]

	if not v then
		return 0, true
	end

	local dataInfo, v2 = Utils.getDataInfo(p, p2)
	buffer.writeu8(buf, offset, dataInfo)
	v(buf, p, offset + 1, p2)
	return 1 + v2, false
end

function Serialize.table(buf, items, p, p2)
	local v = p

	local function w(p3)
		local v2 = buf
		local v3 = v
		local v4 = p2
		local v5 = Serialize[typeof(p3)]
		local v6, flag

		if v5 then
			local dataInfo, v7 = Utils.getDataInfo(p3, v4)
			buffer.writeu8(v2, v3, dataInfo)
			v5(v2, p3, v3 + 1, v4)
			v6 = 1 + v7
			flag = false
		else
			v6 = 0
			flag = true
		end

		v += v6

		if flag then
			type_error(p2, typeof(p3)) -- equivalent call inferred; original call site unknown
		end
	end

	for k, item in items do
		if p2.keys then
			local v2 = v
			local v3 = Serialize[typeof(k)]
			local v4, flag

			if v3 then
				local dataInfo, v5 = Utils.getDataInfo(k, p2)
				buffer.writeu8(buf, v2, dataInfo)
				v3(buf, k, v2 + 1, p2)
				v4 = 1 + v5
				flag = false
			else
				v4 = 0
				flag = true
			end

			v += v4

			if flag then
				type_error(p2, typeof(k)) -- equivalent call inferred; original call site unknown
			end
		end

		local v2 = v
		local v3 = Serialize[typeof(item)]
		local v4, flag

		if v3 then
			local dataInfo, v5 = Utils.getDataInfo(item, p2)
			buffer.writeu8(buf, v2, dataInfo)
			v3(buf, item, v2 + 1, p2)
			v4 = 1 + v5
			flag = false
		else
			v4 = 0
			flag = true
		end

		v += v4

		if not flag then
			continue
		end

		type_error(p2, typeof(item)) -- equivalent call inferred; original call site unknown
	end

	buffer.writeu8(buf, v + 1, 0)
end

function Serialize.Instance(buf, instance, offset, p)
	if not p.writeInstanceAsCopy then
		buffer.writeu16(buf, offset, (instance:GetAttribute("UniqueId")))
		return
	end

	local v = {
		instance.ClassName,
		instance.Name,
		instance:GetAttributes(),
		instance:GetTags(),
		Utils.Properties.getProperties(instance),
		instance:GetChildren()
	}
	Serialize.table(buf, v, offset, p)
end

return Serialize