local bit322 = bit32
local unpack2 = table.unpack or unpack
local wrap_lua_func
local stm_lua_func
local v = {
	[22] = 18,
	[31] = 8,
	[33] = 28,
	[0] = 3,
	[1] = 13,
	[2] = 23,
	[26] = 33,
	[12] = 1,
	[13] = 6,
	[14] = 10,
	[15] = 16,
	[16] = 20,
	[17] = 26,
	[18] = 30,
	[19] = 36,
	[3] = 0,
	[4] = 2,
	[5] = 4,
	[6] = 7,
	[7] = 9,
	[8] = 12,
	[9] = 14,
	[10] = 17,
	[20] = 19,
	[21] = 22,
	[23] = 24,
	[24] = 27,
	[25] = 29,
	[27] = 32,
	[32] = 34,
	[34] = 37,
	[11] = 5,
	[28] = 11,
	[29] = 15,
	[30] = 21,
	[35] = 25,
	[36] = 31,
	[37] = 35
}
local v2 = {
	[0] = "ABC",
	"ABx",
	"ABC",
	"ABC",
	"ABC",
	"ABx",
	"ABC",
	"ABx",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"AsBx",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"ABC",
	"AsBx",
	"AsBx",
	"ABC",
	"ABC",
	"ABC",
	"ABx",
	"ABC"
}
local v3 = {
	[0] = {
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgK",
		c = "OpArgN"
	},
	{
		b = "OpArgU",
		c = "OpArgU"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgU",
		c = "OpArgN"
	},
	{
		b = "OpArgK",
		c = "OpArgN"
	},
	{
		b = "OpArgR",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgN"
	},
	{
		b = "OpArgU",
		c = "OpArgN"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgU",
		c = "OpArgU"
	},
	{
		b = "OpArgR",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgR",
		c = "OpArgR"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgK",
		c = "OpArgK"
	},
	{
		b = "OpArgR",
		c = "OpArgU"
	},
	{
		b = "OpArgR",
		c = "OpArgU"
	},
	{
		b = "OpArgU",
		c = "OpArgU"
	},
	{
		b = "OpArgU",
		c = "OpArgU"
	},
	{
		b = "OpArgU",
		c = "OpArgN"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgR",
		c = "OpArgN"
	},
	{
		b = "OpArgN",
		c = "OpArgU"
	},
	{
		b = "OpArgU",
		c = "OpArgU"
	},
	{
		b = "OpArgN",
		c = "OpArgN"
	},
	{
		b = "OpArgU",
		c = "OpArgN"
	},
	{
		b = "OpArgU",
		c = "OpArgN"
	}
}

local function rd_int_basic(value, p, p2, p3)
	local total = 0

	for i = p, p2, p3 do
		total += string.byte(value, i, i) * 256 ^ (i - p)
	end

	return total
end

local function rd_flt_basic(p, p2, p3, p4)
	local v4 = (-1) ^ bit322.rshift(p4, 7)
	local rshift = bit322.rshift(p3, 7)
	local band = bit322.band(p4, 127)
	local v5 = rshift + bit322.lshift(band, 1)
	local v6 = p + bit322.lshift(p2, 8)
	local band2 = bit322.band(p3, 127)
	local v7 = v6 + bit322.lshift(band2, 16)
	local v8 = 1

	if v5 == 0 then
		if v7 == 0 then
			return v4 * 0
		end

		v5 = 1
		v8 = 0
		return v4 * 2 ^ (v5 - 127) * (v8 / 8388608 + 1)
	else
		if v5 ~= 127 then
			return v4 * 2 ^ (v5 - 127) * (v8 / 8388608 + 1)
		end

		if v7 == 0 then
			return v4 * 1e999
		end

		return v4 * (0 / 0)
	end
end

