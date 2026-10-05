local parent = script.Parent.Parent
local Squash = require(parent.Squash)
local ArraySquash = require(parent.ArraySquash)
local accumulated = ArraySquash.Accumulated
local interleaved = ArraySquash.Interleaved
local I32 = accumulated.I32
local v = Squash.u8()
local u16 = Squash.u16()
local u32 = Squash.u32()
local f32 = Squash.f32()
local vlq = Squash.vlq()
local string = Squash.string()
local cFrame = Squash.CFrame(f32)
local boolean = Squash.boolean()
local frozen = table.freeze({
	Attributes = 1,
	Axes = 2,
	Bool = 3,
	BrickColor = 4,
	CFrame = 5,
	Color3 = 6,
	Color3uint8 = 7,
	ColorSequence = 8,
	Content = 9,
	ContentId = 10,
	EnumItem = 11,
	Faces = 12,
	Float32 = 13,
	Float64 = 14,
	Font = 15,
	Int32 = 16,
	Int64 = 17,
	NumberSequence = 18,
	PhysicalProperties = 19,
	Ray = 20,
	Rect = 21,
	Region3int16 = 22,
	String = 23,
	UDim = 24,
	UDim2 = 25,
	Tags = 26,
	Vector2 = 27,
	NumberRange = 28,
	Vector3 = 29,
	Vector3int16 = 30,
	OptionalCFrame = 31,
	Ref = 32
})
local typeIds = {}
local fn
local fn2

for k, v3 in pairs(frozen) do
	typeIds[v3] = k
end

