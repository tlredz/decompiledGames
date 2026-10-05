local AES = require(game.ReplicatedStorage.UserGenerated.IO.Crypto.AES)
local Base64 = require(game.ReplicatedStorage.UserGenerated.IO.Base64)
local HMAC = require(game.ReplicatedStorage.UserGenerated.IO.Crypto.HMAC)
local ISAAC = require(game.ReplicatedStorage.UserGenerated.Randoms.ISAAC)
local SHA256 = require(game.ReplicatedStorage.UserGenerated.IO.Crypto.SHA256)
require(game.ReplicatedStorage.UserGenerated.IO.Crypto.Hash)
local unique = ISAAC.Unique()

local function GetRandomBytes(size: number)
	local buf = buffer.create(size)

	for i = 0, size - 1 do
		buffer.writeu8(buf, i, (unique:NextInteger(0, 255)))
	end

	return buf
end

local function PBKDF2(buf: buffer, buf2: buffer, size: number, p: number, p2)
	local derive = HMAC.Derive(p2, buf)
	local outputSize = p2.OutputSize
	local v = math.ceil(size / outputSize)
	local buf3 = buffer.create(size)
	local total = 0

	for i = 1, v do
		local buf4 = buffer.create(buffer.len(buf2) + 4)
		buffer.copy(buf4, 0, buf2)
		buffer.writeu32(buf4, buffer.len(buf2), (bit32.byteswap(i)))
		local digestBuffer = derive.DigestBuffer(buf4)
		local buf5 = buffer.create(buffer.len(digestBuffer))
		buffer.copy(buf5, 0, digestBuffer)

		for _ = 2, p do
			digestBuffer = derive.DigestBuffer(digestBuffer)

			for i2 = 0, buffer.len(digestBuffer) - 1 do
				buffer.writeu8(buf5, i2, (bit32.bxor(buffer.readu8(buf5, i2), (buffer.readu8(digestBuffer, i2)))))
			end
		end

		local v2 = math.min(outputSize, size - total)
		buffer.copy(buf3, total, buf5, 0, v2)
		total += v2
	end

	return buf3
end

local function ApplyPKCS7Padding(buffer2: buffer)
	local v = buffer.len(buffer2)
	local v2 = 16 - v % 16
	local v3 = v + v2
	local buf = buffer.create(v3)
	buffer.copy(buf, 0, buffer2)

	for i = v, v3 - 1 do
		buffer.writeu8(buf, i, v2)
	end

	return buf
end

local function RemovePKCS7Padding(decrypt: buffer)
	local v = buffer.len(decrypt)

	if v == 0 then
		error("Invalid padding: empty input")
	end

	local v2 = buffer.readu8(decrypt, v - 1)

	if v2 < 1 or v2 > 16 then
		error("Invalid padding length: " .. v2)
	end

	for i = v - v2, v - 1 do
		if buffer.readu8(decrypt, i) ~= v2 then
			error("Invalid padding")
		end
	end

	local v3 = v - v2
	local buf = buffer.create(v3)
	buffer.copy(buf, 0, decrypt, 0, v3)
	return buf
end

local function Encrypt(str: string, buf: buffer, p)
	local buffer2 = buffer.fromstring(str)
	local buf2 = GetRandomBytes(8)
	local buf3 = PBKDF2(buf, buf2, 48, 10000, p or SHA256)
	local buf4 = buffer.create(32)
	buffer.copy(buf4, 0, buf3, 0, 32)
	local buf5 = buffer.create(16)
	buffer.copy(buf5, 0, buf3, 32, 16)
	local buf6 = ApplyPKCS7Padding(buffer2)
	local encrypt = AES.new(buffer.tostring(buf4), AES.modes.CBC, AES.pads.None):Encrypt(buf6, nil, buf5)
	local v2 = 16 + buffer.len(encrypt)
	local buf7 = buffer.create(v2)
	buffer.writestring(buf7, 0, "Salted__")
	buffer.copy(buf7, 8, buf2)
	buffer.copy(buf7, 16, encrypt)
	return buffer.tostring(Base64.EncodeBuffer(buf7))
end

local function Decrypt(str: string, buf: buffer, p)
	local decodeBuffer = Base64.DecodeBuffer(buffer.fromstring(str))

	if buffer.len(decodeBuffer) < 16 then
		error("Invalid data: too short")
	end

	local buf2 = buffer.create(8)
	buffer.copy(buf2, 0, decodeBuffer, 0, 8)

	if buffer.tostring(buf2) ~= "Salted__" then
		error("Invalid data: Missing 'Salted__' header")
	end

	local buf3 = buffer.create(8)
	buffer.copy(buf3, 0, decodeBuffer, 8, 8)
	local v2 = buffer.len(decodeBuffer) - 16
	local buf4 = buffer.create(v2)
	buffer.copy(buf4, 0, decodeBuffer, 16, v2)
	local buf5 = PBKDF2(buf, buf3, 48, 10000, p or SHA256)
	local buf6 = buffer.create(32)
	buffer.copy(buf6, 0, buf5, 0, 32)
	local buf7 = buffer.create(16)
	buffer.copy(buf7, 0, buf5, 32, 16)
	local buf8 = RemovePKCS7Padding(AES.new(buffer.tostring(buf6), AES.modes.CBC, AES.pads.None):Decrypt(
		buf4,
		nil,
		buf7
	))
	return buffer.tostring(buf8)
end

local SaltedEncryption = {
	Encrypt = Encrypt,
	Decrypt = Decrypt,
	EncryptString = function(p: string, str: string, p2)
		return Encrypt(p, buffer.fromstring(str), p2)
	end,
	DecryptString = function(p: string, str: string, p2)
		return Decrypt(p, buffer.fromstring(str), p2)
	end,
	PBKDF2 = PBKDF2,
	GetRandomBytes = GetRandomBytes
}
table.freeze(SaltedEncryption)
return SaltedEncryption