local function rd_dbl_basic(p, p2, p3, p4, p5, p6, p7, p8)
	local v4 = (-1) ^ bit322.rshift(p8, 7)
	local band = bit322.band(p8, 127)
	local v5 = bit322.lshift(band, 4) + bit322.rshift(p7, 4)
	local v6 = 1
	local v7 = bit322.band(p7, 15) * 281474976710656 + p6 * 1099511627776 + p5 * 4294967296 + p4 * 16777216 + p3 * 65536 + p2 * 256 + p

	if v5 == 0 then
		if v7 == 0 then
			return v4 * 0
		end

		v5 = 1
		v6 = 0
		return v4 * 2 ^ (v5 - 1023) * (v6 + v7 / 4503599627370496)
	else
		if v5 ~= 2047 then
			return v4 * 2 ^ (v5 - 1023) * (v6 + v7 / 4503599627370496)
		end

		if v7 == 0 then
			return v4 * 1e999
		end

		return v4 * (0 / 0)
	end
end

local function rd_int_le(value, p, p2)
	local total = 0

	for i = p, p2 - 1 do
		total += string.byte(value, i, i) * 256 ^ (i - p)
	end

	return total
end

local function rd_int_be(value, p, p2)
	local v4 = p2 - 1
	local total = 0

	for i = v4, p, -1 do
		total += string.byte(value, i, i) * 256 ^ (i - v4)
	end

	return total
end

local function rd_flt_le(value, p)
	return (rd_flt_basic(string.byte(value, p, p + 3)))
end

local function rd_flt_be(value, p)
	local v4, v5, v6, v7 = string.byte(value, p, p + 3)
	return (rd_flt_basic(v7, v6, v5, v4))
end

local function rd_dbl_le(value, p)
	return (rd_dbl_basic(string.byte(value, p, p + 7)))
end

local function rd_dbl_be(value, p)
	local v4, v5, v6, v7, v8, v9, v10, v11 = string.byte(value, p, p + 7)
	return (rd_dbl_basic(v11, v10, v9, v8, v7, v6, v5, v4))
end

