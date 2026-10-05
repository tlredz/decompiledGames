require(script.Parent.Types)
local DataTypeBuffer = {
	DataTypesToString = {
		[BrickColor] = "BrickColor",
		[CFrame] = "CFrame",
		[Color3] = "Color3",
		[DateTime] = "DateTime",
		[Ray] = "Ray",
		[Rect] = "Rect",
		[Region3] = "Region3",
		[Region3int16] = "Region3int16",
		[UDim] = "UDim",
		[UDim2] = "UDim2",
		[Vector2] = "Vector2",
		[Vector3] = "Vector3",
		[Vector2int16] = "Vector2int16",
		[Vector3int16] = "Vector3int16"
	},
	ReadWrite = {}
}
DataTypeBuffer.ReadWrite.BrickColor = {
	write = function(object, p)
		object:WriteUInt16(p.Number)
	end,
	read = function(object)
		local uInt16 = object:ReadUInt16()
		return BrickColor.new(uInt16)
	end
}
DataTypeBuffer.ReadWrite.CFrame = {
	write = function(p, cframe: CFrame)
		DataTypeBuffer.ReadWrite.Vector3.write(p, cframe.Position)
		DataTypeBuffer.ReadWrite.Vector3.write(p, cframe.XVector)
		DataTypeBuffer.ReadWrite.Vector3.write(p, cframe.YVector)
		DataTypeBuffer.ReadWrite.Vector3.write(p, cframe.ZVector)
	end,
	read = function(p)
		local v2 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		local v3 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		local v4 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		local v5 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		return CFrame.fromMatrix(v2, v3, v4, v5)
	end
}
DataTypeBuffer.ReadWrite.Color3 = {
	write = function(object, color: Color3)
		object:WriteFloat32(color.R)
		object:WriteFloat32(color.G)
		object:WriteFloat32(color.B)
	end,
	read = function(object)
		local float32 = object:ReadFloat32()
		local float322 = object:ReadFloat32()
		local float323 = object:ReadFloat32()
		return Color3.new(float32, float322, float323)
	end
}
DataTypeBuffer.ReadWrite.DateTime = {
	write = function(object, p)
		object:WriteFloat64(p.UnixTimestampMillis)
	end,
	read = function(object)
		local float64 = object:ReadFloat64()
		return DateTime.fromUnixTimestampMillis(float64)
	end
}
DataTypeBuffer.ReadWrite.Ray = {
	write = function(p, ray: Ray)
		DataTypeBuffer.ReadWrite.Vector3.write(p, ray.Origin)
		DataTypeBuffer.ReadWrite.Vector3.write(p, ray.Direction)
	end,
	read = function(p)
		local v2 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		local v3 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		return Ray.new(v2, v3)
	end
}
DataTypeBuffer.ReadWrite.Rect = {
	write = function(p, rect: Rect)
		DataTypeBuffer.ReadWrite.Vector3.write(p, rect.Min)
		DataTypeBuffer.ReadWrite.Vector3.write(p, rect.Max)
	end,
	read = function(p)
		local v2 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		local v3 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		return Rect.new(v2, v3)
	end
}
DataTypeBuffer.ReadWrite.Region3 = {
	write = function(p, instance)
		local position = instance.CFrame.Position
		local v2 = instance.Size * 0.5
		local v3 = position - v2
		local v4 = position + v2
		DataTypeBuffer.ReadWrite.Vector3.write(p, v3)
		DataTypeBuffer.ReadWrite.Vector3.write(p, v4)
	end,
	read = function(p)
		local v2 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		local v3 = DataTypeBuffer.ReadWrite.Vector3.read(p)
		return Region3.new(v2, v3)
	end
}
DataTypeBuffer.ReadWrite.Region3int16 = {
	write = function(p, p2)
		DataTypeBuffer.ReadWrite.Vector3int16.write(p, p2.Min)
		DataTypeBuffer.ReadWrite.Vector3int16.write(p, p2.Max)
	end,
	read = function(p)
		local v2 = DataTypeBuffer.ReadWrite.Vector3int16.read(p)
		local v3 = DataTypeBuffer.ReadWrite.Vector3int16.read(p)
		return Region3int16.new(v2, v3)
	end
}
DataTypeBuffer.ReadWrite.UDim = {
	write = function(object, udim: UDim)
		object:WriteFloat32(udim.Scale)
		object:WriteInt32(udim.Offset)
	end,
	read = function(object)
		local float32 = object:ReadFloat32()
		local int32 = object:ReadInt32()
		return UDim.new(float32, int32)
	end
}
DataTypeBuffer.ReadWrite.UDim2 = {
	write = function(p, udim: UDim2)
		DataTypeBuffer.ReadWrite.UDim.write(p, udim.X)
		DataTypeBuffer.ReadWrite.UDim.write(p, udim.Y)
	end,
	read = function(p)
		local v2 = DataTypeBuffer.ReadWrite.UDim.read(p)
		local v3 = DataTypeBuffer.ReadWrite.UDim.read(p)
		return UDim2.new(v2, v3)
	end
}
DataTypeBuffer.ReadWrite.Vector2 = {
	write = function(object, point: Vector2)
		object:WriteFloat32(point.X)
		object:WriteFloat32(point.Y)
	end,
	read = function(object)
		local float32 = object:ReadFloat32()
		local float322 = object:ReadFloat32()
		return Vector2.new(float32, float322)
	end
}
DataTypeBuffer.ReadWrite.Vector3 = {
	write = function(object, vector: Vector3)
		object:WriteFloat32(vector.X)
		object:WriteFloat32(vector.Y)
		object:WriteFloat32(vector.Z)
	end,
	read = function(object)
		return (Vector3.new(object:ReadFloat32(), object:ReadFloat32(), (object:ReadFloat32())))
	end
}
DataTypeBuffer.ReadWrite.Vector2int16 = {
	write = function(object, p)
		object:WriteInt16(p.X)
		object:WriteInt16(p.Y)
	end,
	read = function(object)
		local int16 = object:ReadInt16()
		local int162 = object:ReadInt16()
		return Vector2int16.new(int16, int162)
	end
}
DataTypeBuffer.ReadWrite.Vector3int16 = {
	write = function(object, data)
		object:WriteInt16(data.X)
		object:WriteInt16(data.Y)
		object:WriteInt16(data.Z)
	end,
	read = function(object)
		local int16 = object:ReadInt16()
		local int162 = object:ReadInt16()
		local int163 = object:ReadInt16()
		return Vector3int16.new(int16, int162, int163)
	end
}
return DataTypeBuffer