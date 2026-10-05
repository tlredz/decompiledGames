local copy = buffer.copy
local create = buffer.create
local fill = buffer.fill
local len = buffer.len
local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local random = math.random

local function nonPad(p)
	return p
end

local Pads = {
	None = table.freeze({
		Pad = nonPad,
		Unpad = nonPad,
		Overwrite = false
	})
}

local function anxPad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)
	local v2 = v - v % p

	if buf2 then
		local v3 = len(buf2)
		assert(v + p <= v3, "Output buffer out of bounds")
		local v4 = p - v % p
		copy(buf2, 0, buf, 0, v)
		fill(buf2, v, 0, v4 - 1)
		writeu8(buf2, v2 + p - 1, v4)
		return buf2
	else
		local v3 = v2 + p
		local buf3 = create(v3)
		copy(buf3, 0, buf, 0, v)
		writeu8(buf3, v3 - 1, p - v % p)
		return buf3
	end
end

local function anxUnpad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)
	local v3 = readu8(buf, v - 1)
	local v4 = v - v3
	local v5

	if v3 > 0 then
		v5 = v3 <= p
	else
		v5 = false
	end

	assert(v5, "Got unexpected padding")

	for i = v4, v - 2 do
		if readu8(buf, i) ~= 0 then
			error("Got unexpected padding")
		end
	end

	if buf2 then
		assert(v4 <= len(buf2), "Output buffer out of bounds")
	else
		buf2 = create(v4)
	end

	copy(buf2, 0, buf, 0, v4)
	return buf2
end

local function i10Pad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)
	local v2 = v - v % p

	if buf2 then
		local v3 = len(buf2)
		assert(v + p <= v3, "Output buffer out of bounds")
	else
		buf2 = create(v2 + p)
	end

	copy(buf2, 0, buf, 0, v)

	for i = v, v2 + p - 2 do
		writeu8(buf2, i, (random(0, 255)))
	end

	writeu8(buf2, v2 + p - 1, p - v % p)
	return buf2
end

local function i10Unpad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)
	local v3 = readu8(buf, v - 1)
	local v4 = v - v3
	local v5

	if v3 > 0 then
		v5 = v3 <= p
	else
		v5 = false
	end

	assert(v5, "Got unexpected padding")

	if buf2 then
		assert(v4 <= len(buf2), "Output buffer out of bounds")
	else
		buf2 = create(v4)
	end

	copy(buf2, 0, buf, 0, v4)
	return buf2
end

local function pksPad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)
	local v2 = v - v % p

	if buf2 then
		local v3 = len(buf2)
		assert(v + p <= v3, "Output buffer out of bounds")
	else
		buf2 = create(v2 + p)
	end

	local v3 = p - v % p
	copy(buf2, 0, buf, 0, v)
	fill(buf2, v, v3, v3)
	return buf2
end

local function pksUnpad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)
	local v3 = readu8(buf, v - 1)
	local v4 = v - v3
	local v5

	if v3 > 0 then
		v5 = v3 <= p
	else
		v5 = false
	end

	assert(v5, "Got unexpected padding")

	for i = v4, v - 2 do
		if readu8(buf, i) ~= v3 then
			error("Got unexpected padding")
		end
	end

	if buf2 then
		assert(v4 <= len(buf2), "Output buffer out of bounds")
	else
		buf2 = create(v4)
	end

	copy(buf2, 0, buf, 0, v4)
	return buf2
end

local function ii7Pad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)

	if buf2 then
		local v2 = len(buf2)
		assert(v + p <= v2, "Output buffer out of bounds")
		fill(buf2, v + 1, 0, p - v % p - 1)
	else
		buf2 = create(v + p - v % p)
	end

	copy(buf2, 0, buf, 0, v)
	writeu8(buf2, v, 128)
	return buf2
end

local function ii7Unpad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf) - 1

	for i = v, v - p, -1 do
		local v2 = readu8(buf, i)

		if v2 == 128 then
			if buf2 then
				assert(i <= len(buf2), "Output buffer out of bounds")
			else
				buf2 = create(i)
			end

			copy(buf2, 0, buf, 0, i)
			return buf2
		else
			assert(v2 == 0, "Got unexpected padding")
		end
	end

	error("Got unexpected padding")
	return create(0)
end

local function zroPad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf)

	if buf2 then
		local v2 = len(buf2)
		assert(v + p <= v2, "Output buffer out of bounds")
		fill(buf2, v, 0, p - v % p)
	else
		buf2 = create(v + p - v % p)
	end

	copy(buf2, 0, buf, 0, v)
	return buf2
end

local function zroUnpad(buf: buffer, buf2: buffer, p: number)
	local v = len(buf) - 1

	for i = v, v - p, -1 do
		if readu8(buf, i) ~= 0 then
			continue
		end

		local v2 = i + 1

		if buf2 then
			assert(v2 <= len(buf2), "Output buffer out of bounds")
		else
			buf2 = create(v2)
		end

		copy(buf2, 0, buf, 0, v2)
		return buf2
	end

	copy(buf2, 0, buf, 0, v - p - 1)
	return buf2
end

local v = {
	__index = function(_, p: string)
		if p == "AnsiX923" then
			return {
				Pad = anxPad,
				Unpad = anxPad,
				Overwrite = nil
			}
		elseif p == "Iso10126" then
			return {
				Pad = i10Pad,
				Unpad = i10Unpad,
				Overwrite = nil
			}
		elseif p == "Pkcs7" then
			return {
				Pad = pksPad,
				Unpad = pksUnpad,
				Overwrite = nil
			}
		elseif p == "Iso7816_4" then
			return {
				Pad = ii7Pad,
				Unpad = ii7Unpad,
				Overwrite = nil
			}
		elseif p == "Zero" then
			return {
				Pad = zroPad,
				Unpad = zroUnpad,
				Overwrite = nil
			}
		end

		return nil
	end,
	__newindex = function() end
}
setmetatable(Pads, v)
Pads.AnsiX923 = {}
Pads.Iso10126 = {}
Pads.Pkcs7 = {}
Pads.Iso7816_4 = {}
Pads.Zero = {}
table.freeze(Pads)
v.__metatable = "This metatable is locked"
return Pads