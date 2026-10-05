local createVector = vector.create
local EncodingService = game:GetService("EncodingService")
local Track = {}
Track.__index = Track

local function readVaruint(buf: buffer, count: number)
	local total = 0
	local total2 = 0

	while true do
		local v

		if count < buffer.len(buf) then
			v = total <= 49
		else
			v = false
		end

		assert(v, "Invalid ShowForge packed varint")
		local v2 = buffer.readu8(buf, count)
		count += 1
		local v3 = bit32.band(v2, 127)
		assert(total < 49 or v3 <= 15, "ShowForge packed varint exceeds exact integer range")
		total2 += v3 * 2 ^ total

		if v2 < 128 then
			assert(total == 0 or v3 ~= 0, "ShowForge packed varint is noncanonical")
			return total2, count
		else
			total += 7
		end
	end
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function unzigzag(p: number)
	if p % 2 == 0 then
		return p / 2
	end

	return -(p + 1) / 2
end

local function octDecode(p: number, p2: number)
	local v = p / 32767
	local v2 = p2 / 32767
	local v3 = 1 - math.abs(v) - math.abs(v2)
	local v4

	if v3 < 0 then
		v4 = (1 - math.abs(v2)) * (v >= 0 and 1 or -1)
		v2 = (1 - math.abs(v)) * (v2 >= 0 and 1 or -1)
	else
		v4 = v
	end

	local vector2 = Vector3.new(v4, v2, v3)

	if vector2.Magnitude > 1e-6 then
		return vector2.Unit
	end

	return createVector(1, 0, 0)
end

function Track.decodeBase64(str: string)
	return EncodingService:Base64Decode(buffer.fromstring(str))
end

local function validateChannels(list)
	local v

	if math.abs(list[4]) <= 32767 then
		v = math.abs(list[5]) <= 32767
	else
		v = false
	end

	assert(v, "ShowForge packed direction is out of range")
	local v2

	if list[6] >= 0 then
		v2 = list[6] <= 100000
	else
		v2 = false
	end

	assert(v2, "ShowForge packed brightness is out of range")
	local v3

	if list[7] >= 0 then
		v3 = list[7] <= 255
	else
		v3 = false
	end

	assert(v3, "ShowForge packed color is out of range")
	local v4

	if list[8] >= 0 then
		v4 = list[8] <= 255
	else
		v4 = false
	end

	assert(v4, "ShowForge packed color is out of range")
	local v5

	if list[9] >= 0 then
		v5 = list[9] <= 255
	else
		v5 = false
	end

	assert(v5, "ShowForge packed color is out of range")
	local v6

	if list[10] >= 0 then
		v6 = list[10] <= 18000
	else
		v6 = false
	end

	assert(v6, "ShowForge packed angle is out of range")
	local v7

	if list[11] >= 0 then
		v7 = list[11] <= 255
	else
		v7 = false
	end

	assert(v7, "ShowForge packed opacity is out of range")
end

local function decodeInitial(value: string)
	local decodeBase64 = Track.decodeBase64(value)
	local result = table.create(11, 0)
	local v = 0

	for i = 1, 11 do
		local v2
		v2, v = readVaruint(decodeBase64, v)
		result[i] = unzigzag(v2)
	end

	assert(v == buffer.len(decodeBase64), "ShowForge initial state has trailing bytes")
	validateChannels(result)
	return result
end

local function state(p: number, fps: number, channels, hard: boolean)
	return {
		time = p / fps,
		position = Vector3.new(channels[1], channels[2], channels[3]) / 200,
		direction = octDecode(channels[4], channels[5]),
		brightness = channels[6] / 1000,
		color = Color3.fromRGB(channels[7], channels[8], channels[9]),
		angle = channels[10] / 100,
		opacity = channels[11] / 255,
		hard = hard
	}
end

function Track.decodeCompressedFolder(instance, flag: boolean?)
	debug.profilebegin("ShowForge.DecodeCompressedTrack")
	local success, result = pcall(function()
		local children = instance:GetChildren()
		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)
		local v = table.create(#children)

		for i, stringValue in ipairs(children) do
			assert(stringValue:IsA("StringValue"), "ShowForge animation contains a non-string chunk")
			v[i] = stringValue.Value
		end

		local base64Decode = EncodingService:Base64Decode(buffer.fromstring(table.concat(v)))
		local decompressedBufferSize = EncodingService:GetDecompressedBufferSize(
			base64Decode,
			Enum.CompressionAlgorithm.Zstd
		)
		assert(
			decompressedBufferSize and decompressedBufferSize <= 67108864,
			"ShowForge fixture track is invalid or too large"
		)
		local decompressBuffer = EncodingService:DecompressBuffer(base64Decode, Enum.CompressionAlgorithm.Zstd)

		if not flag then
			instance:Destroy()
		end

		return decompressBuffer
	end)
	debug.profileend()

	if not success then
		error(result, 0)
	end

	return result