local frozen2 = table.freeze({
	boolean = "Bool",
	number = "Float64",
	string = "String",
	bool = "Bool",
	int = "Int32",
	int64 = "Int64",
	float = "Float32",
	double = "Float64",
	OptionalCoordinateFrame = "OptionalCFrame",
	CoordinateFrame = "CFrame",
	RefType = "Ref",
	Rect2D = "Rect",
	Enum = "EnumItem"
})
local v3 = {
	Attributes = {
		des = function(p)
			local result = {}

			for _ = 1, vlq.des(p) do
				local des = string.des(p)
				local v4 = typeIds[u16.des(p)]
				local v5, v6 = fn(p, v4)

				if v5 then
					result[des] = v6
				else
					local formatted = ("ModelSquash - Could not decode attribute value of type %q: %s"):format(
						typeof(v6),
						(tostring(v6))
					)
					warn(formatted)
				end
			end

			return result
		end,
		ser = function(p, items)
			local count = 0

			for k in items do
				if k ~= "__msref" then
					count += 1
				end
			end

			for k, item in items do
				if k == "__msref" then
					continue
				end

				local typeName = typeof(item)
				local v4 = frozen2[typeName] or typeName

				if not frozen[v4] then
					continue
				end

				fn2(p, v4, item)
				u16.ser(p, frozen[v4])
				string.ser(p, k)
			end

			vlq.ser(p, count)
		end
	},
	Axes = Squash.Axes(),
	BrickColor = Squash.BrickColor(),
	Bool = boolean,
	CFrame = cFrame,
	Color3 = Squash.Color3(),
	Color3uint8 = {
		des = function(p)
			local des = v.des(p)
			local des2 = v.des(p)
			local des3 = v.des(p)
			return Color3.fromRGB(des, des2, des3)
		end,
		ser = function(p, color: Color3)
			local v4 = math.clamp(math.round(color.R * 255), 0, 255)
			local v5 = math.clamp(math.round(color.G * 255), 0, 255)
			local v6 = math.clamp(math.round(color.B * 255), 0, 255)
			v.ser(p, v6)
			v.ser(p, v5)
			v.ser(p, v4)
		end
	},
	ColorSequence = Squash.ColorSequence(),
	Content = {
		des = function(p)
			local des = Squash.EnumItem(Enum.ContentSourceType).des(p)

			if des == Enum.ContentSourceType.Uri then
				local des2 = string.des(p)
				return Content.fromUri(des2)
			end

			if des ~= Enum.ContentSourceType.None then
				warn("Deserializing Content of SourceType", des.Name, "is not supported!")
			end

			return Content.none
		end,
		ser = function(p, p2)
			local sourceType = p2.SourceType

			if sourceType == Enum.ContentSourceType.Uri then
				string.ser(p, p2.Uri or "")
			elseif sourceType ~= Enum.ContentSourceType.None then
				warn("Serializing Content of SourceType", tostring(sourceType), "is not supported!")
			end

			Squash.EnumItem(Enum.ContentSourceType).ser(p, sourceType)
		end
	},
	ContentId = string,
	EnumItem = {
		des = function(p)
			local des = string.des(p)
			local des2 = u32.des(p)
			return Enum[des]:FromValue(des2)
		end,
		ser = function(p, p2)
			u32.ser(p, p2.Value)
			string.ser(p, (tostring(p2.EnumType)))
		end
	},
	Faces = Squash.Faces(),
	Float32 = f32,
	Float64 = Squash.f64(),
	Font = Squash.Font(),
	Int32 = Squash.i32(),
	Int64 = Squash.i64(),
	NumberSequence = Squash.NumberSequence(f32),
	NumberRange = Squash.NumberRange(f32),
	OptionalCFrame = {
		des = function(p)
			if boolean.des(p) then
				return cFrame.des(p)
			end

			return nil
		end,
		ser = function(p, p2)
			if p2 ~= nil then
				cFrame.ser(p, p2)
			end

			boolean.ser(p, p2 ~= nil)
		end
	},
	PhysicalProperties = Squash.opt(Squash.PhysicalProperties()),
	Ray = Squash.Ray(f32),
	Rect = Squash.Rect(f32),
	Region3int16 = Squash.Region3int16(),
	String = string,
	UDim = Squash.UDim(f32),
	UDim2 = Squash.UDim2(f32),
	Ref = {
		des = vlq.des,
		ser = function(p, instance)
			if instance then
				local __msref = instance:GetAttribute("__msref")

				if type(__msref) == "number" then
					vlq.ser(p, __msref)
					return
				end
			end

			vlq.ser(p, 0)
		end
	},
	Tags = {
		ser = function(p, list)
			for i = #list, 1, -1 do
				local v4 = list[i]
				string.ser(p, v4)
			end

			vlq.ser(p, #list)
		end,
		des = function(p)
			local des = vlq.des(p)
			local result = table.create(des, "")

			for i = 1, des do
				result[i] = string.des(p)
			end

			return result
		end
	},
	Vector2 = Squash.Vector2(f32),
	Vector3 = Squash.Vector3(f32),
	Vector3int16 = Squash.Vector3int16()
}
local v4 = {
	Bool = Squash.array(boolean),
	BrickColor = interleaved.BrickColor,
	Color3 = interleaved.Color3,
	Float32 = interleaved.F32,
	Int32 = interleaved.I32,
	EnumItem = {
		ser = function(p, list)
			local v5 = {}

			for i = 1, #list do
				v5[i] = list[i].Value
			end

			local enumType = tostring(list[1].EnumType)
			interleaved.I32.ser(p, v5)
			string.ser(p, enumType)
		end,
		des = function(p)
			local des = string.des(p)
			local v5 = Enum[des]
			local des2 = interleaved.I32.des(p)
			local result = {}

			for i = 1, #des2 do
				result[i] = v5:FromValue(des2[i])
			end

			return result
		end
	},
	UDim = interleaved.UDim,
	UDim2 = interleaved.UDim2,
	Rect = interleaved.Rect,
	Ref = {
		des = I32.des,
		ser = function(p, list)
			local v5 = {}

			for i = 1, #list do
				local v6 = list[i]
				local v7 = 0

				if v6 then
					local __msref = v6:GetAttribute("__msref")

					if type(__msref) == "number" then
						v7 = __msref
					end
				end

				v5[i] = v7
			end

			I32.ser(p, v5)
		end
	},
	String = {
		ser = function(p, list)
			local v5 = {}
			local v6 = {}
			local v7 = {}

			for i, v8 in ipairs(list) do
				if v5[v8] == nil then
					local v9 = #v7 + 1
					v7[v9] = v8
					v5[v8] = v9
				end

				v6[i] = v5[v8]
			end

			for i = #v6, 1, -1 do
				local v8 = v6[i]
				vlq.ser(p, v8)
			end

			vlq.ser(p, #v6)

			for i = #v7, 1, -1 do
				local v8 = v7[i]
				string.ser(p, v8)
			end

			vlq.ser(p, #v7)
		end,
		des = function(p)
			local des = vlq.des(p)
			local v5 = table.create(des, "")

			for i = 1, des do
				v5[i] = string.des(p)
			end

			local des2 = vlq.des(p)
			local result = table.create(des2, "")

			for i = 1, des2 do
				result[i] = v5[vlq.des(p)]
			end

			return result
		end
	},
	Vector2 = interleaved.Vector2,
	Vector3 = interleaved.Vector3
}

fn = function(p, p2: string)
	local v5 = v3[p2]

	if v5 then
		return true, v5.des(p)
	end

	return false, ("ModelSquash - Missing decoder for property type %q"):format(p2)
end

local function fn3(p, p2)
	local v5 = v4[p2]

	if v5 then
		return true, v5.des(p)
	end

	local v6 = v3[p2]

	if v6 == nil then
		return false, "Couldn't decode values: " .. tostring(p2)
	end

	return true, Squash.array(v6).des(p)
end

fn2 = function(p, p2: string, item)
	local v5 = v3[p2]

	if not v5 then
		return false, ("ModelSquash - Missing encoder for property type %q"):format(p2)
	end

	v5.ser(p, item)
	return true
end

local function fn4(p, p2, p3)
	assert(p2 ~= nil, "ModelSquash - Property type descriptor is required")

	if v3[p2] == nil and v4[p2] == nil then
		p2 = frozen2[p2] or p2
	end

	local v5 = v4[p2]

	if v5 then
		v5.ser(p, p3)
		return true
	end

	local v6 = v3[p2]

	if not v6 then
		return false, ("ModelSquash - Missing encoder for property type %q"):format(p2)
	end

	Squash.array(v6).ser(p, p3)
	return true
end

local function getTypeIndexFromEngineType(p: string)
	local v5 = frozen[p]

	if v5 == nil then
		local v6 = frozen2[p]

		if v6 then
			return frozen[v6]
		end
	end

	return v5
end

return table.freeze({
	GetTypeIndexFromEngineType = getTypeIndexFromEngineType,
	TypeAliases = frozen2,
	TypeEnum = frozen,
	TypeIds = typeIds,
	DecompressArray = fn3,
	CompressArray = fn4,
	Decompress = fn,
	Compress = fn2
})