local v4 = {
	[4] = {
		little = rd_flt_le,
		big = rd_flt_be
	},
	[8] = {
		little = rd_dbl_le,
		big = rd_dbl_be
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function stm_byte(state)
	local index = state.index
	local v5 = string.byte(state.source, index, index)
	state.index = index + 1
	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stm_string(state, s_szt)
	local v5 = state.index + s_szt
	local v6 = string.sub(state.source, state.index, v5 - 1)
	state.index = v5
	return v6
end

local function stm_lstring(object)
	local s_szt = object:s_szt()
	local v5

	if s_szt ~= 0 then
		return (string.sub(stm_string(object, s_szt), 1, -2))
	end

	return v5
end

local function cst_int_rdr(p, callback)
	return function(state)
		local v5 = state.index + p
		local v6 = callback(state.source, state.index, v5)
		state.index = v5
		return v6
	end
end

local function cst_flt_rdr(p, callback)
	return function(state)
		local v5 = callback(state.source, state.index)
		state.index += p
		return v5
	end
end

local function stm_instructions(object)
	local result = {}

	for i = 1, object:s_int() do
		local s_ins = object:s_ins()
		local band = bit322.band(s_ins, 63)
		local v5 = v2[band]
		local v6 = v3[band]
		local v7 = {
			value = s_ins,
			op = v[band],
			A = 0
		}
		local rshift = bit322.rshift(s_ins, 6)
		v7.A = bit322.band(rshift, 255)

		if v5 == "ABC" then
			local rshift2 = bit322.rshift(s_ins, 23)
			v7.B = bit322.band(rshift2, 511)
			local rshift3 = bit322.rshift(s_ins, 14)
			v7.C = bit322.band(rshift3, 511)
			v7.is_KB = v6.b == "OpArgK" and v7.B > 255
			v7.is_KC = v6.c == "OpArgK" and v7.C > 255
		elseif v5 == "ABx" then
			local rshift2 = bit322.rshift(s_ins, 14)
			v7.Bx = bit322.band(rshift2, 262143)
			v7.is_K = v6.b == "OpArgK"
		elseif v5 == "AsBx" then
			local rshift2 = bit322.rshift(s_ins, 14)
			v7.sBx = bit322.band(rshift2, 262143) - 131071
		end

		result[i] = v7
	end

	return result
end

local function stm_constants(object)
	local result = {}

	for i = 1, object:s_int() do
		local index = object.index
		local v5 = string.byte(object.source, index, index)
		object.index = index + 1
		local v6 = nil

		if v5 == 1 then
			v6 = stm_byte(object) ~= 0
		elseif v5 == 3 then
			v6 = object:s_num()
		elseif v5 == 4 then
			local s_szt = object:s_szt()

			if s_szt ~= 0 then
				v6 = string.sub(stm_string(object, s_szt), 1, -2)
			end
		end

		result[i] = v6
	end

	return result
end

local function stm_subfuncs(object, p)
	local result = {}

	for i = 1, object:s_int() do
		result[i] = stm_lua_func(object, p)
	end

	return result
end

local function stm_lineinfo(object)
	local result = {}

	for i = 1, object:s_int() do
		result[i] = object:s_int()
	end

	return result
end

local function stm_locvars(object)
	local result = {}

	for i = 1, object:s_int() do
		local s_szt = object:s_szt()
		local varname

		if s_szt ~= 0 then
			varname = string.sub(stm_string(object, s_szt), 1, -2)
		end

		result[i] = {
			varname = varname,
			startpc = object:s_int(),
			endpc = object:s_int()
		}
	end

	return result
end

local function stm_upvals(object)
	local result = {}

	for i = 1, object:s_int() do
		local s_szt = object:s_szt()
		local v5

		if s_szt ~= 0 then
			v5 = string.sub(stm_string(object, s_szt), 1, -2)
		end

		result[i] = v5
	end

	return result
end

stm_lua_func = function(object, p)
	local s_szt = object:s_szt()
	local v6

	if s_szt ~= 0 then
		v6 = string.sub(stm_string(object, s_szt), 1, -2)
	end

	local source = v6 or p
	object:s_int()
	object:s_int()
	local v5 = {
		source = source,
		numupvals = stm_byte(object),
		numparams = stm_byte(object)
	}
	local index = object.index
	string.byte(object.source, index, index)
	object.index = index + 1
	local index2 = object.index
	string.byte(object.source, index2, index2)
	object.index = index2 + 1
	v5.code = stm_instructions(object)
	v5.const = stm_constants(object)
	v5.subs = stm_subfuncs(object, source)
	v5.lines = stm_lineinfo(object)
	stm_locvars(object)
	stm_upvals(object)

	for _, v8 in ipairs(v5.code) do
		if v8.is_K then
			v8.const = v5.const[v8.Bx + 1]
		else
			if v8.is_KB then
				v8.const_B = v5.const[v8.B - 255]
			end

			if v8.is_KC then
				v8.const_C = v5.const[v8.C - 255]
			end
		end
	end

	return v5
end

local function stm_lua_bytecode(source)
	local v5 = {
		index = 1,
		source = source
	}
	assert(stm_string(v5, 4) == "\27Lua", "invalid Lua signature")
	assert(stm_byte(v5) == 81, "invalid Lua version")
	assert(stm_byte(v5) == 0, "invalid Lua format")
	local v6 = stm_byte(v5) ~= 0
	local v7 = stm_byte(v5) -- equivalent call inferred; original call site unknown
	local v8 = stm_byte(v5) -- equivalent call inferred; original call site unknown
	local v9 = stm_byte(v5) -- equivalent call inferred; original call site unknown
	local v10 = stm_byte(v5) -- equivalent call inferred; original call site unknown
	local v11 = stm_byte(v5) ~= 0
	local v12 = v6 and rd_int_le or rd_int_be

	function v5:s_int()
		local v13 = self.index + v7
		local v14 = v12(self.source, self.index, v13)
		self.index = v13
		return v14
	end

	function v5:s_szt()
		local v13 = self.index + v8
		local v14 = v12(self.source, self.index, v13)
		self.index = v13
		return v14
	end

	function v5:s_ins()
		local v13 = self.index + v9
		local v14 = v12(self.source, self.index, v13)
		self.index = v13
		return v14
	end

	if v11 then
		function v5:s_num()
			local v13 = self.index + v10
			local v14 = v12(self.source, self.index, v13)
			self.index = v13
			return v14
		end
	elseif v4[v10] then
		local v13 = v4[v10][v6 and "little" or "big"]

		function v5:s_num()
			local v14 = v13(self.source, self.index)
			self.index += v10
			return v14
		end
	else
		error("unsupported float size")
	end

	return stm_lua_func(v5, "@virtual")
end

local function close_lua_upvalues(items, p)
	for k, item in pairs(items) do
		if not (p <= item.index) then
			continue
		end

		item.value = item.store[item.index]
		item.store = item
		item.index = "value"
		items[k] = nil
	end
end

local function open_lua_upvalue(p, p2, store)
	local v5 = p[p2]

	if not v5 then
		v5 = {
			index = p2,
			store = store
		}
		p[p2] = v5
	end

	return v5
end

local function wrap_lua_variadic(...)
	return select("#", ...), { ... }
end

local function on_lua_error(data, result)
	local source = data.source
	local line = data.lines[data.pc - 1]
	local v5, v6, v7 = string.match(result or "", "^(.-):(%d+):%s+(.+)")
	error(string.format("%s:%i: [%s:%i] %s", source, line or "0", v5 or "?", v6 or "0", v7 or result or ""), 0)
end

local function exec_lua_func(state)
	local code = state.code
	local subs = state.subs
	local env = state.env
	local upvals = state.upvals
	local varargs = state.varargs
	local stack = state.stack
	local pc = state.pc
	local v5 = -1
	local v6 = {}

	while true do
		local v7 = code[pc]
		local op = v7.op
		pc += 1

		if op < 18 then
			if op < 8 then
				if op < 3 then
					if op < 1 then
						for i = v7.A, v7.B do
							stack[i] = nil
						end
					elseif op > 1 then
						local upval = upvals[v7.B]
						stack[v7.A] = upval.store[upval.index]
					else
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = const_B + v8
					end
				elseif op > 3 then
					if op < 6 then
						if op > 4 then
							local A = v7.A
							local B = v7.B
							local const_C

							if v7.is_KC then
								const_C = v7.const_C
							else
								const_C = stack[v7.C]
							end

							stack[A + 1] = stack[B]
							stack[A] = stack[B][const_C]
						else
							stack[v7.A] = env[v7.const]
						end
					elseif op > 6 then
						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = stack[v7.B][v8]
					else
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = const_B - v8
					end
				else
					stack[v7.A] = stack[v7.B]
				end
			elseif op > 8 then
				if op < 13 then
					if op < 10 then
						env[v7.const] = stack[v7.A]
					elseif op > 10 then
						if op < 12 then
							local A = v7.A
							local B = v7.B
							local C = v7.C
							local v8

							if B == 0 then
								v8 = v5 - A
							else
								v8 = B - 1
							end

							local v9, v10 = wrap_lua_variadic(stack[A](unpack2(stack, A + 1, A + v8)))

							if C == 0 then
								v5 = A + v9 - 1
							else
								v9 = C - 1
							end

							for i = 1, v9 do
								stack[A + i - 1] = v10[i]
							end
						else
							local upval = upvals[v7.B]
							upval.store[upval.index] = stack[v7.A]
						end
					else
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = const_B * v8
					end
				elseif op > 13 then
					if op < 16 then
						if op > 14 then
							local A = v7.A
							local B = v7.B
							local v8

							if B == 0 then
								v8 = v5 - A
							else
								v8 = B - 1
							end

							close_lua_upvalues(v6, 0)
							return wrap_lua_variadic(stack[A](unpack2(stack, A + 1, A + v8)))
						else
							local const_B

							if v7.is_KB then
								const_B = v7.const_B
							else
								const_B = stack[v7.B]
							end

							local v8

							if v7.is_KC then
								v8 = v7.const_C
							else
								v8 = stack[v7.C]
							end

							stack[v7.A][const_B] = v8
						end
					elseif op > 16 then
						stack[v7.A] = {}
					else
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = const_B / v8
					end
				else
					stack[v7.A] = v7.const
				end
			else
				local A = v7.A
				local v8 = stack[A + 2]
				local v9 = stack[A] + v8
				local v10 = stack[A + 1]
				local v11

				if v8 == math.abs(v8) then
					v11 = v9 <= v10
				else
					v11 = v10 <= v9
				end

				if v11 then
					stack[v7.A] = v9
					stack[v7.A + 3] = v9
					pc += v7.sBx
				end
			end
		elseif op > 18 then
			if op < 28 then
				if op < 23 then
					if op < 20 then
						stack[v7.A] = #stack[v7.B]
					elseif op > 20 then
						if op < 22 then
							local A = v7.A
							local B = v7.B
							local result = {}
							local v8

							if B == 0 then
								v8 = v5 - A + 1
							else
								v8 = B - 1
							end

							for i = 1, v8 do
								result[i] = stack[A + i - 1]
							end

							close_lua_upvalues(v6, 0)
							return v8, result
						else
							local v8 = stack[v7.B]

							for i = v7.B + 1, v7.C do
								v8 ..= stack[i]
							end

							stack[v7.A] = v8
						end
					else
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = const_B % v8
					end
				elseif op > 23 then
					if op < 26 then
						if op > 24 then
							close_lua_upvalues(v6, v7.A)
						else
							local const_B

							if v7.is_KB then
								const_B = v7.const_B
							else
								const_B = stack[v7.B]
							end

							local v8

							if v7.is_KC then
								v8 = v7.const_C
							else
								v8 = stack[v7.C]
							end

							if const_B == v8 == (v7.A ~= 0) then
								pc += code[pc].sBx
							end

							pc += 1
						end
					elseif op > 26 then
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						if const_B < v8 == (v7.A ~= 0) then
							pc += code[pc].sBx
						end

						pc += 1
					else
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						stack[v7.A] = const_B ^ v8
					end
				else
					stack[v7.A] = v7.B ~= 0

					if v7.C ~= 0 then
						pc += 1
					end
				end
			elseif op > 28 then
				if op < 33 then
					if op < 30 then
						local const_B

						if v7.is_KB then
							const_B = v7.const_B
						else
							const_B = stack[v7.B]
						end

						local v8

						if v7.is_KC then
							v8 = v7.const_C
						else
							v8 = stack[v7.C]
						end

						if const_B <= v8 == (v7.A ~= 0) then
							pc += code[pc].sBx
						end

						pc += 1
					elseif op > 30 then
						if op < 32 then
							local sub = subs[v7.Bx + 1]
							local numupvals = sub.numupvals
							local v8

							if numupvals ~= 0 then
								v8 = {}

								for i = 1, numupvals do
									local v9 = code[pc + i - 1]

									if v9.op == v[0] then
										local v10 = i - 1
										local B = v9.B
										local v11 = v6[B]

										if not v11 then
											v11 = {
												index = B,
												store = stack
											}
											v6[B] = v11
										end

										v8[v10] = v11
									elseif v9.op == v[4] then
										v8[i - 1] = upvals[v9.B]
									end
								end

								pc += numupvals
							end

							stack[v7.A] = wrap_lua_func(sub, env, v8)
						else
							local A = v7.A
							local B = v7.B

							if not stack[B] == (v7.C ~= 0) then
								pc += 1
							else
								stack[A] = stack[B]
							end
						end
					else
						stack[v7.A] = -stack[v7.B]
					end
				elseif op > 33 then
					if op < 36 then
						if op > 34 then
							local A = v7.A
							local B = v7.B

							if B == 0 then
								B = varargs.size
								v5 = A + B - 1
							end

							for i = 1, B do
								stack[A + i - 1] = varargs.list[i]
							end
						else
							local A = v7.A
							local v8 = assert(tonumber(stack[A]), "`for` initial value must be a number")
							local v9 = assert(tonumber(stack[A + 1]), "`for` limit must be a number")
							local v10 = assert(tonumber(stack[A + 2]), "`for` step must be a number")
							stack[A] = v8 - v10
							stack[A + 1] = v9
							stack[A + 2] = v10
							pc += v7.sBx
						end
					elseif op > 36 then
						local A = v7.A
						local C = v7.C
						local B = v7.B
						local v8 = stack[A]

						if B == 0 then
							B = v5 - A
						end

						if C == 0 then
							C = v7[pc].value
							pc += 1
						end

						local v9 = (C - 1) * 50

						for i = 1, B do
							v8[i + v9] = stack[A + i]
						end
					else
						stack[v7.A] = not stack[v7.B]
					end
				elseif not stack[v7.A] == (v7.C ~= 0) then
					pc += 1
				end
			else
				local A = v7.A
				local v8 = stack[A]
				local v9 = stack[A + 1]
				local v10 = stack[A + 2]
				local v11 = A + 3

				if not v10 and not v9 and type(v8) == "table" then
					local v12 = pcall(getmetatable, v8)
					local v13

					if v12 then
						v13 = not (pcall(setmetatable, v8, (getmetatable(v8))) and v12)
					else
						v13 = not v12
					end

					local metatable = v12 and getmetatable(v8)

					if not (table.isfrozen and table.isfrozen(v8)) and v13 and not metatable then
						warn("[FiOne]: The table has a metatable buts it's hidden, __iter and __call won't work in forloop.")
					end

					if type(metatable) ~= "table" or not rawget(metatable, "__call") then
						local v14 = type(metatable) == "table" and rawget(metatable, "__iter") or next
						v10 = nil
						local v15 = A + 1
						local v16 = A + 2
						stack[A] = v14
						stack[v15] = v8
						stack[v16] = v10
						v9 = v8
						v8 = v14
					end
				end

				stack[v11 + 2] = v10
				stack[v11 + 1] = v9
				stack[v11] = v8
				local v12 = { v8(v9, v10) }

				for i = 1, v7.C do
					stack[v11 + i - 1] = v12[i]
				end

				if stack[v11] == nil then
					pc += 1
				else
					stack[A + 2] = stack[v11]
				end
			end
		else
			pc += v7.sBx
		end

		state.pc = pc
	end
end

wrap_lua_func = function(data, env, upvals)
	local code = data.code
	local subs = data.subs
	local lines = data.lines
	local source = data.source
	local numparams = data.numparams

	local function exec_wrap(...)
		local v5, v6 = wrap_lua_variadic(...)
		local stack = {}
		local list = {}
		local size = 0

		for i = 1, numparams do
			stack[i - 1] = v6[i]
		end

		if numparams < v5 then
			size = v5 - numparams

			for i = 1, size do
				list[i] = v6[numparams + i]
			end
		end

		local v10 = {
			varargs = {
				list = list,
				size = size
			},
			code = code,
			subs = subs,
			lines = lines,
			source = source,
			env = env,
			upvals = upvals,
			stack = stack,
			pc = 1
		}
		local success, result, v11 = pcall(exec_lua_func, v10, ...)

		if success then
			return unpack2(v11, 1, result)
		end

		on_lua_error(v10, result)
	end

	return exec_wrap
end

return function(source, options)
	return wrap_lua_func(stm_lua_bytecode(source), options or {})
end