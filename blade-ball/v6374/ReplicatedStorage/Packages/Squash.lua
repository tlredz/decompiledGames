local function newcursor(size: number?, value: number?)
	return {
		Buf = buffer.create(size or 8),
		Pos = value or 0
	}
end

local function tryrealloc(state, p: number)
	local buf = state.Buf
	local pos = state.Pos
	local v = buffer.len(buf)

	if v < pos + p then
		local v2 = math.ceil((math.log((p + pos) / v, 1.5)))
		local buf2 = buffer.create(v * 1.5 ^ v2)
		buffer.copy(buf2, 0, buf, 0)
		state.Buf = buf2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu1(state, value: number)
	buffer.writeu8(state.Buf, state.Pos, value)
	state.Pos += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu1(state)
	state.Pos -= 1
	return (buffer.readu8(state.Buf, state.Pos))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu2(state, value: number)
	buffer.writeu16(state.Buf, state.Pos, value)
	state.Pos += 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu2(state)
	state.Pos -= 2
	return (buffer.readu16(state.Buf, state.Pos))
end

local function pushu3(state, value: number)
	buffer.writeu8(state.Buf, state.Pos, value)
	buffer.writeu16(state.Buf, state.Pos + 1, value // 256)
	state.Pos += 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu3(state)
	state.Pos -= 3
	return buffer.readu8(state.Buf, state.Pos) + buffer.readu16(state.Buf, state.Pos + 1) * 256
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu4(state, value: number)
	buffer.writeu32(state.Buf, state.Pos, value)
	state.Pos += 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu4(state)
	state.Pos -= 4
	return (buffer.readu32(state.Buf, state.Pos))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu5(state, value: number)
	buffer.writeu8(state.Buf, state.Pos, value)
	buffer.writeu32(state.Buf, state.Pos + 1, value // 256)
	state.Pos += 5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu5(state)
	state.Pos -= 5
	return buffer.readu8(state.Buf, state.Pos) + buffer.readu32(state.Buf, state.Pos + 1) * 256
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu6(state, value: number)
	buffer.writeu16(state.Buf, state.Pos, value)
	buffer.writeu32(state.Buf, state.Pos + 2, value // 65536)
	state.Pos += 6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu6(state)
	state.Pos -= 6
	return buffer.readu16(state.Buf, state.Pos) + buffer.readu32(state.Buf, state.Pos + 2) * 65536
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu7(state, value: number)
	buffer.writeu8(state.Buf, state.Pos, value)
	buffer.writeu16(state.Buf, state.Pos + 1, value // 256)
	buffer.writeu32(state.Buf, state.Pos + 3, value // 16777216)
	state.Pos += 7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu7(state)
	state.Pos -= 7
	local v = buffer.readu8(state.Buf, state.Pos)
	local v2 = buffer.readu16(state.Buf, state.Pos + 1)
	local v3 = buffer.readu32(state.Buf, state.Pos + 3)
	return v + v2 * 256 + v3 * 16777216
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu8(state, value: number)
	buffer.writeu32(state.Buf, state.Pos, value)
	buffer.writeu32(state.Buf, state.Pos + 4, value // 4294967296)
	state.Pos += 8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu8(state)
	state.Pos -= 8
	return buffer.readu32(state.Buf, state.Pos) + buffer.readu32(state.Buf, state.Pos + 4) * 4294967296
end

local function pushi1(state, value: number)
	buffer.writei8(state.Buf, state.Pos, value)
	state.Pos += 1
end

local function popi1(state)
	state.Pos -= 1
	return (buffer.readi8(state.Buf, state.Pos))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi2(state, value: number)
	buffer.writei16(state.Buf, state.Pos, value)
	state.Pos += 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popi2(state)
	state.Pos -= 2
	return (buffer.readi16(state.Buf, state.Pos))
end

local function pushi3(state, p)
	local v

	if p >= 0 then
		v = p * 2
	else
		v = -p * 2 - 1
	end

	buffer.writeu8(state.Buf, state.Pos, v % 256)
	buffer.writeu16(state.Buf, state.Pos + 1, v // 256)
	state.Pos += 3
end

local function popi3(state)
	local v = popu3(state) -- equivalent call inferred; original call site unknown

	if v % 2 == 0 then
		return v // 2
	end

	return -((v + 1) // 2)
end

local function pushi4(state, value: number)
	buffer.writei32(state.Buf, state.Pos, value)
	state.Pos += 4
end

local function popi4(state)
	state.Pos -= 4
	return (buffer.readi32(state.Buf, state.Pos))
end

local function pushi5(state, p: number)
	local v

	if p >= 0 then
		v = p * 2
	else
		v = -p * 2 - 1
	end

	pushu5(state, v) -- equivalent call inferred; original call site unknown
end

local function popi5(state)
	local v = popu5(state) -- equivalent call inferred; original call site unknown

	if v % 2 == 0 then
		return v // 2
	end

	return -((v + 1) // 2)
end

local function pushi6(state, p: number)
	local v

	if p >= 0 then
		v = p * 2
	else
		v = -p * 2 - 1
	end

	pushu6(state, v) -- equivalent call inferred; original call site unknown
end

local function popi6(state)
	local v = popu6(state) -- equivalent call inferred; original call site unknown

	if v % 2 == 0 then
		return v // 2
	end

	return -((v + 1) // 2)
end

local function pushi7(state, p: number)
	local v

	if p >= 0 then
		v = p * 2
	else
		v = -p * 2 - 1
	end

	pushu7(state, v) -- equivalent call inferred; original call site unknown
end

local function popi7(state)
	local v = popu7(state) -- equivalent call inferred; original call site unknown

	if v % 2 == 0 then
		return v // 2
	end

	return -((v + 1) // 2)
end

local function pushi8(state, p: number)
	local v

	if p >= 0 then
		v = p * 2
	else
		v = -p * 2 - 1
	end

	pushu8(state, v) -- equivalent call inferred; original call site unknown
end

local function popi8(state)
	local v = popu8(state) -- equivalent call inferred; original call site unknown

	if v % 2 == 0 then
		return v // 2
	end

	return -((v + 1) // 2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushf4(state, value: number)
	buffer.writef32(state.Buf, state.Pos, value)
	state.Pos += 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popf4(state)
	state.Pos -= 4
	return (buffer.readf32(state.Buf, state.Pos))
end

local function pushf8(state, value: number)
	buffer.writef64(state.Buf, state.Pos, value)
	state.Pos += 8
end

local function popf8(state)
	state.Pos -= 8
	return (buffer.readf64(state.Buf, state.Pos))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushbool(state, flag: boolean, flag2: boolean?, flag3: boolean?, flag4: boolean?, flag5: boolean?, flag6: boolean?, flag7: boolean?, flag8: boolean?)
	pushu1(
		state,
		(flag and 1 or 0) + (flag2 and 2 or 0) + (flag3 and 4 or 0) + (flag4 and 8 or 0) + (flag5 and 16 or 0) + (flag6 and 32 or 0) + (flag7 and 64 or 0) + (flag8 and 128 or 0)
	) -- equivalent call inferred; original call site unknown
end

local function popbool(state)
	local v = popu1(state) -- equivalent call inferred; original call site unknown
	return v % 2 >= 1, v % 4 >= 2, v % 8 >= 4, v % 16 >= 8, v % 32 >= 16, v % 64 >= 32, v % 128 >= 64, v % 256 >= 128
end

local function pushvlqrealloc(state, p: number)
	local v

	if p >= 562949953421312 then
		v = 8
	elseif p >= 4398046511104 then
		v = 7
	elseif p >= 34359738368 then
		v = 6
	elseif p >= 268435456 then
		v = 5
	elseif p >= 2097152 then
		v = 4
	elseif p >= 16384 then
		v = 3
	elseif p >= 128 then
		v = 2
	else
		v = 1
	end

	tryrealloc(state, v)
	local v2 = p // 4294967296
	local v3 = p - v2 * 4294967296
	pushu1(state, v3 % 128) -- equivalent call inferred; original call site unknown

	if v >= 2 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(state, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 3 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(state, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 4 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(state, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 5 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(state, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 6 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(state, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 7 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(state, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v == 8 then
		pushu1(state, (v2 % 128 * 33554432 + v3 // 128) % 128 + 128) -- equivalent call inferred; original call site unknown
	end
end

local function popvlq(state)
	local v = popu1(state) -- equivalent call inferred; original call site unknown
	local v2 = v % 128

	if v < 128 then
		return v2
	end

	local v3 = popu1(state) -- equivalent call inferred; original call site unknown
	local v4 = v2 * 128 + v3 % 128

	if v3 < 128 then
		return v4
	end

	local v5 = popu1(state) -- equivalent call inferred; original call site unknown
	local v6 = v4 * 128 + v5 % 128

	if v5 < 128 then
		return v6
	end

	local v7 = popu1(state) -- equivalent call inferred; original call site unknown
	local v8 = v6 * 128 + v7 % 128

	if v7 < 128 then
		return v8
	end

	local v9 = popu1(state) -- equivalent call inferred; original call site unknown
	local v10 = v8 * 128 + v9 % 128

	if v9 < 128 then
		return v10
	end

	local v11 = popu1(state) -- equivalent call inferred; original call site unknown
	local v12 = v10 * 128 + v11 % 128

	if v11 < 128 then
		return v12
	end

	local v13 = popu1(state) -- equivalent call inferred; original call site unknown
	local v14 = v12 * 128 + v13 % 128

	if v13 < 128 then
		return v14
	end

	local v15 = popu1(state) -- equivalent call inferred; original call site unknown
	return v14 * 128 + v15 % 128
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushstr(state, str: string, p: number?)
	local v = p or #str
	buffer.writestring(state.Buf, state.Pos, str)
	state.Pos += v

	if not p then
		pushvlqrealloc(state, v)
	end
end

local function popstr(state, p: number?)
	local v = p or popvlq(state)
	state.Pos -= v
	return buffer.readstring(state.Buf, state.Pos, v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushbuf(state, buf: buffer, p: number?)
	local v = p or buffer.len(buf)
	buffer.copy(state.Buf, state.Pos, buf, 0, v)
	state.Pos += v

	if not p then
		pushvlqrealloc(state, v)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popbuf(state, p: number?)
	local v = p or popvlq(state)
	state.Pos -= v
	local buf = buffer.create(v)
	buffer.copy(buf, 0, state.Buf, state.Pos, v)
	return buf
end

local function printcursor(p)
	local v = { string.byte(buffer.tostring(p.Buf), 1, -1) }
	local total = 7

	for i = 1, p.Pos do
		local v2 = v[i]
		total += (v2 == 0 and 1 or math.ceil((math.log10(1 + v2)))) + 1
	end

	local v2 = v[p.Pos + 1]

	if v2 then
		total += (v2 == 0 and 1 or math.ceil((math.log10(1 + v2)))) // 2
	end

	if #v == 0 or p.Pos == buffer.len(p.Buf) then
		table.insert(v, " ")
	end

	print((`Pos: {p.Pos} / {buffer.len(p.Buf)}\nBuf: \{ {table.concat(v, " ")} }\n{string.rep(" ", total)}^`))
end

local Squash = {
	print = printcursor,
	cursor = newcursor,
	frombuffer = function(buf: buffer)
		return {
			Buf = buf,
			Pos = buffer.len(buf)
		}
	end,
	tobuffer = function(p)
		local buf = buffer.create(p.Pos)
		buffer.copy(buf, 0, p.Buf, 0, p.Pos)
		return buf
	end,
	tryrealloc = tryrealloc,
	T = function(p)
		return p
	end
}
local v = {
	ser = function(p, p2, p3, p4, p5, p6, p7, p8, p9)
		tryrealloc(p, 1)
		pushbool(p, p2, p3, p4, p5, p6, p7, p8, p9) -- equivalent call inferred; original call site unknown
	end,
	des = popbool
}

function Squash.boolean()
	return v
end

local v2 = {}

function Squash.uint(p: number)
	if v2[p] then
		return v2[p]
	end

	local v3 = nil
	local des = nil

	if p == 1 then
		v3 = pushu1
		des = popu1
	elseif p == 2 then
		v3 = pushu2
		des = popu2
	elseif p == 3 then
		v3 = pushu3
		des = popu3
	elseif p == 4 then
		v3 = pushu4
		des = popu4
	elseif p == 5 then
		v3 = pushu5
		des = popu5
	elseif p == 6 then
		v3 = pushu6
		des = popu6
	elseif p == 7 then
		v3 = pushu7
		des = popu7
	elseif p == 8 then
		v3 = pushu8
		des = popu8
	else
		error((`uint bytes must be integer between [1, 8], got {p}`))
	end

	local v5 = {
		ser = function(p2, p3)
			tryrealloc(p2, p)
			v3(p2, p3)
		end,
		des = des
	}
	v2[p] = v5
	return v5
end

local v3 = {}

function Squash.int(p: number)
	if v3[p] then
		return v3[p]
	end

	local v4 = nil
	local des = nil

	if p == 1 then
		v4 = pushi1
		des = popi1
	elseif p == 2 then
		v4 = pushi2
		des = popi2
	elseif p == 3 then
		v4 = pushi3
		des = popi3
	elseif p == 4 then
		v4 = pushi4
		des = popi4
	elseif p == 5 then
		v4 = pushi5
		des = popi5
	elseif p == 6 then
		v4 = pushi6
		des = popi6
	elseif p == 7 then
		v4 = pushi7
		des = popi7
	elseif p == 8 then
		v4 = pushi8
		des = popi8
	else
		error((`int bytes must be integer between [1, 8], got {p}`))
	end

	local v6 = {
		ser = function(p2, p3)
			tryrealloc(p2, p)
			v4(p2, p3)
		end,
		des = des
	}
	v3[p] = v6
	return v6
end

local v4 = {}

function Squash.number(p: number)
	if v4[p] then
		return v4[p]
	end

	local v5 = nil
	local des = nil

	if p == 4 then
		v5 = pushf4
		des = popf4
	elseif p == 8 then
		v5 = pushf8
		des = popf8
	else
		error((`number bytes must be integer 4 or 8, got {p}`))
	end

	local v7 = {
		ser = function(p2, p3)
			tryrealloc(p2, p)
			v5(p2, p3)
		end,
		des = des
	}
	v4[p] = v7
	return v7
end

local v5 = {}

function Squash.range(p: number, p2: number)
	local formatted = `{p}_{p2}`
	local v6 = v5[formatted]

	if v6 then
		return v6
	end

	local v7

	if p == p // 1 and p2 == p2 // 1 then
		v7 = p < p2
	else
		v7 = false
	end

	assert(v7, "min and max must be integers, and min < max")
	local v8 = p2 - p
	local v9, v10, v11

	if v8 < 256 then
		v9 = pushu1
		v10 = popu1
		v11 = 1
	elseif v8 < 65536 then
		v9 = pushu2
		v10 = popu2
		v11 = 2
	elseif v8 < 16777216 then
		v9 = pushu3
		v10 = popu3
		v11 = 3
	elseif v8 < 4294967296 then
		v9 = pushu4
		v10 = popu4
		v11 = 4
	elseif v8 < 1099511627776 then
		v9 = pushu5
		v10 = popu5
		v11 = 5
	elseif v8 < 281474976710656 then
		v9 = pushu6
		v10 = popu6
		v11 = 6
	elseif v8 < 7.205759403792794e16 then
		v9 = pushu7
		v10 = popu7
		v11 = 7
	else
		v9 = pushu8
		v10 = popu8
		v11 = 8
	end

	local v12 = {
		ser = function(p3, p4)
			tryrealloc(p3, v11)
			v9(p3, p4 - p)
		end,
		des = function(p3)
			return v10(p3) + p
		end
	}
	v5[formatted] = v12
	return v12
end

local v6 = {
	ser = function(state, list)
		tryrealloc(state, #list)
		pushstr(state, list, false) -- equivalent call inferred; original call site unknown
	end,
	des = popstr
}
local v7 = {}
local v9 = table.create(256)
local v10 = {
	convert = function(value: string, value2: string, value3: string)
		local v11 = {}

		for i = 1, #value2 do
			v11[string.byte(value2, i)] = i - 1
		end

		local v12 = {}

		for i = 1, #value3 do
			v12[i - 1] = string.byte(value3, i)
		end

		local v13 = {}

		for i = 1, #value do
			table.insert(v13, v11[string.byte(value, i)])
		end

		local v14 = #value2
		local count = #value3
		local v15 = {}

		while #v13 > 0 do
			local v16 = 0

			for i = 1, #v13 do
				local v17 = v13[i] + v16 * v14
				v13[i] = math.floor(v17 / count)
				v16 = v17 % count
			end

			while #v13 > 0 and v13[1] == 0 do
				table.remove(v13, 1)
			end

			table.insert(v15, 1, (string.char(v12[v16])))
		end

		return table.concat(v15)
	end,
	alphabet = function(value: string)
		local v11 = table.create(#value)
		local v12 = {}

		for i = 1, #value do
			local v13 = string.sub(value, i, i)

			if v12[v13] then
				continue
			end

			v12[v13] = true
			table.insert(v11, v13)
		end

		table.sort(v11)
		return table.concat(v11)
	end,
	binary = "01",
	octal = "01234567",
	decimal = "0123456789",
	duodecimal = "0123456789AB",
	hexadecimal = "0123456789ABCDEF"
}

for i = 0, 255 do
	v9[i + 1] = string.char(i)
end

v10.utf8 = table.concat(v9)
v10.lower = "abcdefghijklmnopqrstuvwxyz"
v10.upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
v10.letters = v10.lower .. v10.upper
v10.punctuation = " .,?!:;'\"-_"
v10.english = v10.letters .. v10.punctuation
v10.filepath = v10.letters .. ":/"
v10.datastore = " !#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
Squash.string = setmetatable(v10, {
	__call = function(_, p: number?)
		if not p then
			return v6
		end

		if v7[p] then
			return v7[p]
		end

		local v9 = {
			ser = function(state, str)
				tryrealloc(state, p)
				pushstr(state, str, p) -- equivalent call inferred; original call site unknown
			end,
			des = function(p2)
				return popstr(p2, p)
			end
		}
		v7[p] = v9
		return v9
	end
})
local v11 = {}
local v12 = {}

function Squash.opt(p)
	if v12[p] then
		return v12[p]
	end

	local v13 = {
		ser = function(state, p2)
			if p2 == nil then
				tryrealloc(state, 1)
				buffer.writeu8(state.Buf, state.Pos, 0)
			else
				p.ser(state, p2)
				tryrealloc(state, 1)
				buffer.writeu8(state.Buf, state.Pos, 1)
			end

			state.Pos += 1
		end,
		des = function(state)
			if popu1(state) == 1 then
				return p.des(state)
			end

			return nil
		end
	}
	v12[p] = v13
	v11[v13] = p
	return v13
end

local v13 = {
	ser = function(state, p)
		tryrealloc(state, buffer.len(p))
		local v14 = buffer.len(p)
		buffer.copy(state.Buf, state.Pos, p, 0, v14)
		state.Pos += v14
		pushvlqrealloc(state, v14)
	end,
	des = popbuf
}
local v14 = {}

function Squash.buffer(p: number?)
	if not p then
		return v13
	end

	if v14[p] then
		return v14[p]
	end

	local v15 = {
		ser = function(state, p2)
			tryrealloc(state, p)
			pushbuf(state, p2, p) -- equivalent call inferred; original call site unknown
		end,
		des = function(state)
			return popbuf(state, p)
		end
	}
	v14[p] = v15
	return v15
end

local v15 = {
	ser = pushvlqrealloc,
	des = popvlq
}

function Squash.vlq()
	return v15
end

local function serbitarr(state, list, p: number?)
	local v16 = p or #list

	if v16 == 0 then
		return
	end

	local v17 = v16 % 8
	local v18 = v16 - v17

	for i = 0, v18 - 1, 8 do
		pushbool(
			state,
			list[i + 1],
			list[i + 2],
			list[i + 3],
			list[i + 4],
			list[i + 5],
			list[i + 6],
			list[i + 7],
			list[i + 8]
		) -- equivalent call inferred; original call site unknown
	end

	if v17 == 1 then
		pushu1(state, (list[v18 + 1] and 1 or 0) + 0 + 0 + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
	elseif v17 == 2 then
		pushu1(state, (list[v18 + 1] and 1 or 0) + (list[v18 + 2] and 2 or 0) + 0 + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
	elseif v17 == 3 then
		local flag = list[v18 + 1]
		local flag2 = list[v18 + 2]
		local flag3 = list[v18 + 3]
		pushu1(state, (flag and 1 or 0) + (flag2 and 2 or 0) + (flag3 and 4 or 0) + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
	elseif v17 == 4 then
		local flag = list[v18 + 1]
		local flag2 = list[v18 + 2]
		local flag3 = list[v18 + 3]
		local flag4 = list[v18 + 4]
		pushu1(state, (flag and 1 or 0) + (flag2 and 2 or 0) + (flag3 and 4 or 0) + (flag4 and 8 or 0) + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
	elseif v17 == 5 then
		local flag = list[v18 + 1]
		local flag2 = list[v18 + 2]
		local flag3 = list[v18 + 3]
		local flag4 = list[v18 + 4]
		local flag5 = list[v18 + 5]
		pushu1(
			state,
			(flag and 1 or 0) + (flag2 and 2 or 0) + (flag3 and 4 or 0) + (flag4 and 8 or 0) + (flag5 and 16 or 0) + 0 + 0 + 0
		) -- equivalent call inferred; original call site unknown
	elseif v17 == 6 then
		local flag = list[v18 + 1]
		local flag2 = list[v18 + 2]
		local flag3 = list[v18 + 3]
		local flag4 = list[v18 + 4]
		local flag5 = list[v18 + 5]
		local flag6 = list[v18 + 6]
		pushu1(
			state,
			(flag and 1 or 0) + (flag2 and 2 or 0) + (flag3 and 4 or 0) + (flag4 and 8 or 0) + (flag5 and 16 or 0) + (flag6 and 32 or 0) + 0 + 0
		) -- equivalent call inferred; original call site unknown
	elseif v17 == 7 then
		local flag = list[v18 + 1]
		local flag2 = list[v18 + 2]
		local flag3 = list[v18 + 3]
		local flag4 = list[v18 + 4]
		local flag5 = list[v18 + 5]
		local flag6 = list[v18 + 6]
		local flag7 = list[v18 + 7]
		pushu1(
			state,
			(flag and 1 or 0) + (flag2 and 2 or 0) + (flag3 and 4 or 0) + (flag4 and 8 or 0) + (flag5 and 16 or 0) + (flag6 and 32 or 0) + (flag7 and 64 or 0) + 0
		) -- equivalent call inferred; original call site unknown
	end
end

local function desbitarr(state, p: number)
	if p == 0 then
		return {}
	end

	local result = table.create(p)
	local v16 = p // 8
	local v17 = v16 * 8
	local v18 = p % 8

	if v18 > 0 then
		local v19 = popu1(state) -- equivalent call inferred; original call site unknown
		local v20 = v19 % 2 >= 1
		local v21 = v19 % 4 >= 2
		local v22 = v19 % 8 >= 4
		local v23 = v19 % 16 >= 8
		local v24 = v19 % 32 >= 16
		local v25 = v19 % 64 >= 32
		local v26 = v19 % 128 >= 64
		local _ = v19 % 256 >= 128
		result[v17 + 1] = v20
		local v27 = v17 + 2

		if not (v18 > 1) then
			v21 = nil
		end

		result[v27] = v21
		local v28 = v17 + 3

		if not (v18 > 2) then
			v22 = nil
		end

		result[v28] = v22
		local v29 = v17 + 4

		if not (v18 > 3) then
			v23 = nil
		end

		result[v29] = v23
		local v30 = v17 + 5

		if not (v18 > 4) then
			v24 = nil
		end

		result[v30] = v24
		local v31 = v17 + 6

		if not (v18 > 5) then
			v25 = nil
		end

		result[v31] = v25
		local v32 = v17 + 7

		if not (v18 > 6) then
			v26 = nil
		end

		result[v32] = v26
	end

	for i = v16 - 1, 0, -1 do
		local v19 = i * 8
		local v20 = v19 + 1
		local v21 = v19 + 2
		local v22 = v19 + 3
		local v23 = v19 + 4
		local v24 = v19 + 5
		local v25 = v19 + 6
		local v26 = v19 + 7
		local v27 = v19 + 8
		local v28 = popu1(state) -- equivalent call inferred; original call site unknown
		local v29 = v28 % 2 >= 1
		local v30 = v28 % 4 >= 2
		local v31 = v28 % 8 >= 4
		local v32 = v28 % 16 >= 8
		local v33 = v28 % 32 >= 16
		local v34 = v28 % 64 >= 32
		local v35 = v28 % 128 >= 64
		local v36 = v28 % 256 >= 128
		result[v20] = v29
		result[v21] = v30
		result[v22] = v31
		result[v23] = v32
		result[v24] = v33
		result[v25] = v34
		result[v26] = v35
		result[v27] = v36
	end

	return result
end

local v16 = {}

function Squash.array(p, value)
	local v17 = v16[p]
	local v18 = value or 0

	if v17 then
		if v17[v18] then
			return v17[v18]
		end
	else
		v17 = {}
		v16[p] = v17
	end

	if p == v then
		local v19 = {
			ser = function(p2, list)
				local v20

				if type(value) == "number" then
					v20 = value
				else
					v20 = #list
				end

				serbitarr(p2, list, v20)

				if not value then
					pushvlqrealloc(p2, v20)
				elseif type(value) ~= "number" then
					value.ser(p2, v20)
				end
			end,
			des = function(p2)
				local v20

				if value then
					if type(value) == "number" then
						v20 = value
					else
						v20 = value.des(p2)
					end
				else
					v20 = popvlq(p2)
				end

				return (desbitarr(p2, v20))
			end
		}
		v17[v18] = v19
		return v19
	elseif v11[p] then
		local v19 = v11[p]

		if v19 == v then
			local v20 = {
				ser = function(p2, list)
					local v21

					if type(value) == "number" then
						v21 = value
					else
						v21 = table.maxn(list)
					end

					local v22 = table.create(v21)
					local v23 = table.create(v21)

					for i = 1, v21 do
						local v24 = list[i]

						if v24 == nil then
							v23[i] = false
						else
							table.insert(v22, v24)
							v23[i] = true
						end
					end

					tryrealloc(p2, #v22 // 8 + 1 + (1 + v21 // 8))
					serbitarr(p2, v22)
					serbitarr(p2, v23)

					if not value then
						pushvlqrealloc(p2, v21)
					elseif type(value) ~= "number" then
						value.ser(p2, v21)
					end
				end,
				des = function(p2)
					local v21

					if value then
						if type(value) == "number" then
							v21 = value
						else
							v21 = value.des(p2)
						end
					else
						v21 = popvlq(p2)
					end

					local v22 = desbitarr(p2, v21)
					local total = 0

					for _, v23 in v22 do
						total += v23 and 1 or 0
					end

					local v23 = desbitarr(p2, total)
					local result = table.create(v21)
					local v24 = 1

					for k, v25 in v22 do
						if not v25 then
							continue
						end

						result[k] = v23[v24]
						v24 += 1
					end

					return result
				end
			}
			v17[v18] = v20
			return v20
		else
			local v20 = {
				ser = function(p2, list)
					local ser = v19.ser
					local v21

					if type(value) == "number" then
						v21 = value
					else
						v21 = table.maxn(list)
					end

					local v22 = table.create(v21)

					for i = 1, v21 do
						local v23 = list[i]

						if v23 == nil then
							v22[i] = false
						else
							ser(p2, v23)
							v22[i] = true
						end
					end

					tryrealloc(p2, 1 + v21 // 8)
					serbitarr(p2, v22)

					if not value then
						pushvlqrealloc(p2, v21)
					elseif type(value) ~= "number" then
						value.ser(p2, v21)
					end
				end,
				des = function(p2)
					local des = v19.des
					local v21

					if value then
						if type(value) == "number" then
							v21 = value
						else
							v21 = value.des(p2)
						end
					else
						v21 = popvlq(p2)
					end

					local v22 = desbitarr(p2, v21)
					local result = table.create(v21)

					for i = v21, 1, -1 do
						if v22[i] then
							result[i] = des(p2)
						end
					end

					return result
				end
			}
			v17[v18] = v20
			return v20
		end
	else
		local v19 = {
			ser = function(p2, list)
				local ser = p.ser
				local v20

				if type(value) == "number" then
					v20 = value
				else
					v20 = #list
				end

				for i = 1, v20 do
					ser(p2, list[i])
				end

				if not value then
					pushvlqrealloc(p2, v20)
				elseif type(value) ~= "number" then
					value.ser(p2, v20)
				end
			end,
			des = function(p2)
				local des = p.des
				local v20

				if value then
					if type(value) == "number" then
						v20 = value
					else
						v20 = value.des(p2)
					end
				else
					v20 = popvlq(p2)
				end

				local result = table.create(v20)

				for i = v20, 1, -1 do
					result[i] = des(p2)
				end

				return result
			end
		}
		v17[v18] = v19
		return v19
	end
end

function Squash.tuple(...)
	local v17 = { ... }
	local count = #v17

	if count == 1 then
		return v17[1]
	end

	return {
		ser = function(p, ...)
			for k, v18 in { ... } do
				v17[k].ser(p, v18)
			end
		end,
		des = function(p)
			local v18 = table.create(count)

			for i = count, 1, -1 do
				v18[i] = v17[i].des(p)
			end

			return table.unpack(v18)
		end
	}
end

function Squash.record(items)
	local v17 = {}
	local v18 = {}
	local v19 = {}
	local v20 = {}

	for k, item in items do
		if type(k) ~= "string" then
			continue
		end

		local v21 = v11[item]

		if v21 == v then
			table.insert(v17, k)
		elseif v21 then
			table.insert(v18, k)
		elseif item == v then
			table.insert(v19, k)
		else
			table.insert(v20, k)
		end
	end

	local count = #v20
	table.sort(v20)
	local count2 = #v19

	if count2 > 0 then
		table.sort(v19)
	end

	local count3 = #v18
	local v21 = {}

	if count3 > 0 then
		table.sort(v18)

		for k, v22 in v18 do
			v21[k] = v11[items[v22]]
		end
	end

	local count4 = #v17

	if count4 > 0 then
		table.sort(v17)
	end

	return {
		ser = function(p, p2)
			for _, v22 in v20 do
				local v23 = p2[v22]
				items[v22].ser(p, v23)
			end

			local v22 = table.create(count2 + count4)

			for k, v23 in v19 do
				v22[k] = p2[v23]
			end

			local v23 = count2
			local v24 = table.create(count4 + count3)

			for k, v25 in v17 do
				local v26 = p2[v25]

				if v26 == nil then
					v24[k] = false
				else
					v23 += 1
					v22[v23] = v26
					v24[k] = true
				end
			end

			for k, v25 in v18 do
				local v26 = k + count4
				local v27 = p2[v25]

				if v27 == nil then
					v24[v26] = false
				else
					v21[k].ser(p, v27)
					v24[v26] = true
				end
			end

			tryrealloc(p, v23 + count4 + count3)
			serbitarr(p, v22, v23)
			serbitarr(p, v24, count4 + count3)
		end,
		des = function(p)
			local v22 = desbitarr(p, count4 + count3)
			local v23 = count2
			local result = {}

			for i = 1, count4 do
				v23 += v22[i] and 1 or 0
			end

			local v24 = desbitarr(p, v23)

			for k, v25 in v19 do
				result[v25] = v24[k]
			end

			for i = count4, 1, -1 do
				if not v22[i] then
					continue
				end

				result[v17[i]] = v24[v23]
				v23 -= 1
			end

			for i = count3, 1, -1 do
				if not v22[i + count4] then
					continue
				end

				local v25 = v18[i]
				local _ = items[v25]
				result[v25] = v21[i].des(p)
			end

			for i = count, 1, -1 do
				local v25 = v20[i]
				result[v25] = items[v25].des(p)
			end

			return result
		end
	}
end

function Squash.map(p, p2, value)
	return {
		ser = function(p3, items)
			local count = 0

			for k, item in items do
				p2.ser(p3, item)
				p.ser(p3, k)
				count += 1
			end

			if not value then
				pushvlqrealloc(p3, count)
			elseif type(value) ~= "number" then
				value.ser(p3, count)
			end
		end,
		des = function(p3)
			local result = {}
			local v17

			if value then
				if type(value) == "number" then
					v17 = value
				else
					v17 = value.des(p3)
				end
			else
				v17 = popvlq(p3)
			end

			for _ = 1, v17 do
				result[p.des(p3)] = p2.des(p3)
			end

			return result
		end
	}
end

function Squash.literal(...)
	local v17 = { ... }
	local v18 = {}

	for k, v19 in v17 do
		v18[v19] = k - 1
	end

	return {
		ser = function(state, p)
			tryrealloc(state, 1)
			pushu1(state, v18[p]) -- equivalent call inferred; original call site unknown
		end,
		des = function(state)
			return v17[popu1(state) + 1]
		end
	}
end

function Squash.table(items, value)
	local v17 = {}
	local v18 = {}

	for k in items do
		local v19 = #v17 + 1
		v17[v19] = k
		v18[k] = v19
	end

	return {
		ser = function(state, items2)
			local count = 0

			for k, item in items2 do
				local typeName = typeof(item)
				local item2 = items[typeName]

				if not item2 then
					continue
				end

				local typeName2 = typeof(k)
				local item3 = items[typeName2]

				if not item3 then
					continue
				end

				item2.ser(state, item)
				local v19 = v18[typeName] or error("")
				tryrealloc(state, 1)
				pushu1(state, v19 - 1) -- equivalent call inferred; original call site unknown
				item3.ser(state, k)
				local v21 = v18[typeName2] or error("")
				tryrealloc(state, 1)
				pushu1(state, v21 - 1) -- equivalent call inferred; original call site unknown
				count += 1
			end

			if not value then
				pushvlqrealloc(state, count)
			elseif type(value) ~= "number" then
				value.ser(state, count)
			end
		end,
		des = function(state)
			local result = {}
			local v19

			if value then
				if type(value) == "number" then
					v19 = value
				else
					v19 = value.des(state)
				end
			else
				v19 = popvlq(state)
			end

			for _ = 1, v19 do
				local des = items[v17[popu1(state) + 1]].des(state)
				result[des] = items[v17[popu1(state) + 1]].des(state)
			end

			return result
		end
	}
end

local v17 = {
	ser = function(state, data)
		tryrealloc(state, 2)
		local back = data.Back
		local bottom = data.Bottom
		local front = data.Front
		local left = data.Left
		local right = data.Right
		local top = data.Top
		pushu1(
			state,
			(back and 1 or 0) + (bottom and 2 or 0) + (front and 4 or 0) + (left and 8 or 0) + (right and 16 or 0) + (top and 32 or 0) + 0 + 0
		) -- equivalent call inferred; original call site unknown
		local X = data.X
		local Y = data.Y
		local Z = data.Z
		pushu1(state, (X and 1 or 0) + (Y and 2 or 0) + (Z and 4 or 0) + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v18 = popu1(state) -- equivalent call inferred; original call site unknown
		local v19 = v18 % 2 >= 1
		local v20 = v18 % 4 >= 2
		local v21 = v18 % 8 >= 4
		local _ = v18 % 16 >= 8
		local _ = v18 % 32 >= 16
		local _ = v18 % 64 >= 32
		local _ = v18 % 128 >= 64
		local _ = v18 % 256 >= 128
		local v22 = popu1(state) -- equivalent call inferred; original call site unknown
		local v23 = v22 % 2 >= 1
		local v24 = v22 % 4 >= 2
		local v25 = v22 % 8 >= 4
		local v26 = v22 % 16 >= 8
		local v27 = v22 % 32 >= 16
		local v28 = v22 % 64 >= 32
		local _ = v22 % 128 >= 64
		local _ = v22 % 256 >= 128
		return Axes.new(
			v19 and Enum.Axis.X,
			v20 and Enum.Axis.Y,
			v21 and Enum.Axis.Z,
			v23 and Enum.NormalId.Back,
			v24 and Enum.NormalId.Bottom,
			v25 and Enum.NormalId.Front,
			v26 and Enum.NormalId.Left,
			v27 and Enum.NormalId.Right,
			v28 and Enum.NormalId.Top
		)
	end
}

function Squash.Axes()
	return v17
end

local v18 = {
	ser = function(state, p)
		tryrealloc(state, 2)
		pushu2(state, p.Number) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v19 = popu2(state) -- equivalent call inferred; original call site unknown
		return BrickColor.new(v19)
	end
}

function Squash.BrickColor()
	return v18
end

local v19 = {}

function Squash.EnumItem(object)
	if v19[object] then
		return v19[object]
	end

	local enumItems = object:GetEnumItems()
	table.sort(enumItems, function(a, b)
		return a.Value < b.Value
	end)
	local enumItems2 = table.create(#enumItems)
	local v20 = {}

	for k, enumItem in enumItems do
		v20[enumItem] = k
		enumItems2[k] = enumItem
	end

	local v21 = {
		ser = function(p, p2)
			pushvlqrealloc(p, v20[p2])
		end,
		des = function(p)
			return enumItems2[popvlq(p)]
		end
	}
	v19[object] = v21
	return v21
end

local enumItem = Squash.EnumItem
local v20 = {
	ser = function(state, data)
		tryrealloc(state, #data.CreatorName + 10 + #data.SearchKeyword)
		pushu1(state, (data.IncludeOffSale and 1 or 0) + 0 + 0 + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
		pushu1(state, data.Limit) -- equivalent call inferred; original call site unknown
		pushu4(state, data.MinPrice) -- equivalent call inferred; original call site unknown
		pushu4(state, data.MaxPrice) -- equivalent call inferred; original call site unknown
		pushstr(state, data.CreatorName, false) -- equivalent call inferred; original call site unknown
		pushstr(state, data.SearchKeyword, false) -- equivalent call inferred; original call site unknown
		enumItem(Enum.CatalogSortType).ser(state, data.SortType)
		enumItem(Enum.CatalogSortAggregation).ser(state, data.SortAggregation)
		enumItem(Enum.CatalogCategoryFilter).ser(state, data.CategoryFilter)
		enumItem(Enum.SalesTypeFilter).ser(state, data.SalesTypeFilter)

		for _, assetType in data.AssetTypes do
			enumItem(Enum.AssetType).ser(state, assetType)
		end

		pushvlqrealloc(state, #data.AssetTypes)
	end,
	des = function(state)
		local catalogSearchParams = CatalogSearchParams.new()
		local v21 = popvlq(state)
		local assetTypes = table.create(v21)

		for i = v21, 1, -1 do
			assetTypes[i] = enumItem(Enum.AssetType).des(state)
		end

		catalogSearchParams.AssetTypes = assetTypes
		catalogSearchParams.SalesTypeFilter = enumItem(Enum.SalesTypeFilter).des(state)
		catalogSearchParams.CategoryFilter = enumItem(Enum.CatalogCategoryFilter).des(state)
		catalogSearchParams.SortAggregation = enumItem(Enum.CatalogSortAggregation).des(state)
		catalogSearchParams.SortType = enumItem(Enum.CatalogSortType).des(state)
		local v23 = popvlq(state)
		state.Pos -= v23
		catalogSearchParams.SearchKeyword = buffer.readstring(state.Buf, state.Pos, v23)
		local v24 = popvlq(state)
		state.Pos -= v24
		catalogSearchParams.CreatorName = buffer.readstring(state.Buf, state.Pos, v24)
		catalogSearchParams.MaxPrice = popu4(state)
		catalogSearchParams.MinPrice = popu4(state)
		catalogSearchParams.Limit = popu1(state)
		local v25 = popu1(state) -- equivalent call inferred; original call site unknown
		local includeOffSale = v25 % 2 >= 1
		local _ = v25 % 4 >= 2
		local _ = v25 % 8 >= 4
		local _ = v25 % 16 >= 8
		local _ = v25 % 32 >= 16
		local _ = v25 % 64 >= 32
		local _ = v25 % 128 >= 64
		local _ = v25 % 256 >= 128
		catalogSearchParams.IncludeOffSale = includeOffSale
		return catalogSearchParams
	end
}

function Squash.CatalogSearchParams()
	return v20
end

local function cframeLookupEntries()
	return {
		CFrame.Angles(0, 0, 0),
		CFrame.Angles(1.5707963267948966, 0, 0),
		CFrame.Angles(0, 3.141592653589793, 3.141592653589793),
		CFrame.Angles(-1.5707963267948966, 0, 0),
		CFrame.Angles(0, 3.141592653589793, 1.5707963267948966),
		CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966),
		CFrame.Angles(0, 0, 1.5707963267948966),
		CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966),
		CFrame.Angles(-1.5707963267948966, -1.5707963267948966, 0),
		CFrame.Angles(0, -1.5707963267948966, 0),
		CFrame.Angles(1.5707963267948966, -1.5707963267948966, 0),
		CFrame.Angles(0, 1.5707963267948966, 3.141592653589793),
		CFrame.Angles(0, -1.5707963267948966, 3.141592653589793),
		CFrame.Angles(0, 3.141592653589793, 0),
		CFrame.Angles(-1.5707963267948966, -3.141592653589793, 0),
		CFrame.Angles(0, 0, 3.141592653589793),
		CFrame.Angles(1.5707963267948966, 3.141592653589793, 0),
		CFrame.Angles(0, 0, -1.5707963267948966),
		CFrame.Angles(0, -1.5707963267948966, -1.5707963267948966),
		CFrame.Angles(0, -3.141592653589793, -1.5707963267948966),
		CFrame.Angles(0, 1.5707963267948966, -1.5707963267948966),
		CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0),
		CFrame.Angles(0, 1.5707963267948966, 0),
		CFrame.Angles(-1.5707963267948966, 1.5707963267948966, 0)
	}
end

local function cframeSpecialCaseLookup(items)
	local result = {}

	for k, item in items do
		result[Vector3.new(item:ToOrientation())] = k
	end

	return result
end

local v21 = cframeLookupEntries()
local v22 = cframeSpecialCaseLookup(v21)

local function rotser(state, cframe: CFrame)
	local v23 = v22[Vector3.new(cframe:ToOrientation())]

	if v23 then
		tryrealloc(state, 1)
		pushu1(state, v23) -- equivalent call inferred; original call site unknown
	else
		local axisAngle, v24 = cframe:ToAxisAngle()
		local v25 = axisAngle * math.sin(v24 / 2)
		tryrealloc(state, 7)
		local v26 = math.round((v25.Z + 1) * 32768 - 1)
		local v27 = math.round((v25.Y + 1) * 32768 - 1)
		local v28 = math.round((v25.X + 1) * 32768 - 1)
		pushu2(state, v26) -- equivalent call inferred; original call site unknown
		pushu2(state, v27) -- equivalent call inferred; original call site unknown
		pushu2(state, v28) -- equivalent call inferred; original call site unknown
		pushu1(state, 0) -- equivalent call inferred; original call site unknown
	end
end

local function rotdes(state)
	local v23 = popu1(state) -- equivalent call inferred; original call site unknown

	if v23 ~= 0 then
		return v21[v23]
	end

	local v24 = (popu2(state) + 1) * 0.000030517578125 - 1
	local v25 = (popu2(state) + 1) * 0.000030517578125 - 1
	local v26 = (popu2(state) + 1) * 0.000030517578125 - 1
	local v27 = math.sqrt(1 - math.clamp(v24 * v24 + v25 * v25 + v26 * v26, 0, 1))
	return CFrame.new(0, 0, 0, v24, v25, v26, v27)
end

local v23 = {
	ser = rotser,
	des = rotdes
}

function Squash.rotation()
	return v23
end

local v24 = {}

function Squash.CFrame(p)
	if v24[p] then
		return v24[p]
	end

	local ser = p.ser
	local des = p.des
	local v25 = {
		ser = function(p2, p3)
			rotser(p2, p3)
			local position = p3.Position
			ser(p2, position.Z)
			ser(p2, position.Y)
			ser(p2, position.X)
		end,
		des = function(p2)
			local v26 = des(p2)
			local v27 = des(p2)
			local v28 = des(p2)
			return rotdes(p2) + Vector3.new(v26, v27, v28)
		end
	}
	v24[p] = v25
	return v25
end

local cFrame = Squash.CFrame

-- equivalent calls inferred from this helper; original call sites unknown
local function pushcolor3(state, data)
	pushu1(state, data.B * 255) -- equivalent call inferred; original call site unknown
	pushu1(state, data.G * 255) -- equivalent call inferred; original call site unknown
	pushu1(state, data.R * 255) -- equivalent call inferred; original call site unknown
end

local function popcolor3(state)
	local v25 = popu1(state) -- equivalent call inferred; original call site unknown
	local v26 = popu1(state) -- equivalent call inferred; original call site unknown
	return Color3.fromRGB(v25, v26, popu1(state))
end

local v25 = {
	ser = function(p, data)
		tryrealloc(p, 3)
		pushcolor3(p, data) -- equivalent call inferred; original call site unknown
	end,
	des = popcolor3
}

function Squash.Color3()
	return v25
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushcolorsequencekeypoint(state, p)
	pushcolor3(state, p.Value) -- equivalent call inferred; original call site unknown
	pushu1(state, p.Time * 255) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popcolorsequencekeypoint(state)
	return ColorSequenceKeypoint.new(popu1(state) / 255, popcolor3(state))
end

local v26 = {
	ser = function(p, p2)
		tryrealloc(p, 4)
		pushcolorsequencekeypoint(p, p2) -- equivalent call inferred; original call site unknown
	end,
	des = popcolorsequencekeypoint
}

function Squash.ColorSequenceKeypoint()
	return v26
end

local v27 = {
	ser = function(p, sequence)
		tryrealloc(p, #sequence.Keypoints * 4)

		for _, keypoint in sequence.Keypoints do
			pushcolorsequencekeypoint(p, keypoint) -- equivalent call inferred; original call site unknown
		end

		pushvlqrealloc(p, #sequence.Keypoints)
	end,
	des = function(p)
		local v28 = popvlq(p)
		local v29 = table.create(v28)

		for i = v28, 1, -1 do
			v29[i] = popcolorsequencekeypoint(p)
		end

		return ColorSequence.new(v29)
	end
}

function Squash.ColorSequence()
	return v27
end

local v28 = {
	ser = function(state, p)
		tryrealloc(state, 6)
		pushu6(state, p.UnixTimestampMillis) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		return DateTime.fromUnixTimestampMillis(popu6(state))
	end
}

function Squash.DateTime()
	return v28
end

local v29 = {
	ser = function(state, data)
		tryrealloc(state, 1)
		local back = data.Back
		local bottom = data.Bottom
		local front = data.Front
		local left = data.Left
		local right = data.Right
		local top = data.Top
		pushu1(
			state,
			(back and 1 or 0) + (bottom and 2 or 0) + (front and 4 or 0) + (left and 8 or 0) + (right and 16 or 0) + (top and 32 or 0) + 0 + 0
		) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v30 = popu1(state) -- equivalent call inferred; original call site unknown
		local v31 = v30 % 2 >= 1
		local v32 = v30 % 4 >= 2
		local v33 = v30 % 8 >= 4
		local v34 = v30 % 16 >= 8
		local v35 = v30 % 32 >= 16
		local v36 = v30 % 64 >= 32
		local _ = v30 % 128 >= 64
		local _ = v30 % 256 >= 128
		return Faces.new(
			v31 and Enum.NormalId.Back,
			v32 and Enum.NormalId.Bottom,
			v33 and Enum.NormalId.Front,
			v34 and Enum.NormalId.Left,
			v35 and Enum.NormalId.Right,
			v36 and Enum.NormalId.Top
		)
	end
}

function Squash.Faces()
	return v29
end

local v30 = {
	ser = function(state, data)
		enumItem(Enum.KeyInterpolationMode).ser(state, data.Interpolation)
		tryrealloc(state, 8)
		pushf4(state, data.Value) -- equivalent call inferred; original call site unknown
		pushf4(state, data.Time) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local new = FloatCurveKey.new
		local v31 = popf4(state) -- equivalent call inferred; original call site unknown
		return new(v31, popf4(state), (enumItem(Enum.KeyInterpolationMode).des(state)))
	end
}

function Squash.FloatCurveKey()
	return v30
end

local v31 = {
	ser = function(state, data)
		local v32 = string.match(data.Family, "rbxasset://fonts/families/(.+).json") or error((`Invalid font family {data.Family}`))
		tryrealloc(state, #v32 + 1)
		pushstr(state, v32, false) -- equivalent call inferred; original call site unknown
		pushu1(state, (data.Bold and 1 or 0) + 0 + 0 + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
		enumItem(Enum.FontWeight).ser(state, data.Weight)
		enumItem(Enum.FontStyle).ser(state, data.Style)
	end,
	des = function(state)
		local des = enumItem(Enum.FontStyle).des(state)
		local des2 = enumItem(Enum.FontWeight).des(state)
		local v32 = popu1(state) -- equivalent call inferred; original call site unknown
		local bold = v32 % 2 >= 1
		local _ = v32 % 4 >= 2
		local _ = v32 % 8 >= 4
		local _ = v32 % 16 >= 8
		local _ = v32 % 32 >= 16
		local _ = v32 % 64 >= 32
		local _ = v32 % 128 >= 64
		local _ = v32 % 256 >= 128
		local v34 = popvlq(state)
		state.Pos -= v34
		local v35 = buffer.readstring(state.Buf, state.Pos, v34)
		local font = Font.new(`rbxasset://fonts/families/{v35}.json`, des2, des)
		font.Bold = bold
		return font
	end
}

function Squash.Font()
	return v31
end

local v32 = {}

function Squash.NumberRange(p)
	if v32[p] then
		return v32[p]
	end

	local ser = p.ser
	local des = p.des
	local v33 = {
		ser = function(p2, p3)
			ser(p2, p3.Max)
			ser(p2, p3.Min)
		end,
		des = function(p2)
			return NumberRange.new(des(p2), des(p2))
		end
	}
	v32[p] = v33
	return v33
end

local v33 = {}

function Squash.NumberSequenceKeypoint(p)
	if v33[p] then
		return v33[p]
	end

	local ser = p.ser
	local des = p.des
	local v34 = {
		ser = function(state, data)
			ser(state, data.Value)
			ser(state, data.Envelope)
			tryrealloc(state, 4)
			pushf4(state, data.Time) -- equivalent call inferred; original call site unknown
		end,
		des = function(state)
			local v35 = popf4(state) -- equivalent call inferred; original call site unknown
			local v36 = des(state)
			local v37 = des(state)
			return NumberSequenceKeypoint.new(v35, v37, v36)
		end
	}
	v33[p] = v34
	return v34
end

local numberSequenceKeypoint = Squash.NumberSequenceKeypoint
local v34 = {}

function Squash.NumberSequence(p)
	if v34[p] then
		return v34[p]
	end

	local ser = numberSequenceKeypoint(p).ser
	local des = numberSequenceKeypoint(p).des
	local v35 = {
		ser = function(p2, sequence)
			local ser2 = ser

			for _, keypoint in sequence.Keypoints do
				ser2(p2, keypoint)
			end

			pushvlqrealloc(p2, #sequence.Keypoints)
		end,
		des = function(p2)
			local v36 = popvlq(p2)
			local v37 = table.create(v36)

			for i = v36, 1, -1 do
				v37[i] = des(p2)
			end

			return NumberSequence.new(v37)
		end
	}
	v34[p] = v35
	return v35
end

local v35 = {
	ser = function(state, data)
		tryrealloc(state, #data.CollisionGroup + 3)
		pushu1(state, (data.BruteForceAllSlow and 1 or 0) + (data.RespectCanCollide and 2 or 0) + 0 + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
		pushu2(state, data.MaxParts) -- equivalent call inferred; original call site unknown
		pushstr(state, data.CollisionGroup, false) -- equivalent call inferred; original call site unknown
		enumItem(Enum.RaycastFilterType).ser(state, data.FilterType)
	end,
	des = function(state)
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = enumItem(Enum.RaycastFilterType).des(state)
		local v36 = popvlq(state)
		state.Pos -= v36
		overlapParams.CollisionGroup = buffer.readstring(state.Buf, state.Pos, v36)
		overlapParams.MaxParts = popu2(state)
		local v37 = popu1(state) -- equivalent call inferred; original call site unknown
		local bruteForceAllSlow = v37 % 2 >= 1
		local respectCanCollide = v37 % 4 >= 2
		local _ = v37 % 8 >= 4
		local _ = v37 % 16 >= 8
		local _ = v37 % 32 >= 16
		local _ = v37 % 64 >= 32
		local _ = v37 % 128 >= 64
		local _ = v37 % 256 >= 128
		overlapParams.BruteForceAllSlow = bruteForceAllSlow
		overlapParams.RespectCanCollide = respectCanCollide
		return overlapParams
	end
}

function Squash.OverlapParams()
	return v35
end

local v36 = {
	ser = function(state, data)
		tryrealloc(state, #data.CollisionGroup + 1)
		local bruteForceAllSlow = data.BruteForceAllSlow
		local respectCanCollide = data.RespectCanCollide
		local ignoreWater = data.IgnoreWater
		pushu1(
			state,
			(bruteForceAllSlow and 1 or 0) + (respectCanCollide and 2 or 0) + (ignoreWater and 4 or 0) + 0 + 0 + 0 + 0 + 0
		) -- equivalent call inferred; original call site unknown
		pushstr(state, data.CollisionGroup, false) -- equivalent call inferred; original call site unknown
		enumItem(Enum.RaycastFilterType).ser(state, data.FilterType)
	end,
	des = function(state)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = enumItem(Enum.RaycastFilterType).des(state)
		local v37 = popvlq(state)
		state.Pos -= v37
		raycastParams.CollisionGroup = buffer.readstring(state.Buf, state.Pos, v37)
		local v38 = popu1(state) -- equivalent call inferred; original call site unknown
		local bruteForceAllSlow = v38 % 2 >= 1
		local respectCanCollide = v38 % 4 >= 2
		local ignoreWater = v38 % 8 >= 4
		local _ = v38 % 16 >= 8
		local _ = v38 % 32 >= 16
		local _ = v38 % 64 >= 32
		local _ = v38 % 128 >= 64
		local _ = v38 % 256 >= 128
		raycastParams.BruteForceAllSlow = bruteForceAllSlow
		raycastParams.RespectCanCollide = respectCanCollide
		raycastParams.IgnoreWater = ignoreWater
		return raycastParams
	end
}

function Squash.RaycastParams()
	return v36
end

local v37 = {}

function Squash.Vector3(p)
	if v37[p] then
		return v37[p]
	end

	local ser = p.ser
	local des = p.des
	local v38 = {
		ser = function(p2, data)
			ser(p2, data.Z)
			ser(p2, data.Y)
			ser(p2, data.X)
		end,
		des = function(p2)
			return (Vector3.new(des(p2), des(p2), des(p2)))
		end
	}
	v37[p] = v38
	return v38
end

local v38 = {}

function Squash.PathWaypoint(p)
	if v38[p] then
		return v38[p]
	end

	local ser = p.ser
	local des = p.des
	local v39 = {
		ser = function(state, data)
			tryrealloc(state, #data.Label)
			pushstr(state, data.Label, false) -- equivalent call inferred; original call site unknown
			enumItem(Enum.PathWaypointAction).ser(state, data.Action)
			ser(state, data.Position.Z)
			ser(state, data.Position.Y)
			ser(state, data.Position.X)
		end,
		des = function(p2)
			return PathWaypoint.new(
				Vector3.new(des(p2), des(p2), des(p2)),
				enumItem(Enum.PathWaypointAction).des(p2),
				popstr(p2)
			)
		end
	}
	v38[p] = v39
	return v39
end

local v39 = {
	ser = function(state, data)
		tryrealloc(state, 20)
		pushf4(state, data.ElasticityWeight) -- equivalent call inferred; original call site unknown
		pushf4(state, data.FrictionWeight) -- equivalent call inferred; original call site unknown
		pushf4(state, data.Elasticity) -- equivalent call inferred; original call site unknown
		pushf4(state, data.Friction) -- equivalent call inferred; original call site unknown
		pushf4(state, data.Density) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v40 = popf4(state) -- equivalent call inferred; original call site unknown
		local v41 = popf4(state) -- equivalent call inferred; original call site unknown
		local v42 = popf4(state) -- equivalent call inferred; original call site unknown
		local v43 = popf4(state) -- equivalent call inferred; original call site unknown
		return PhysicalProperties.new(v40, v41, v42, v43, popf4(state))
	end
}

function Squash.PhysicalProperties()
	return v39
end

local v40 = {}

function Squash.Ray(p)
	if v40[p] then
		return v40[p]
	end

	local ser = p.ser
	local des = p.des
	local v41 = {
		ser = function(p2, p3)
			ser(p2, p3.Direction.Z)
			ser(p2, p3.Direction.Y)
			ser(p2, p3.Direction.X)
			ser(p2, p3.Origin.Z)
			ser(p2, p3.Origin.Y)
			ser(p2, p3.Origin.X)
		end,
		des = function(p2)
			return Ray.new(Vector3.new(des(p2), des(p2), des(p2)), (Vector3.new(des(p2), des(p2), des(p2))))
		end
	}
	v40[p] = v41
	return v41
end

local v41 = {}

function Squash.RaycastResult(p)
	if v41[p] then
		return v41[p]
	end

	local ser = p.ser
	local des = p.des
	local v42 = {
		ser = function(state, raycastResult: RaycastResult)
			tryrealloc(state, 4)
			pushf4(state, raycastResult.Distance) -- equivalent call inferred; original call site unknown
			ser(state, raycastResult.Position.Z)
			ser(state, raycastResult.Position.Y)
			ser(state, raycastResult.Position.X)
			ser(state, raycastResult.Normal.Z)
			ser(state, raycastResult.Normal.Y)
			ser(state, raycastResult.Normal.X)
			enumItem(Enum.Material).ser(state, raycastResult.Material)
		end,
		des = function(state)
			return {
				Material = enumItem(Enum.Material).des(state),
				Normal = Vector3.new(des(state), des(state), des(state)),
				Position = Vector3.new(des(state), des(state), des(state)),
				Distance = popf4(state),
				Instance = nil
			}
		end
	}
	v41[p] = v42
	return v42
end

local v42 = {}

function Squash.Vector2(p)
	if v42[p] then
		return v42[p]
	end

	local ser = p.ser
	local des = p.des
	local v43 = {
		ser = function(p2, p3)
			ser(p2, p3.Y)
			ser(p2, p3.X)
		end,
		des = function(p2)
			return Vector2.new(des(p2), des(p2))
		end
	}
	v42[p] = v43
	return v43
end

local v43 = {}

function Squash.Rect(p)
	if v43[p] then
		return v43[p]
	end

	local ser = p.ser
	local des = p.des
	local v44 = {
		ser = function(p2, p3)
			ser(p2, p3.Max.Y)
			ser(p2, p3.Max.X)
			ser(p2, p3.Min.Y)
			ser(p2, p3.Min.X)
		end,
		des = function(p2)
			return Rect.new(des(p2), des(p2), des(p2), des(p2))
		end
	}
	v43[p] = v44
	return v44
end

local v44 = {}

function Squash.Region3(p)
	if v44[p] then
		return v44[p]
	end

	local ser = p.ser
	local des = p.des
	local v45 = {
		ser = function(p2, instance)
			local size = instance.Size
			ser(p2, size.Z)
			ser(p2, size.Y)
			ser(p2, size.X)
			local position = instance.CFrame.Position
			ser(p2, position.Z)
			ser(p2, position.Y)
			ser(p2, position.X)
		end,
		des = function(p2)
			local vector = Vector3.new(des(p2), des(p2), des(p2))
			local vector2 = Vector3.new(des(p2), des(p2), des(p2)) * 0.5
			return Region3.new(vector - vector2, vector + vector2)
		end
	}
	v44[p] = v45
	return v45
end

local v45 = {
	ser = function(state, p)
		tryrealloc(state, 12)
		local max = p.Max
		pushi2(state, max.Z) -- equivalent call inferred; original call site unknown
		pushi2(state, max.Y) -- equivalent call inferred; original call site unknown
		pushi2(state, max.X) -- equivalent call inferred; original call site unknown
		local min = p.Min
		pushi2(state, min.Z) -- equivalent call inferred; original call site unknown
		pushi2(state, min.Y) -- equivalent call inferred; original call site unknown
		pushi2(state, min.X) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v46 = popi2(state) -- equivalent call inferred; original call site unknown
		local v47 = popi2(state) -- equivalent call inferred; original call site unknown
		local vector3int = Vector3int16.new(v46, v47, popi2(state))
		local v48 = popi2(state) -- equivalent call inferred; original call site unknown
		local v49 = popi2(state) -- equivalent call inferred; original call site unknown
		local vector3int2 = Vector3int16.new(v48, v49, popi2(state))
		return Region3int16.new(vector3int, vector3int2)
	end
}

function Squash.Region3int16()
	return v45
end

local v46 = {}

function Squash.RotationCurveKey(p)
	if v46[p] then
		return v46[p]
	end

	local ser = cFrame(p).ser
	local des = cFrame(p).des
	local v47 = {
		ser = function(state, data)
			enumItem(Enum.KeyInterpolationMode).ser(state, data.Interpolation)
			ser(state, data.Value)
			tryrealloc(state, 4)
			pushf4(state, data.Time) -- equivalent call inferred; original call site unknown
		end,
		des = function(state)
			return RotationCurveKey.new(popf4(state), des(state), (enumItem(Enum.KeyInterpolationMode).des(state)))
		end
	}
	v46[p] = v47
	return v47
end

local v47 = {
	ser = function(state, data)
		tryrealloc(state, 9)
		pushf4(state, data.DelayTime) -- equivalent call inferred; original call site unknown
		pushf4(state, data.Time) -- equivalent call inferred; original call site unknown
		pushu1(state, (data.Reverses and 1 or 0) + 0 + 0 + 0 + 0 + 0 + 0 + 0) -- equivalent call inferred; original call site unknown
		pushvlqrealloc(state, data.RepeatCount)
		enumItem(Enum.EasingDirection).ser(state, data.EasingDirection)
		enumItem(Enum.EasingStyle).ser(state, data.EasingStyle)
	end,
	des = function(state)
		local des = enumItem(Enum.EasingStyle).des(state)
		local des2 = enumItem(Enum.EasingDirection).des(state)
		local v48 = popvlq(state)
		local v49 = popu1(state) -- equivalent call inferred; original call site unknown
		local v50 = v49 % 2 >= 1
		local _ = v49 % 4 >= 2
		local _ = v49 % 8 >= 4
		local _ = v49 % 16 >= 8
		local _ = v49 % 32 >= 16
		local _ = v49 % 64 >= 32
		local _ = v49 % 128 >= 64
		local _ = v49 % 256 >= 128
		local v51 = popf4(state) -- equivalent call inferred; original call site unknown
		local v52 = popf4(state) -- equivalent call inferred; original call site unknown
		return TweenInfo.new(v51, des, des2, v48, v50, v52)
	end
}

function Squash.TweenInfo()
	return v47
end

local v48 = {}

function Squash.UDim(p)
	if v48[p] then
		return v48[p]
	end

	local ser = p.ser
	local des = p.des
	local v49 = {
		ser = function(p2, p3)
			ser(p2, p3.Offset)
			ser(p2, p3.Scale)
		end,
		des = function(p2)
			return UDim.new(des(p2), des(p2))
		end
	}
	v48[p] = v49
	return v49
end

local v49 = {}

function Squash.UDim2(p)
	if v49[p] then
		return v49[p]
	end

	local ser = p.ser
	local des = p.des
	local v50 = {
		ser = function(p2, p3)
			ser(p2, p3.Y.Offset)
			ser(p2, p3.Y.Scale)
			ser(p2, p3.X.Offset)
			ser(p2, p3.X.Scale)
		end,
		des = function(p2)
			return UDim2.new(des(p2), des(p2), des(p2), des(p2))
		end
	}
	v49[p] = v50
	return v50
end

local v50 = {
	ser = function(state, p)
		tryrealloc(state, 4)
		pushi2(state, p.Y) -- equivalent call inferred; original call site unknown
		pushi2(state, p.X) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v51 = popi2(state) -- equivalent call inferred; original call site unknown
		return Vector2int16.new(v51, popi2(state))
	end
}

function Squash.Vector2int16()
	return v50
end

local v51 = {
	ser = function(state, data)
		tryrealloc(state, 6)
		pushi2(state, data.Z) -- equivalent call inferred; original call site unknown
		pushi2(state, data.Y) -- equivalent call inferred; original call site unknown
		pushi2(state, data.X) -- equivalent call inferred; original call site unknown
	end,
	des = function(state)
		local v52 = popi2(state) -- equivalent call inferred; original call site unknown
		local v53 = popi2(state) -- equivalent call inferred; original call site unknown
		return Vector3int16.new(v52, v53, popi2(state))
	end
}

function Squash.Vector3int16()
	return v51
end

return Squash