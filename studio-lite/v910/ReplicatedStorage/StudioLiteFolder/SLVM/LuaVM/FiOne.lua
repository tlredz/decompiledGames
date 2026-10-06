local fn
local stm_lua_func
game:GetService("RunService")
local sandboxedCalls = script.SandboxedCalls
debug.info(1, "s")
local advDebug = nil
local print2 = nil
local warn2 = nil

local function fn2()
	for i = 2, 1e999 do
		if not debug.info(i, "f") then
			return i - 1
		end
	end
end

local function fn3()
	for i = 2, fn2() do
		local v, v2 = debug.info(i, "nf")

		if v ~= "c_wrapped" then
			continue
		end

		warn2("Virtualized function / call found", v2)
		return false
	end

	return true
end

local fn4

fn4 = function(items)
	for _, item in items do
		if type(item) == "function" then
			local v = debug.info(item, "n")

			if item == fn2 or item == fn3 or v == "lua_bc_to_state" or v == "lua_wrap_state" or v == "run_lua_func" then
				return true
			end
		end

		if type(item) == "table" then
			return fn4(item)
		end
	end

	return false
end

local v = {
	GetDataStore = true,
	GetGlobalDataStore = true,
	GetOrderedDataStore = true,
	GetRequestBudgetForRequestType = true,
	ListDataStoresAsync = true
}
local v2 = {
	GetHashMap = true,
	GetQueue = true,
	GetSortedMap = true
}
local v3 = {
	CreateWebStreamClient = true,
	GetAsync = true,
	PostAsync = true,
	RequestAsync = true,
	GetSecret = true
}
local v4 = {
	GetLatestAssetVersionAsync = true,
	GetUserSets = true,
	LoadAsset = true,
	LoadAssetVersion = true
}
local v5 = {
	AwardBadge = true
}
local v6 = {
	BanAsync = true
}
local v7 = {
	require = true,
	setfenv = true,
	getfenv = true
}

local function fn5(max_stack, data)
	local v8 = table.create(max_stack)
	local v9 = newproxy(true)
	local metatable = getmetatable(v9)

	function metatable.__newindex(_, p, value)
		warn2("Value added to STACK", p, value, v8)

		if typeof(value) == "Instance" then
			if value.ClassName == "DataStoreService" then
				error(
					"DataStoreService is not available in Play mode. But it could work in your published game. Or try Studio Lite's DataStoreScript.",
					3
				)
			elseif value.ClassName == "OpenCloudService" then
				error("OpenCloudService is deprecated. (But it could work in your published game.)", 3)
			elseif value.ClassName == "MemoryStoreService" then
				error("MemoryStoreService is not available in Play mode. But it could work in your published game.", 3)
			elseif value.ClassName == "MessagingService" then
				error("MessagingService is not available in Play mode. But it could work in your published game.", 3)
			end
		end

		if type(value) == "function" then
			local v10 = debug.info(value, "n")

			if v7[v10] then
				error(
					"Keyword '" .. v10 .. "' not available in Play mode. (But it could work in your published game.)",
					3
				)
			end

			if v[v10] then
				error(
					"DataStoreService is not available in Play mode. (But it could work in your published game.) Or try Studio Lite's DataStoreScript.",
					3
				)
			end

			if v2[v10] then
				error(
					"MemoryStoreService is not available in Play mode. (But it could work in your published game.) Or try Studio Lite's DataStoreScript.",
					3
				)
			end

			if v3[v10] then
				error(
					"Some HttpService function not available in Play mode. (But it could work in your published game.)",
					3
				)
			end

			if v4[v10] then
				error(
					"InsertService is not available in Play mode. (But it could work in your published game.) Or try the Toolbox or blue-plus.",
					3
				)
			end

			if v5[v10] then
				error("Awarding Badges is not available in Play mode. (But it could work in your published game.)", 3)
			end

			if v6[v10] then
				error("BanAsync is not available in Play mode. (But it could work in your published game.)", 3)
			end

			local v11 = debug.info(value, "n")

			if value == fn2 or value == fn3 or v11 == "lua_bc_to_state" or v11 == "lua_wrap_state" or v11 == "run_lua_func" then
				warn2("Stack fault:\n\tValStack: '" .. type(value) == "function" and table.concat(
					{ debug.info(value, "slnaf") } or value,
					" "
				) .. "'\n\tCaller: '" .. table.concat({ debug.info(2, "slnaf") }, " ") .. "'")
				error("cannot add internal functions to stack", fn2())
			end

			local v12 = data.SLVMReplaced[value]

			if v12 then
				print2("Hook catched by stack", v12)
				value = v12
			end
		end

		local v10 = data.SLVMBlock[value]

		if v10 then
			print2("Block catched by stack", v10)
			error(v10, fn2())
		end

		local sLVMType = data.SLVMTypes[type(value)]

		if sLVMType then
			print2("Type-blacklist catched by stack", sLVMType)
			error(sLVMType, fn2())
		end

		v8[p] = value
	end

	function metatable.__index(_, p)
		return v8[p]
	end

	metatable.__metatable = "The metatable is locked"
	return v9, v8, metatable
