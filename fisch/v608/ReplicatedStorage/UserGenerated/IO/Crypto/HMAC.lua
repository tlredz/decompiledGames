require(game.ReplicatedStorage.UserGenerated.IO.Crypto.Hash)

local function Derive(data, buf: buffer)
	local blockSize = data.BlockSize

	if blockSize < buffer.len(buf) then
		buf = data.DigestBuffer(buf)
	end

	local buf2 = buffer.create(blockSize)
	buffer.copy(buf2, 0, buf)
	local buf3 = buffer.create(blockSize)
	local buf4 = buffer.create(blockSize)

	for i = 0, blockSize - 1 do
		local v = buffer.readu8(buf2, i)
		buffer.writeu8(buf3, i, (bit32.bxor(v, 92)))
		buffer.writeu8(buf4, i, (bit32.bxor(v, 54)))
	end

	local function ComputeHmac(buf5: buffer)
		local buf6 = buffer.create(blockSize + buffer.len(buf5))
		buffer.copy(buf6, 0, buf4)
		buffer.copy(buf6, blockSize, buf5)
		local digestBuffer = data.DigestBuffer(buf6)
		local buf7 = buffer.create(blockSize + buffer.len(digestBuffer))
		buffer.copy(buf7, 0, buf3)
		buffer.copy(buf7, blockSize, digestBuffer)
		return data.DigestBuffer(buf7)
	end

	return {
		Name = "HMAC-" .. data.Name,
		BlockSize = data.BlockSize,
		OutputSize = data.OutputSize,
		Digest = function(str)
			return buffer.tostring(ComputeHmac(buffer.fromstring(str)))
		end,
		DigestBuffer = ComputeHmac,
		DigestToBuffer = function(str)
			return ComputeHmac(buffer.fromstring(str))
		end
	}
end

return {
	Derive = Derive,
	DeriveString = function(p, str: string)
		return (Derive(p, buffer.fromstring(str)))
	end
}