end

function Track.new(buf: buffer, fps: number, value2: number, value3: string?, p: number?, flag: boolean?)
	local v

	if type(fps) == "number" and fps == fps and fps > 0 then
		v = fps < 1e999
	else
		v = false
	end

	assert(v, "ShowForge track FPS must be finite and positive")
	local sparse = type(value3) == "string"
	local v3

	if type(value2) == "number" and (sparse and 0 or 1) <= value2 then
		v3 = value2 % 1 == 0
	else
		v3 = false
	end

	assert(v3, "ShowForge track key count is invalid")
	local channelMask = not sparse and 2047 or p
	local v5

	if type(channelMask) == "number" and channelMask >= 0 and channelMask <= 2047 then
		v5 = channelMask % 1 == 0
	else
		v5 = false
	end

	assert(v5, "ShowForge track channel mask is invalid")
	local initial

	if sparse then
		initial = decodeInitial(value3)
	else
		initial = table.create(11, 0)
	end

	local self = setmetatable({
		payload = buf,
		fps = fps,
		keyCount = value2,
		channelMask = channelMask,
		sparse = sparse,
		initial = initial,
		offset = 0,
		frame = 0,
		channels = table.create(11, 0),
		decoded = 0,
		current = nil,
		next = nil,
		output = {}
	}, Track)
	self:_reset()

	if flag ~= false then
		while self:_decodeNext() do

		end

		self:_reset()
	end

	return self
end

function Track:_decodeNext()
	if self.offset >= buffer.len(self.payload) or self.decoded >= self.keyCount then
		assert(
			self.decoded == self.keyCount,
			("ShowForge track decoded %d of %d declared keys"):format(self.decoded, self.keyCount)
		)
		assert(self.offset == buffer.len(self.payload), "ShowForge track has trailing payload bytes")
		return nil
	else
		local v, offset = readVaruint(self.payload, self.offset)
		self.offset = offset
		self.frame += v

		for i = 1, 11 do
			if not (not self.sparse or bit32.band(self.channelMask, (bit32.lshift(1, i - 1))) ~= 0) then
				continue
			end

			local v3, offset2 = readVaruint(self.payload, self.offset)
			self.offset = offset2
			self.channels[i] += unzigzag(v3)
		end

		local v3

		if self.sparse and bit32.band(self.channelMask, 1056) == 0 then
			v3 = false
		else
			assert(self.offset < buffer.len(self.payload), "Packed ShowForge key is missing flags")
			local v4 = buffer.readu8(self.payload, self.offset)
			assert(v4 <= 1, "ShowForge packed key has invalid flags")
			v3 = v4 ~= 0
			self.offset += 1
		end

		self.decoded += 1
		validateChannels(self.channels)
		return (state(self.frame, self.fps, self.channels, v3))
	end
end

function Track:_reset()
	self.offset = 0
	self.frame = 0
	self.decoded = 0

	for i = 1, 11 do
		self.channels[i] = self.initial[i]
	end

	if self.sparse then
		self.current = state(0, self.fps, self.channels, false)
	else
		self.current = self:_decodeNext()
	end

	self.next = self:_decodeNext()
end

function Track:Sample(time: number)
	if not self.current then
		return nil
	end

	if time < self.current.time then
		self:_reset()
	end

	while self.next and self.next.time <= time do
		self.current = self.next
		self.next = self:_decodeNext()
	end

	local current = self.current
	local next = self.next

	if not next then
		return current
	end

	local v = next.time - current.time
	local v2 = v <= 0 and 0 or math.clamp((time - current.time) / v, 0, 1)
	local output = self.output
	output.time = time
	output.position = current.position:Lerp(next.position, v2)
	local lerped = current.direction:Lerp(next.direction, v2)
	local direction

	if lerped.Magnitude > 1e-6 then
		direction = lerped.Unit
	else
		direction = current.direction
	end

	output.direction = direction
	output.color = current.color:Lerp(next.color, v2)
	output.angle = current.angle + (next.angle - current.angle) * v2

	if next.hard and time < next.time then
		local brightness = current.brightness
		local opacity = current.opacity
		output.brightness = brightness
		output.opacity = opacity
	else
		output.brightness = current.brightness + (next.brightness - current.brightness) * v2
		output.opacity = current.opacity + (next.opacity - current.opacity) * v2
	end

	output.hard = false
	return output
end

return Track