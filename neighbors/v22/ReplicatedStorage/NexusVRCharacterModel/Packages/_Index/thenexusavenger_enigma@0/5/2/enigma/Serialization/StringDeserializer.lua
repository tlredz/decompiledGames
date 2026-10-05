local StringDeserializer = {}
StringDeserializer.__index = StringDeserializer

function StringDeserializer.new(value: string)
	return (setmetatable({
		Index = 1,
		Data = string.split(value, "|")
	}, StringDeserializer))
end

function StringDeserializer:ReadString()
	local index = self.Index

	if not self.Data[index] then
		error("Reached end of serialized string.")
	end

	self.Index += 1
	return self.Data[index]
end

function StringDeserializer:ReadNumber()
	return (tonumber(self:ReadString()))
end

function StringDeserializer:ReadVector3()
	return (Vector3.new(self:ReadNumber(), self:ReadNumber(), self:ReadNumber()))
end

function StringDeserializer:ReadQuaternion()
	return {
		X = self:ReadNumber(),
		Y = self:ReadNumber(),
		Z = self:ReadNumber(),
		W = self:ReadNumber()
	}
end

return StringDeserializer