local class = {}
local class2 = {}
local class3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function lua_assert(p)
	if not p then
		error("assertion failed!")
	end
end

function class.make_getS(_, p)
	local v = p
	return function()
		if not v then
			return nil
		end

		local v2 = v
		v = nil
		return v2
	end
end

function class:make_getF(value)
	local v = 1
	return function()
		local v2 = value:sub(v, v + 512 - 1)
		v = math.min(#value + 1, v + 512)
		return v2
	end
end

function class:init(reader, value)
	if not reader then
		return
	end

	local v = {
		reader = reader,
		data = value or "",
		name = ""
	}

	if value and value ~= "" then
		v.n = #value
	else
		v.n = 0
	end

	v.p = 0
	return v
end

function class:fill(p)
	local reader = p.reader()
	p.data = reader

	if not reader or reader == "" then
		return "EOZ"
	end

	p.n = #reader - 1
	p.p = 1
	return (string.sub(reader, 1, 1))
end

function class:zgetc(state)
	local n = state.n
	local v = state.p + 1

	if n > 0 then
		state.n = n - 1
		state.p = v
		return (string.sub(state.data, v, v))
	else
		return self:fill(state)
	end
end

class2.RESERVED = [[
TK_AND and
TK_BREAK break
TK_DO do
TK_ELSE else
TK_ELSEIF elseif
TK_END end
TK_FALSE false
TK_FOR for
TK_FUNCTION function
TK_IF if
TK_IN in
TK_LOCAL local
TK_NIL nil
TK_NOT not
TK_OR or
TK_REPEAT repeat
TK_RETURN return
TK_THEN then
TK_TRUE true
TK_UNTIL until
TK_WHILE while
TK_CONCAT ..
TK_DOTS ...
TK_EQ ==
TK_GE >=
TK_LE <=
TK_NE ~=
TK_NAME <name>
TK_NUMBER <number>
TK_STRING <string>
TK_EOS <eof>]]
class2.MAXSRC = 80
class2.MAX_INT = 2147483645
class2.LUA_QS = "'%s'"
class2.LUA_COMPAT_LSTR = 1

function class2:init()
	local tokens = {}
	local enums = {}

	for k in string.gmatch(self.RESERVED, "[^\n]+") do
		local _, _, v3, v4 = string.find(k, "(%S+)%s+(%S+)")
		tokens[v3] = v4
		enums[v4] = v3
	end

	self.tokens = tokens
	self.enums = enums
end

function class2:chunkid(value, p)
	local v = string.sub(value, 1, 1)

	if v == "=" then
		return (string.sub(value, 2, p))
	end

	if v == "@" then
		local v2 = string.sub(value, 2)
		local v3 = p - 7
		local count = #v2
		local v4 = ""

		if v3 < count then
			v2 = string.sub(v2, count + 1 - v3)
			v4 ..= "..."
		end

		return v4 .. v2
	else
		local v2 = string.find(value, "[\n\r]")
		local v3 = v2 and v2 - 1 or #value
		local v4 = p - 16

		if v4 < v3 then
			v3 = v4
		end

		local v5 = "[string \""
		local v6

		if v3 < #value then
			v6 = v5 .. string.sub(value, 1, v3) .. "..."
		else
			v6 = v5 .. value
		end

		return v6 .. "\"]"
	end
end

function class2:token2str(_, value)
	if string.sub(value, 1, 3) == "TK_" then
		return self.tokens[value]
	end

	if string.find(value, "%c") then
		return string.format("char(%d)", string.byte(value))
	end

	return value
end

function class2:lexerror(p, p2, p3)
	local function txtToken(p4, p5)
		if p5 == "TK_NAME" or p5 == "TK_STRING" or p5 == "TK_NUMBER" then
			return p4.buff
		end

		return self:token2str(p4, p5)
	end

	local chunkid = self:chunkid(p.source, self.MAXSRC)
	local v = string.format("%s:%d: %s", chunkid, p.linenumber, p2)

	if p3 then
		v = string.format("%s near " .. self.LUA_QS, v, txtToken(p, p3))
	end

	error(v)
end

function class2:syntaxerror(p, p2)
	self:lexerror(p, p2, p.t.token)
end

function class2:currIsNewline(p)
	return p.current == "\n" or p.current == "\r"
end

function class2:inclinenumber(state)
	local current = state.current
	self:nextc(state)

	if self:currIsNewline(state) and state.current ~= current then
		self:nextc(state)
	end

	state.linenumber += 1

	if state.linenumber >= self.MAX_INT then
		self:syntaxerror(state, "chunk has too many lines")
	end
end

function class2:setinput(p, options, p2, source)
	local v = options or {}

	if not v.lookahead then
		v.lookahead = {}
	end

	if not v.t then
		v.t = {}
	end

	v.decpoint = "."
	v.L = p
	v.lookahead.token = "TK_EOS"
	v.z = p2
	v.fs = nil
	v.linenumber = 1
	v.lastline = 1
	v.source = source
	self:nextc(v)
end

function class2:check_next(p, value)
	if not string.find(value, p.current, 1, 1) then
		return false
	end

	self:save_and_next(p)
	return true
end

function class2:next(state)
	state.lastline = state.linenumber

	if state.lookahead.token == "TK_EOS" then
		state.t.token = self:llex(state, state.t)
		return
	end

	state.t.seminfo = state.lookahead.seminfo
	state.t.token = state.lookahead.token
	state.lookahead.token = "TK_EOS"
end

function class2:lookahead(p)
	p.lookahead.token = self:llex(p, p.lookahead)
end

function class2:nextc(p)
	local zgetc = class:zgetc(p.z)
	p.current = zgetc
	return zgetc
end

function class2:save(p, p2)
	p.buff ..= p2
end

function class2:save_and_next(p)
	self:save(p, p.current)
	return self:nextc(p)
end

function class2:str2d(value)
	local v = tonumber(value)

	if v then
		return v
	end

	local v2 = string.lower((string.sub(value, 1, 2))) == "0x" and tonumber(value, 16)
	return v2 or nil
end

function class2:buffreplace(p, p2, p3)
	local buff = p.buff
	local buff2 = ""

	for i = 1, #buff do
		local v2 = string.sub(buff, i, i)

		if v2 == p2 then
			v2 = p3
		end

		buff2 ..= v2
	end

	p.buff = buff2
end

function class2:trydecpoint(p, p2)
	self:buffreplace(p, p.decpoint, p.decpoint)
	local str2d = self:str2d(p.buff)
	p2.seminfo = str2d

	if not str2d then
		self:buffreplace(p, p.decpoint, ".")
		self:lexerror(p, "malformed number", "TK_NUMBER")
	end
end

function class2:read_numeral(data, p)
	repeat
		self:save_and_next(data)
	until string.find(data.current, "%D") and data.current ~= "."

	if self:check_next(data, "Ee") then
		self:check_next(data, "+-")
	end

	while string.find(data.current, "^%w$") or data.current == "_" do
		self:save_and_next(data)
	end

	self:buffreplace(data, ".", data.decpoint)
	local str2d = self:str2d(data.buff)
	p.seminfo = str2d

	if not str2d then
		self:trydecpoint(data, p)
	end
end

function class2:skip_sep(p)
	local current = p.current
	self:save_and_next(p)
	local count = 0

	while p.current == "=" do
		self:save_and_next(p)
		count += 1
	end

	return p.current == current and count or -count - 1
end

function class2:read_long_string(state, p, p2)
	local count = 0
	self:save_and_next(state)

	if self:currIsNewline(state) then
		self:inclinenumber(state)
	end

	while true do
		local current = state.current

		if current == "EOZ" then
			self:lexerror(state, p and "unfinished long string" or "unfinished long comment", "TK_EOS")
		elseif current == "[" then
			if self.LUA_COMPAT_LSTR and self:skip_sep(state) == p2 then
				self:save_and_next(state)
				count += 1

				if self.LUA_COMPAT_LSTR == 1 and p2 == 0 then
					self:lexerror(state, "nesting of [[...]] is deprecated", "[")
				end
			end
		elseif current == "]" then
			if self:skip_sep(state) == p2 then
				self:save_and_next(state)

				if self.LUA_COMPAT_LSTR and self.LUA_COMPAT_LSTR == 2 then
					local v = count - 1

					if p2 == 0 then
						local _ = v >= 0
					end
				end

				if p then
					local v = 3 + p2
					p.seminfo = string.sub(state.buff, v, -v)
				end

				break
			end
		elseif self:currIsNewline(state) then
			self:save(state, "\n")
			self:inclinenumber(state)

			if not p then
				state.buff = ""
			end
		elseif p then
			self:save_and_next(state)
		else
			self:nextc(state)
		end
	end
end

function class2:read_string(p, p2, p3)
	self:save_and_next(p)

	while p.current ~= p2 do
		local current = p.current

		if current == "EOZ" then
			self:lexerror(p, "unfinished string", "TK_EOS")
		elseif self:currIsNewline(p) then
			self:lexerror(p, "unfinished string", "TK_STRING")
		elseif current == "\\" then
			local nextc = self:nextc(p)

			if self:currIsNewline(p) then
				self:save(p, "\n")
				self:inclinenumber(p)
			elseif nextc ~= "EOZ" then
				local v = string.find("abfnrtv", nextc, 1, 1)

				if v then
					self:save(p, (string.sub("\7\8\f\n\r\t\11", v, v)))
					self:nextc(p)
				elseif string.find(nextc, "%d") then
					local v2 = 0
					local count = 0

					repeat
						v2 = 10 * v2 + p.current
						self:nextc(p)
						count += 1
					until count >= 3 or not string.find(p.current, "%d")

					if v2 > 255 then
						self:lexerror(p, "escape sequence too large", "TK_STRING")
					end

					self:save(p, (string.char(v2)))
				else
					self:save_and_next(p)
				end
			end
		else
			self:save_and_next(p)
		end
	end

	self:save_and_next(p)
	p3.seminfo = string.sub(p.buff, 2, -2)
end

function class2:llex(state, p)
	state.buff = ""

	while true do
		local current = state.current

		if self:currIsNewline(state) then
			self:inclinenumber(state)
		elseif current == "-" then
			if self:nextc(state) ~= "-" then
				return "-"
			end

			local v

			if self:nextc(state) == "[" then
				v = self:skip_sep(state)
				state.buff = ""
			else
				v = -1
			end

			if v >= 0 then
				self:read_long_string(state, nil, v)
				state.buff = ""
			else
				while not self:currIsNewline(state) and state.current ~= "EOZ" do
					self:nextc(state)
				end
			end
		elseif current == "[" then
			local skip_sep = self:skip_sep(state)

			if skip_sep >= 0 then
				self:read_long_string(state, p, skip_sep)
				return "TK_STRING"
			end

			if skip_sep == -1 then
				return "["
			else
				self:lexerror(state, "invalid long string delimiter", "TK_STRING")
			end
		elseif current == "=" then
			if self:nextc(state) ~= "=" then
				return "="
			end

			self:nextc(state)
			return "TK_EQ"
		elseif current == "<" then
			if self:nextc(state) ~= "=" then
				return "<"
			end

			self:nextc(state)
			return "TK_LE"
		elseif current == ">" then
			if self:nextc(state) ~= "=" then
				return ">"
			end

			self:nextc(state)
			return "TK_GE"
		elseif current == "~" then
			if self:nextc(state) ~= "=" then
				return "~"
			end

			self:nextc(state)
			return "TK_NE"
		else
			if current == "\"" or current == "'" then
				self:read_string(state, current, p)
				return "TK_STRING"
			end

			if current == "." then
				local save_and_next = self:save_and_next(state)

				if self:check_next(state, ".") then
					if self:check_next(state, ".") then
						return "TK_DOTS"
					end

					return "TK_CONCAT"
				else
					if not string.find(save_and_next, "%d") then
						return "."
					end

					self:read_numeral(state, p)
					return "TK_NUMBER"
				end
			else
				if current == "EOZ" then
					return "TK_EOS"
				end

				if string.find(current, "%s") then
					self:nextc(state)
				else
					if string.find(current, "%d") then
						self:read_numeral(state, p)
						return "TK_NUMBER"
					end

					if not string.find(current, "[_%a]") then
						self:nextc(state)
						return current
					end

					repeat
						local save_and_next = self:save_and_next(state)
					until save_and_next == "EOZ" or not string.find(save_and_next, "[_%w]")

					local buff = state.buff
					local enum = self.enums[buff]

					if enum then
						return enum
					end

					p.seminfo = buff
					return "TK_NAME"
				end
			end
		end
	end
end

class3.OpMode = {
	iABC = 0,
	iABx = 1,
	iAsBx = 2
}
class3.SIZE_C = 9
class3.SIZE_B = 9
class3.SIZE_Bx = class3.SIZE_C + class3.SIZE_B
class3.SIZE_A = 8
class3.SIZE_OP = 6
class3.POS_OP = 0
class3.POS_A = class3.POS_OP + class3.SIZE_OP
class3.POS_C = class3.POS_A + class3.SIZE_A
class3.POS_B = class3.POS_C + class3.SIZE_C
class3.POS_Bx = class3.POS_C
class3.MAXARG_Bx = math.ldexp(1, class3.SIZE_Bx) - 1
class3.MAXARG_sBx = math.floor(class3.MAXARG_Bx / 2)
class3.MAXARG_A = math.ldexp(1, class3.SIZE_A) - 1
class3.MAXARG_B = math.ldexp(1, class3.SIZE_B) - 1
class3.MAXARG_C = math.ldexp(1, class3.SIZE_C) - 1

function class3:GET_OPCODE(p2)
	return self.ROpCode[p2.OP]
end

function class3:SET_OPCODE(p2, p3)
	p2.OP = self.OpCode[p3]
end

function class3:GETARG_A(p)
	return p.A
end

function class3:SETARG_A(p, p2)
	p.A = p2
end

function class3:GETARG_B(p)
	return p.B
end

function class3:SETARG_B(p, p2)
	p.B = p2
end

function class3.GETARG_C(_, p)
	return p.C
end

function class3:SETARG_C(p, p2)
	p.C = p2
end

function class3.GETARG_Bx(_, p)
	return p.Bx
end

function class3.SETARG_Bx(_, p, bx)
	p.Bx = bx
end

function class3:GETARG_sBx(p2)
	return p2.Bx - self.MAXARG_sBx
end

function class3:SETARG_sBx(p2, p3)
	p2.Bx = p3 + self.MAXARG_sBx
end

function class3:CREATE_ABC(p2, p3, p4, p5)
	return {
		OP = self.OpCode[p2],
		A = p3,
		B = p4,
		C = p5
	}
end

function class3:CREATE_ABx(p2, p3, bx)
	return {
		OP = self.OpCode[p2],
		A = p3,
		Bx = bx
	}
end

function class3:CREATE_Inst(p)
	local v = p % 64
	local v2 = (p - v) / 64
	local v3 = v2 % 256
	return self:CREATE_ABx(v, v3, (v2 - v3) / 256)
end

function class3:Instruction(state)
	if state.Bx then
		state.C = state.Bx % 512
		state.B = (state.Bx - state.C) / 512
	end

	local v = state.A * 64 + state.OP
	local v2 = v % 256
	local v3 = state.C * 64 + (v - v2) / 256
	local v4 = v3 % 256
	local v5 = state.B * 128 + (v3 - v4) / 256
	local v6 = v5 % 256
	return (string.char(v2, v4, v6, (v5 - v6) / 256))
end

function class3.DecodeInst(p, p2)
	local byte = string.byte
	local v2 = byte(p2, 1)
	local OP = v2 % 64
	local v4 = byte(p2, 2) * 4 + (v2 - OP) / 64
	local v5 = v4 % 256
	local v6 = byte(p2, 3) * 4 + (v4 - v5) / 256
	local v7 = v6 % 512
	local v = {
		OP = OP,
		A = v5,
		C = v7,
		B = byte(p2, 4) * 2 + (v6 - v7) / 512
	}

	if p.OpMode[tonumber((string.sub(p.opmodes[OP + 1], 7, 7)))] ~= "iABC" then
		v.Bx = v.B * 512 + v.C
	end

	return v
end

class3.BITRK = math.ldexp(1, class3.SIZE_B - 1)

function class3:ISK(p2)
	return self.BITRK <= p2
end

function class3.INDEXK(p, p2)
	return p2 - p.BITRK
end

class3.MAXINDEXRK = class3.BITRK - 1

function class3:RKASK(p2)
	return p2 + self.BITRK
end

class3.NO_REG = class3.MAXARG_A
class3.opnames = {}
class3.OpCode = {}
class3.ROpCode = {}
local count = 0
local class4 = {}
local class5 = {}
local class6 = {}

for k in string.gmatch([[
MOVE LOADK LOADBOOL LOADNIL GETUPVAL
GETGLOBAL GETTABLE SETGLOBAL SETUPVAL SETTABLE
NEWTABLE SELF ADD SUB MUL
DIV MOD POW UNM NOT
LEN CONCAT JMP EQ LT
LE TEST TESTSET CALL TAILCALL
RETURN FORLOOP FORPREP TFORLOOP SETLIST
CLOSE CLOSURE VARARG
]], "%S+") do
	local v = "OP_" .. k
	class3.opnames[count] = k
	class3.OpCode[v] = count
	class3.ROpCode[count] = v
	count += 1
end

class3.NUM_OPCODES = count
class3.OpArgMask = {
	OpArgN = 0,
	OpArgU = 1,
	OpArgR = 2,
	OpArgK = 3
}

function class3:getOpMode(p2)
	return self.opmodes[self.OpCode[p2]] % 4
end

function class3:getBMode(p2)
	return math.floor(self.opmodes[self.OpCode[p2]] / 16) % 4
end

function class3:getCMode(p2)
	return math.floor(self.opmodes[self.OpCode[p2]] / 4) % 4
end

function class3.testAMode(p, p2)
	return math.floor(p.opmodes[p.OpCode[p2]] / 64) % 2
end

function class3:testTMode(p2)
	return (math.floor(self.opmodes[self.OpCode[p2]] / 128))
end

class3.LFIELDS_PER_FLUSH = 50

local function opmode(p, p2, p3, p4, p5)
	local v = class3
	return p * 128 + p2 * 64 + v.OpArgMask[p3] * 16 + v.OpArgMask[p4] * 4 + v.OpMode[p5]
end

class3.opmodes = {
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABx,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABx,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	0 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABx,
	0 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	0 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgR * 4 + class3.OpMode.iABC,
	0 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iAsBx,
	128 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	128 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	128 + class3.OpArgMask.OpArgK * 16 + class3.OpArgMask.OpArgK * 4 + class3.OpMode.iABC,
	192 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	192 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	0 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iAsBx,
	64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iAsBx,
	128 + class3.OpArgMask.OpArgN * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	0 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgU * 4 + class3.OpMode.iABC,
	0 + class3.OpArgMask.OpArgN * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABx,
	64 + class3.OpArgMask.OpArgU * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC
}
class3.opmodes[0] = 64 + class3.OpArgMask.OpArgR * 16 + class3.OpArgMask.OpArgN * 4 + class3.OpMode.iABC
class4.LUA_SIGNATURE = "\27Lua"
class4.LUA_TNUMBER = 3
class4.LUA_TSTRING = 4
class4.LUA_TNIL = 0
class4.LUA_TBOOLEAN = 1
class4.LUA_TNONE = -1
class4.LUAC_VERSION = 81
class4.LUAC_FORMAT = 0
class4.LUAC_HEADERSIZE = 12

function class4:make_setS()
	return function(p, p2)
		if not p then
			return 0
		end

		p2.data ..= p
		return 0
	end, {
		data = ""
	}
end

function class4.make_setF(_, _)
	local v = {
		h = nil
	}

	if v.h then
		return function(p, p2)
			if not p2.h then
				return 0
			end

			if p then
				if p2.h:write(p) then
					return 0
				end
			elseif p2.h:close() then
				return 0
			end

			return 1
		end, v
	end

	return nil
end

function class4:ttype(p)
	local typeName = type(p.value)

	if typeName == "number" then
		return self.LUA_TNUMBER
	elseif typeName == "string" then
		return self.LUA_TSTRING
	elseif typeName == "nil" then
		return self.LUA_TNIL
	elseif typeName == "boolean" then
		return self.LUA_TBOOLEAN
	end

	return self.LUA_TNONE
end

function class4:from_double(p)
	local function grab_byte(p2)
		local v = p2 % 256
		return (p2 - v) / 256, (string.char(v))
	end

	local v

	if p < 0 then
		p = -p
		v = 1
	else
		v = 0
	end

	local v2, v3 = math.frexp(p)
	local v4, v5

	if p == 0 then
		v4 = 0
		v5 = 0
	elseif p == 1e999 then
		v4 = 0
		v5 = 2047
	else
		v4 = (v2 * 2 - 1) * 4503599627370496
		v5 = v3 + 1022
	end

	local v6 = math.floor(v4)
	local v7 = ""

	for _ = 1, 6 do
		local v8 = v6 % 256
		v6 = (v6 - v8) / 256
		v7 ..= string.char(v8)
	end

	local v8 = v5 * 16 + v6
	local v9 = v8 % 256
	local v10 = (v8 - v9) / 256
	local v11 = v7 .. string.char(v9)
	local v12 = v * 128 + v10
	local v13 = v12 % 256
	local _ = (v12 - v13) / 256
	return v11 .. string.char(v13)
end

function class4:from_int(p)
	local v2 = math.floor(p)

	if v2 < 0 then
		v2 = 4294967296 + v2
	end

	local v3 = "" .. string.char(v2 % 256)
	local v4 = math.floor(v2 / 256)
	local v5 = v3 .. string.char(v4 % 256)
	local v6 = math.floor(v4 / 256)
	local v7 = v5 .. string.char(v6 % 256)
	local v8 = math.floor(v6 / 256)
	local v9 = v7 .. string.char(v8 % 256)
	math.floor(v8 / 256)
	return v9
end

function class4:DumpBlock(p, state)
	if state.status == 0 then
		state.status = state.write(p, state.data)
	end
end

function class4:DumpChar(p, p2)
	self:DumpBlock(string.char(p), p2)
end

function class4:DumpInt(p, p2)
	self:DumpBlock(self:from_int(p), p2)
end

function class4:DumpSizeT(p, p2)
	self:DumpBlock(self:from_int(p), p2)
	self:DumpBlock(self:from_int(0), p2)
end

function class4:DumpNumber(p, p2)
	self:DumpBlock(self:from_double(p), p2)
end

function class4:DumpString(p, p2)
	if p == nil then
		self:DumpSizeT(0, p2)
		return
	end

	local v = p .. "\0"
	self:DumpSizeT(#v, p2)
	self:DumpBlock(v, p2)
end

function class4:DumpCode(p, p2)
	local sizecode = p.sizecode
	self:DumpInt(sizecode, p2)

	for i = 0, sizecode - 1 do
		self:DumpBlock(class3:Instruction(p.code[i]), p2)
	end
end

function class4:DumpConstants(data, p)
	local sizek = data.sizek
	self:DumpInt(sizek, p)

	for i = 0, sizek - 1 do
		local v = data.k[i]
		local ttype = self:ttype(v)
		self:DumpChar(ttype, p)

		if ttype == self.LUA_TNIL then
			continue
		end

		if ttype == self.LUA_TBOOLEAN then
			self:DumpChar(v.value and 1 or 0, p)
		elseif ttype == self.LUA_TNUMBER then
			self:DumpNumber(v.value, p)
		elseif ttype == self.LUA_TSTRING then
			self:DumpString(v.value, p)
		end
	end

	local sizep = data.sizep
	self:DumpInt(sizep, p)

	for i = 0, sizep - 1 do
		self:DumpFunction(data.p[i], data.source, p)
	end
end

function class4:DumpDebug(data, p)
	local v = p.strip and 0 or data.sizelineinfo
	self:DumpInt(v, p)

	for i = 0, v - 1 do
		self:DumpInt(data.lineinfo[i], p)
	end

	local v2 = p.strip and 0 or data.sizelocvars
	self:DumpInt(v2, p)

	for i = 0, v2 - 1 do
		self:DumpString(data.locvars[i].varname, p)
		self:DumpInt(data.locvars[i].startpc, p)
		self:DumpInt(data.locvars[i].endpc, p)
	end

	local v3 = p.strip and 0 or data.sizeupvalues
	self:DumpInt(v3, p)

	for i = 0, v3 - 1 do
		self:DumpString(data.upvalues[i], p)
	end
end

function class4:DumpFunction(data, p, p2)
	local source = data.source

	if source == p or p2.strip then
		source = nil
	end

	self:DumpString(source, p2)
	self:DumpInt(data.lineDefined, p2)
	self:DumpInt(data.lastlinedefined, p2)
	self:DumpChar(data.nups, p2)
	self:DumpChar(data.numparams, p2)
	self:DumpChar(data.is_vararg, p2)
	self:DumpChar(data.maxstacksize, p2)
	self:DumpCode(data, p2)
	self:DumpConstants(data, p2)
	self:DumpDebug(data, p2)
end

function class4:DumpHeader(p)
	local header = self:header()
	assert(#header == self.LUAC_HEADERSIZE)
	self:DumpBlock(header, p)
end

function class4:header()
	return self.LUA_SIGNATURE .. string.char(self.LUAC_VERSION, self.LUAC_FORMAT, 1, 4, 8, 4, 8, 0)
end

function class4:dump(p, p2, write, p4, strip)
	local v = {
		L = p,
		write = write,
		data = p4,
		strip = strip,
		status = 0
	}
	self:DumpHeader(v)
	self:DumpFunction(p2, nil, v)
	v.write(nil, v.data)
	return v.status
end

class5.MAXSTACK = 250

function class5:ttisnumber(p)
	if p then
		return type(p.value) == "number"
	end

	return false
end

function class5:nvalue(p)
	return p.value
end

function class5:setnilvalue(p)
	p.value = nil
end

function class5:setsvalue(p, p2)
	p.value = p2
end

class5.setnvalue = class5.setsvalue
class5.sethvalue = class5.setsvalue
class5.setbvalue = class5.setsvalue

function class5:numadd(p, p2)
	return p + p2
end

function class5:numsub(p, p2)
	return p - p2
end

function class5:nummul(p, p2)
	return p * p2
end

function class5:numdiv(p, p2)
	return p / p2
end

function class5:nummod(p, p2)
	return p % p2
end

function class5:numpow(p, p2)
	return p ^ p2
end

function class5:numunm(p)
	return -p
end

function class5:numisnan(p)
	return p ~= p
end

class5.NO_JUMP = -1
class5.BinOpr = {
	OPR_ADD = 0,
	OPR_SUB = 1,
	OPR_MUL = 2,
	OPR_DIV = 3,
	OPR_MOD = 4,
	OPR_POW = 5,
	OPR_CONCAT = 6,
	OPR_NE = 7,
	OPR_EQ = 8,
	OPR_LT = 9,
	OPR_LE = 10,
	OPR_GT = 11,
	OPR_GE = 12,
	OPR_AND = 13,
	OPR_OR = 14,
	OPR_NOBINOPR = 15
}
class5.UnOpr = {
	OPR_MINUS = 0,
	OPR_NOT = 1,
	OPR_LEN = 2,
	OPR_NOUNOPR = 3
}

function class5:getcode(p, p2)
	return p.f.code[p2.info]
end

function class5:codeAsBx(p, p2, p3, p4)
	return self:codeABx(p, p2, p3, p4 + class3.MAXARG_sBx)
end

function class5:setmultret(p, p2)
	self:setreturns(p, p2, class6.LUA_MULTRET)
end

function class5:hasjumps(p)
	return p.t ~= p.f
end

function class5:isnumeral(data)
	return data.k == "VKNUM" and data.t == self.NO_JUMP and data.f == self.NO_JUMP
end

function class5:_nil(data, p, p2)
	if data.pc > data.lasttarget then
		if data.pc == 0 then
			if data.nactvar <= p then
				return
			end
		else
			local v = data.f.code[data.pc - 1]

			if class3:GET_OPCODE(v) == "OP_LOADNIL" then
				local GETARG_A = class3:GETARG_A(v)
				local GETARG_B = class3:GETARG_B(v)

				if GETARG_A <= p and p <= GETARG_B + 1 then
					if GETARG_B < p + p2 - 1 then
						class3:SETARG_B(v, p + p2 - 1)
					end

					return
				end
			end
		end
	end

	self:codeABC(data, "OP_LOADNIL", p, p + p2 - 1, 0)
end

function class5:jump(p)
	local jpc = p.jpc
	p.jpc = self.NO_JUMP
	return (self:concat(p, self:codeAsBx(p, "OP_JMP", 0, self.NO_JUMP), jpc))
end

function class5:ret(p, p2, p3)
	self:codeABC(p, "OP_RETURN", p2, p3 + 1, 0)
end

function class5:condjump(p, p2, p3, p4, p5)
	self:codeABC(p, p2, p3, p4, p5)
	return self:jump(p)
end

function class5:fixjump(p2, p3, p4)
	local v = p2.f.code[p3]
	local v2 = p4 - (p3 + 1)

	if p4 == self.NO_JUMP then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if math.abs(v2) > class3.MAXARG_sBx then
		class2:syntaxerror(p2.ls, "control structure too long")
	end

	class3:SETARG_sBx(v, v2)
end

function class5:getlabel(p)
	p.lasttarget = p.pc
	return p.pc
end

function class5:getjump(p2, p3)
	local gETARG_sBx = class3:GETARG_sBx(p2.f.code[p3])

	if gETARG_sBx == self.NO_JUMP then
		return self.NO_JUMP
	end

	return p3 + 1 + gETARG_sBx
end

function class5:getjumpcontrol(p, p2)
	local v = p.f.code[p2]
	local v2 = p.f.code[p2 - 1]

	if p2 >= 1 and class3:testTMode(class3:GET_OPCODE(v2)) ~= 0 then
		return v2
	end

	return v
end

function class5:need_value(p, p2)
	while p2 ~= self.NO_JUMP do
		if class3:GET_OPCODE((self:getjumpcontrol(p, p2))) ~= "OP_TESTSET" then
			return true
		end

		p2 = self:getjump(p, p2)
	end

	return false
end

function class5:patchtestreg(p, p2, p3)
	local getjumpcontrol = self:getjumpcontrol(p, p2)

	if class3:GET_OPCODE(getjumpcontrol) ~= "OP_TESTSET" then
		return false
	end

	if p3 == class3.NO_REG or p3 == class3:GETARG_B(getjumpcontrol) then
		class3:SET_OPCODE(getjumpcontrol, "OP_TEST")
		class3:SETARG_A(getjumpcontrol, (class3:GETARG_B(getjumpcontrol)))
		class3:SETARG_B(getjumpcontrol, 0)
	else
		class3:SETARG_A(getjumpcontrol, p3)
	end

	return true
end

function class5:removevalues(p, p2)
	while p2 ~= self.NO_JUMP do
		self:patchtestreg(p, p2, class3.NO_REG)
		p2 = self:getjump(p, p2)
	end
end

function class5:patchlistaux(p, p2, p3, p4, p5)
	while p2 ~= self.NO_JUMP do
		local getjump = self:getjump(p, p2)

		if self:patchtestreg(p, p2, p4) then
			self:fixjump(p, p2, p3)
		else
			self:fixjump(p, p2, p5)
		end

		p2 = getjump
	end
end

function class5:dischargejpc(state)
	self:patchlistaux(state, state.jpc, state.pc, class3.NO_REG, state.pc)
	state.jpc = self.NO_JUMP
end

function class5:patchlist(p, p2, p3)
	if p3 == p.pc then
		self:patchtohere(p, p2)
		return
	end

	if not (p3 < p.pc) then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	self:patchlistaux(p, p2, p3, class3.NO_REG, p3)
end

function class5:patchtohere(p, p2)
	self:getlabel(p)
	p.jpc = self:concat(p, p.jpc, p2)
end

function class5:concat(p, p2, p3)
	if p3 == self.NO_JUMP then
		return p2
	end

	if p2 == self.NO_JUMP then
		return p3
	end

	local getjump = self:getjump(p, p2)
	local v = p2

	while getjump ~= self.NO_JUMP do
		v = getjump
		getjump = self:getjump(p, getjump)
	end

	self:fixjump(p, v, p3)
	return p2
end

function class5:checkstack(data, p2)
	local maxstacksize = data.freereg + p2

	if data.f.maxstacksize < maxstacksize then
		if self.MAXSTACK <= maxstacksize then
			class2:syntaxerror(data.ls, "function or expression too complex")
		end

		data.f.maxstacksize = maxstacksize
	end
end

function class5:reserveregs(p, p2)
	self:checkstack(p, p2)
	p.freereg += p2
end

function class5:freereg(state, p)
	if not class3:ISK(p) and state.nactvar <= p then
		state.freereg -= 1

		if p ~= state.freereg then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end
	end
end

function class5:freeexp(p, p2)
	if p2.k == "VNONRELOC" then
		self:freereg(p, p2.info)
	end
end

function class5:addk(state, p, p2)
	local L = state.L
	local v = state.h[p.value]
	local f = state.f

	if self:ttisnumber(v) then
		return self:nvalue(v)
	end

	local v2 = {}
	self:setnvalue(v2, state.nk)
	state.h[p.value] = v2
	class6:growvector(L, f.k, state.nk, f.sizek, nil, class3.MAXARG_Bx, "constant table overflow")
	f.k[state.nk] = p2
	local nk = state.nk
	state.nk += 1
	return nk
end

function class5:stringK(p, p2)
	local v = {}
	self:setsvalue(v, p2)
	return self:addk(p, v, v)
end

function class5:numberK(p, p2)
	local v = {}
	self:setnvalue(v, p2)
	return self:addk(p, v, v)
end

function class5:boolK(p, p2)
	local v = {}
	self:setbvalue(v, p2)
	return self:addk(p, v, v)
end

function class5:nilK(p)
	local v = {}
	local v2 = {}
	self:setnilvalue(v2)
	self:sethvalue(v, p.h)
	return self:addk(p, v, v2)
end

function class5:setreturns(p, p2, p3)
	if p2.k == "VCALL" then
		class3:SETARG_C(self:getcode(p, p2), p3 + 1)
	elseif p2.k == "VVARARG" then
		class3:SETARG_B(self:getcode(p, p2), p3 + 1)
		class3:SETARG_A(self:getcode(p, p2), p.freereg)
		class5:reserveregs(p, 1)
	end
end

function class5:setoneret(p, p2)
	if p2.k == "VCALL" then
		p2.k = "VNONRELOC"
		p2.info = class3:GETARG_A(self:getcode(p, p2))
	elseif p2.k == "VVARARG" then
		class3:SETARG_B(self:getcode(p, p2), 2)
		p2.k = "VRELOCABLE"
	end
end

function class5:dischargevars(p, state)
	local k = state.k

	if k == "VLOCAL" then
		state.k = "VNONRELOC"
	elseif k == "VUPVAL" then
		state.info = self:codeABC(p, "OP_GETUPVAL", 0, state.info, 0)
		state.k = "VRELOCABLE"
	elseif k == "VGLOBAL" then
		state.info = self:codeABx(p, "OP_GETGLOBAL", 0, state.info)
		state.k = "VRELOCABLE"
	elseif k == "VINDEXED" then
		self:freereg(p, state.aux)
		self:freereg(p, state.info)
		state.info = self:codeABC(p, "OP_GETTABLE", 0, state.info, state.aux)
		state.k = "VRELOCABLE"
	else
		if k ~= "VVARARG" and k ~= "VCALL" then
			return
		end

		self:setoneret(p, state)
	end
end

function class5:code_label(p, p2, p3, p4)
	self:getlabel(p)
	return self:codeABC(p, "OP_LOADBOOL", p2, p3, p4)
end

function class5:discharge2reg(p, state, info)
	self:dischargevars(p, state)
	local k = state.k

	if k == "VNIL" then
		self:_nil(p, info, 1)
	elseif k == "VFALSE" or k == "VTRUE" then
		self:codeABC(p, "OP_LOADBOOL", info, state.k == "VTRUE" and 1 or 0, 0)
	elseif k == "VK" then
		self:codeABx(p, "OP_LOADK", info, state.info)
	elseif k == "VKNUM" then
		self:codeABx(p, "OP_LOADK", info, self:numberK(p, state.nval))
	elseif k == "VRELOCABLE" then
		class3:SETARG_A(self:getcode(p, state), info)
	elseif k == "VNONRELOC" then
		if info ~= state.info then
			self:codeABC(p, "OP_MOVE", info, state.info, 0)
		end
	else
		if state.k ~= "VVOID" and state.k ~= "VJMP" then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end

		return
	end

	state.info = info
	state.k = "VNONRELOC"
end

function class5:discharge2anyreg(p, p2)
	if p2.k ~= "VNONRELOC" then
		self:reserveregs(p, 1)
		self:discharge2reg(p, p2, p.freereg - 1)
	end
end

function class5:exp2reg(p, state, info)
	self:discharge2reg(p, state, info)

	if state.k == "VJMP" then
		state.t = self:concat(p, state.t, state.info)
	end

	if self:hasjumps(state) then
		local NO_JUMP = self.NO_JUMP
		local NO_JUMP2 = self.NO_JUMP

		if self:need_value(p, state.t) or self:need_value(p, state.f) then
			local NO_JUMP3 = state.k == "VJMP" and self.NO_JUMP or self:jump(p)
			NO_JUMP = self:code_label(p, info, 0, 1)
			NO_JUMP2 = self:code_label(p, info, 1, 0)
			self:patchtohere(p, NO_JUMP3)
		end

		local getlabel = self:getlabel(p)
		self:patchlistaux(p, state.f, getlabel, info, NO_JUMP)
		self:patchlistaux(p, state.t, getlabel, info, NO_JUMP2)
	end

	local NO_JUMP = self.NO_JUMP
	local NO_JUMP2 = self.NO_JUMP
	state.f = NO_JUMP
	state.t = NO_JUMP2
	state.info = info
	state.k = "VNONRELOC"
end

function class5:exp2nextreg(p, p2)
	self:dischargevars(p, p2)
	self:freeexp(p, p2)
	self:reserveregs(p, 1)
	self:exp2reg(p, p2, p.freereg - 1)
end

function class5:exp2anyreg(p, p2)
	self:dischargevars(p, p2)

	if p2.k == "VNONRELOC" then
		if not self:hasjumps(p2) then
			return p2.info
		end

		if p2.info >= p.nactvar then
			self:exp2reg(p, p2, p2.info)
			return p2.info
		end
	end

	self:exp2nextreg(p, p2)
	return p2.info
end

function class5:exp2val(p, p2)
	if self:hasjumps(p2) then
		self:exp2anyreg(p, p2)
	else
		self:dischargevars(p, p2)
	end
end

function class5:exp2RK(p, state)
	self:exp2val(p, state)
	local k = state.k

	if k == "VKNUM" or k == "VTRUE" or k == "VFALSE" or k == "VNIL" then
		if p.nk <= class3.MAXINDEXRK then
			if state.k == "VNIL" then
				state.info = self:nilK(p)
			else
				state.info = state.k == "VKNUM" and self:numberK(p, state.nval) or self:boolK(p, state.k == "VTRUE")
			end

			state.k = "VK"
			return class3:RKASK(state.info)
		end
	elseif k == "VK" and state.info <= class3.MAXINDEXRK then
		return class3:RKASK(state.info)
	end

	return self:exp2anyreg(p, state)
end

function class5:storevar(p, data, p2)
	local k = data.k

	if k == "VLOCAL" then
		self:freeexp(p, p2)
		self:exp2reg(p, p2, data.info)
	else
		if k == "VUPVAL" then
			self:codeABC(p, "OP_SETUPVAL", self:exp2anyreg(p, p2), data.info, 0)
		elseif k == "VGLOBAL" then
			self:codeABx(p, "OP_SETGLOBAL", self:exp2anyreg(p, p2), data.info)
		elseif k == "VINDEXED" then
			local exp2RK = self:exp2RK(p, p2)
			self:codeABC(p, "OP_SETTABLE", data.info, data.aux, exp2RK)
		end

		self:freeexp(p, p2)
	end
end

function class5:_self(p, p2, p3)
	self:exp2anyreg(p, p2)
	self:freeexp(p, p2)
	local freereg = p.freereg
	self:reserveregs(p, 2)
	self:codeABC(p, "OP_SELF", freereg, p2.info, self:exp2RK(p, p3))
	self:freeexp(p, p3)
	p2.info = freereg
	p2.k = "VNONRELOC"
end

function class5:invertjump(p, p2)
	local getjumpcontrol = self:getjumpcontrol(p, p2.info)
	local v

	if class3:testTMode(class3:GET_OPCODE(getjumpcontrol)) == 0 or class3:GET_OPCODE(getjumpcontrol) == "OP_TESTSET" then
		v = false
	else
		v = class3:GET_OPCODE(getjumpcontrol) ~= "OP_TEST"
	end

	if not v then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	class3:SETARG_A(getjumpcontrol, class3:GETARG_A(getjumpcontrol) == 0 and 1 or 0)
end

function class5:jumponcond(p, p2, p3)
	if p2.k == "VRELOCABLE" then
		local getcode = self:getcode(p, p2)

		if class3:GET_OPCODE(getcode) == "OP_NOT" then
			p.pc -= 1
			return self:condjump(p, "OP_TEST", class3:GETARG_B(getcode), 0, p3 and 0 or 1)
		end
	end

	self:discharge2anyreg(p, p2)
	self:freeexp(p, p2)
	return self:condjump(p, "OP_TESTSET", class3.NO_REG, p2.info, p3 and 1 or 0)
end

function class5:goiftrue(p, state)
	self:dischargevars(p, state)
	local k = state.k
	local NO_JUMP

	if k == "VK" or k == "VKNUM" or k == "VTRUE" then
		NO_JUMP = self.NO_JUMP
	elseif k == "VFALSE" then
		NO_JUMP = self:jump(p)
	elseif k == "VJMP" then
		self:invertjump(p, state)
		NO_JUMP = state.info
	else
		NO_JUMP = self:jumponcond(p, state, false)
	end

	state.f = self:concat(p, state.f, NO_JUMP)
	self:patchtohere(p, state.t)
	state.t = self.NO_JUMP
end

function class5:goiffalse(p, state)
	self:dischargevars(p, state)
	local k = state.k
	local NO_JUMP

	if k == "VNIL" or k == "VFALSE" then
		NO_JUMP = self.NO_JUMP
	elseif k == "VTRUE" then
		NO_JUMP = self:jump(p)
	elseif k == "VJMP" then
		NO_JUMP = state.info
	else
		NO_JUMP = self:jumponcond(p, state, true)
	end

	state.t = self:concat(p, state.t, NO_JUMP)
	self:patchtohere(p, state.f)
	state.f = self.NO_JUMP
end

function class5:codenot(p, state)
	self:dischargevars(p, state)
	local k = state.k

	if k == "VNIL" or k == "VFALSE" then
		state.k = "VTRUE"
	elseif k == "VK" or k == "VKNUM" or k == "VTRUE" then
		state.k = "VFALSE"
	elseif k == "VJMP" then
		self:invertjump(p, state)
	elseif k == "VRELOCABLE" or k == "VNONRELOC" then
		self:discharge2anyreg(p, state)
		self:freeexp(p, state)
		state.info = self:codeABC(p, "OP_NOT", 0, state.info, 0)
		state.k = "VRELOCABLE"
	end

	local t = state.t
	local f = state.f
	state.f = t
	state.t = f
	self:removevalues(p, state.f)
	self:removevalues(p, state.t)
end

function class5:indexed(p, p2, p3)
	p2.aux = self:exp2RK(p, p3)
	p2.k = "VINDEXED"
end

function class5:constfolding(p, p2, p3)
	if not (self:isnumeral(p2) and self:isnumeral(p3)) then
		return false
	end

	local nval = p2.nval
	local nval2 = p3.nval
	local nval3

	if p == "OP_ADD" then
		nval3 = self:numadd(nval, nval2)
	elseif p == "OP_SUB" then
		nval3 = self:numsub(nval, nval2)
	elseif p == "OP_MUL" then
		nval3 = self:nummul(nval, nval2)
	elseif p == "OP_DIV" then
		if nval2 == 0 then
			return false
		else
			nval3 = self:numdiv(nval, nval2)
		end
	elseif p == "OP_MOD" then
		if nval2 == 0 then
			return false
		else
			nval3 = self:nummod(nval, nval2)
		end
	elseif p == "OP_POW" then
		nval3 = self:numpow(nval, nval2)
	elseif p == "OP_UNM" then
		nval3 = self:numunm(nval)
	elseif p == "OP_LEN" then
		return false
	else
		nval3 = 0
	end

	if self:numisnan(nval3) then
		return false
	end

	p2.nval = nval3
	return true
end

function class5:codearith(p, p2, p3, p4)
	if self:constfolding(p2, p3, p4) then
		return
	end

	local v = (p2 == "OP_UNM" or p2 == "OP_LEN") and 0 or self:exp2RK(p, p4) or 0
	local exp2RK = self:exp2RK(p, p3)

	if v < exp2RK then
		self:freeexp(p, p3)
		self:freeexp(p, p4)
	else
		self:freeexp(p, p4)
		self:freeexp(p, p3)
	end

	p3.info = self:codeABC(p, p2, 0, exp2RK, v)
	p3.k = "VRELOCABLE"
end

function class5:codecomp(p, p2, p3, p4, p5)
	local exp2RK = self:exp2RK(p, p4)
	local exp2RK2 = self:exp2RK(p, p5)
	self:freeexp(p, p5)
	self:freeexp(p, p4)

	if p3 == 0 and p2 ~= "OP_EQ" then
		exp2RK2, exp2RK = exp2RK, exp2RK2
		p3 = 1
	end

	p4.info = self:condjump(p, p2, p3, exp2RK, exp2RK2)
	p4.k = "VJMP"
end

function class5:prefix(p, p2, p3)
	local v = {
		t = self.NO_JUMP,
		f = self.NO_JUMP,
		k = "VKNUM",
		nval = 0
	}

	if p2 == "OPR_MINUS" then
		if not self:isnumeral(p3) then
			self:exp2anyreg(p, p3)
		end

		self:codearith(p, "OP_UNM", p3, v)
	else
		if p2 == "OPR_NOT" then
			self:codenot(p, p3)
			return
		end

		if p2 ~= "OPR_LEN" then
			return
		end

		self:exp2anyreg(p, p3)
		self:codearith(p, "OP_LEN", p3, v)
	end
end

function class5:infix(p, p2, p3)
	if p2 == "OPR_AND" then
		self:goiftrue(p, p3)
	elseif p2 == "OPR_OR" then
		self:goiffalse(p, p3)
	elseif p2 == "OPR_CONCAT" then
		self:exp2nextreg(p, p3)
	elseif p2 == "OPR_ADD" or p2 == "OPR_SUB" or p2 == "OPR_MUL" or p2 == "OPR_DIV" or p2 == "OPR_MOD" or p2 == "OPR_POW" then
		if not self:isnumeral(p3) then
			self:exp2RK(p, p3)
		end
	else
		self:exp2RK(p, p3)
	end
end

class5.arith_op = {
	OPR_ADD = "OP_ADD",
	OPR_SUB = "OP_SUB",
	OPR_MUL = "OP_MUL",
	OPR_DIV = "OP_DIV",
	OPR_MOD = "OP_MOD",
	OPR_POW = "OP_POW"
}
class5.comp_op = {
	OPR_EQ = "OP_EQ",
	OPR_NE = "OP_EQ",
	OPR_LT = "OP_LT",
	OPR_LE = "OP_LE",
	OPR_GT = "OP_LT",
	OPR_GE = "OP_LE"
}
class5.comp_cond = {
	OPR_EQ = 1,
	OPR_NE = 0,
	OPR_LT = 1,
	OPR_LE = 1,
	OPR_GT = 0,
	OPR_GE = 0
}

function class5:posfix(p, p2, state, state2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function copyexp(state3, data)
		state3.k = data.k
		state3.info = data.info
		state3.aux = data.aux
		state3.nval = data.nval
		state3.t = data.t
		state3.f = data.f
	end

	if p2 == "OPR_AND" then
		if state.t ~= self.NO_JUMP then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end

		self:dischargevars(p, state2)
		state2.f = self:concat(p, state2.f, state.f)
		copyexp(state, state2) -- equivalent call inferred; original call site unknown
	elseif p2 == "OPR_OR" then
		if state.f ~= self.NO_JUMP then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end

		self:dischargevars(p, state2)
		state2.t = self:concat(p, state2.t, state.t)
		copyexp(state, state2) -- equivalent call inferred; original call site unknown
	elseif p2 == "OPR_CONCAT" then
		self:exp2val(p, state2)

		if state2.k == "VRELOCABLE" and class3:GET_OPCODE(self:getcode(p, state2)) == "OP_CONCAT" then
			if state.info ~= class3:GETARG_B(self:getcode(p, state2)) - 1 then
				lua_assert(false) -- equivalent call inferred; original call site unknown
			end

			self:freeexp(p, state)
			class3:SETARG_B(self:getcode(p, state2), state.info)
			state.k = "VRELOCABLE"
			state.info = state2.info
		else
			self:exp2nextreg(p, state2)
			self:codearith(p, "OP_CONCAT", state, state2)
		end
	else
		local v = self.arith_op[p2]

		if v then
			self:codearith(p, v, state, state2)
			return
		end

		local v2 = self.comp_op[p2]

		if not v2 then
			return
		end

		self:codecomp(p, v2, self.comp_cond[p2], state, state2)
	end
end

function class5:fixline(p, p2)
	p.f.lineinfo[p.pc - 1] = p2
end

function class5:code(state, p, p2)
	local f = state.f
	self:dischargejpc(state)
	class6:growvector(state.L, f.code, state.pc, f.sizecode, nil, class6.MAX_INT, "code size overflow")
	f.code[state.pc] = p
	class6:growvector(state.L, f.lineinfo, state.pc, f.sizelineinfo, nil, class6.MAX_INT, "code size overflow")
	f.lineinfo[state.pc] = p2
	local pc = state.pc
	state.pc += 1
	return pc
end

function class5:codeABC(p, p2, p3, p4, p5)
	if class3:getOpMode(p2) ~= class3.OpMode.iABC then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if class3:getBMode(p2) == class3.OpArgMask.OpArgN and p4 ~= 0 then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if class3:getCMode(p2) == class3.OpArgMask.OpArgN and p5 ~= 0 then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	return self:code(p, class3:CREATE_ABC(p2, p3, p4, p5), p.ls.lastline)
end

function class5:codeABx(p, p2, p3, p4)
	if class3:getOpMode(p2) ~= class3.OpMode.iABx and class3:getOpMode(p2) ~= class3.OpMode.iAsBx then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if class3:getCMode(p2) ~= class3.OpArgMask.OpArgN then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	return self:code(p, class3:CREATE_ABx(p2, p3, p4), p.ls.lastline)
end

function class5:setlist(p, p2, p3, p4)
	local v = math.floor((p3 - 1) / class3.LFIELDS_PER_FLUSH) + 1
	local v2 = p4 == class6.LUA_MULTRET and 0 or p4

	if p4 == 0 then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if v <= class3.MAXARG_C then
		self:codeABC(p, "OP_SETLIST", p2, v2, v)
	else
		self:codeABC(p, "OP_SETLIST", p2, v2, 0)
		self:code(p, class3:CREATE_Inst(v), p.ls.lastline)
	end

	p.freereg = p2 + 1
end

class6.LUA_QS = class2.LUA_QS or "'%s'"
class6.SHRT_MAX = 32767
class6.LUAI_MAXVARS = 200
class6.LUAI_MAXUPVALUES = 60
class6.MAX_INT = class2.MAX_INT or 2147483645
class6.LUAI_MAXCCALLS = 200
class6.VARARG_HASARG = 1
class6.HASARG_MASK = 2
class6.VARARG_ISVARARG = 2
class6.VARARG_NEEDSARG = 4
class6.LUA_MULTRET = -1

function class6:LUA_QL(p)
	return "'" .. p .. "'"
end

function class6:growvector(_, _, p, _, _, p2, message)
	if p2 <= p then
		error(message)
	end
end

function class6:newproto(_)
	return {
		k = {},
		sizek = 0,
		p = {},
		sizep = 0,
		code = {},
		sizecode = 0,
		sizelineinfo = 0,
		sizeupvalues = 0,
		nups = 0,
		upvalues = {},
		numparams = 0,
		is_vararg = 0,
		maxstacksize = 0,
		lineinfo = {},
		sizelocvars = 0,
		locvars = {},
		lineDefined = 0,
		lastlinedefined = 0,
		source = nil
	}
end

function class6:int2fb(p)
	local count2 = 0

	while p >= 16 do
		p = math.floor((p + 1) / 2)
		count2 += 1
	end

	if p < 8 then
		return p
	end

	return (count2 + 1) * 8 + (p - 8)
end

function class6:hasmultret(p)
	return p == "VCALL" or p == "VVARARG"
end

function class6:getlocvar(p, p2)
	return p.f.locvars[p.actvar[p2]]
end

function class6:checklimit(p, p2, p3, p4)
	if p3 < p2 then
		self:errorlimit(p, p3, p4)
	end
end

function class6:anchor_token(p)
	if p.t.token ~= "TK_NAME" then
		local _ = p.t.token == "TK_STRING"
	end
end

function class6:error_expected(p2, p3)
	class2:syntaxerror(p2, string.format(self.LUA_QS .. " expected", class2:token2str(p2, p3)))
end

function class6:errorlimit(p, p2, p3)
	local v = p.f.linedefined == 0 and string.format("main function has more than %d %s", p2, p3) or string.format(
		"function at line %d has more than %d %s",
		p.f.linedefined,
		p2,
		p3
	)
	class2:lexerror(p.ls, v, 0)
end

function class6:testnext(p, p2)
	if p.t.token ~= p2 then
		return false
	end

	class2:next(p)
	return true
end

function class6:check(p, p2)
	if p.t.token ~= p2 then
		self:error_expected(p, p2)
	end
end

function class6:checknext(p, p2)
	self:check(p, p2)
	class2:next(p)
end

function class6:check_condition(p, p2, p3)
	if not p2 then
		class2:syntaxerror(p, p3)
	end
end

function class6:check_match(p, p2, p3, p4)
	if not self:testnext(p, p2) then
		if p4 == p.linenumber then
			self:error_expected(p, p2)
		else
			class2:syntaxerror(
				p,
				string.format(
					self.LUA_QS .. " expected (to close " .. self.LUA_QS .. " at line %d)",
					class2:token2str(p, p2),
					class2:token2str(p, p3),
					p4
				)
			)
		end
	end
end

function class6:str_checkname(p)
	self:check(p, "TK_NAME")
	local seminfo = p.t.seminfo
	class2:next(p)
	return seminfo
end

function class6:init_exp(p, p2, info)
	local NO_JUMP = class5.NO_JUMP
	local NO_JUMP2 = class5.NO_JUMP
	p.f = NO_JUMP
	p.t = NO_JUMP2
	p.k = p2
	p.info = info
end

function class6:codestring(p, p2, p3)
	self:init_exp(p2, "VK", class5:stringK(p.fs, p3))
end

function class6:checkname(p, p2)
	self:codestring(p, p2, self:str_checkname(p))
end

function class6:registerlocalvar(p, varname)
	local fs = p.fs
	local f = fs.f
	self:growvector(p.L, f.locvars, fs.nlocvars, f.sizelocvars, nil, self.SHRT_MAX, "too many local variables")
	f.locvars[fs.nlocvars] = {}
	f.locvars[fs.nlocvars].varname = varname
	local nlocvars = fs.nlocvars
	fs.nlocvars += 1
	return nlocvars
end

function class6:new_localvarliteral(p, p2, p3)
	self:new_localvar(p, p2, p3)
end

function class6:new_localvar(p, p2, p3)
	local fs = p.fs
	self:checklimit(fs, fs.nactvar + p3 + 1, self.LUAI_MAXVARS, "local variables")
	fs.actvar[fs.nactvar + p3] = self:registerlocalvar(p, p2)
end

function class6:adjustlocalvars(p, p2)
	local fs = p.fs
	fs.nactvar += p2

	for i = p2, 1, -1 do
		local getlocvar = self:getlocvar(fs, fs.nactvar - i)
		getlocvar.startpc = fs.pc
	end
end

function class6:removevars(p, p2)
	local fs = p.fs

	while p2 < fs.nactvar do
		fs.nactvar -= 1
		local getlocvar = self:getlocvar(fs, fs.nactvar)
		getlocvar.endpc = fs.pc
	end
end

function class6:indexupvalue(data, p, p2)
	local f = data.f

	for i = 0, f.nups - 1 do
		if not (data.upvalues[i].k == p2.k and data.upvalues[i].info == p2.info) then
			continue
		end

		if f.upvalues[i] ~= p then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end

		return i
	end

	self:checklimit(data, f.nups + 1, self.LUAI_MAXUPVALUES, "upvalues")
	self:growvector(data.L, f.upvalues, f.nups, f.sizeupvalues, nil, self.MAX_INT, "")
	f.upvalues[f.nups] = p

	if p2.k ~= "VLOCAL" and p2.k ~= "VUPVAL" then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	data.upvalues[f.nups] = {
		k = p2.k,
		info = p2.info
	}
	local nups = f.nups
	f.nups += 1
	return nups
end

function class6:searchvar(p, p2)
	for i = p.nactvar - 1, 0, -1 do
		if p2 == self:getlocvar(p, i).varname then
			return i
		end
	end

	return -1
end

function class6:markupval(p, p2)
	local bl = p.bl

	while bl and p2 < bl.nactvar do
		bl = bl.previous
	end

	if bl then
		bl.upval = true
	end
end

function class6:singlevaraux(p, p2, p3, p4)
	if p == nil then
		self:init_exp(p3, "VGLOBAL", class3.NO_REG)
		return "VGLOBAL"
	end

	local searchvar = self:searchvar(p, p2)

	if searchvar >= 0 then
		self:init_exp(p3, "VLOCAL", searchvar)

		if p4 == 0 then
			self:markupval(p, searchvar)
		end

		return "VLOCAL"
	else
		if self:singlevaraux(p.prev, p2, p3, 0) == "VGLOBAL" then
			return "VGLOBAL"
		end

		p3.info = self:indexupvalue(p, p2, p3)
		p3.k = "VUPVAL"
		return "VUPVAL"
	end
end

function class6:singlevar(p, p2)
	local str_checkname = self:str_checkname(p)
	local fs = p.fs

	if self:singlevaraux(fs, str_checkname, p2, 1) == "VGLOBAL" then
		p2.info = class5:stringK(fs, str_checkname)
	end
end

function class6:adjust_assign(p, p2, p3, p4)
	local fs = p.fs
	local v = p2 - p3

	if self:hasmultret(p4.k) then
		local v2 = v + 1
		local v3 = v2 <= 0 and 0 or v2
		class5:setreturns(fs, p4, v3)

		if v3 > 1 then
			class5:reserveregs(fs, v3 - 1)
		end
	else
		if p4.k ~= "VVOID" then
			class5:exp2nextreg(fs, p4)
		end

		if v > 0 then
			local freereg = fs.freereg
			class5:reserveregs(fs, v)
			class5:_nil(fs, freereg, v)
		end
	end
end

function class6:enterlevel(p2)
	p2.L.nCcalls = p2.L.nCcalls + 1

	if p2.L.nCcalls > self.LUAI_MAXCCALLS then
		class2:lexerror(p2, "chunk has too many syntax levels", 0)
	end
end

function class6:leavelevel(p)
	p.L.nCcalls = p.L.nCcalls - 1
end

function class6:enterblock(state, bl, isbreakable)
	bl.breaklist = class5.NO_JUMP
	bl.isbreakable = isbreakable
	bl.nactvar = state.nactvar
	bl.upval = false
	bl.previous = state.bl
	state.bl = bl

	if state.freereg ~= state.nactvar then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end
end

function class6:leaveblock(state)
	local bl = state.bl
	state.bl = bl.previous
	self:removevars(state.ls, bl.nactvar)

	if bl.upval then
		class5:codeABC(state, "OP_CLOSE", bl.nactvar, 0, 0)
	end

	if bl.isbreakable and bl.upval then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if bl.nactvar ~= state.nactvar then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	state.freereg = state.nactvar
	class5:patchtohere(state, bl.breaklist)
end

function class6:pushclosure(p, p2, p3)
	local fs = p.fs
	local f = fs.f
	self:growvector(p.L, f.p, fs.np, f.sizep, nil, class3.MAXARG_Bx, "constant table overflow")
	f.p[fs.np] = p2.f
	fs.np += 1
	self:init_exp(p3, "VRELOCABLE", class5:codeABx(fs, "OP_CLOSURE", 0, fs.np - 1))

	for i = 0, p2.f.nups - 1 do
		class5:codeABC(fs, p2.upvalues[i].k == "VLOCAL" and "OP_MOVE" or "OP_GETUPVAL", 0, p2.upvalues[i].info, 0)
	end
end

function class6:open_func(ls, fs)
	local L = ls.L
	local newproto = self:newproto(ls.L)
	fs.f = newproto
	fs.prev = ls.fs
	fs.ls = ls
	fs.L = L
	ls.fs = fs
	fs.pc = 0
	fs.lasttarget = -1
	fs.jpc = class5.NO_JUMP
	fs.freereg = 0
	fs.nk = 0
	fs.np = 0
	fs.nlocvars = 0
	fs.nactvar = 0
	fs.bl = nil
	newproto.source = ls.source
	newproto.maxstacksize = 2
	fs.h = {}
end

function class6:close_func(state)
	local _ = state.L
	local fs = state.fs
	local f = fs.f
	self:removevars(state, 0)
	class5:ret(fs, 0, 0)
	f.sizecode = fs.pc
	f.sizelineinfo = fs.pc
	f.sizek = fs.nk
	f.sizep = fs.np
	f.sizelocvars = fs.nlocvars
	f.sizeupvalues = f.nups

	if fs.bl ~= nil then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	state.fs = fs.prev

	if fs then
		self:anchor_token(state)
	end
end

function class6:parser(p, p2, buff, p3)
	local v2 = {
		upvalues = {},
		actvar = {}
	}
	p.nCcalls = 0
	local v = {
		t = {},
		lookahead = {},
		buff = buff
	}
	class2:setinput(p, v, p2, p3)
	self:open_func(v, v2)
	v2.f.is_vararg = self.VARARG_ISVARARG
	class2:next(v)
	self:chunk(v)
	self:check(v, "TK_EOS")
	self:close_func(v)

	if v2.prev ~= nil then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if v2.f.nups ~= 0 then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	if v.fs ~= nil then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	return v2.f
end

function class6:field(p, p2)
	local fs = p.fs
	local v = {}
	class5:exp2anyreg(fs, p2)
	class2:next(p)
	self:checkname(p, v)
	class5:indexed(fs, p2, v)
end

function class6:yindex(p, p2)
	class2:next(p)
	self:expr(p, p2)
	class5:exp2val(p.fs, p2)
	self:checknext(p, "]")
end

function class6:recfield(p, state)
	local fs = p.fs
	local freereg = p.fs.freereg
	local v = {}
	local v2 = {}

	if p.t.token == "TK_NAME" then
		self:checklimit(fs, state.nh, self.MAX_INT, "items in a constructor")
		self:checkname(p, v)
	else
		self:yindex(p, v)
	end

	state.nh += 1
	self:checknext(p, "=")
	local exp2RK = class5:exp2RK(fs, v)
	self:expr(p, v2)
	class5:codeABC(fs, "OP_SETTABLE", state.t.info, exp2RK, class5:exp2RK(fs, v2))
	fs.freereg = freereg
end

function class6:closelistfield(p, state)
	if state.v.k == "VVOID" then
		return
	end

	class5:exp2nextreg(p, state.v)
	state.v.k = "VVOID"

	if state.tostore == class3.LFIELDS_PER_FLUSH then
		class5:setlist(p, state.t.info, state.na, state.tostore)
		state.tostore = 0
	end
end

function class6:lastlistfield(p, state)
	if state.tostore == 0 then
		return
	end

	if self:hasmultret(state.v.k) then
		class5:setmultret(p, state.v)
		class5:setlist(p, state.t.info, state.na, self.LUA_MULTRET)
		state.na -= 1
	else
		if state.v.k ~= "VVOID" then
			class5:exp2nextreg(p, state.v)
		end

		class5:setlist(p, state.t.info, state.na, state.tostore)
	end
end

function class6:listfield(p, state)
	self:expr(p, state.v)
	self:checklimit(p.fs, state.na, self.MAX_INT, "items in a constructor")
	state.na += 1
	state.tostore += 1
end

function class6:constructor(data, p)
	local fs = data.fs
	local linenumber = data.linenumber
	local codeABC = class5:codeABC(fs, "OP_NEWTABLE", 0, 0, 0)
	local v = {
		v = {},
		na = 0,
		nh = 0,
		tostore = 0,
		t = p
	}
	self:init_exp(p, "VRELOCABLE", codeABC)
	self:init_exp(v.v, "VVOID", 0)
	class5:exp2nextreg(data.fs, p)
	self:checknext(data, "{")

	while true do
		if v.v.k ~= "VVOID" and not (v.tostore > 0) then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end

		if data.t.token ~= "}" then
			self:closelistfield(fs, v)
			local token = data.t.token

			if token == "TK_NAME" then
				class2:lookahead(data)

				if data.lookahead.token == "=" then
					self:recfield(data, v)
				else
					self:listfield(data, v)
				end
			elseif token == "[" then
				self:recfield(data, v)
			else
				self:listfield(data, v)
			end

			if self:testnext(data, ",") or self:testnext(data, ";") then
				continue
			end
		end

		self:check_match(data, "}", "{", linenumber)
		self:lastlistfield(fs, v)
		class3:SETARG_B(fs.f.code[codeABC], self:int2fb(v.na))
		class3:SETARG_C(fs.f.code[codeABC], self:int2fb(v.nh))
		break
	end
end

function class6:parlist(p)
	local fs = p.fs
	local f = fs.f
	local count2 = 0
	f.is_vararg = 0

	if p.t.token ~= ")" then
		repeat
			local token = p.t.token

			if token == "TK_NAME" then
				self:new_localvar(p, self:str_checkname(p), count2)
				count2 += 1
			elseif token == "TK_DOTS" then
				class2:next(p)
				self:new_localvarliteral(p, "arg", count2)
				count2 += 1
				f.is_vararg = self.VARARG_HASARG + self.VARARG_NEEDSARG
				f.is_vararg += self.VARARG_ISVARARG
			else
				class2:syntaxerror(p, "<name> or " .. self:LUA_QL("...") .. " expected")
			end
		until f.is_vararg ~= 0 or not self:testnext(p, ",")
	end

	self:adjustlocalvars(p, count2)
	f.numparams = fs.nactvar - f.is_vararg % self.HASARG_MASK
	class5:reserveregs(fs, fs.nactvar)
end

function class6:body(p, p2, p3, lineDefined)
	local v = {
		upvalues = {},
		actvar = {}
	}
	self:open_func(p, v)
	v.f.lineDefined = lineDefined
	self:checknext(p, "(")

	if p3 then
		self:new_localvarliteral(p, "self", 0)
		self:adjustlocalvars(p, 1)
	end

	self:parlist(p)
	self:checknext(p, ")")
	self:chunk(p)
	v.f.lastlinedefined = p.linenumber
	self:check_match(p, "TK_END", "TK_FUNCTION", lineDefined)
	self:close_func(p)
	self:pushclosure(p, v, p2)
end

function class6:explist1(p, p2)
	self:expr(p, p2)
	local v = 1

	while self:testnext(p, ",") do
		class5:exp2nextreg(p.fs, p2)
		self:expr(p, p2)
		v += 1
	end

	return v
end

function class6:funcargs(data, p)
	local fs = data.fs
	local v = {}
	local linenumber = data.linenumber
	local token = data.t.token

	if token == "(" then
		if linenumber ~= data.lastline then
			class2:syntaxerror(data, "ambiguous syntax (function call x new statement)")
		end

		class2:next(data)

		if data.t.token == ")" then
			v.k = "VVOID"
		else
			self:explist1(data, v)
			class5:setmultret(fs, v)
		end

		self:check_match(data, ")", "(", linenumber)
	elseif token == "{" then
		self:constructor(data, v)
	elseif token == "TK_STRING" then
		self:codestring(data, v, data.t.seminfo)
		class2:next(data)
	else
		class2:syntaxerror(data, "function arguments expected")
		return
	end

	if p.k ~= "VNONRELOC" then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	local info = p.info
	local LUA_MULTRET

	if self:hasmultret(v.k) then
		LUA_MULTRET = self.LUA_MULTRET
	else
		if v.k ~= "VVOID" then
			class5:exp2nextreg(fs, v)
		end

		LUA_MULTRET = fs.freereg - (info + 1)
	end

	self:init_exp(p, "VCALL", class5:codeABC(fs, "OP_CALL", info, LUA_MULTRET + 1, 2))
	class5:fixline(fs, linenumber)
	fs.freereg = info + 1
end

function class6:prefixexp(data, p)
	local token = data.t.token

	if token == "(" then
		local linenumber = data.linenumber
		class2:next(data)
		self:expr(data, p)
		self:check_match(data, ")", "(", linenumber)
		class5:dischargevars(data.fs, p)
	elseif token == "TK_NAME" then
		self:singlevar(data, p)
	else
		class2:syntaxerror(data, "unexpected symbol")
	end
end

function class6:primaryexp(p, p2)
	local fs = p.fs
	self:prefixexp(p, p2)

	while true do
		local token = p.t.token

		if token == "." then
			self:field(p, p2)
		elseif token == "[" then
			local v = {}
			class5:exp2anyreg(fs, p2)
			self:yindex(p, v)
			class5:indexed(fs, p2, v)
		elseif token == ":" then
			local v = {}
			class2:next(p)
			self:checkname(p, v)
			class5:_self(fs, p2, v)
			self:funcargs(p, p2)
		else
			if token ~= "(" and token ~= "TK_STRING" and token ~= "{" then
				break
			end

			class5:exp2nextreg(fs, p2)
			self:funcargs(p, p2)
		end
	end
end

function class6:simpleexp(data, p)
	local token = data.t.token

	if token == "TK_NUMBER" then
		self:init_exp(p, "VKNUM", 0)
		p.nval = data.t.seminfo
	elseif token == "TK_STRING" then
		self:codestring(data, p, data.t.seminfo)
	elseif token == "TK_NIL" then
		self:init_exp(p, "VNIL", 0)
	elseif token == "TK_TRUE" then
		self:init_exp(p, "VTRUE", 0)
	elseif token == "TK_FALSE" then
		self:init_exp(p, "VFALSE", 0)
	elseif token == "TK_DOTS" then
		local fs = data.fs
		self:check_condition(
			data,
			fs.f.is_vararg ~= 0,
			"cannot use " .. self:LUA_QL("...") .. " outside a vararg function"
		)
		local is_vararg = fs.f.is_vararg

		if self.VARARG_NEEDSARG <= is_vararg then
			fs.f.is_vararg = is_vararg - self.VARARG_NEEDSARG
		end

		self:init_exp(p, "VVARARG", class5:codeABC(fs, "OP_VARARG", 0, 1, 0))
	else
		if token == "{" then
			self:constructor(data, p)
			return
		end

		if token ~= "TK_FUNCTION" then
			self:primaryexp(data, p)
			return
		end

		class2:next(data)
		self:body(data, p, false, data.linenumber)
		return
	end

	class2:next(data)
end

function class6.getunopr(_, p)
	if p == "TK_NOT" then
		return "OPR_NOT"
	elseif p == "-" then
		return "OPR_MINUS"
	elseif p == "#" then
		return "OPR_LEN"
	end

	return "OPR_NOUNOPR"
end

class6.getbinopr_table = {
	["+"] = "OPR_ADD",
	["-"] = "OPR_SUB",
	["*"] = "OPR_MUL",
	["/"] = "OPR_DIV",
	["%"] = "OPR_MOD",
	["^"] = "OPR_POW",
	TK_CONCAT = "OPR_CONCAT",
	TK_NE = "OPR_NE",
	TK_EQ = "OPR_EQ",
	["<"] = "OPR_LT",
	TK_LE = "OPR_LE",
	[">"] = "OPR_GT",
	TK_GE = "OPR_GE",
	TK_AND = "OPR_AND",
	TK_OR = "OPR_OR"
}

function class6:getbinopr(p2)
	local v = self.getbinopr_table[p2]
	return v or "OPR_NOBINOPR"
end

class6.priority = {
	{ 6, 6 },
	{ 6, 6 },
	{ 7, 7 },
	{ 7, 7 },
	{ 7, 7 },
	{ 10, 9 },
	{ 5, 4 },
	{ 3, 3 },
	{ 3, 3 },
	{ 3, 3 },
	{ 3, 3 },
	{ 3, 3 },
	{ 3, 3 },
	{ 2, 2 },
	{ 1, 1 }
}
class6.UNARY_PRIORITY = 8

function class6:subexpr(p, p2, p3)
	self:enterlevel(p)
	local getunopr2 = self:getunopr(p.t.token)

	if getunopr2 == "OPR_NOUNOPR" then
		self:simpleexp(p, p2)
	else
		class2:next(p)
		self:subexpr(p, p2, self.UNARY_PRIORITY)
		class5:prefix(p.fs, getunopr2, p2)
	end

	local getbinopr = self:getbinopr(p.t.token)

	while getbinopr ~= "OPR_NOBINOPR" and p3 < self.priority[class5.BinOpr[getbinopr] + 1][1] do
		local v = {}
		class2:next(p)
		class5:infix(p.fs, getbinopr, p2)
		local subexpr = self:subexpr(p, v, self.priority[class5.BinOpr[getbinopr] + 1][2])
		class5:posfix(p.fs, getbinopr, p2, v)
		getbinopr = subexpr
	end

	self:leavelevel(p)
	return getbinopr
end

function class6:expr(p, p2)
	self:subexpr(p, p2, 0)
end

function class6.block_follow(_, p)
	return p == "TK_ELSE" or p == "TK_ELSEIF" or p == "TK_END" or p == "TK_UNTIL" or p == "TK_EOS"
end

function class6:block(p)
	local fs = p.fs
	local v = {}
	self:enterblock(fs, v, false)
	self:chunk(p)

	if v.breaklist ~= class5.NO_JUMP then
		lua_assert(false) -- equivalent call inferred; original call site unknown
	end

	self:leaveblock(fs)
end

function class6:check_conflict(p, prev, p2)
	local fs = p.fs
	local freereg = fs.freereg
	local flag = false

	while prev do
		if prev.v.k == "VINDEXED" then
			if prev.v.info == p2.info then
				prev.v.info = freereg
				flag = true
			end

			if prev.v.aux == p2.info then
				prev.v.aux = freereg
				flag = true
			end
		end

		prev = prev.prev
	end

	if flag then
		class5:codeABC(fs, "OP_MOVE", fs.freereg, p2.info, 0)
		class5:reserveregs(fs, 1)
	end
end

function class6:assignment(p, prev, p3)
	local v = {}
	local k = prev.v.k
	self:check_condition(p, k == "VLOCAL" or k == "VUPVAL" or k == "VGLOBAL" or k == "VINDEXED", "syntax error")

	if self:testnext(p, ",") then
		local v2 = {
			v = {},
			prev = prev
		}
		self:primaryexp(p, v2.v)

		if v2.v.k == "VLOCAL" then
			self:check_conflict(p, prev, v2.v)
		end

		self:checklimit(p.fs, p3, self.LUAI_MAXCCALLS - p.L.nCcalls, "variables in assignment")
		self:assignment(p, v2, p3 + 1)
	else
		self:checknext(p, "=")
		local explist1 = self:explist1(p, v)

		if explist1 == p3 then
			class5:setoneret(p.fs, v)
			class5:storevar(p.fs, prev.v, v)
			return
		else
			self:adjust_assign(p, p3, explist1, v)

			if p3 < explist1 then
				p.fs.freereg = p.fs.freereg - (explist1 - p3)
			end
		end
	end

	self:init_exp(v, "VNONRELOC", p.fs.freereg - 1)
	class5:storevar(p.fs, prev.v, v)
end

function class6:cond(p)
	local v = {}
	self:expr(p, v)

	if v.k == "VNIL" then
		v.k = "VFALSE"
	end

	class5:goiftrue(p.fs, v)
	return v.f
end

function class6:breakstat(p)
	local fs = p.fs
	local bl = fs.bl
	local v = false

	while bl and not bl.isbreakable do
		v = bl.upval and true or v
		bl = bl.previous
	end

	if not bl then
		class2:syntaxerror(p, "no loop to break")
	end

	if v then
		class5:codeABC(fs, "OP_CLOSE", bl.nactvar, 0, 0)
	end

	bl.breaklist = class5:concat(fs, bl.breaklist, class5:jump(fs))
end

function class6:whilestat(p, p2)
	local fs = p.fs
	class2:next(p)
	local getlabel = class5:getlabel(fs)
	local cond = self:cond(p)
	self:enterblock(fs, {}, true)
	self:checknext(p, "TK_DO")
	self:block(p)
	class5:patchlist(fs, class5:jump(fs), getlabel)
	self:check_match(p, "TK_END", "TK_WHILE", p2)
	self:leaveblock(fs)
	class5:patchtohere(fs, cond)
end

function class6:repeatstat(p, p2)
	local fs = p.fs
	local getlabel = class5:getlabel(fs)
	local v = {}
	self:enterblock(fs, {}, true)
	self:enterblock(fs, v, false)
	class2:next(p)
	self:chunk(p)
	self:check_match(p, "TK_UNTIL", "TK_REPEAT", p2)
	local cond = self:cond(p)

	if v.upval then
		self:breakstat(p)
		class5:patchtohere(p.fs, cond)
		self:leaveblock(fs)
		class5:patchlist(p.fs, class5:jump(fs), getlabel)
	else
		self:leaveblock(fs)
		class5:patchlist(p.fs, cond, getlabel)
	end

	self:leaveblock(fs)
end

function class6:exp1(p)
	local v = {}
	self:expr(p, v)
	local k = v.k
	class5:exp2nextreg(p.fs, v)
	return k
end

function class6:forbody(p, p2, p3, p4, p5)
	local fs = p.fs
	self:adjustlocalvars(p, 3)
	self:checknext(p, "TK_DO")
	local v = p5 and class5:codeAsBx(fs, "OP_FORPREP", p2, class5.NO_JUMP) or class5:jump(fs)
	self:enterblock(fs, {}, false)
	self:adjustlocalvars(p, p4)
	class5:reserveregs(fs, p4)
	self:block(p)
	self:leaveblock(fs)
	class5:patchtohere(fs, v)
	local v2 = p5 and class5:codeAsBx(fs, "OP_FORLOOP", p2, class5.NO_JUMP) or class5:codeABC(
		fs,
		"OP_TFORLOOP",
		p2,
		0,
		p4
	)
	class5:fixline(fs, p3)
	class5:patchlist(fs, p5 and v2 or class5:jump(fs), v + 1)
end

function class6:fornum(p, p2, p3)
	local fs = p.fs
	local freereg = fs.freereg
	self:new_localvarliteral(p, "(for index)", 0)
	self:new_localvarliteral(p, "(for limit)", 1)
	self:new_localvarliteral(p, "(for step)", 2)
	self:new_localvar(p, p2, 3)
	self:checknext(p, "=")
	self:exp1(p)
	self:checknext(p, ",")
	self:exp1(p)

	if self:testnext(p, ",") then
		self:exp1(p)
	else
		class5:codeABx(fs, "OP_LOADK", fs.freereg, class5:numberK(fs, 1))
		class5:reserveregs(fs, 1)
	end

	self:forbody(p, freereg, p3, 1, true)
end

function class6:forlist(p, p2)
	local fs = p.fs
	local v = 0
	local freereg = fs.freereg
	self:new_localvarliteral(p, "(for generator)", v)
	local v2 = v + 1
	self:new_localvarliteral(p, "(for state)", v2)
	local v3 = v2 + 1
	self:new_localvarliteral(p, "(for control)", v3)
	local v4 = v3 + 1
	self:new_localvar(p, p2, v4)
	local v5 = v4 + 1
	local v6 = {}

	while self:testnext(p, ",") do
		self:new_localvar(p, self:str_checkname(p), v5)
		v5 += 1
	end

	self:checknext(p, "TK_IN")
	local linenumber = p.linenumber
	self:adjust_assign(p, 3, self:explist1(p, v6), v6)
	class5:checkstack(fs, 3)
	self:forbody(p, freereg, linenumber, v5 - 3, false)
end

function class6:forstat(p, p2)
	local fs = p.fs
	self:enterblock(fs, {}, true)
	class2:next(p)
	local str_checkname = self:str_checkname(p)
	local token = p.t.token

	if token == "=" then
		self:fornum(p, str_checkname, p2)
	elseif token == "," or token == "TK_IN" then
		self:forlist(p, str_checkname)
	else
		class2:syntaxerror(p, self:LUA_QL("=") .. " or " .. self:LUA_QL("in") .. " expected")
	end

	self:check_match(p, "TK_END", "TK_FOR", p2)
	self:leaveblock(fs)
end

function class6:test_then_block(p)
	class2:next(p)
	local cond = self:cond(p)
	self:checknext(p, "TK_THEN")
	self:block(p)
	return cond
end

function class6:ifstat(p, p2)
	local fs = p.fs
	local NO_JUMP = class5.NO_JUMP
	local test_then_block = self:test_then_block(p)

	while p.t.token == "TK_ELSEIF" do
		NO_JUMP = class5:concat(fs, NO_JUMP, class5:jump(fs))
		class5:patchtohere(fs, test_then_block)
		test_then_block = self:test_then_block(p)
	end

	local v

	if p.t.token == "TK_ELSE" then
		v = class5:concat(fs, NO_JUMP, class5:jump(fs))
		class5:patchtohere(fs, test_then_block)
		class2:next(p)
		self:block(p)
	else
		v = class5:concat(fs, NO_JUMP, test_then_block)
	end

	class5:patchtohere(fs, v)
	self:check_match(p, "TK_END", "TK_IF", p2)
end

function class6:localfunc(p)
	local v = {}
	local v2 = {}
	local fs = p.fs
	self:new_localvar(p, self:str_checkname(p), 0)
	self:init_exp(v, "VLOCAL", fs.freereg)
	class5:reserveregs(fs, 1)
	self:adjustlocalvars(p, 1)
	self:body(p, v2, false, p.linenumber)
	class5:storevar(fs, v, v2)
	local getlocvar = self:getlocvar(fs, fs.nactvar - 1)
	getlocvar.startpc = fs.pc
end

function class6:localstat(p)
	local count2 = 0
	local v = {}

	repeat
		self:new_localvar(p, self:str_checkname(p), count2)
		count2 += 1
	until not self:testnext(p, ",")

	local v2

	if self:testnext(p, "=") then
		v2 = self:explist1(p, v)
	else
		v.k = "VVOID"
		v2 = 0
	end

	self:adjust_assign(p, count2, v2, v)
	self:adjustlocalvars(p, count2)
end

function class6:funcname(p, p2)
	self:singlevar(p, p2)
	local v = false

	while p.t.token == "." do
		self:field(p, p2)
	end

	if p.t.token == ":" then
		self:field(p, p2)
		return true
	end

	return v
end

function class6:funcstat(p, p2)
	local v = {}
	local v2 = {}
	class2:next(p)
	self:body(p, v2, self:funcname(p, v), p2)
	class5:storevar(p.fs, v, v2)
	class5:fixline(p.fs, p2)
end

function class6:exprstat(p)
	local fs = p.fs
	local v = {
		v = {}
	}
	self:primaryexp(p, v.v)

	if v.v.k == "VCALL" then
		class3:SETARG_C(class5:getcode(fs, v.v), 1)
		return
	end

	v.prev = nil
	self:assignment(p, v, 1)
end

function class6:retstat(p)
	local fs = p.fs
	local v = {}
	class2:next(p)
	local nactvar, LUA_MULTRET

	if self:block_follow(p.t.token) or p.t.token == ";" then
		nactvar = 0
		LUA_MULTRET = 0
	else
		LUA_MULTRET = self:explist1(p, v)

		if self:hasmultret(v.k) then
			class5:setmultret(fs, v)

			if v.k == "VCALL" and LUA_MULTRET == 1 then
				class3:SET_OPCODE(class5:getcode(fs, v), "OP_TAILCALL")

				if class3:GETARG_A(class5:getcode(fs, v)) ~= fs.nactvar then
					lua_assert(false) -- equivalent call inferred; original call site unknown
				end
			end

			nactvar = fs.nactvar
			LUA_MULTRET = self.LUA_MULTRET
		elseif LUA_MULTRET == 1 then
			nactvar = class5:exp2anyreg(fs, v)
		else
			class5:exp2nextreg(fs, v)
			nactvar = fs.nactvar

			if LUA_MULTRET ~= fs.freereg - nactvar then
				lua_assert(false) -- equivalent call inferred; original call site unknown
			end
		end
	end

	class5:ret(fs, nactvar, LUA_MULTRET)
end

function class6:statement(p)
	local linenumber = p.linenumber
	local token = p.t.token

	if token == "TK_IF" then
		self:ifstat(p, linenumber)
		return false
	elseif token == "TK_WHILE" then
		self:whilestat(p, linenumber)
		return false
	end

	if token == "TK_DO" then
		class2:next(p)
		self:block(p)
		self:check_match(p, "TK_END", "TK_DO", linenumber)
		return false
	else
		if token == "TK_FOR" then
			self:forstat(p, linenumber)
			return false
		elseif token == "TK_REPEAT" then
			self:repeatstat(p, linenumber)
			return false
		elseif token == "TK_FUNCTION" then
			self:funcstat(p, linenumber)
			return false
		end

		if token == "TK_LOCAL" then
			class2:next(p)

			if self:testnext(p, "TK_FUNCTION") then
				self:localfunc(p)
			else
				self:localstat(p)
			end

			return false
		else
			if token == "TK_RETURN" then
				self:retstat(p)
				return true
			end

			if token ~= "TK_BREAK" then
				self:exprstat(p)
				return false
			end

			class2:next(p)
			self:breakstat(p)
			return true
		end
	end
end

function class6:chunk(p)
	self:enterlevel(p)
	local v = false

	while not (v or self:block_follow(p.t.token)) do
		v = self:statement(p)
		self:testnext(p, ";")
		local v2

		if p.fs.f.maxstacksize >= p.fs.freereg then
			v2 = p.fs.freereg >= p.fs.nactvar
		else
			v2 = false
		end

		if not v2 then
			lua_assert(false) -- equivalent call inferred; original call site unknown
		end

		p.fs.freereg = p.fs.nactvar
	end

	self:leavelevel(p)
end

class2:init()
local v = {}
return function(p, value)
	local v3 = class:init(class:make_getF(p), nil)

	if not v3 then
		return
	end

	local parser = class6:parser(v, v3, nil, "@" .. (value or "compiled-lua"))
	local make_setS, v4 = class4:make_setS()
	class4:dump(v, parser, make_setS, v4)
	return v4.data
end