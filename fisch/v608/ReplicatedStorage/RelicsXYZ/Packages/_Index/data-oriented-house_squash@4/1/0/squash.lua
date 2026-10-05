local function newcursor(size: number?, value: number?)
	local buf = buffer.create((size or 8) + 4)
	buffer.writeu32(buf, 0, (value or 0) + 4)
	return { buf }
end

local function tryrealloc(bufs, p: number)
	local buf = bufs[1]
	local v = buffer.readu32(buf, 0)
	local v2 = buffer.len(buf)
	local v3 = v + p

	if v2 < v3 then
		repeat
			v2 *= 2
		until v3 < v2

		local buf2 = buffer.create(v2)
		buffer.copy(buf2, 0, buf, 0, v)
		bufs[1] = buf2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu1(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 1)
	buffer.writeu8(buf, v, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu1(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 1
	buffer.writeu32(buf, 0, v)
	return (buffer.readu8(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu2(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 2)
	buffer.writeu16(buf, v, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu2(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 2
	buffer.writeu32(buf, 0, v)
	return (buffer.readu16(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu3(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 3)
	buffer.writeu8(buf, v, value)
	buffer.writeu16(buf, v + 1, value // 256)
end

local function popu3(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 3
	local v2 = buffer.readu8(buf, v)
	local v3 = buffer.readu16(buf, v + 1)
	buffer.writeu32(buf, 0, v)
	return v2 + v3 * 256
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu4(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 4)
	buffer.writeu32(buf, v, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popu4(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 4
	buffer.writeu32(buf, 0, v)
	return (buffer.readu32(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu5(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 5)
	buffer.writeu8(buf, v, value)
	buffer.writeu32(buf, v + 1, value // 256)
end

local function popu5(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 5
	local v2 = buffer.readu8(buf, v)
	local v3 = buffer.readu32(buf, v + 1)
	buffer.writeu32(buf, 0, v)
	return v2 + v3 * 256
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu6(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 6)
	buffer.writeu16(buf, v, value)
	buffer.writeu32(buf, v + 2, value // 65536)
end

local function popu6(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 6
	local v2 = buffer.readu16(buf, v)
	local v3 = buffer.readu32(buf, v + 2)
	buffer.writeu32(buf, 0, v)
	return v2 + v3 * 65536
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu7(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 7)
	buffer.writeu8(buf, v, value)
	buffer.writeu16(buf, v + 1, value // 256)
	buffer.writeu32(buf, v + 3, value // 16777216)
end

local function popu7(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 7
	local v2 = buffer.readu8(buf, v)
	local v3 = buffer.readu16(buf, v + 1)
	local v4 = buffer.readu32(buf, v + 3)
	buffer.writeu32(buf, 0, v)
	return v2 + v3 * 256 + v4 * 16777216
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushu8(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 8)
	buffer.writeu32(buf, v, value)
	buffer.writeu32(buf, v + 4, value // 4294967296)
end

local function popu8(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 8
	local v2 = buffer.readu32(buf, v)
	local v3 = buffer.readu32(buf, v + 4)
	buffer.writeu32(buf, 0, v)
	return v2 + v3 * 4294967296
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi1(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 1)
	buffer.writei8(buf, v, value)
end

local function popi1(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 1
	buffer.writeu32(buf, 0, v)
	return (buffer.readi8(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi2(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 2)
	buffer.writei16(buf, v, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popi2(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 2
	buffer.writeu32(buf, 0, v)
	return (buffer.readi16(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi3(list, p: number)
	local v = p % 16777216
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v2 + 3)
	buffer.writeu8(buf, v2, v % 256)
	buffer.writeu16(buf, v2 + 1, v / 256)
end

local function popi3(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 3
	local v2 = buffer.readu8(buf, v)
	local v3 = buffer.readu16(buf, v + 1)
	buffer.writeu32(buf, 0, v)
	local v4 = v2 + v3 * 256

	if v4 >= 8388608 then
		return v4 - 16777216
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi4(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 4)
	buffer.writei32(buf, v, value)
end

local function popi4(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 4
	buffer.writeu32(buf, 0, v)
	return (buffer.readi32(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi5(list, p: number)
	local v = p % 1099511627776
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v2 + 5)
	buffer.writeu8(buf, v2, v)
	buffer.writeu32(buf, v2 + 1, v / 256)
end

local function popi5(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 5
	buffer.writeu32(buf, 0, v)
	local v2 = buffer.readu8(buf, v) + buffer.readu32(buf, v + 1) * 256

	if v2 >= 549755813888 then
		return v2 - 1099511627776
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi6(list, p: number)
	local v = p % 281474976710656
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v2 + 6)
	buffer.writeu16(buf, v2, v)
	buffer.writeu32(buf, v2 + 2, v / 65536)
end

local function popi6(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 6
	buffer.writeu32(buf, 0, v)
	local v2 = buffer.readu16(buf, v) + buffer.readu32(buf, v + 2) * 65536

	if v2 >= 140737488355328 then
		return v2 - 281474976710656
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi7(list, p: number)
	local v = p % 7.205759403792794e16
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v2 + 7)
	buffer.writeu8(buf, v2, v)
	buffer.writeu16(buf, v2 + 1, v / 256)
	buffer.writeu32(buf, v2 + 3, v / 16777216)
end

local function popi7(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 7
	buffer.writeu32(buf, 0, v)
	local v2 = buffer.readu8(buf, v)
	local v3 = buffer.readu16(buf, v + 1)
	local v4 = buffer.readu32(buf, v + 3)
	local v5 = v2 + v3 * 256 + v4 * 16777216

	if v5 >= 3.602879701896397e16 then
		return v5 - 7.205759403792794e16
	end

	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushi8(list, p: number)
	local v = p % 1.8446744073709552e19
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v2 + 8)
	buffer.writeu32(buf, v2, v)
	buffer.writeu32(buf, v2 + 4, v / 4294967296)
end

local function popi8(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 8
	buffer.writeu32(buf, 0, v)
	local v2 = buffer.readu32(buf, v) + buffer.readu32(buf, v + 4) * 4294967296

	if v2 >= 9.223372036854776e18 then
		return v2 - 1.8446744073709552e19
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushf4(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 4)
	buffer.writef32(buf, v, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popf4(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 4
	buffer.writeu32(buf, 0, v)
	return (buffer.readf32(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushf8(list, value: number)
	local buf = list[1]
	local v = buffer.readu32(buf, 0)
	buffer.writeu32(buf, 0, v + 8)
	buffer.writef64(buf, v, value)
end

local function popf8(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 8
	buffer.writeu32(buf, 0, v)
	return (buffer.readf64(buf, v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushbool(list, flag: boolean, flag2: boolean?, flag3: boolean?, flag4: boolean?, flag5: boolean?, flag6: boolean?, flag7: boolean?, flag8: boolean?)
	local v = flag and 1 or 0

	if flag2 then
		v += 2
	end

	if flag3 then
		v += 4
	end

	if flag4 then
		v += 8
	end

	if flag5 then
		v += 16
	end

	if flag6 then
		v += 32
	end

	if flag7 then
		v += 64
	end

	if flag8 then
		v += 128
	end

	pushu1(list, v) -- equivalent call inferred; original call site unknown
end

local function popbool(list)
	local v = popu1(list) -- equivalent call inferred; original call site unknown
	return v % 2 >= 1, v % 4 >= 2, v % 8 >= 4, v % 16 >= 8, v % 32 >= 16, v % 64 >= 32, v % 128 >= 64, v % 256 >= 128
end

local function pushvlqrealloc(list, p: number)
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

	tryrealloc(list, v)
	local v2 = p // 4294967296
	local v3 = p - v2 * 4294967296
	pushu1(list, v3 % 128) -- equivalent call inferred; original call site unknown

	if v >= 2 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(list, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 3 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(list, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 4 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(list, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 5 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(list, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 6 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(list, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v >= 7 then
		v3 = v2 % 128 * 33554432 + v3 // 128
		v2 //= 128
		pushu1(list, v3 % 128 + 128) -- equivalent call inferred; original call site unknown
	end

	if v == 8 then
		pushu1(list, (v2 % 128 * 33554432 + v3 // 128) % 128 + 128) -- equivalent call inferred; original call site unknown
	end
end

local function popvlq(list)
	local v = popu1(list) -- equivalent call inferred; original call site unknown
	local v2 = v % 128

	if v < 128 then
		return v2
	end

	local v3 = popu1(list) -- equivalent call inferred; original call site unknown
	local v4 = v2 * 128 + v3 % 128

	if v3 < 128 then
		return v4
	end

	local v5 = popu1(list) -- equivalent call inferred; original call site unknown
	local v6 = v4 * 128 + v5 % 128

	if v5 < 128 then
		return v6
	end

	local v7 = popu1(list) -- equivalent call inferred; original call site unknown
	local v8 = v6 * 128 + v7 % 128

	if v7 < 128 then
		return v8
	end

	local v9 = popu1(list) -- equivalent call inferred; original call site unknown
	local v10 = v8 * 128 + v9 % 128

	if v9 < 128 then
		return v10
	end

	local v11 = popu1(list) -- equivalent call inferred; original call site unknown
	local v12 = v10 * 128 + v11 % 128

	if v11 < 128 then
		return v12
	end

	local v13 = popu1(list) -- equivalent call inferred; original call site unknown
	local v14 = v12 * 128 + v13 % 128

	if v13 < 128 then
		return v14
	end

	local v15 = popu1(list) -- equivalent call inferred; original call site unknown
	return v14 * 128 + v15 % 128
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushstr(list, str: string, p: number?)
	local v = p or #str
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0)
	buffer.writestring(buf, v2, str)
	buffer.writeu32(buf, 0, v2 + v)

	if not p then
		pushvlqrealloc(list, v)
	end
end

local function popstr(list, p: number?)
	local v = p or popvlq(list)
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0) - v
	buffer.writeu32(buf, 0, v2)
	return buffer.readstring(buf, v2, v)
end

local function pushbuf(list, buf: buffer, p: number?)
	local v = p or buffer.len(buf)
	tryrealloc(list, v)
	local buf2 = list[1]
	local v2 = buffer.readu32(buf2, 0)
	buffer.copy(buf2, v2, buf, 0, v)
	buffer.writeu32(buf2, 0, v2 + v)

	if not p then
		pushvlqrealloc(list, v)
	end
end

local function popbuf(list, p: number?)
	local v = p or popvlq(list)
	local buf = list[1]
	local v2 = buffer.readu32(buf, 0) - v
	buffer.writeu32(buf, 0, v2)
	local buf2 = buffer.create(v)
	buffer.copy(buf2, 0, buf, v2, v)
	return buf2
end

local function printcursor(list)
	local buf = list[1]
	local v = buffer.readu32(buf, 0) - 4
	local v2 = { string.byte(buffer.tostring(buf), 5, -1) }
	local total = 7

	for i = 1, v do
		local v3 = v2[i]
		total += (v3 == 0 and 1 or math.ceil((math.log10(1 + v3)))) + 1
	end

	local v3 = v2[v + 1]

	if v3 then
		total += (v3 == 0 and 1 or math.ceil((math.log10(1 + v3)))) // 2
	end

	if #v2 == 0 or v == buffer.len(buf) - 4 then
		table.insert(v2, " ")
	end

	print((`Pos: {v} / {buffer.len(buf) - 4}\nBuf: \{ {table.concat(v2, " ")} }\n{string.rep(" ", total)}^`))
end

local Squash = {
	print = printcursor,
	cursor = newcursor,
	frombuffer = function(buf: buffer, p: number?)
		local v = buffer.len(buf)
		local buf2 = buffer.create(v + 4)
		buffer.writeu32(buf2, 0, (p or v) + 4)
		buffer.copy(buf2, 4, buf, 0, v)
		return { buf2 }
	end,
	tobuffer = function(list)
		local buf = list[1]
		local v = buffer.readu32(buf, 0)
		local buf2 = buffer.create(v - 4)
		buffer.copy(buf2, 0, buf, 4, v - 4)
		return buf2
	end,
	tryrealloc = tryrealloc,
	setpos = function(buf: buffer, value: number)
		buffer.writeu32(buf, 0, value)
	end,
	getpos = function(buf: buffer)
		return (buffer.readu32(buf, 0))
	end,
	setbuf = function(list, buf: buffer)
		list[1] = buf
	end,
	getbuf = function(list)
		return list[1]
	end,
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

local v2 = {
	ser = function(list, value)
		tryrealloc(list, 1)
		pushu1(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu1
}

function Squash.u8()
	return v2
end

local v3 = {
	ser = function(list, value)
		tryrealloc(list, 2)
		pushu2(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu2
}

function Squash.u16()
	return v3
end

local v4 = {
	ser = function(list, value)
		tryrealloc(list, 3)
		pushu3(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu3
}

function Squash.u24()
	return v4
end

local v5 = {
	ser = function(list, value)
		tryrealloc(list, 4)
		pushu4(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu4
}

function Squash.u32()
	return v5
end

local v6 = {
	ser = function(list, value)
		tryrealloc(list, 5)
		pushu5(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu5
}

function Squash.u40()
	return v6
end

local v7 = {
	ser = function(list, value)
		tryrealloc(list, 6)
		pushu6(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu6
}

function Squash.u48()
	return v7
end

local v8 = {
	ser = function(list, value)
		tryrealloc(list, 7)
		pushu7(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu7
}

function Squash.u56()
	return v8
end

local v9 = {
	ser = function(list, value)
		tryrealloc(list, 8)
		pushu8(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popu8
}

function Squash.u64()
	return v9
end

local v10 = {
	ser = function(list, value)
		tryrealloc(list, 1)
		pushi1(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popi1
}

function Squash.i8()
	return v10
end

local v11 = {
	ser = function(list, value)
		tryrealloc(list, 2)
		pushi2(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popi2
}

function Squash.i16()
	return v11
end

local v12 = {
	ser = function(list, p)
		tryrealloc(list, 3)
		pushi3(list, p) -- equivalent call inferred; original call site unknown
	end,
	des = popi3
}

function Squash.i24()
	return v12
end

local v13 = {
	ser = function(list, value)
		tryrealloc(list, 4)
		pushi4(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popi4
}

function Squash.i32()
	return v13
end

local v14 = {
	ser = function(list, p)
		tryrealloc(list, 5)
		pushi5(list, p) -- equivalent call inferred; original call site unknown
	end,
	des = popi5
}

function Squash.i40()
	return v14
end

local v15 = {
	ser = function(list, p)
		tryrealloc(list, 6)
		pushi6(list, p) -- equivalent call inferred; original call site unknown
	end,
	des = popi6
}

function Squash.i48()
	return v15
end

local v16 = {
	ser = function(list, p)
		tryrealloc(list, 7)
		pushi7(list, p) -- equivalent call inferred; original call site unknown
	end,
	des = popi7
}

function Squash.i56()
	return v16
end

local v17 = {
	ser = function(list, p)
		tryrealloc(list, 8)
		pushi8(list, p) -- equivalent call inferred; original call site unknown
	end,
	des = popi8
}

function Squash.i64()
	return v17
end

local v18 = {
	ser = function(list, value)
		tryrealloc(list, 4)
		pushf4(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popf4
}

function Squash.f32()
	return v18
end

local v19 = {
	ser = function(list, value)
		tryrealloc(list, 8)
		pushf8(list, value) -- equivalent call inferred; original call site unknown
	end,
	des = popf8
}

function Squash.f64()
	return v19
end

local function getNumberSizePushPop(p)
	if p == Squash.f64() then
		return 8, pushf8, popf8
	end

	if p == Squash.f32() then
		return 4, pushf4, popf4
	end

	if p == Squash.u8() then
		return 1, pushu1, popu1
	end

	if p == Squash.u16() then
		return 2, pushu2, popu2
	end

	if p == Squash.u24() then
		return 3, pushu3, popu3
	end

	if p == Squash.u32() then
		return 4, pushu4, popu4
	end

	if p == Squash.u40() then
		return 5, pushu5, popu5
	end

	if p == Squash.u48() then
		return 6, pushu6, popu6
	end

	if p == Squash.u56() then
		return 7, pushu7, popu7
	end

	if p == Squash.u64() then
		return 8, pushu8, popu8
	end

	if p == Squash.i8() then
		return 1, pushi1, popi1
	end

	if p == Squash.i16() then
		return 2, pushi2, popi2
	end

	if p == Squash.i24() then
		return 3, pushi3, popi3
	end

	if p == Squash.i32() then
		return 4, pushi4, popi4
	end

	if p == Squash.i40() then
		return 5, pushi5, popi5
	end

	if p == Squash.i48() then
		return 6, pushi6, popi6
	end

	if p == Squash.i56() then
		return 7, pushi7, popi7
	end

	if p == Squash.i64() then
		return 8, pushi8, popi8
	end

	return nil, p.ser, p.des
end

local v20 = {}

function Squash.vector2(p)
	if v20[p] then
		return v20[p]
	end

	local numberSizePushPop, v21, v22 = getNumberSizePushPop(p)
	local v23 = {}

	if numberSizePushPop then
		local v24 = numberSizePushPop * 2

		function v23.ser(p2, p3)
			tryrealloc(p2, v24)
			v21(p2, p3.y)
			v21(p2, p3.x)
		end
	else
		function v23.ser(p2, p3)
			v21(p2, p3.y)
			v21(p2, p3.x)
		end
	end

	function v23.des(p2)
		return (vector.create(v22(p2), v22(p2)))
	end

	v20[p] = v23
	return v23
end

local v21 = {}

function Squash.vector3(p)
	if v21[p] then
		return v21[p]
	end

	local numberSizePushPop, v22, v23 = getNumberSizePushPop(p)
	local v24 = {}

	if numberSizePushPop then
		local v25 = numberSizePushPop * 3

		function v24.ser(p2, data)
			tryrealloc(p2, v25)
			v22(p2, data.z)
			v22(p2, data.y)
			v22(p2, data.x)
		end
	else
		function v24.ser(p2, data)
			v22(p2, data.z)
			v22(p2, data.y)
			v22(p2, data.x)
		end
	end

	function v24.des(p2)
		return (vector.create(v23(p2), v23(p2), v23(p2)))
	end

	v21[p] = v24
	return v24
end

local v22 = {}

function Squash.vector4(p)
	if v22[p] then
		return v22[p]
	end

	local numberSizePushPop, v23, v24 = getNumberSizePushPop(p)
	local v25 = {}

	if numberSizePushPop then
		local v26 = numberSizePushPop * 4

		function v25.ser(p2, data)
			tryrealloc(p2, v26)
			v23(p2, data.w)
			v23(p2, data.z)
			v23(p2, data.y)
			v23(p2, data.x)
		end
	else
		function v25.ser(p2, data)
			v23(p2, data.w)
			v23(p2, data.z)
			v23(p2, data.y)
			v23(p2, data.x)
		end
	end

	function v25.des(p2)
		return (vector.create(v24(p2), v24(p2), v24(p2), v24(p2)))
	end

	v22[p] = v25
	return v25
end

local vector4

if pcall(function()
	return vector.zero.w
end) then
	vector4 = Squash.vector4
else
	vector4 = Squash.vector3
end

Squash.vector = vector4
local v24 = {}

function Squash.range(p: number, p2: number)
	local formatted = `{p}_{p2}`
	local v25 = v24[formatted]

	if v25 then
		return v25
	end

	local v26

	if p == p // 1 and p2 == p2 // 1 then
		v26 = p < p2
	else
		v26 = false
	end

	assert(v26, "min and max must be integers, and min < max")
	local v27 = p2 - p
	local v28, v29, v30

	if v27 < 256 then
		v28 = pushu1
		v29 = popu1
		v30 = 1
	elseif v27 < 65536 then
		v28 = pushu2
		v29 = popu2
		v30 = 2
	elseif v27 < 16777216 then
		v28 = pushu3
		v29 = popu3
		v30 = 3
	elseif v27 < 4294967296 then
		v28 = pushu4
		v29 = popu4
		v30 = 4
	elseif v27 < 1099511627776 then
		v28 = pushu5
		v29 = popu5
		v30 = 5
	elseif v27 < 281474976710656 then
		v28 = pushu6
		v29 = popu6
		v30 = 6
	elseif v27 < 7.205759403792794e16 then
		v28 = pushu7
		v29 = popu7
		v30 = 7
	else
		v28 = pushu8
		v29 = popu8
		v30 = 8
	end

	local v31 = {
		ser = function(p3, p4)
			tryrealloc(p3, v30)
			v28(p3, p4 - p)
		end,
		des = function(p3)
			return v29(p3) + p
		end
	}
	v24[formatted] = v31
	return v31
end

local v25 = {
	ser = function(list, list2)
		tryrealloc(list, #list2)
		pushstr(list, list2, false) -- equivalent call inferred; original call site unknown
	end,
	des = popstr
}
local v26 = {}
local v27 = table.create(256)
local v28 = {
	convert = function(value: string, value2: string, value3: string)
		local v29 = {}

		for i = 1, #value2 do
			v29[string.byte(value2, i)] = i - 1
		end

		local v30 = {}

		for i = 1, #value3 do
			v30[i - 1] = string.byte(value3, i)
		end

		local v31 = {}

		for i = 1, #value do
			table.insert(v31, v29[string.byte(value, i)])
		end

		local v32 = #value2
		local count = #value3
		local v33 = {}

		while #v31 > 0 do
			local v34 = 0

			for i = 1, #v31 do
				local v35 = v31[i] + v34 * v32
				v31[i] = v35 // count
				v34 = v35 % count
			end

			while #v31 > 0 and v31[1] == 0 do
				table.remove(v31, 1)
			end

			table.insert(v33, 1, (string.char(v30[v34])))
		end

		return table.concat(v33)
	end,
	alphabet = function(value: string)
		local v29 = table.create(#value)
		local v30 = {}

		for i = 1, #value do
			local v31 = string.sub(value, i, i)

			if v30[v31] then
				continue
			end

			v30[v31] = true
			table.insert(v29, v31)
		end

		table.sort(v29)
		return table.concat(v29)
	end,
	binary = "01",
	octal = "01234567",
	decimal = "0123456789",
	duodecimal = "0123456789AB",
	hexadecimal = "0123456789ABCDEF"
}

for i = 0, 255 do
	v27[i + 1] = string.char(i)
end

v28.utf8 = table.concat(v27)
v28.lower = "abcdefghijklmnopqrstuvwxyz"
v28.upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
v28.letters = v28.lower .. v28.upper
v28.punctuation = " .,?!:;'\"-_"
v28.english = v28.letters .. v28.punctuation
v28.filepath = v28.letters .. ":/"
v28.datastore = " !#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
Squash.string = setmetatable(v28, {
	__call = function(_, p: number?)
		if not p then
			return v25
		end

		if v26[p] then
			return v26[p]
		end

		local v30 = {
			ser = function(p2, p3)
				tryrealloc(p2, p)
				pushstr(p2, p3, p)
			end,
			des = function(p2)
				return popstr(p2, p)
			end
		}
		v26[p] = v30
		return v30
	end
})
local v30 = {}
local v31 = {}

function Squash.opt(p)
	if v31[p] then
		return v31[p]
	end

	local v32 = {
		ser = function(list, p2)
			if p2 == nil then
				tryrealloc(list, 1)
				pushu1(list, 0) -- equivalent call inferred; original call site unknown
			else
				p.ser(list, p2)
				tryrealloc(list, 1)
				pushu1(list, 1) -- equivalent call inferred; original call site unknown
			end
		end,
		des = function(list)
			if popu1(list) == 1 then
				return p.des(list)
			end

			return nil
		end
	}
	v31[p] = v32
	v30[v32] = p
	return v32
end

local v32 = {
	ser = function(p, buf)
		tryrealloc(p, buffer.len(buf))
		pushbuf(p, buf)
	end,
	des = popbuf
}
local v33 = {}

function Squash.buffer(p: number?)
	if not p then
		return v32
	end

	if v33[p] then
		return v33[p]
	end

	local v34 = {
		ser = function(p2, p3)
			tryrealloc(p2, p)
			pushbuf(p2, p3, p)
		end,
		des = function(p2)
			return (popbuf(p2, p))
		end
	}
	v33[p] = v34
	return v34
end

local v34 = {
	ser = pushvlqrealloc,
	des = popvlq
}

function Squash.vlq()
	return v34
end

local function serbitarr(list, list2, p: number?)
	local v35 = p or #list2

	if v35 == 0 then
		return
	end

	local v36 = v35 % 8
	local v37 = v35 - v36

	for i = 0, v37 - 1, 8 do
		pushbool(
			list,
			list2[i + 1],
			list2[i + 2],
			list2[i + 3],
			list2[i + 4],
			list2[i + 5],
			list2[i + 6],
			list2[i + 7],
			list2[i + 8]
		) -- equivalent call inferred; original call site unknown
	end

	if v36 == 1 then
		pushu1(list, list2[v37 + 1] and 1 or 0) -- equivalent call inferred; original call site unknown
	elseif v36 == 2 then
		local v38 = list2[v37 + 1] and 1 or 0

		if list2[v37 + 2] then
			v38 += 2
		end

		pushu1(list, v38) -- equivalent call inferred; original call site unknown
	elseif v36 == 3 then
		local flag = list2[v37 + 1]
		local flag2 = list2[v37 + 2]
		local flag3 = list2[v37 + 3]
		local v38 = flag and 1 or 0

		if flag2 then
			v38 += 2
		end

		if flag3 then
			v38 += 4
		end

		pushu1(list, v38) -- equivalent call inferred; original call site unknown
	elseif v36 == 4 then
		local flag = list2[v37 + 1]
		local flag2 = list2[v37 + 2]
		local flag3 = list2[v37 + 3]
		local flag4 = list2[v37 + 4]
		local v38 = flag and 1 or 0

		if flag2 then
			v38 += 2
		end

		if flag3 then
			v38 += 4
		end

		if flag4 then
			v38 += 8
		end

		pushu1(list, v38) -- equivalent call inferred; original call site unknown
	elseif v36 == 5 then
		local flag = list2[v37 + 1]
		local flag2 = list2[v37 + 2]
		local flag3 = list2[v37 + 3]
		local flag4 = list2[v37 + 4]
		local flag5 = list2[v37 + 5]
		local v38 = flag and 1 or 0

		if flag2 then
			v38 += 2
		end

		if flag3 then
			v38 += 4
		end

		if flag4 then
			v38 += 8
		end

		if flag5 then
			v38 += 16
		end

		pushu1(list, v38) -- equivalent call inferred; original call site unknown
	elseif v36 == 6 then
		local flag = list2[v37 + 1]
		local flag2 = list2[v37 + 2]
		local flag3 = list2[v37 + 3]
		local flag4 = list2[v37 + 4]
		local flag5 = list2[v37 + 5]
		local flag6 = list2[v37 + 6]
		local v38 = flag and 1 or 0

		if flag2 then
			v38 += 2
		end

		if flag3 then
			v38 += 4
		end

		if flag4 then
			v38 += 8
		end

		if flag5 then
			v38 += 16
		end

		if flag6 then
			v38 += 32
		end

		pushu1(list, v38) -- equivalent call inferred; original call site unknown
	elseif v36 == 7 then
		local flag = list2[v37 + 1]
		local flag2 = list2[v37 + 2]
		local flag3 = list2[v37 + 3]
		local flag4 = list2[v37 + 4]
		local flag5 = list2[v37 + 5]
		local flag6 = list2[v37 + 6]
		local flag7 = list2[v37 + 7]
		local v38 = flag and 1 or 0

		if flag2 then
			v38 += 2
		end

		if flag3 then
			v38 += 4
		end

		if flag4 then
			v38 += 8
		end

		if flag5 then
			v38 += 16
		end

		if flag6 then
			v38 += 32
		end

		if flag7 then
			v38 += 64
		end

		pushu1(list, v38) -- equivalent call inferred; original call site unknown
	end
end

local function desbitarr(list, p: number)
	if p == 0 then
		return {}
	end

	local result = table.create(p)
	local v35 = p // 8
	local v36 = v35 * 8
	local v37 = p % 8

	if v37 > 0 then
		local v38 = popu1(list) -- equivalent call inferred; original call site unknown
		local v39 = v38 % 2 >= 1
		local v40 = v38 % 4 >= 2
		local v41 = v38 % 8 >= 4
		local v42 = v38 % 16 >= 8
		local v43 = v38 % 32 >= 16
		local v44 = v38 % 64 >= 32
		local v45 = v38 % 128 >= 64
		local _ = v38 % 256 >= 128
		result[v36 + 1] = v39
		local v46 = v36 + 2

		if not (v37 > 1) then
			v40 = nil
		end

		result[v46] = v40
		local v47 = v36 + 3

		if not (v37 > 2) then
			v41 = nil
		end

		result[v47] = v41
		local v48 = v36 + 4

		if not (v37 > 3) then
			v42 = nil
		end

		result[v48] = v42
		local v49 = v36 + 5

		if not (v37 > 4) then
			v43 = nil
		end

		result[v49] = v43
		local v50 = v36 + 6

		if not (v37 > 5) then
			v44 = nil
		end

		result[v50] = v44
		local v51 = v36 + 7

		if not (v37 > 6) then
			v45 = nil
		end

		result[v51] = v45
	end

	for i = v35 - 1, 0, -1 do
		local v38 = i * 8
		local v39 = v38 + 1
		local v40 = v38 + 2
		local v41 = v38 + 3
		local v42 = v38 + 4
		local v43 = v38 + 5
		local v44 = v38 + 6
		local v45 = v38 + 7
		local v46 = v38 + 8
		local v47 = popu1(list) -- equivalent call inferred; original call site unknown
		local v48 = v47 % 2 >= 1
		local v49 = v47 % 4 >= 2
		local v50 = v47 % 8 >= 4
		local v51 = v47 % 16 >= 8
		local v52 = v47 % 32 >= 16
		local v53 = v47 % 64 >= 32
		local v54 = v47 % 128 >= 64
		local v55 = v47 % 256 >= 128
		result[v39] = v48
		result[v40] = v49
		result[v41] = v50
		result[v42] = v51
		result[v43] = v52
		result[v44] = v53
		result[v45] = v54
		result[v46] = v55
	end

	return result
end

local v35 = {}

function Squash.array(p, value)
	local v36 = v35[p]
	local v37 = value or 0

	if v36 then
		if v36[v37] then
			return v36[v37]
		end
	else
		v36 = {}
		v35[p] = v36
	end

	if p == v then
		local v38 = {
			ser = function(p2, list)
				local v39

				if type(value) == "number" then
					v39 = value
				else
					v39 = #list
				end

				serbitarr(p2, list, v39)

				if not value then
					pushvlqrealloc(p2, v39)
				elseif type(value) ~= "number" then
					value.ser(p2, v39)
				end
			end,
			des = function(p2)
				local v39

				if value then
					if type(value) == "number" then
						v39 = value
					else
						v39 = value.des(p2)
					end
				else
					v39 = popvlq(p2)
				end

				return (desbitarr(p2, v39))
			end
		}
		v36[v37] = v38
		return v38
	elseif v30[p] then
		local v38 = v30[p]

		if v38 == v then
			local v39 = {
				ser = function(p2, list)
					local v40

					if type(value) == "number" then
						v40 = value
					else
						v40 = table.maxn(list)
					end

					local v41 = table.create(v40)
					local v42 = table.create(v40)

					for i = 1, v40 do
						local v43 = list[i]

						if v43 == nil then
							v42[i] = false
						else
							table.insert(v41, v43)
							v42[i] = true
						end
					end

					tryrealloc(p2, #v41 // 8 + 1 + (1 + v40 // 8))
					serbitarr(p2, v41)
					serbitarr(p2, v42)

					if not value then
						pushvlqrealloc(p2, v40)
					elseif type(value) ~= "number" then
						value.ser(p2, v40)
					end
				end,
				des = function(p2)
					local v40

					if value then
						if type(value) == "number" then
							v40 = value
						else
							v40 = value.des(p2)
						end
					else
						v40 = popvlq(p2)
					end

					local v41 = desbitarr(p2, v40)
					local total = 0

					for _, v42 in v41 do
						total += v42 and 1 or 0
					end

					local v42 = desbitarr(p2, total)
					local result = table.create(v40)
					local v43 = 1

					for k, v44 in v41 do
						if not v44 then
							continue
						end

						result[k] = v42[v43]
						v43 += 1
					end

					return result
				end
			}
			v36[v37] = v39
			return v39
		else
			local v39 = {
				ser = function(p2, list)
					local ser = v38.ser
					local v40

					if type(value) == "number" then
						v40 = value
					else
						v40 = table.maxn(list)
					end

					local v41 = table.create(v40)

					for i = 1, v40 do
						local v42 = list[i]

						if v42 == nil then
							v41[i] = false
						else
							ser(p2, v42)
							v41[i] = true
						end
					end

					tryrealloc(p2, 1 + v40 // 8)
					serbitarr(p2, v41)

					if not value then
						pushvlqrealloc(p2, v40)
					elseif type(value) ~= "number" then
						value.ser(p2, v40)
					end
				end,
				des = function(p2)
					local des = v38.des
					local v40

					if value then
						if type(value) == "number" then
							v40 = value
						else
							v40 = value.des(p2)
						end
					else
						v40 = popvlq(p2)
					end

					local v41 = desbitarr(p2, v40)
					local result = table.create(v40)

					for i = v40, 1, -1 do
						if v41[i] then
							result[i] = des(p2)
						end
					end

					return result
				end
			}
			v36[v37] = v39
			return v39
		end
	else
		local v38 = {
			ser = function(p2, list)
				local ser = p.ser
				local v39

				if type(value) == "number" then
					v39 = value
				else
					v39 = #list
				end

				for i = 1, v39 do
					ser(p2, list[i])
				end

				if not value then
					pushvlqrealloc(p2, v39)
				elseif type(value) ~= "number" then
					value.ser(p2, v39)
				end
			end,
			des = function(p2)
				local des = p.des
				local v39

				if value then
					if type(value) == "number" then
						v39 = value
					else
						v39 = value.des(p2)
					end
				else
					v39 = popvlq(p2)
				end

				local result = table.create(v39)

				for i = v39, 1, -1 do
					result[i] = des(p2)
				end

				return result
			end
		}
		v36[v37] = v38
		return v38
	end
end

function Squash.tuple(...)
	local v36 = { ... }
	local count = #v36

	if count == 1 then
		return v36[1]
	end

	return {
		ser = function(p, ...)
			for k, v37 in { ... } do
				v36[k].ser(p, v37)
			end
		end,
		des = function(p)
			local v37 = table.create(count)

			for i = count, 1, -1 do
				v37[i] = v36[i].des(p)
			end

			return table.unpack(v37)
		end
	}
end

function Squash.record(items)
	local v36 = {}
	local v37 = {}
	local v38 = {}
	local v39 = {}

	for k, item in items do
		if type(k) ~= "string" then
			continue
		end

		local v40 = v30[item]

		if v40 == v then
			table.insert(v36, k)
		elseif v40 then
			table.insert(v37, k)
		elseif item == v then
			table.insert(v38, k)
		else
			table.insert(v39, k)
		end
	end

	local count = #v39
	table.sort(v39)
	local count2 = #v38

	if count2 > 0 then
		table.sort(v38)
	end

	local count3 = #v37
	local v40 = {}

	if count3 > 0 then
		table.sort(v37)

		for k, v41 in v37 do
			v40[k] = v30[items[v41]]
		end
	end

	local count4 = #v36

	if count4 > 0 then
		table.sort(v36)
	end

	return {
		ser = function(p, p2)
			for _, v41 in v39 do
				local v42 = p2[v41]
				items[v41].ser(p, v42)
			end

			local v41 = table.create(count2 + count4)

			for k, v42 in v38 do
				v41[k] = p2[v42]
			end

			local v42 = count2
			local v43 = table.create(count4 + count3)

			for k, v44 in v36 do
				local v45 = p2[v44]

				if v45 == nil then
					v43[k] = false
				else
					v42 += 1
					v41[v42] = v45
					v43[k] = true
				end
			end

			for k, v44 in v37 do
				local v45 = k + count4
				local v46 = p2[v44]

				if v46 == nil then
					v43[v45] = false
				else
					v40[k].ser(p, v46)
					v43[v45] = true
				end
			end

			tryrealloc(p, v42 + count4 + count3)
			serbitarr(p, v41, v42)
			serbitarr(p, v43, count4 + count3)
		end,
		des = function(p)
			local v41 = desbitarr(p, count4 + count3)
			local v42 = count2
			local result = {}

			for i = 1, count4 do
				v42 += v41[i] and 1 or 0
			end

			local v43 = desbitarr(p, v42)

			for k, v44 in v38 do
				result[v44] = v43[k]
			end

			for i = count4, 1, -1 do
				if not v41[i] then
					continue
				end

				result[v36[i]] = v43[v42]
				v42 -= 1
			end

			for i = count3, 1, -1 do
				if v41[i + count4] then
					result[v37[i]] = v40[i].des(p)
				end
			end

			for i = count, 1, -1 do
				local v44 = v39[i]
				result[v44] = items[v44].des(p)
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
			local v36

			if value then
				if type(value) == "number" then
					v36 = value
				else
					v36 = value.des(p3)
				end
			else
				v36 = popvlq(p3)
			end

			for _ = 1, v36 do
				result[p.des(p3)] = p2.des(p3)
			end

			return result
		end
	}
end

function Squash.literal(...)
	local v36 = { ... }
	local v37 = {}

	for k, v38 in v36 do
		v37[v38] = k - 1
	end

	return {
		ser = function(list, p)
			tryrealloc(list, 1)
			pushu1(list, v37[p]) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			return v36[popu1(list) + 1]
		end
	}
end

function Squash.table(items, value)
	local v36 = {}
	local v37 = {}

	for k in items do
		local v38 = #v36 + 1
		v36[v38] = k
		v37[k] = v38
	end

	return {
		ser = function(list, items2)
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

				item2.ser(list, item)
				local v38 = v37[typeName] or error("")
				tryrealloc(list, 1)
				pushu1(list, v38 - 1) -- equivalent call inferred; original call site unknown
				item3.ser(list, k)
				local v40 = v37[typeName2] or error("")
				tryrealloc(list, 1)
				pushu1(list, v40 - 1) -- equivalent call inferred; original call site unknown
				count += 1
			end

			if not value then
				pushvlqrealloc(list, count)
			elseif type(value) ~= "number" then
				value.ser(list, count)
			end
		end,
		des = function(list)
			local result = {}
			local v38

			if value then
				if type(value) == "number" then
					v38 = value
				else
					v38 = value.des(list)
				end
			else
				v38 = popvlq(list)
			end

			for _ = 1, v38 do
				local des = items[v36[popu1(list) + 1]].des(list)
				result[des] = items[v36[popu1(list) + 1]].des(list)
			end

			return result
		end
	}
end

if Axes ~= nil then
	local v36 = {
		ser = function(list, data)
			tryrealloc(list, 2)
			local back = data.Back
			local bottom = data.Bottom
			local front = data.Front
			local left = data.Left
			local right = data.Right
			local top = data.Top
			local v37 = back and 1 or 0

			if bottom then
				v37 += 2
			end

			if front then
				v37 += 4
			end

			if left then
				v37 += 8
			end

			if right then
				v37 += 16
			end

			if top then
				v37 += 32
			end

			pushu1(list, v37) -- equivalent call inferred; original call site unknown
			local X = data.X
			local Y = data.Y
			local Z = data.Z
			local v38 = X and 1 or 0

			if Y then
				v38 += 2
			end

			if Z then
				v38 += 4
			end

			pushu1(list, v38) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v37 = popu1(list) -- equivalent call inferred; original call site unknown
			local v38 = v37 % 2 >= 1
			local v39 = v37 % 4 >= 2
			local v40 = v37 % 8 >= 4
			local _ = v37 % 16 >= 8
			local _ = v37 % 32 >= 16
			local _ = v37 % 64 >= 32
			local _ = v37 % 128 >= 64
			local _ = v37 % 256 >= 128
			local v41 = popu1(list) -- equivalent call inferred; original call site unknown
			local v42 = v41 % 2 >= 1
			local v43 = v41 % 4 >= 2
			local v44 = v41 % 8 >= 4
			local v45 = v41 % 16 >= 8
			local v46 = v41 % 32 >= 16
			local v47 = v41 % 64 >= 32
			local _ = v41 % 128 >= 64
			local _ = v41 % 256 >= 128
			return Axes.new(
				v38 and Enum.Axis.X,
				v39 and Enum.Axis.Y,
				v40 and Enum.Axis.Z,
				v42 and Enum.NormalId.Back,
				v43 and Enum.NormalId.Bottom,
				v44 and Enum.NormalId.Front,
				v45 and Enum.NormalId.Left,
				v46 and Enum.NormalId.Right,
				v47 and Enum.NormalId.Top
			)
		end
	}

	function Squash.Axes()
		return v36
	end
end

if BrickColor ~= nil then
	local v36 = {
		ser = function(list, p)
			tryrealloc(list, 2)
			pushu2(list, p.Number) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v37 = popu2(list) -- equivalent call inferred; original call site unknown
			return BrickColor.new(v37)
		end
	}

	function Squash.BrickColor()
		return v36
	end
end

local enumItem

if Enum == nil then
	enumItem = nil
else
	local v36 = {}

	function Squash.EnumItem(object)
		if v36[object] then
			return v36[object]
		end

		local enumItems = object:GetEnumItems()
		table.sort(enumItems, function(a, b)
			return a.Value < b.Value
		end)
		local enumItems2 = table.create(#enumItems)
		local v37 = {}

		for k, enumItem2 in enumItems do
			v37[enumItem2] = k
			enumItems2[k] = enumItem2
		end

		local v38 = {
			ser = function(p, p2)
				pushvlqrealloc(p, v37[p2])
			end,
			des = function(p)
				return enumItems2[popvlq(p)]
			end
		}
		v36[object] = v38
		return v38
	end

	enumItem = Squash.EnumItem
end

if CatalogSearchParams ~= nil then
	local v36 = {
		ser = function(list, data)
			tryrealloc(list, #data.CreatorName + 10 + #data.SearchKeyword)
			pushu1(list, data.IncludeOffSale and 1 or 0) -- equivalent call inferred; original call site unknown
			pushu1(list, data.Limit) -- equivalent call inferred; original call site unknown
			pushu4(list, data.MinPrice) -- equivalent call inferred; original call site unknown
			pushu4(list, data.MaxPrice) -- equivalent call inferred; original call site unknown
			pushstr(list, data.CreatorName, false) -- equivalent call inferred; original call site unknown
			pushstr(list, data.SearchKeyword, false) -- equivalent call inferred; original call site unknown
			enumItem(Enum.CatalogSortType).ser(list, data.SortType)
			enumItem(Enum.CatalogSortAggregation).ser(list, data.SortAggregation)
			enumItem(Enum.CatalogCategoryFilter).ser(list, data.CategoryFilter)
			enumItem(Enum.SalesTypeFilter).ser(list, data.SalesTypeFilter)

			for _, assetType in data.AssetTypes do
				enumItem(Enum.AssetType).ser(list, assetType)
			end

			pushvlqrealloc(list, #data.AssetTypes)
		end,
		des = function(list)
			local catalogSearchParams = CatalogSearchParams.new()
			local v37 = popvlq(list)
			local assetTypes = table.create(v37)

			for i = v37, 1, -1 do
				assetTypes[i] = enumItem(Enum.AssetType).des(list)
			end

			catalogSearchParams.AssetTypes = assetTypes
			catalogSearchParams.SalesTypeFilter = enumItem(Enum.SalesTypeFilter).des(list)
			catalogSearchParams.CategoryFilter = enumItem(Enum.CatalogCategoryFilter).des(list)
			catalogSearchParams.SortAggregation = enumItem(Enum.CatalogSortAggregation).des(list)
			catalogSearchParams.SortType = enumItem(Enum.CatalogSortType).des(list)
			local v39 = popvlq(list)
			local buf = list[1]
			local v40 = buffer.readu32(buf, 0) - v39
			buffer.writeu32(buf, 0, v40)
			catalogSearchParams.SearchKeyword = buffer.readstring(buf, v40, v39)
			local v41 = popvlq(list)
			local buf2 = list[1]
			local v42 = buffer.readu32(buf2, 0) - v41
			buffer.writeu32(buf2, 0, v42)
			catalogSearchParams.CreatorName = buffer.readstring(buf2, v42, v41)
			catalogSearchParams.MaxPrice = popu4(list)
			catalogSearchParams.MinPrice = popu4(list)
			catalogSearchParams.Limit = popu1(list)
			local v43 = popu1(list) -- equivalent call inferred; original call site unknown
			local includeOffSale = v43 % 2 >= 1
			local _ = v43 % 4 >= 2
			local _ = v43 % 8 >= 4
			local _ = v43 % 16 >= 8
			local _ = v43 % 32 >= 16
			local _ = v43 % 64 >= 32
			local _ = v43 % 128 >= 64
			local _ = v43 % 256 >= 128
			catalogSearchParams.IncludeOffSale = includeOffSale
			return catalogSearchParams
		end
	}

	function Squash.CatalogSearchParams()
		return v36
	end
end

local rotser
local rotdes
local v36 = nil
local v37

if CFrame == nil then
	v37 = nil
else
	v36 = {
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
	v37 = {}

	for k, cframe in v36 do
		v37[vector.create(cframe:ToOrientation())] = k
	end

	rotser = function(list, cframe: CFrame)
		local v38 = v37[vector.create(cframe:ToOrientation())]

		if v38 then
			tryrealloc(list, 1)
			pushu1(list, v38) -- equivalent call inferred; original call site unknown
		else
			local axisAngle, v39 = cframe:ToAxisAngle()
			local v40 = axisAngle * math.sin(v39 / 2)
			tryrealloc(list, 7)
			local v41 = math.round((v40.Z + 1) * 32768 - 1)
			local v42 = math.round((v40.Y + 1) * 32768 - 1)
			local v43 = math.round((v40.X + 1) * 32768 - 1)
			pushu2(list, v41) -- equivalent call inferred; original call site unknown
			pushu2(list, v42) -- equivalent call inferred; original call site unknown
			pushu2(list, v43) -- equivalent call inferred; original call site unknown
			pushu1(list, 0) -- equivalent call inferred; original call site unknown
		end
	end

	rotdes = function(list)
		local v38 = popu1(list) -- equivalent call inferred; original call site unknown

		if v38 ~= 0 then
			return v36[v38]
		end

		local v39 = (popu2(list) + 1) * 0.000030517578125 - 1
		local v40 = (popu2(list) + 1) * 0.000030517578125 - 1
		local v41 = (popu2(list) + 1) * 0.000030517578125 - 1
		local v42 = math.sqrt(1 - math.clamp(v39 * v39 + v40 * v40 + v41 * v41, 0, 1))
		return CFrame.new(0, 0, 0, v39, v40, v41, v42)
	end

	local v38 = {
		ser = rotser,
		des = rotdes
	}

	function Squash.rotation()
		return v38
	end
end

local cFrame

if CFrame == nil then
	cFrame = nil
else
	local v38 = {}

	function Squash.CFrame(p)
		if v38[p] then
			return v38[p]
		end

		local numberSizePushPop, v39, v40 = getNumberSizePushPop(p)
		local v41 = {}

		if numberSizePushPop then
			local v42 = numberSizePushPop * 3

			function v41.ser(list, cframe)
				local v43 = v37[vector.create(cframe:ToOrientation())]

				if v43 then
					tryrealloc(list, 1 + v42)
					pushu1(list, v43) -- equivalent call inferred; original call site unknown
				else
					local axisAngle, v44 = cframe:ToAxisAngle()
					local v45 = axisAngle * math.sin(v44 / 2)
					tryrealloc(list, 7 + v42)
					local v46 = math.round((v45.Z + 1) * 32768 - 1)
					local v47 = math.round((v45.Y + 1) * 32768 - 1)
					local v48 = math.round((v45.X + 1) * 32768 - 1)
					pushu2(list, v46) -- equivalent call inferred; original call site unknown
					pushu2(list, v47) -- equivalent call inferred; original call site unknown
					pushu2(list, v48) -- equivalent call inferred; original call site unknown
					pushu1(list, 0) -- equivalent call inferred; original call site unknown
				end

				local position = cframe.Position
				v39(list, position.Z)
				v39(list, position.Y)
				v39(list, position.X)
			end
		else
			function v41.ser(p2, p3)
				rotser(p2, p3)
				local position = p3.Position
				v39(p2, position.Z)
				v39(p2, position.Y)
				v39(p2, position.X)
			end
		end

		function v41.des(p2)
			local v42 = v40(p2)
			local v43 = v40(p2)
			local v44 = v40(p2)
			return rotdes(p2) + Vector3.new(v42, v43, v44)
		end

		v38[p] = v41
		return v41
	end

	cFrame = Squash.CFrame
end

local pushcolor3, popcolor3

if Color3 == nil then
	pushcolor3 = nil
	popcolor3 = nil
else
	pushcolor3 = function(list, data)
		pushu1(list, data.B * 255) -- equivalent call inferred; original call site unknown
		pushu1(list, data.G * 255) -- equivalent call inferred; original call site unknown
		pushu1(list, data.R * 255) -- equivalent call inferred; original call site unknown
	end

	popcolor3 = function(list)
		local v38 = popu1(list) -- equivalent call inferred; original call site unknown
		local v39 = popu1(list) -- equivalent call inferred; original call site unknown
		return Color3.fromRGB(v38, v39, popu1(list))
	end

	local v38 = {
		ser = function(p, p2)
			tryrealloc(p, 3)
			pushcolor3(p, p2)
		end,
		des = popcolor3
	}

	function Squash.Color3()
		return v38
	end
end

local pushcolorsequencekeypoint, popcolorsequencekeypoint

if ColorSequenceKeypoint == nil then
	pushcolorsequencekeypoint = nil
	popcolorsequencekeypoint = nil
else
	pushcolorsequencekeypoint = function(list, p)
		pushcolor3(list, p.Value)
		pushu1(list, p.Time * 255) -- equivalent call inferred; original call site unknown
	end

	popcolorsequencekeypoint = function(list)
		return ColorSequenceKeypoint.new(popu1(list) / 255, popcolor3(list))
	end

	local v38 = {
		ser = function(p, p2)
			tryrealloc(p, 4)
			pushcolorsequencekeypoint(p, p2)
		end,
		des = popcolorsequencekeypoint
	}

	function Squash.ColorSequenceKeypoint()
		return v38
	end
end

if ColorSequence ~= nil then
	local v38 = {
		ser = function(p, sequence)
			tryrealloc(p, #sequence.Keypoints * 4)

			for _, keypoint in sequence.Keypoints do
				pushcolorsequencekeypoint(p, keypoint)
			end

			pushvlqrealloc(p, #sequence.Keypoints)
		end,
		des = function(p)
			local v39 = popvlq(p)
			local v40 = table.create(v39)

			for i = v39, 1, -1 do
				v40[i] = popcolorsequencekeypoint(p)
			end

			return ColorSequence.new(v40)
		end
	}

	function Squash.ColorSequence()
		return v38
	end
end

if DateTime ~= nil then
	local v38 = {
		ser = function(list, p)
			tryrealloc(list, 6)
			pushu6(list, p.UnixTimestampMillis) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local buf = list[1]
			local v39 = buffer.readu32(buf, 0) - 6
			local v40 = buffer.readu16(buf, v39)
			local v41 = buffer.readu32(buf, v39 + 2)
			buffer.writeu32(buf, 0, v39)
			return DateTime.fromUnixTimestampMillis(v40 + v41 * 65536)
		end
	}

	function Squash.DateTime()
		return v38
	end
end

if Faces ~= nil then
	local v38 = {
		ser = function(list, data)
			tryrealloc(list, 1)
			local back = data.Back
			local bottom = data.Bottom
			local front = data.Front
			local left = data.Left
			local right = data.Right
			local top = data.Top
			local v39 = back and 1 or 0

			if bottom then
				v39 += 2
			end

			if front then
				v39 += 4
			end

			if left then
				v39 += 8
			end

			if right then
				v39 += 16
			end

			if top then
				v39 += 32
			end

			pushu1(list, v39) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v39 = popu1(list) -- equivalent call inferred; original call site unknown
			local v40 = v39 % 2 >= 1
			local v41 = v39 % 4 >= 2
			local v42 = v39 % 8 >= 4
			local v43 = v39 % 16 >= 8
			local v44 = v39 % 32 >= 16
			local v45 = v39 % 64 >= 32
			local _ = v39 % 128 >= 64
			local _ = v39 % 256 >= 128
			return Faces.new(
				v40 and Enum.NormalId.Back,
				v41 and Enum.NormalId.Bottom,
				v42 and Enum.NormalId.Front,
				v43 and Enum.NormalId.Left,
				v44 and Enum.NormalId.Right,
				v45 and Enum.NormalId.Top
			)
		end
	}

	function Squash.Faces()
		return v38
	end
end

if FloatCurveKey ~= nil then
	local v38 = {
		ser = function(list, data)
			enumItem(Enum.KeyInterpolationMode).ser(list, data.Interpolation)
			tryrealloc(list, 8)
			pushf4(list, data.Value) -- equivalent call inferred; original call site unknown
			pushf4(list, data.Time) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local new = FloatCurveKey.new
			local v39 = popf4(list) -- equivalent call inferred; original call site unknown
			return new(v39, popf4(list), (enumItem(Enum.KeyInterpolationMode).des(list)))
		end
	}

	function Squash.FloatCurveKey()
		return v38
	end
end

if Font ~= nil then
	local v38 = {
		ser = function(list, data)
			local v39 = string.match(data.Family, "rbxasset://fonts/families/(.+).json") or error((`Invalid font family {data.Family}`))
			tryrealloc(list, #v39 + 1)
			pushstr(list, v39, false) -- equivalent call inferred; original call site unknown
			pushu1(list, data.Bold and 1 or 0) -- equivalent call inferred; original call site unknown
			enumItem(Enum.FontWeight).ser(list, data.Weight)
			enumItem(Enum.FontStyle).ser(list, data.Style)
		end,
		des = function(list)
			local des = enumItem(Enum.FontStyle).des(list)
			local des2 = enumItem(Enum.FontWeight).des(list)
			local v39 = popu1(list) -- equivalent call inferred; original call site unknown
			local bold = v39 % 2 >= 1
			local _ = v39 % 4 >= 2
			local _ = v39 % 8 >= 4
			local _ = v39 % 16 >= 8
			local _ = v39 % 32 >= 16
			local _ = v39 % 64 >= 32
			local _ = v39 % 128 >= 64
			local _ = v39 % 256 >= 128
			local v41 = popvlq(list)
			local buf = list[1]
			local v42 = buffer.readu32(buf, 0) - v41
			buffer.writeu32(buf, 0, v42)
			local v43 = buffer.readstring(buf, v42, v41)
			local font = Font.new(`rbxasset://fonts/families/{v43}.json`, des2, des)
			font.Bold = bold
			return font
		end
	}

	function Squash.Font()
		return v38
	end
end

if NumberRange ~= nil then
	local v38 = {}

	function Squash.NumberRange(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
			ser = function(p2, p3)
				ser(p2, p3.Max)
				ser(p2, p3.Min)
			end,
			des = function(p2)
				return NumberRange.new(des(p2), des(p2))
			end
		}
		v38[p] = v39
		return v39
	end
end

local numberSequenceKeypoint

if NumberSequenceKeypoint == nil then
	numberSequenceKeypoint = nil
else
	local v38 = {}

	function Squash.NumberSequenceKeypoint(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
			ser = function(list, data)
				ser(list, data.Value)
				ser(list, data.Envelope)
				tryrealloc(list, 4)
				pushf4(list, data.Time) -- equivalent call inferred; original call site unknown
			end,
			des = function(list)
				local v40 = popf4(list) -- equivalent call inferred; original call site unknown
				local v41 = des(list)
				local v42 = des(list)
				return NumberSequenceKeypoint.new(v40, v42, v41)
			end
		}
		v38[p] = v39
		return v39
	end

	numberSequenceKeypoint = Squash.NumberSequenceKeypoint
end

if NumberSequence ~= nil then
	local v38 = {}

	function Squash.NumberSequence(p)
		if v38[p] then
			return v38[p]
		end

		local ser = numberSequenceKeypoint(p).ser
		local des = numberSequenceKeypoint(p).des
		local v39 = {
			ser = function(p2, sequence)
				local ser2 = ser

				for _, keypoint in sequence.Keypoints do
					ser2(p2, keypoint)
				end

				pushvlqrealloc(p2, #sequence.Keypoints)
			end,
			des = function(p2)
				local v40 = popvlq(p2)
				local v41 = table.create(v40)

				for i = v40, 1, -1 do
					v41[i] = des(p2)
				end

				return NumberSequence.new(v41)
			end
		}
		v38[p] = v39
		return v39
	end
end

if OverlapParams ~= nil then
	local v38 = {
		ser = function(list, data)
			tryrealloc(list, #data.CollisionGroup + 3)
			local v39 = data.BruteForceAllSlow and 1 or 0

			if data.RespectCanCollide then
				v39 += 2
			end

			pushu1(list, v39) -- equivalent call inferred; original call site unknown
			pushu2(list, data.MaxParts) -- equivalent call inferred; original call site unknown
			pushstr(list, data.CollisionGroup, false) -- equivalent call inferred; original call site unknown
			enumItem(Enum.RaycastFilterType).ser(list, data.FilterType)
		end,
		des = function(list)
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = enumItem(Enum.RaycastFilterType).des(list)
			local v39 = popvlq(list)
			local buf = list[1]
			local v40 = buffer.readu32(buf, 0) - v39
			buffer.writeu32(buf, 0, v40)
			overlapParams.CollisionGroup = buffer.readstring(buf, v40, v39)
			overlapParams.MaxParts = popu2(list)
			local v41 = popu1(list) -- equivalent call inferred; original call site unknown
			local bruteForceAllSlow = v41 % 2 >= 1
			local respectCanCollide = v41 % 4 >= 2
			local _ = v41 % 8 >= 4
			local _ = v41 % 16 >= 8
			local _ = v41 % 32 >= 16
			local _ = v41 % 64 >= 32
			local _ = v41 % 128 >= 64
			local _ = v41 % 256 >= 128
			overlapParams.BruteForceAllSlow = bruteForceAllSlow
			overlapParams.RespectCanCollide = respectCanCollide
			return overlapParams
		end
	}

	function Squash.OverlapParams()
		return v38
	end
end

if RaycastParams ~= nil then
	local v38 = {
		ser = function(list, data)
			tryrealloc(list, #data.CollisionGroup + 1)
			local bruteForceAllSlow = data.BruteForceAllSlow
			local respectCanCollide = data.RespectCanCollide
			local ignoreWater = data.IgnoreWater
			local v39 = bruteForceAllSlow and 1 or 0

			if respectCanCollide then
				v39 += 2
			end

			if ignoreWater then
				v39 += 4
			end

			pushu1(list, v39) -- equivalent call inferred; original call site unknown
			pushstr(list, data.CollisionGroup, false) -- equivalent call inferred; original call site unknown
			enumItem(Enum.RaycastFilterType).ser(list, data.FilterType)
		end,
		des = function(list)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = enumItem(Enum.RaycastFilterType).des(list)
			local v39 = popvlq(list)
			local buf = list[1]
			local v40 = buffer.readu32(buf, 0) - v39
			buffer.writeu32(buf, 0, v40)
			raycastParams.CollisionGroup = buffer.readstring(buf, v40, v39)
			local v41 = popu1(list) -- equivalent call inferred; original call site unknown
			local bruteForceAllSlow = v41 % 2 >= 1
			local respectCanCollide = v41 % 4 >= 2
			local ignoreWater = v41 % 8 >= 4
			local _ = v41 % 16 >= 8
			local _ = v41 % 32 >= 16
			local _ = v41 % 64 >= 32
			local _ = v41 % 128 >= 64
			local _ = v41 % 256 >= 128
			raycastParams.BruteForceAllSlow = bruteForceAllSlow
			raycastParams.RespectCanCollide = respectCanCollide
			raycastParams.IgnoreWater = ignoreWater
			return raycastParams
		end
	}

	function Squash.RaycastParams()
		return v38
	end
end

if Vector2 ~= nil then
	local v38 = {}

	function Squash.Vector2(p)
		if v38[p] then
			return v38[p]
		end

		local numberSizePushPop, v39, v40 = getNumberSizePushPop(p)
		local v41 = {}

		if numberSizePushPop then
			local v42 = numberSizePushPop * 2

			function v41.ser(p2, p3)
				tryrealloc(p2, v42)
				v39(p2, p3.Y)
				v39(p2, p3.X)
			end
		else
			function v41.ser(p2, p3)
				v39(p2, p3.Y)
				v39(p2, p3.X)
			end
		end

		function v41.des(p2)
			return Vector2.new(v40(p2), v40(p2))
		end

		v38[p] = v41
		return v41
	end
end

if PathWaypoint ~= nil then
	local v38 = {}

	function Squash.PathWaypoint(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
			ser = function(list, data)
				tryrealloc(list, #data.Label)
				pushstr(list, data.Label, false) -- equivalent call inferred; original call site unknown
				enumItem(Enum.PathWaypointAction).ser(list, data.Action)
				ser(list, data.Position.Z)
				ser(list, data.Position.Y)
				ser(list, data.Position.X)
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
end

if PhysicalProperties ~= nil then
	local v38 = {
		ser = function(list, data)
			tryrealloc(list, 20)
			pushf4(list, data.ElasticityWeight) -- equivalent call inferred; original call site unknown
			pushf4(list, data.FrictionWeight) -- equivalent call inferred; original call site unknown
			pushf4(list, data.Elasticity) -- equivalent call inferred; original call site unknown
			pushf4(list, data.Friction) -- equivalent call inferred; original call site unknown
			pushf4(list, data.Density) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v39 = popf4(list) -- equivalent call inferred; original call site unknown
			local v40 = popf4(list) -- equivalent call inferred; original call site unknown
			local v41 = popf4(list) -- equivalent call inferred; original call site unknown
			local v42 = popf4(list) -- equivalent call inferred; original call site unknown
			return PhysicalProperties.new(v39, v40, v41, v42, popf4(list))
		end
	}

	function Squash.PhysicalProperties()
		return v38
	end
end

if Ray ~= nil then
	local v38 = {}

	function Squash.Ray(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
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
		v38[p] = v39
		return v39
	end
end

if RaycastParams ~= nil then
	local v38 = {}

	function Squash.RaycastResult(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
			ser = function(list, raycastResult: RaycastResult)
				tryrealloc(list, 4)
				pushf4(list, raycastResult.Distance) -- equivalent call inferred; original call site unknown
				ser(list, raycastResult.Position.Z)
				ser(list, raycastResult.Position.Y)
				ser(list, raycastResult.Position.X)
				ser(list, raycastResult.Normal.Z)
				ser(list, raycastResult.Normal.Y)
				ser(list, raycastResult.Normal.X)
				enumItem(Enum.Material).ser(list, raycastResult.Material)
			end,
			des = function(list)
				return {
					Material = enumItem(Enum.Material).des(list),
					Normal = Vector3.new(des(list), des(list), des(list)),
					Position = Vector3.new(des(list), des(list), des(list)),
					Distance = popf4(list),
					Instance = nil
				}
			end
		}
		v38[p] = v39
		return v39
	end
end

if Vector3 ~= nil then
	local v38 = {}

	function Squash.Vector3(p)
		if v38[p] then
			return v38[p]
		end

		local numberSizePushPop, v39, v40 = getNumberSizePushPop(p)
		local v41 = {}

		if numberSizePushPop then
			local v42 = numberSizePushPop * 3

			function v41.ser(p2, data)
				tryrealloc(p2, v42)
				v39(p2, data.Z)
				v39(p2, data.Y)
				v39(p2, data.X)
			end
		else
			function v41.ser(p2, data)
				v39(p2, data.Z)
				v39(p2, data.Y)
				v39(p2, data.X)
			end
		end

		function v41.des(p2)
			return (Vector3.new(v40(p2), v40(p2), v40(p2)))
		end

		v38[p] = v41
		return v41
	end
end

if Rect ~= nil then
	local v38 = {}

	function Squash.Rect(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
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
		v38[p] = v39
		return v39
	end
end

if Region3 ~= nil then
	local v38 = {}

	function Squash.Region3(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
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
				local vector2 = Vector3.new(des(p2), des(p2), des(p2))
				local vector3 = Vector3.new(des(p2), des(p2), des(p2)) * 0.5
				return Region3.new(vector2 - vector3, vector2 + vector3)
			end
		}
		v38[p] = v39
		return v39
	end
end

if Region3int16 ~= nil then
	local v38 = {
		ser = function(list, p)
			tryrealloc(list, 12)
			local max = p.Max
			pushi2(list, max.Z) -- equivalent call inferred; original call site unknown
			pushi2(list, max.Y) -- equivalent call inferred; original call site unknown
			pushi2(list, max.X) -- equivalent call inferred; original call site unknown
			local min = p.Min
			pushi2(list, min.Z) -- equivalent call inferred; original call site unknown
			pushi2(list, min.Y) -- equivalent call inferred; original call site unknown
			pushi2(list, min.X) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v39 = popi2(list) -- equivalent call inferred; original call site unknown
			local v40 = popi2(list) -- equivalent call inferred; original call site unknown
			local vector3int = Vector3int16.new(v39, v40, popi2(list))
			local v41 = popi2(list) -- equivalent call inferred; original call site unknown
			local v42 = popi2(list) -- equivalent call inferred; original call site unknown
			local vector3int2 = Vector3int16.new(v41, v42, popi2(list))
			return Region3int16.new(vector3int, vector3int2)
		end
	}

	function Squash.Region3int16()
		return v38
	end
end

if RotationCurveKey ~= nil then
	local v38 = {}

	function Squash.RotationCurveKey(p)
		if v38[p] then
			return v38[p]
		end

		local ser = cFrame(p).ser
		local des = cFrame(p).des
		local v39 = {
			ser = function(list, data)
				enumItem(Enum.KeyInterpolationMode).ser(list, data.Interpolation)
				ser(list, data.Value)
				tryrealloc(list, 4)
				pushf4(list, data.Time) -- equivalent call inferred; original call site unknown
			end,
			des = function(list)
				return RotationCurveKey.new(popf4(list), des(list), (enumItem(Enum.KeyInterpolationMode).des(list)))
			end
		}
		v38[p] = v39
		return v39
	end
end

if TweenInfo ~= nil then
	local v38 = {
		ser = function(list, data)
			tryrealloc(list, 9)
			pushf4(list, data.DelayTime) -- equivalent call inferred; original call site unknown
			pushf4(list, data.Time) -- equivalent call inferred; original call site unknown
			pushu1(list, data.Reverses and 1 or 0) -- equivalent call inferred; original call site unknown
			pushvlqrealloc(list, data.RepeatCount)
			enumItem(Enum.EasingDirection).ser(list, data.EasingDirection)
			enumItem(Enum.EasingStyle).ser(list, data.EasingStyle)
		end,
		des = function(list)
			local des = enumItem(Enum.EasingStyle).des(list)
			local des2 = enumItem(Enum.EasingDirection).des(list)
			local v39 = popvlq(list)
			local v40 = popu1(list) -- equivalent call inferred; original call site unknown
			local v41 = v40 % 2 >= 1
			local _ = v40 % 4 >= 2
			local _ = v40 % 8 >= 4
			local _ = v40 % 16 >= 8
			local _ = v40 % 32 >= 16
			local _ = v40 % 64 >= 32
			local _ = v40 % 128 >= 64
			local _ = v40 % 256 >= 128
			local v42 = popf4(list) -- equivalent call inferred; original call site unknown
			local v43 = popf4(list) -- equivalent call inferred; original call site unknown
			return TweenInfo.new(v42, des, des2, v39, v41, v43)
		end
	}

	function Squash.TweenInfo()
		return v38
	end
end

if UDim ~= nil then
	local v38 = {}

	function Squash.UDim(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
			ser = function(p2, p3)
				ser(p2, p3.Offset)
				ser(p2, p3.Scale)
			end,
			des = function(p2)
				return UDim.new(des(p2), des(p2))
			end
		}
		v38[p] = v39
		return v39
	end
end

if UDim2 ~= nil then
	local v38 = {}

	function Squash.UDim2(p)
		if v38[p] then
			return v38[p]
		end

		local ser = p.ser
		local des = p.des
		local v39 = {
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
		v38[p] = v39
		return v39
	end
end

if Vector2int16 ~= nil then
	local v38 = {
		ser = function(list, p)
			tryrealloc(list, 4)
			pushi2(list, p.Y) -- equivalent call inferred; original call site unknown
			pushi2(list, p.X) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v39 = popi2(list) -- equivalent call inferred; original call site unknown
			return Vector2int16.new(v39, popi2(list))
		end
	}

	function Squash.Vector2int16()
		return v38
	end
end

if Vector3int16 ~= nil then
	local v38 = {
		ser = function(list, data)
			tryrealloc(list, 6)
			pushi2(list, data.Z) -- equivalent call inferred; original call site unknown
			pushi2(list, data.Y) -- equivalent call inferred; original call site unknown
			pushi2(list, data.X) -- equivalent call inferred; original call site unknown
		end,
		des = function(list)
			local v39 = popi2(list) -- equivalent call inferred; original call site unknown
			local v40 = popi2(list) -- equivalent call inferred; original call site unknown
			return Vector3int16.new(v39, v40, popi2(list))
		end
	}

	function Squash.Vector3int16()
		return v38
	end
end

return Squash