end

local v8 = {
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
local v9 = {
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
local v10 = {
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
		total += 256 ^ math.abs(i - p) * string.byte(value, i, i)
	end

	return total
end

local function rd_flt_basic(p, p2, p3, p4)
	local v11 = (-1) ^ bit32.rshift(p4, 7)
	local v12 = bit32.rshift(p3, 7) + bit32.lshift(bit32.band(p4, 127), 1)
	local v13 = p + bit32.lshift(p2, 8) + bit32.lshift(bit32.band(p3, 127), 16)
	local v14 = 1

	if v12 == 0 then
		if v13 == 0 then
			return v11 * 0
		end

		v12 = 1
		v14 = 0
		return v11 * 2 ^ (v12 - 127) * (v14 / 8388608 + 1)
	else
		if v12 ~= 127 then
			return v11 * 2 ^ (v12 - 127) * (v14 / 8388608 + 1)
		end

		if v13 == 0 then
			return v11 * 1e999
		end

		return v11 * (0 / 0)
	end
end

local function rd_dbl_basic(p, p2, p3, p4, p5, p6, p7, p8)
	local v11 = (-1) ^ bit32.rshift(p8, 7)
	local v12 = bit32.lshift(bit32.band(p8, 127), 4) + bit32.rshift(p7, 4)
	local v13 = 1
	local v14 = bit32.band(p7, 15) * 281474976710656 + p6 * 1099511627776 + p5 * 4294967296 + p4 * 16777216 + p3 * 65536 + p2 * 256 + p

	if v12 == 0 then
		if v14 == 0 then
			return v11 * 0
		end

		v12 = 1
		v13 = 0
		return v11 * 2 ^ (v12 - 1023) * (v13 + v14 / 4503599627370496)
	else
		if v12 ~= 2047 then
			return v11 * 2 ^ (v12 - 1023) * (v13 + v14 / 4503599627370496)
		end

		if v14 == 0 then
			return v11 * 1e999
		end

		return v11 * (0 / 0)
	end
end

local function rd_int_le(value, p, p2)
	local total = 0

	for i = p, p2 - 1 do
		total += 256 ^ math.abs(i - p) * string.byte(value, i, i)
	end

	return total
end

local function rd_int_be(value, p, p2)
	local v11 = p2 - 1
	local total = 0

	for i = v11, p, -1 do
		total += 256 ^ math.abs(i - v11) * string.byte(value, i, i)
	end

	return total
end

local function rd_flt_le(value, p)
	return (rd_flt_basic(string.byte(value, p, p + 3)))
end

local function rd_flt_be(value, p)
	local v11, v12, v13, v14 = string.byte(value, p, p + 3)
	return (rd_flt_basic(v14, v13, v12, v11))
end

local function rd_dbl_le(value, p)
	return (rd_dbl_basic(string.byte(value, p, p + 7)))
end

local function rd_dbl_be(value, p)
	local v11, v12, v13, v14, v15, v16, v17, v18 = string.byte(value, p, p + 7)
	return (rd_dbl_basic(v18, v17, v16, v15, v14, v13, v12, v11))
end

local v11 = {
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
	local v12 = string.byte(state.source, index, index)
	state.index = index + 1
	return v12
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stm_string(state, s_szt)
	local v12 = state.index + s_szt
	local v13 = string.sub(state.source, state.index, v12 - 1)
	state.index = v12
	return v13
end

local function stm_lstring(object)
	local s_szt = object:s_szt()
	local v12

	if s_szt ~= 0 then
		return (string.sub(stm_string(object, s_szt), 1, -2))
	end

	return v12
end

local function cst_int_rdr(p, callback)
	return function(state)
		local v12 = state.index + p
		local v13 = callback(state.source, state.index, v12)
		state.index = v12
		return v13
	end
end

local function cst_flt_rdr(p, callback)
	return function(state)
		local v12 = callback(state.source, state.index)
		state.index += p
		return v12
	end
end

local function stm_inst_list(object)
	local s_int = object:s_int()
	local result = table.create(s_int)

	for i = 1, s_int do
		local s_ins = object:s_ins()
		local v12 = bit32.band(s_ins, 63)
		local v13 = v9[v12]
		local v14 = v10[v12]
		local v15 = {
			value = s_ins,
			op = v8[v12],
			A = bit32.band(bit32.rshift(s_ins, 6), 255)
		}

		if v13 == "ABC" then
			v15.B = bit32.band(bit32.rshift(s_ins, 23), 511)
			v15.C = bit32.band(bit32.rshift(s_ins, 14), 511)
			v15.is_KB = v14.b == "OpArgK" and v15.B > 255
			v15.is_KC = v14.c == "OpArgK" and v15.C > 255
		elseif v13 == "ABx" then
			v15.Bx = bit32.band(bit32.rshift(s_ins, 14), 262143)
			v15.is_K = v14.b == "OpArgK"
		elseif v13 == "AsBx" then
			v15.sBx = bit32.band(bit32.rshift(s_ins, 14), 262143) - 131071
		end

		result[i] = v15
	end

	return result
end

local function stm_const_list(object)
	local s_int = object:s_int()
	local result = table.create(s_int)

	for i = 1, s_int do
		local index = object.index
		local v12 = string.byte(object.source, index, index)
		object.index = index + 1
		local v13 = nil

		if v12 == 1 then
			v13 = stm_byte(object) ~= 0
		elseif v12 == 3 then
			v13 = object:s_num()
		elseif v12 == 4 then
			local s_szt = object:s_szt()

			if s_szt ~= 0 then
				v13 = string.sub(stm_string(object, s_szt), 1, -2)
			end
		end

		result[i] = v13
	end

	return result
end

local function stm_sub_list(object, p)
	local s_int = object:s_int()
	local result = table.create(s_int)

	for i = 1, s_int do
		result[i] = stm_lua_func(object, p)
	end

	return result
end

local function stm_line_list(object)
	local s_int = object:s_int()
	local result = table.create(s_int)

	for i = 1, s_int do
		result[i] = object:s_int()
	end

	return result
end

local function stm_loc_list(object)
	local s_int = object:s_int()
	local result = table.create(s_int)

	for i = 1, s_int do
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

local function stm_upval_list(object)
	local s_int = object:s_int()
	local result = table.create(s_int)

	for i = 1, s_int do
		local s_szt = object:s_szt()
		local v12

		if s_szt ~= 0 then
			v12 = string.sub(stm_string(object, s_szt), 1, -2)
		end

		result[i] = v12
	end

	return result
end

stm_lua_func = function(object, p)
	local s_szt = object:s_szt()
	local v13

	if s_szt ~= 0 then
		v13 = string.sub(stm_string(object, s_szt), 1, -2)
	end

	local source = v13 or p
	object:s_int()
	object:s_int()
	local v12 = {
		source = source,
		num_upval = stm_byte(object),
		num_param = stm_byte(object)
	}
	local index = object.index
	string.byte(object.source, index, index)
	object.index = index + 1
	v12.max_stack = stm_byte(object)
	v12.code = stm_inst_list(object)
	v12.const = stm_const_list(object)
	v12.subs = stm_sub_list(object, source)
	v12.lines = stm_line_list(object)
	stm_loc_list(object)
	stm_upval_list(object)

	for _, v15 in ipairs(v12.code) do
		if v15.is_K then
			v15.const = v12.const[v15.Bx + 1]
		else
			if v15.is_KB then
				v15.const_B = v12.const[v15.B - 255]
			end

			if v15.is_KC then
				v15.const_C = v12.const[v15.C - 255]
			end
		end
	end

	return v12
end

local function fn6(source)
	local v12 = {
		index = 1,
		source = source
	}
	assert(stm_string(v12, 4) == "\27Lua", "invalid Lua signature")
	assert(stm_byte(v12) == 81, "invalid Lua version")
	assert(stm_byte(v12) == 0, "invalid Lua format")
	local v13 = stm_byte(v12) ~= 0
	local v14 = stm_byte(v12) -- equivalent call inferred; original call site unknown
	local v15 = stm_byte(v12) -- equivalent call inferred; original call site unknown
	local v16 = stm_byte(v12) -- equivalent call inferred; original call site unknown
	local v17 = stm_byte(v12) -- equivalent call inferred; original call site unknown
	local v18 = stm_byte(v12) ~= 0
	local v19 = v13 and rd_int_le or rd_int_be

	function v12:s_int()
		local v20 = self.index + v14
		local v21 = v19(self.source, self.index, v20)
		self.index = v20
		return v21
	end

	function v12:s_szt()
		local v20 = self.index + v15
		local v21 = v19(self.source, self.index, v20)
		self.index = v20
		return v21
	end

	function v12:s_ins()
		local v20 = self.index + v16
		local v21 = v19(self.source, self.index, v20)
		self.index = v20
		return v21
	end

	if v18 then
		function v12:s_num()
			local v20 = self.index + v17
			local v21 = v19(self.source, self.index, v20)
			self.index = v20
			return v21
		end
	elseif v11[v17] then
		local v20 = v11[v17][v13 and "little" or "big"]

		function v12:s_num()
			local v21 = v20(self.source, self.index)
			self.index += v17
			return v21
		end
	else
		error("unsupported float size")
	end

	return stm_lua_func(v12, "@virtual")
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
	local v12 = p[p2]

	if not v12 then
		v12 = {
			index = p2,
			store = store
		}
		p[p2] = v12
	end

	return v12
end

local function on_lua_error(data, p)
	local source = data.source
	local line = data.lines[data.pc - 1]
	local v12 = p and tostring(p) or "Error occurred, no output from SLVM."
	print2(source, line, v12)
	error(string.format("%s:%i: %s", source, line or -1, v12), 3)
end

function run_lua_func(p, data, state, p2, p3)
	local code = state.code
	local subs = state.subs
	local vararg = state.vararg
	local v12 = -1
	local v13 = {}
	local memory = state.memory
	local raw_memory = state.raw_memory
	local pc = state.pc
	local count = 0
	local count2 = 0
	local fn7

	fn7 = function(value, ...)
		assert(value ~= fn7, "function must not be called by a virtualized state")

		if type(value) ~= "function" and type(value) ~= "table" and type(value) ~= "userdata" then
			return false, (`attempt to call a {type(value)} value`)
		end

		print2("CALL", value, { ... })

		if data.AdditionalSettings.SandboxCalls then
			sandboxedCalls.Value += 1

			if sandboxedCalls.Value >= 200 then
				warn2("Throttling thread calls! Global Limit reached:", sandboxedCalls.Value)
				task.wait()
				sandboxedCalls.Value = 0
			end

			local success = nil
			local v15 = nil
			local result = nil
			local v16 = nil
			local thread = task.spawn(function(...)
				v16 = debug.info(1, "f")

				if debug.info(2, "f") then
					warn2("illegal call detected #1")
					error("function must not be called by a virtualized state", fn2())
				else
					success, result = pcall(function(...)
						if debug.info(2, "f") ~= pcall or debug.info(3, "f") ~= v16 then
							warn2("illegal call detected #2")
							error("function must not be called by a virtualized state", fn2())
						end

						v15 = table.pack(value(...))
					end, ...)
				end
			end, ...)

			while type(success) ~= "boolean" and type(result) ~= "string" and type(v15) ~= "table" and coroutine.status(thread) ~= "dead" do
				task.wait()
			end

			print2("RESP", success, v15, result)
			return success, success and v15 or result
		else
			if not data.AdditionalSettings.ThrottleRecursiveCalls or value ~= p then
				return true, table.pack(value(...))
			end

			if count2 >= 15 then
				count2 = 0
				task.wait()
			else
				count2 += 1
			end

			return true, table.pack(value(...))
		end
	end

	while true do
		local v14 = code[pc]
		local op = v14.op
		pc += 1

		if op < 18 then
			if op < 8 then
				if op < 3 then
					if op < 1 then
						local v15 = data.SLVMTypes["nil"]

						if v15 then
							error(v15)
						end

						for i = v14.A, v14.B do
							memory[i] = nil
						end
					elseif op > 1 then
						local v15 = p3[v14.B]
						memory[v14.A] = v15.store[v15.index]
					else
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local v15

						if v14.is_KC then
							v15 = v14.const_C
						else
							v15 = memory[v14.C]
						end

						memory[v14.A] = const_B + v15
					end
				elseif op > 3 then
					if op < 6 then
						if op > 4 then
							local A = v14.A
							local B = v14.B
							local const_C

							if v14.is_KC then
								const_C = v14.const_C
							else
								const_C = memory[v14.C]
							end

							memory[A + 1] = memory[B]
							memory[A] = memory[B][const_C]
						else
							local A = v14.A

							if data.SLVMBlock[v14.const] then
								error(data.SLVMBlock[v14.const])
							end

							if data.SLVMBlock[A] then
								error(data.SLVMBlock[A])
							end

							if data.SLVMReplaced[A] then
								memory[v14.A] = data.SLVMReplaced[A]
								break
							end

							local sLVMType = data.SLVMTypes[type(p2[v14.const])]

							if sLVMType then
								error(sLVMType)
							end

							memory[A] = p2[v14.const]
						end
					elseif op > 6 then
						local const_C

						if v14.is_KC then
							const_C = v14.const_C
						else
							const_C = memory[v14.C]
						end

						local instanceHook = typeof(memory[v14.B]) == "Instance" and data.SLVMReadHook.InstanceHook or data.SLVMReadHook[memory[v14.B]]

						if instanceHook then
							warn2((`GETTABLE Hook detected for '{memory[v14.B]}'! Calling with index '{const_C}'...`))
							memory[v14.A] = instanceHook(memory[v14.B], const_C, memory[v14.B][const_C])
						elseif data.SLVMBlock[p2[const_C]] then
							error(data.SLVMBlock[p2[const_C]])
						elseif data.SLVMBlock[memory[v14.B]] then
							error(data.SLVMBlock[memory[v14.B]])
						else
							warn2("GETTABLE Adding value:", const_C, memory[v14.B], memory[v14.B][const_C])
							memory[v14.A] = memory[v14.B][const_C]
						end
					else
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local v15

						if v14.is_KC then
							v15 = v14.const_C
						else
							v15 = memory[v14.C]
						end

						memory[v14.A] = const_B - v15
					end
				else
					memory[v14.A] = memory[v14.B]
				end
			elseif op > 8 then
				if op < 13 then
					if op < 10 then
						p2[v14.const] = memory[v14.A]
					elseif op > 10 then
						if op < 12 then
							local A = v14.A
							local B = v14.B
							local C = v14.C
							local v15

							if B == 0 then
								v15 = v12 - A
							else
								v15 = B - 1
							end

							print2("CALL", A, v15, raw_memory, memory[A])
							local v16, v17 = fn7(memory[A], table.unpack(raw_memory, A + 1, A + v15))

							if not v16 then
								print2("Call not successful")
								error(v17, fn2())
							end

							local n = v17.n or #v17

							if C == 0 then
								print2("CALL `C`", A, n, v17)
								v12 = A + n - 1
							else
								n = C - 1
							end

							if fn4(v17) then
								error("cannot return internal functions", fn2())
							end

							table.move(v17, 1, n, A, raw_memory)
						else
							local v15 = p3[v14.B]
							v15.store[v15.index] = memory[v14.A]
						end
					else
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local v15

						if v14.is_KC then
							v15 = v14.const_C
						else
							v15 = memory[v14.C]
						end

						memory[v14.A] = const_B * v15
					end
				elseif op > 13 then
					if op < 16 then
						if op > 14 then
							local A = v14.A
							local B = v14.B
							local v15

							if B == 0 then
								v15 = v12 - A
							else
								v15 = B - 1
							end

							close_lua_upvalues(v13, 0)
							local v16, v17 = fn7(memory[A], table.unpack(raw_memory, A + 1, A + v15))

							if not v16 then
								print2("Tailcall not successful")
								error(v17)
							end

							return unpack(v17)
						else
							local const_B

							if v14.is_KB then
								const_B = v14.const_B
							else
								const_B = memory[v14.B]
							end

							local const_C

							if v14.is_KC then
								const_C = v14.const_C
							else
								const_C = memory[v14.C]
							end

							local instanceHook = typeof(memory[v14.A]) == "Instance" and data.SLVMWriteHook.InstanceHook or data.SLVMWriteHook[memory[v14.A]]

							if instanceHook then
								warn2((`SETTABLE Hook detected for '{memory[v14.A]}'! Calling with index '{const_B}'...`))
								memory[v14.A][const_B] = instanceHook(memory[v14.A], const_B, const_C)
							else
								memory[v14.A][const_B] = const_C
							end
						end
					elseif op > 16 then
						local table2 = data.SLVMTypes.table

						if table2 then
							error(table2)
						end

						memory[v14.A] = {}
					else
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local v15

						if v14.is_KC then
							v15 = v14.const_C
						else
							v15 = memory[v14.C]
						end

						memory[v14.A] = const_B / v15
					end
				else
					local sLVMType = data.SLVMTypes[type(v14.const)]

					if sLVMType then
						error(sLVMType)
					end

					print2("LOADK", v14.A, v14.const)
					memory[v14.A] = v14.const
				end
			else
				local A = v14.A
				local v15 = memory[A + 2]
				local v16 = memory[A] + v15
				local v17 = memory[A + 1]
				local v18

				if v15 == math.abs(v15) then
					v18 = v16 <= v17
				else
					v18 = v17 <= v16
				end

				if v18 then
					memory[A] = v16
					memory[A + 3] = v16
					pc += v14.sBx
				end

				count += 1

				if data.AdditionalSettings.ThrottleLoopInstructions and count >= 3 then
					task.wait()
					count = 0
				end
			end
		elseif op > 18 then
			if op < 28 then
				if op < 23 then
					if op < 20 then
						memory[v14.A] = #memory[v14.B]
					elseif op > 20 then
						if op < 22 then
							local A = v14.A
							local B = v14.B
							local v15

							if B == 0 then
								v15 = v12 - A + 1
							else
								v15 = B - 1
							end

							close_lua_upvalues(v13, 0)
							return table.unpack(raw_memory, A, A + v15 - 1)
						else
							local B = v14.B
							local v15 = memory[B]

							for i = B + 1, v14.C do
								v15 ..= memory[i]
							end

							memory[v14.A] = v15
						end
					else
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local v15

						if v14.is_KC then
							v15 = v14.const_C
						else
							v15 = memory[v14.C]
						end

						memory[v14.A] = const_B % v15
					end
				elseif op > 23 then
					if op < 26 then
						if op > 24 then
							close_lua_upvalues(v13, v14.A)
						else
							local const_B

							if v14.is_KB then
								const_B = v14.const_B
							else
								const_B = memory[v14.B]
							end

							local v15

							if v14.is_KC then
								v15 = v14.const_C
							else
								v15 = memory[v14.C]
							end

							if const_B == v15 == (v14.A ~= 0) then
								pc += code[pc].sBx
							end

							pc += 1
						end
					elseif op > 26 then
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local const_C

						if v14.is_KC then
							const_C = v14.const_C
						else
							const_C = memory[v14.C]
						end

						print2("LT", const_B, const_C)

						if const_B < const_C == (v14.A ~= 0) then
							pc += code[pc].sBx
						end

						pc += 1
					else
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local v15

						if v14.is_KC then
							v15 = v14.const_C
						else
							v15 = memory[v14.C]
						end

						memory[v14.A] = const_B ^ v15
					end
				else
					local boolean = data.SLVMTypes.boolean

					if boolean then
						error(boolean)
					end

					memory[v14.A] = v14.B ~= 0

					if v14.C ~= 0 then
						pc += 1
					end
				end
			elseif op > 28 then
				if op < 33 then
					if op < 30 then
						local const_B

						if v14.is_KB then
							const_B = v14.const_B
						else
							const_B = memory[v14.B]
						end

						local const_C

						if v14.is_KC then
							const_C = v14.const_C
						else
							const_C = memory[v14.C]
						end

						print2("LE", const_B, const_C)

						if const_B <= const_C == (v14.A ~= 0) then
							pc += code[pc].sBx
						end

						pc += 1
					elseif op > 30 then
						if op < 32 then
							local sub = subs[v14.Bx + 1]
							assert(sub, "invalid subroutine closure operation")
							local num_upval = sub.num_upval
							local v15

							if num_upval ~= 0 then
								v15 = {}

								for i = 1, num_upval do
									local v16 = code[pc + i - 1]

									if v16.op == v8[0] then
										local v17 = i - 1
										local B = v16.B
										local v18 = v13[B]

										if not v18 then
											v18 = {
												index = B,
												store = memory
											}
											v13[B] = v18
										end

										v15[v17] = v18
									elseif v16.op == v8[4] then
										v15[i - 1] = p3[v16.B]
									end
								end

								pc += num_upval
							end

							local v16 = fn(sub, data, p2, v15)
							memory[v14.A] = v16
						else
							local A = v14.A
							local B = v14.B

							if not memory[B] ~= (v14.C ~= 0) then
								memory[A] = memory[B]
								pc += code[pc].sBx
							end

							pc += 1
						end
					else
						memory[v14.A] = -memory[v14.B]
					end
				elseif op > 33 then
					if op < 36 then
						if op > 34 then
							local A = v14.A
							local B = v14.B

							if B == 0 then
								B = vararg.len
								v12 = A + B - 1
							end

							table.move(vararg.list, 1, B, A, raw_memory)
						else
							local A = v14.A
							local v15 = assert(tonumber(memory[A]), "`for` initial value must be a number")
							local v16 = assert(tonumber(memory[A + 1]), "`for` limit must be a number")
							local v17 = assert(tonumber(memory[A + 2]), "`for` step must be a number")
							memory[A] = v15 - v17
							memory[A + 1] = v16
							memory[A + 2] = v17
							pc += v14.sBx
						end
					elseif op > 36 then
						local A = v14.A
						local C = v14.C
						local B = v14.B
						local v15 = memory[A]

						if B == 0 then
							B = v12 - A
						end

						if C == 0 then
							C = v14[pc].value
							pc += 1
						end

						local v16 = (C - 1) * 50
						table.move(raw_memory, A + 1, A + B, v16 + 1, v15)
					else
						memory[v14.A] = not memory[v14.B]
					end
				else
					if not memory[v14.A] ~= (v14.C ~= 0) then
						pc += code[pc].sBx
					end

					pc += 1
				end
			else
				local A = v14.A
				local v15 = A + 3
				local v16 = { table.unpack(select(2, fn7(memory[A], memory[A + 1], memory[A + 2]))) }
				table.move(v16, 1, v14.C, v15, raw_memory)

				if memory[v15] ~= nil then
					memory[A + 2] = memory[v15]
					pc += code[pc].sBx
				end

				pc += 1
				count += 1

				if data.AdditionalSettings.ThrottleLoopInstructions and count >= 3 then
					task.wait()
					count = 0
				end
			end
		else
			count += 1

			if data.AdditionalSettings.ThrottleLoopInstructions and count >= 3 then
				task.wait()
				count = 0
			end

			pc += v14.sBx
		end

		state.pc = pc
	end
end

fn = function(data, p, p2, p3)
	if p3 then
		local function c_wrapped(...)
			local v12 = table.pack(...)
			local vararg = {
				len = 0,
				list = {}
			}
			local memory, raw_memory, _ = fn5(data.max_stack, p)
			table.move(v12, 1, data.num_param, 0, raw_memory)

			if data.num_param < v12.n then
				local v16 = data.num_param + 1
				local len = v12.n - data.num_param
				vararg.len = len
				table.move(v12, v16, v16 + len - 1, 1, vararg.list)
			end

			local v16 = {
				vararg = vararg,
				memory = memory,
				raw_memory = raw_memory,
				code = data.code,
				subs = data.subs,
				pc = 1
			}
			local v17 = table.pack(pcall(run_lua_func, debug.info(1, "f"), p, v16, p2, p3))

			if v17[1] then
				return table.unpack(v17, 2, v17.n)
			end

			on_lua_error({
				pc = v16.pc,
				source = data.source,
				lines = data.lines
			}, v17[2])
		end

		return c_wrapped
	end

	local function n_wrapped(...)
		local v12 = table.pack(...)
		local vararg = {
			len = 0,
			list = {}
		}
		local memory, raw_memory, _ = fn5(data.max_stack, p)
		table.move(v12, 1, data.num_param, 0, raw_memory)

		if data.num_param < v12.n then
			local v16 = data.num_param + 1
			local len = v12.n - data.num_param
			vararg.len = len
			table.move(v12, v16, v16 + len - 1, 1, vararg.list)
		end

		local v16 = {
			vararg = vararg,
			memory = memory,
			raw_memory = raw_memory,
			code = data.code,
			subs = data.subs,
			pc = 1
		}
		local v17 = table.pack(pcall(run_lua_func, debug.info(1, "f"), p, v16, p2, p3))

		if v17[1] then
			return table.unpack(v17, 2, v17.n)
		end

		on_lua_error({
			pc = v16.pc,
			source = data.source,
			lines = data.lines
		}, v17[2])
	end

	return n_wrapped
end

return function(source, p2, p3)
	advDebug = p2.AdvDebug
	print2 = advDebug and print or function() end
	warn2 = advDebug and warn or function() end
	warn2("SLVM DEBUG is enabled! VM Logs will be emitted. Please toggle it off in the SLVM module if you would not like it enabled.")
	return fn(fn6(source), p2, p3)
end