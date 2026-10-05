local function writei8(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 1 then
		local buf = buffer.create(v2 + 1 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writei8(state.buffer, state.cursor, value)
	state.cursor += 1
end

local function readi8(state)
	local v2 = buffer.readi8(state.buffer, state.cursor)
	state.cursor += 1
	return v2
end

local function writei16(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 2 then
		local buf = buffer.create(v2 + 2 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writei16(state.buffer, state.cursor, value)
	state.cursor += 2
end

local function readi16(state)
	local v2 = buffer.readi16(state.buffer, state.cursor)
	state.cursor += 2
	return v2
end

local function writei32(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 4 then
		local buf = buffer.create(v2 + 4 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writei32(state.buffer, state.cursor, value)
	state.cursor += 4
end

local function readi32(state)
	local v2 = buffer.readi32(state.buffer, state.cursor)
	state.cursor += 4
	return v2
end

local function writeu8(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 1 then
		local buf = buffer.create(v2 + 1 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writeu8(state.buffer, state.cursor, value)
	state.cursor += 1
end

local function readu8(state)
	local v2 = buffer.readu8(state.buffer, state.cursor)
	state.cursor += 1
	return v2
end

local function writeu16(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 2 then
		local buf = buffer.create(v2 + 2 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writeu16(state.buffer, state.cursor, value)
	state.cursor += 2
end

local function readu16(state)
	local v2 = buffer.readu16(state.buffer, state.cursor)
	state.cursor += 2
	return v2
end

local function writeu32(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 4 then
		local buf = buffer.create(v2 + 4 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writeu32(state.buffer, state.cursor, value)
	state.cursor += 4
end

local function readu32(state)
	local v2 = buffer.readu32(state.buffer, state.cursor)
	state.cursor += 4
	return v2
end

local function writef32(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 4 then
		local buf = buffer.create(v2 + 4 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writef32(state.buffer, state.cursor, value)
	state.cursor += 4
end

local function readf32(state)
	local v2 = buffer.readf32(state.buffer, state.cursor)
	state.cursor += 4
	return v2
end

local function writef64(state, value: number)
	local v2 = buffer.len(state.buffer)

	if v2 < state.cursor + 8 then
		local buf = buffer.create(v2 + 8 + state.allocstep)
		buffer.copy(buf, 0, state.buffer)
		state.buffer = buf
	end

	buffer.writef64(state.buffer, state.cursor, value)
	state.cursor += 8
end

local function readf64(state)
	local v2 = buffer.readf64(state.buffer, state.cursor)
	state.cursor += 8
	return v2
end

return table.freeze({
	create = function(size: number, value: number?)
		return {
			buffer = buffer.create(size),
			cursor = 0,
			allocstep = value or 10240
		}
	end,
	fromstring = function(str: string, value: number?)
		return {
			buffer = buffer.fromstring(str),
			cursor = 0,
			allocstep = value or 10240
		}
	end,
	frombuffer = function(buf: buffer, value: number?)
		return {
			buffer = buf,
			cursor = 0,
			allocstep = value or 10240
		}
	end,
	resizeIfNeeded = function(state, p: number)
		local v2 = buffer.len(state.buffer)

		if v2 < state.cursor + p then
			local buf = buffer.create(v2 + p + state.allocstep)
			buffer.copy(buf, 0, state.buffer)
			state.buffer = buf
		end
	end,
	fns = {
		i8 = {
			write = writei8,
			read = readi8
		},
		i16 = {
			write = writei16,
			read = readi16
		},
		i32 = {
			write = writei32,
			read = readi32
		},
		u8 = {
			write = writeu8,
			read = readu8
		},
		u16 = {
			write = writeu16,
			read = readu16
		},
		u32 = {
			write = writeu32,
			read = readu32
		},
		f32 = {
			write = writef32,
			read = readf32
		},
		f64 = {
			write = writef64,
			read = readf64
		}
	},
	readi8 = readi8,
	writei8 = writei8,
	readi16 = readi16,
	writei16 = writei16,
	readi32 = readi32,
	writei32 = writei32,
	readu8 = readu8,
	writeu8 = writeu8,
	readu16 = readu16,
	writeu16 = writeu16,
	readu32 = readu32,
	writeu32 = writeu32,
	readf32 = readf32,
	writef32 = writef32,
	readf64 = readf64,
	writef64 = writef64,
	readstring = function(state, count: number)
		local v2 = buffer.readstring(state.buffer, state.cursor, count)
		state.cursor += count
		return v2
	end,
	writestring = function(state, str: string, count: number?)
		local v2 = count or #str
		local v3 = buffer.len(state.buffer)

		if v3 < state.cursor + v2 then
			local buf = buffer.create(v3 + v2 + state.allocstep)
			buffer.copy(buf, 0, state.buffer)
			state.buffer = buf
		end

		buffer.writestring(state.buffer, state.cursor, str, count)
		state.cursor += count or #str
	end,
	fill = function(state, value: number, count: number?)
		if count then
			local v2 = buffer.len(state.buffer)

			if v2 < state.cursor + count then
				local buf = buffer.create(v2 + count + state.allocstep)
				buffer.copy(buf, 0, state.buffer)
				state.buffer = buf
			end
		end

		buffer.fill(state.buffer, state.cursor, value, count)
		local cursor

		if count then
			cursor = state.cursor + count
		else
			cursor = buffer.len(state.buffer)
		end

		state.cursor = cursor
	end
})