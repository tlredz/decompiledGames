local assert2 = assert
local error2 = error
local copy = buffer.copy
local create = buffer.create
local fill = buffer.fill
local len = buffer.len
local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local random = math.random
local freeze = table.freeze

local function nonPad(p)
	return p
end

local Pads = {
	None = freeze({
		Pad = nonPad,
		Unpad = nonPad,
		Overwrite = false
	})
}

local function anxPad(p, p2, p3)
	local v = len(p)
	local v2 = v - v % p3

	if p2 then
		local v3 = len(p2)
		assert2(v + p3 <= v3, "Output buffer out of bounds")
		local v5 = p3 - v % p3
		copy(p2, 0, p, 0, v)
		fill(p2, v, 0, v5 - 1)
		writeu8(p2, v2 + p3 - 1, v5)
		return p2
	else
		local v3 = v2 + p3
		local buf = create(v3)
		copy(buf, 0, p, 0, v)
		writeu8(buf, v3 - 1, p3 - v % p3)
		return buf
	end
end

local function anxUnpad(p, buf, p2)
	local v = len(p)
	local v3 = readu8(p, v - 1)
	local v4 = v - v3
	assert2(v3 > 0 and v3 <= p2, "Got unexpected padding")

	for i = v4, v - 2 do
		if readu8(p, i) ~= 0 then
			error2("Got unexpected padding")
		end
	end

	if buf then
		assert2(v4 <= len(buf), "Output buffer out of bounds")
	else
		buf = create(v4)
	end

	copy(buf, 0, p, 0, v4)
	return buf
end

local function i10Pad(p, buf, p2)
	local v = len(p)
	local v2 = v - v % p2

	if buf then
		local v3 = len(buf)
		assert2(v + p2 <= v3, "Output buffer out of bounds")
	else
		buf = create(v2 + p2)
	end

	copy(buf, 0, p, 0, v)

	for i = v, v2 + p2 - 2 do
		writeu8(buf, i, (random(0, 255)))
	end

	writeu8(buf, v2 + p2 - 1, p2 - v % p2)
	return buf
end

local function i10Unpad(p, buf, p2)
	local v = len(p)
	local v3 = readu8(p, v - 1)
	local v4 = v - v3
	assert2(v3 > 0 and v3 <= p2, "Got unexpected padding")

	if buf then
		assert2(v4 <= len(buf), "Output buffer out of bounds")
	else
		buf = create(v4)
	end

	copy(buf, 0, p, 0, v4)
	return buf
end

local function pksPad(p, buf, p2)
	local v = len(p)
	local v2 = v - v % p2

	if buf then
		local v3 = len(buf)
		assert2(v + p2 <= v3, "Output buffer out of bounds")
	else
		buf = create(v2 + p2)
	end

	local v3 = p2 - v % p2
	copy(buf, 0, p, 0, v)
	fill(buf, v, v3, v3)
	return buf
end

local function pksUnpad(p, buf, p2)
	local v = len(p)
	local v3 = readu8(p, v - 1)
	local v4 = v - v3
	assert2(v3 > 0 and v3 <= p2, "Got unexpected padding")

	for i = v4, v - 2 do
		if readu8(p, i) ~= v3 then
			error2("Got unexpected padding")
		end
	end

	if buf then
		assert2(v4 <= len(buf), "Output buffer out of bounds")
	else
		buf = create(v4)
	end

	copy(buf, 0, p, 0, v4)
	return buf
end

local function ii7Pad(p, buf, p2)
	local v = len(p)

	if buf then
		local v2 = len(buf)
		assert2(v + p2 <= v2, "Output buffer out of bounds")
		fill(buf, v + 1, 0, p2 - v % p2 - 1)
	else
		buf = create(v + p2 - v % p2)
	end

	copy(buf, 0, p, 0, v)
	writeu8(buf, v, 128)
	return buf
end

local function ii7Unpad(p, buf, p2)
	local v = len(p) - 1

	for i = v, v - p2, -1 do
		local v2 = readu8(p, i)

		if v2 == 128 then
			if buf then
				assert2(i <= len(buf), "Output buffer out of bounds")
			else
				buf = create(i)
			end

			copy(buf, 0, p, 0, i)
			return buf
		else
			assert2(v2 == 0, "Got unexpected padding")
		end
	end

	error2("Got unexpected padding")
	return create(0)
end

local function zroPad(p, buf, p2)
	local v = len(p)

	if buf then
		local v2 = len(buf)
		assert2(v + p2 <= v2, "Output buffer out of bounds")
		fill(buf, v, 0, p2 - v % p2)
	else
		buf = create(v + p2 - v % p2)
	end

	copy(buf, 0, p, 0, v)
	return buf
end

local function zroUnpad(p, buf, p2)
	local v = len(p) - 1

	for i = v, v - p2, -1 do
		if readu8(p, i) ~= 0 then
			continue
		end

		local v2 = i + 1

		if buf then
			assert2(v2 <= len(buf), "Output buffer out of bounds")
		else
			buf = create(v2)
		end

		copy(buf, 0, p, 0, v2)
		return buf
	end

	copy(buf, 0, p, 0, v - p2 - 1)
	return buf
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
freeze(Pads)
v.__metatable = "This metatable is locked"
return Pads