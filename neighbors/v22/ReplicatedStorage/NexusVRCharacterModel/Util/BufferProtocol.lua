local v = {
	{
		Name = "UpdateTime",
		Type = "number"
	},
	{
		Name = "CurrentWalkspeed",
		Type = "number"
	},
	{
		Name = "HeadCFrame",
		Type = "CFrame"
	},
	{
		Name = "LeftHandCFrame",
		Type = "CFrame"
	},
	{
		Name = "RightHandCFrame",
		Type = "CFrame"
	},
	{
		Name = "LeftFootCFrame",
		Type = "CFrame"
	},
	{
		Name = "RightFootCFrame",
		Type = "CFrame"
	}
}
local v2 = {
	number = 8,
	CFrame = 28
}
local BufferProtocol = {
	Serialize = function(p)
		local total = 1
		local v3 = {}

		for k, v4 in v do
			local v5 = p[v4.Name]

			if not (v5 and typeof(v5) == v4.Type) then
				continue
			end

			local length = v2[v4.Type]
			total += 1 + v2[v4.Type]
			table.insert(v3, {
				Index = k,
				Length = length,
				Data = v5
			})
		end

		local buf = buffer.create(total)
		buffer.writei8(buf, 0, #v3)
		local v4 = 1

		for _, v5 in v3 do
			buffer.writei8(buf, v4, v5.Index)
			local v6 = v4 + 1
			local data = v5.Data
			local typeName = typeof(data)

			if typeName == "number" then
				buffer.writef64(buf, v6, data)
			elseif typeName == "CFrame" then
				local position = data.Position
				local axisAngle, v7 = data:ToAxisAngle()
				buffer.writef32(buf, v6, position.X)
				buffer.writef32(buf, v6 + 4, position.Y)
				buffer.writef32(buf, v6 + 8, position.Z)
				buffer.writef32(buf, v6 + 12, axisAngle.X)
				buffer.writef32(buf, v6 + 16, axisAngle.Y)
				buffer.writef32(buf, v6 + 20, axisAngle.Z)
				buffer.writef32(buf, v6 + 24, v7)
			end

			v4 = v6 + v5.Length
		end

		return buf
	end,
	DeserializeSection = function(buf: buffer, offset: number)
		local v3 = buffer.readi8(buf, offset)
		local v4 = offset + 1
		local result = {}

		for _ = 1, v3 do
			local v5 = v[buffer.readi8(buf, v4)]
			v4 += 1

			if v5.Type == "number" then
				result[v5.Name] = buffer.readf64(buf, v4)
				v4 += 8
			elseif v5.Type == "CFrame" then
				local cframe = CFrame.new(
					buffer.readf32(buf, v4),
					buffer.readf32(buf, v4 + 4),
					(buffer.readf32(buf, v4 + 8))
				)
				local vector = Vector3.new(
					buffer.readf32(buf, v4 + 12),
					buffer.readf32(buf, v4 + 16),
					(buffer.readf32(buf, v4 + 20))
				)
				local v6 = buffer.readf32(buf, v4 + 24)
				result[v5.Name] = cframe * CFrame.fromAxisAngle(vector, v6)
				v4 += 28
			end
		end

		return result, v4 - offset
	end
}

function BufferProtocol.Deserialize(buf: buffer)
	local v3 = buffer.len(buf)
	local v4 = 0
	local result = {}

	while v4 < v3 do
		local v5 = buffer.readf64(buf, v4)
		local v6 = v4 + 8
		local deserializeSection, v7 = BufferProtocol.DeserializeSection(buf, v6)
		result[v5] = deserializeSection
		v4 = v6 + v7
	end

	return result
end

return BufferProtocol